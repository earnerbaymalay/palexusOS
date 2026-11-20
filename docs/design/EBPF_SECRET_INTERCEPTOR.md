# PalexusOS eBPF Secret Leak Interceptor (Architecture & Design Spike)

> **Document Version**: 1.0.0  
> **Status**: Approved Design Specification (Milestone 9.2)  
> **Target Subsystem**: `packages/core/palexus-ebpf-guard`  
> **Lead Architect**: PalexusOS Core Systems Team  

---

## 1. Executive Summary & Threat Model

In modern AI-assisted engineering environments, developers constantly copy, paste, reference, and generate code snippets containing cloud credentials, API tokens, and private SSH/TLS keys. While the PalexusOS **Bidirectional Context Firewall** (`palexus-core`) inspects prompt traffic directed at AI endpoints on `127.0.0.1:8000`, third-party applications (CLI tools, rogue npm scripts, background telemetry, unproxied curl commands) can inadvertently or maliciously egress sensitive credentials directly to the public internet.

The **eBPF Secret Leak Interceptor** (`palexus-ebpf-guard`) provides a kernel-enforced data loss prevention (DLP) security layer. Operating beneath userspace, it monitors outbound data streams, inspects payloads for private keys and high-entropy credentials, and halts outbound transmission before data leaves the local network namespace.

```mermaid
flowchart TD
    subgraph Userspace ["Userspace Applications"]
        APP1["CLI Tools & Build Scripts (curl, git, npm)"]
        APP2["Palexus Command HUD & Local LLM Client"]
        LIBSSL["Shared TLS Libraries (libssl.so / GnuTLS)"]
    end

    subgraph Kernel ["Linux Kernel (linux-cachyos BPF & LSM)"]
        UPROBE["eBPF uretprobe / uprobe (SSL_write / gnutls_record_send)"]
        LSM["BPF LSM Hook (socket_sendmsg / security_socket_sendmsg)"]
        FILTER["In-Kernel Pattern & Entropy Filter (Aya BPF)"]
        RING["BPF Perf / Ring Buffer (/sys/fs/bpf/palexus_events)"]
    end

    subgraph Actions ["Enforcement & Telemetry"]
        DROP["Packet Drop / -EPERM Termination"]
        AUDIT["Journald Security Audit Log"]
        HUD["Palexus HUD Desktop Warning Alert"]
    end

    APP1 -->|Plaintext Traffic| LSM
    APP1 -->|TLS Traffic| LIBSSL
    LIBSSL -->|Pre-Encryption Buffer| UPROBE
    UPROBE --> FILTER
    LSM --> FILTER
    
    FILTER -->|Secret Detected (Enforce)| DROP
    FILTER -->|Secret Detected (Audit)| RING
    RING --> AUDIT
    RING --> HUD
```

---

## 2. Kernel Hook Point Analysis & Architecture Selection

### Hook Point Comparison

| Mechanism | Inspection Layer | TLS Visibility | Performance Impact | Recommended |
| :--- | :--- | :--- | :--- | :--- |
| **TC / cgroup_skb (Egress)** | L3/L4 Network Packets | Ciphertext Only (Blind to TLS) | Negligible (<0.1%) | ❌ Supplementary only |
| **sock_ops / sockmsg** | Socket buffer (TCP) | Ciphertext Only for TLS | Very Low (<0.3%) | ❌ Insufficient for HTTPS |
| **BPF LSM (`socket_sendmsg`)** | Kernel VFS/Socket Interface | Plaintext for unencrypted protocols (HTTP, raw TCP, SSH pre-auth) | Minimal (<0.2%) | ✅ Primary for Non-TLS |
| **uprobes on `libssl.so`** | Userspace library entry | **Cleartext prior to TLS encryption** | Low (~1.5% on TLS handshakes/writes) | ✅ Primary for TLS |

### The TLS Visibility Solution: Dual-Layer Interception

Because over 95% of egress developer traffic uses HTTPS/TLS, inspecting raw `sk_buff` structures at the network layer is blind to encrypted secrets. To achieve 100% inspection fidelity without breaking TLS forward secrecy or operating an intrusive MITM certificate proxy, `palexus-ebpf-guard` implements a **cooperative dual-layer architecture**:

1. **Layer A: BPF LSM (`socket_sendmsg`)**:
   - Attached to the kernel security module hook `security_socket_sendmsg`.
   - Inspects outbound payloads for unencrypted protocols (raw HTTP, git daemon, IRC, raw TCP sockets).
   - Bypasses localhost loopback (`127.0.0.1`, `::1`) with zero inspection penalty.

2. **Layer B: Userspace eBPF Uprobes (`libssl.so` / `libgnutls.so`)**:
   - Attached to `SSL_write` and `gnutls_record_send`.
   - Intercepts the plaintext buffer pointer `const void *buf` and `int num` *before* cryptographic ciphertext transformation.
   - If an unauthorized secret is matched in enforce mode, the probe overrides the return value with `-EPERM`, terminating the socket write at the application layer.

> [!NOTE]
> **Static Go / Rust TLS Limitations**: Statically-linked Go binaries (`crypto/tls`) and Rust binaries using statically compiled `rustls` do not link against dynamically loaded `libssl.so`. For these processes, outbound egress protection is guaranteed via the `palexus-core` loopback proxy firewall (`localhost:8000`), and system network isolation (RFC 4941 + MAC randomization).

---

## 3. Pattern Detection Engine & `firewall.rs` Reuse

To guarantee absolute consistency with `palexus-core`'s prompt firewall, `palexus-ebpf-guard` reuses the exact pattern matching logic defined in the upstream core engine.

### Signature Set

1. **Cryptographic Private Keys**:
   - OpenSSH Private Keys: `-----BEGIN OPENSSH PRIVATE KEY-----`
   - RSA / DSA / EC Private Keys: `-----BEGIN (RSA|EC|DSA|ENCRYPTED)? PRIVATE KEY-----`
   - PGP Private Keys: `-----BEGIN PGP PRIVATE KEY BLOCK-----`

2. **Cloud Provider & LLM Service Tokens**:
   - OpenAI API Keys: `sk-[a-zA-Z0-9]{20,}`
   - Anthropic API Keys: `sk-ant-[a-zA-Z0-9]{20,}`
   - GitHub Personal Access Tokens: `gh[pousr]_[A-Za-z0-9_]{36,}`
   - AWS Access Key IDs & Secrets: `AKIA[0-9A-Z]{16}`, `aws_secret_access_key`
   - Hugging Face Tokens: `hf_[a-zA-Z0-9]{34}`
   - Slack / Discord Webhook Secrets: `https://hooks.slack.com/services/T[0-9A-Z]{8}/B[0-9A-Z]{8}/[0-9A-Za-z]{24}`

3. **High Shannon Entropy Strings**:
   - Evaluates randomness across blocks $\ge 32$ alphanumeric characters:
     $$H(X) = -\sum_{i=1}^{n} P(x_i) \log_2 P(x_i)$$
   - Blocks with $H(X) > 4.65 \text{ bits/char}$ that are not accompanied by base64 image/asset headers trigger entropy warnings.

---

## 4. Kernel Configuration & Runtime Prerequisites

`palexus-ebpf-guard` requires specific kernel features provided out-of-the-box by the default `linux-cachyos` kernel shipped in PalexusOS:

| Kernel Config Option | Required Value | Purpose |
| :--- | :--- | :--- |
| `CONFIG_BPF` | `=y` | Core Berkeley Packet Filter support |
| `CONFIG_BPF_SYSCALL` | `=y` | `bpf()` syscall for userspace loading |
| `CONFIG_BPF_JIT` | `=y` | Just-In-Time native x86-64 machine code compilation |
| `CONFIG_BPF_LSM` | `=y` | Linux Security Module BPF hooks |
| `CONFIG_UPROBE_EVENTS` | `=y` | Dynamic userspace probes on shared libraries |
| `CONFIG_DEBUG_INFO_BTF` | `=y` | BPF Type Format for CO-RE (Compile Once – Run Everywhere) |

### Boot Parameter Verification
The bootloader (`efiboot/loader/entries/01-palexusos-x86_64-linux.conf`) enables BPF LSM via the kernel command line:
```text
options ... lsm=landlock,lockdown,yama,integrity,apparmor,bpf
```

---

## 5. Toolchain Decision: Aya (Pure Rust eBPF)

We select **Aya** (`https://aya-rs.dev/`) over `libbpf` (C) for the implementation of `palexus-ebpf-guard`.

### Technical Justification
1. **Direct Code Sharing**: Both `palexus-core` and `palexus-ebpf-guard` are authored in Rust. Signature tables, entropy calculators, and token regex definitions can be extracted into a shared `palexus-security-common` crate without foreign function interface (FFI) overhead.
2. **Memory Safety**: Writing kernel-level probe loaders in safe Rust eliminates potential buffer overflow vulnerabilities in userspace monitor daemons.
3. **No LLVM/Clang Dependency at Runtime**: Aya compiles eBPF bytecode into ELF objects at package build time (`cargo xtask build-ebpf`). The target installation does not require clang, llvm, or kernel headers.

---

## 6. Operational Modes & Configuration

Configuration file located at `/etc/palexus/ebpf-guard.toml`:

```toml
[general]
# Operating mode: "audit" (log & notify only) or "enforce" (block & drop)
mode = "audit"
log_target = "journald"
notify_desktop = true

[network]
# Interfaces to monitor (empty means all non-loopback interfaces)
interfaces = []
# Always bypass local IPC and internal proxies
exempt_loopback = true
exempt_subnets = ["127.0.0.0/8", "::1/128", "10.0.0.0/8", "192.168.0.0/16"]

[patterns]
block_private_keys = true
block_cloud_tokens = true
entropy_threshold = 4.65

[whitelist]
# Process executables permitted to transmit credentials (e.g. ssh-agent, gpg)
exempt_binaries = [
    "/usr/bin/ssh",
    "/usr/bin/git-remote-http",
    "/usr/bin/gpg"
]
```

---

## 7. Implementation Roadmap & Follow-Up Tasks

The implementation of `palexus-ebpf-guard` is decomposed into three distinct cards:

```mermaid
flowchart LR
    C1["Card 9.2A: Core aya eBPF Scaffolding & PKGBUILD"]
    C2["Card 9.2B: Userspace Daemon, Uprobes & Ring Buffer Bus"]
    C3["Card 9.2C: HUD Desktop Integration & Automated Smoke Tests"]

    C1 --> C2 --> C3
```

- **Card 9.2A: Core Aya eBPF Scaffolding & PKGBUILD**:
  - Author `packages/core/palexus-ebpf-guard/` PKGBUILD and cargo workspace.
  - Implement eBPF kernel bytecode for `socket_sendmsg` and `SSL_write` hooks using Aya.
  - Compile CO-RE eBPF object file.

- **Card 9.2B: Userspace Daemon, Uprobes & Ring Buffer Bus**:
  - Implement the `/usr/bin/palexus-ebpf-guard` loader daemon.
  - Handle BPF ring buffer events and stream JSON alerts to systemd journal.
  - Add `/usr/lib/systemd/system/palexus-ebpf-guard.service` with strict systemd sandbox settings (`ProtectSystem=strict`, `CapabilityBoundingSet=CAP_BPF CAP_NET_ADMIN`).

- **Card 9.2C: HUD Desktop Integration & Automated Smoke Tests**:
  - Connect `palexus-hud` notification popup when a secret leak attempt is intercepted.
  - Create integration test suite sending synthetic private keys over loopback and dummy interfaces to verify `-EPERM` rejection.
