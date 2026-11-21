# Security & Hardening Guide

Comprehensive security guide for PalexusOS development, deployment, and operations.

**Audience**: Developers, security engineers, maintainers  
**Scope**: Code security, dependency management, deployment hardening  
**Last Reviewed**: 2026-11-20

---

## Table of Contents

1. [Security Principles](#security-principles)
2. [Code Security](#code-security)
3. [Dependency Security](#dependency-security)
4. [Input Validation](#input-validation)
5. [Cryptography & Secrets](#cryptography--secrets)
6. [Access Control](#access-control)
7. [Deployment Hardening](#deployment-hardening)
8. [Security Audit Checklist](#security-audit-checklist)
9. [Incident Response](#incident-response)

---

## Security Principles

### Core Rules

1. **Least Privilege**: Each component has minimum necessary permissions
2. **Defense in Depth**: Multiple layers of security (not just one)
3. **Fail Securely**: On error, fail closed (deny) not open (allow)
4. **Never Trust Input**: Validate everything from outside
5. **Keep Secrets Secret**: Never log, store, or transmit plaintext secrets

### PalexusOS Security Stance

PalexusOS follows a **zero-telemetry, secure-by-default** philosophy:

- ✅ No default credentials
- ✅ No hardcoded secrets
- ✅ No telemetry collection
- ✅ Minimal external dependencies
- ✅ Explicit permission model

---

## Code Security

### Secure Coding Patterns

#### ✅ SAFE: Explicit error handling

```python
try:
    value = registry.color("primary", "mauve")
except KeyError:
    logger.error("Token not found: primary.mauve")
    value = DEFAULT_COLOR  # Safe fallback
```

#### ❌ UNSAFE: Silent failures

```python
value = registry.colors("primary").get("mauve")  # What if None breaks downstream?
```

---

#### ✅ SAFE: Type-checked functions

```python
def add_custom_token(name: str, value: str) -> None:
    """Register a token.
    
    Args:
        name (str): Token name (validated format)
        value (str): Token value (validated format)
        
    Raises:
        ValueError: If name or value invalid
    """
    if not _is_valid_token_name(name):
        raise ValueError(f"Invalid token name: {name}")
    
    if not _is_valid_token_value(value):
        raise ValueError(f"Invalid token value: {value}")
    
    self.tokens[name] = value
```

#### ❌ UNSAFE: Dynamic code execution

```python
# NEVER DO THIS:
exec(f"color = {value}")  # Arbitrary code execution!
eval(value)                # Arbitrary code execution!
__import__(name)           # Dynamic imports

# NEVER:
import pickle
pickle.loads(user_data)    # Can execute code
```

---

#### ✅ SAFE: Path validation

```python
from pathlib import Path

def load_tokens(tokens_file: Path) -> dict:
    """Load tokens from file.
    
    Args:
        tokens_file (Path): Path to tokens.json
        
    Raises:
        ValueError: If path is outside allowed directories
    """
    # Resolve to absolute path
    tokens_file = tokens_file.resolve()
    
    # Verify inside allowed directory
    allowed_root = Path("/home/user/palexusOS/docs/design-system")
    
    try:
        tokens_file.relative_to(allowed_root)
    except ValueError:
        raise ValueError(f"Path outside allowed directory: {tokens_file}")
    
    with open(tokens_file) as f:
        return json.load(f)
```

#### ❌ UNSAFE: Unvalidated paths

```python
# Path traversal attack:
# User provides: "../../../../etc/passwd"
with open(tokens_file) as f:  # Could read sensitive files!
    return json.load(f)
```

---

### Regular Security Reviews

#### Code Review Checklist

Before merging code, verify:

- [ ] No hardcoded secrets (passwords, API keys, tokens)
- [ ] No dangerous functions (eval, exec, pickle, __import__)
- [ ] Input validation on all external data
- [ ] Type hints on public methods
- [ ] Error handling catches and logs appropriately
- [ ] No path traversal vulnerabilities
- [ ] No SQL injection (N/A - no SQL, but check JSON operations)
- [ ] No XXE (XML external entity) issues
- [ ] Logging doesn't expose secrets
- [ ] Comments don't reveal security approaches

#### Automated Checks

```bash
# Check for common patterns
grep -r "eval\|exec\|pickle\|__import__" palexus/
# Output should be empty

# Check for hardcoded secrets (basic)
grep -r "password\|api_key\|secret" palexus/ --include="*.py"
# Review any matches carefully

# Use bandit for security linting
pip install bandit
bandit -r palexus/
```

---

## Dependency Security

### Vulnerability Scanning

#### Check for CVEs

```bash
# Audit installed packages
pip install pip-audit
pip-audit

# Or with safety
pip install safety
safety check
```

#### Lock Dependencies

```bash
# pyproject.toml pins versions
[project]
dependencies = [
    "package>=1.0,<2.0",  # Ranges are OK
]

# Avoid:
# - "package" (unpinned)
# - "package>=1.0" (unbounded max)
```

---

#### Update Strategy

```bash
# 1. Check for updates
pip list --outdated

# 2. Review changes
# - Read CHANGELOG for each package
# - Check for security advisories
# - Look for breaking changes

# 3. Update in development branch
pip install --upgrade package

# 4. Run full test suite
make test

# 5. Commit changes
git commit -m "deps: Update package to 1.5.0 (security fix)"
```

---

### Supply Chain Security

#### Verify Downloads

```bash
# Install signed packages when possible
# - Use official repositories (PyPI)
- - Avoid unofficial mirrors
# - Check package signatures (if available)

# Example: install from official PyPI only
pip install --only-binary=:all: package
```

#### Review Dependencies

```bash
# See full dependency tree
pip install pipdeptree
pipdeptree

# Identify unnecessary dependencies
# Goal: Minimal dependencies = minimal attack surface
```

---

## Input Validation

### Validation Strategy

#### 1. Define Expected Format

```python
# Token name: lowercase letters, numbers, slashes
# Format: category/subcategory/name
# Example: color/bg/primary

TOKEN_NAME_PATTERN = r"^[a-z0-9]+(/[a-z0-9]+)*$"
```

#### 2. Validate All Input

```python
import re

def validate_token_name(name: str) -> bool:
    """Validate token name format.
    
    Args:
        name (str): Token name to validate
        
    Returns:
        bool: True if valid, False otherwise
    """
    if not isinstance(name, str):
        return False
    
    if not 1 <= len(name) <= 100:  # Reasonable length
        return False
    
    return bool(re.match(TOKEN_NAME_PATTERN, name))


def add_custom_token(name: str, value: str) -> None:
    """Register a token with validation.
    
    Raises:
        ValueError: If name or value invalid
    """
    if not validate_token_name(name):
        raise ValueError(f"Invalid token name: {name}")
    
    if not isinstance(value, str) or not value:
        raise ValueError("Token value must be non-empty string")
    
    self.tokens[name] = value
```

#### 3. Whitelist, Not Blacklist

```python
# ✅ GOOD: Define what's allowed
ALLOWED_PHASES = {"GREETER", "USER_SELECT", "HUD", "THEME", "COMPLETE"}

def set_phase(phase: str) -> None:
    if phase not in ALLOWED_PHASES:
        raise ValueError(f"Invalid phase: {phase}")
```

#### 4. Fail Safely

```python
# ✅ GOOD: Explicit error
try:
    registry = TokenRegistry(Path("tokens.json"))
except FileNotFoundError as e:
    logger.error(f"Tokens file not found: {e}")
    raise  # Let caller know immediately

# ❌ BAD: Silent failure
try:
    registry = TokenRegistry(Path("tokens.json"))
except FileNotFoundError:
    registry = None  # Downstream code breaks mysteriously
```

---

## Cryptography & Secrets

### Secret Management

#### Don't Store Secrets

```python
# ✅ GOOD: Credentials passed at runtime, never stored
def authenticate(username: str, password: str) -> bool:
    """Authenticate without storing password.
    
    Args:
        username: User name
        password: Plaintext password (hashed by function)
        
    Returns:
        bool: True if authenticated
    """
    # Hash password immediately
    hashed = hashlib.sha256(password.encode()).hexdigest()
    
    # Compare with stored hash
    stored_hash = self._get_stored_hash(username)
    
    return secrets.compare_digest(hashed, stored_hash)
```

#### If You Must Store Secrets

```python
# 1. Hash with salt (not just plaintext)
import hashlib
import secrets

password = user_input
salt = secrets.token_hex(16)  # 32-char random salt
hashed = hashlib.pbkdf2_hmac(
    'sha256',
    password.encode(),
    bytes.fromhex(salt),
    100000  # iterations
)

# 2. Use secrets module for tokens
token = secrets.token_urlsafe(32)  # 42-char token

# 3. Never log passwords
logger.debug(f"Login attempt for {username}")  # ✅ OK
logger.debug(f"Password: {password}")  # ❌ NEVER
```

---

#### Credential Rotation

```bash
# 1. Generate new credentials
NEW_TOKEN=$(python -c "import secrets; print(secrets.token_urlsafe(32))")

# 2. Update in secure location (not in git)
# - Save to ~/.palexus/credentials.conf
# - Or set as environment variable: export PALEXUS_TOKEN=$NEW_TOKEN

# 3. Verify new credentials work
# - Test API access
# - Run test suite

# 4. Revoke old credentials
# - Delete old token
# - Update all systems
```

---

## Access Control

### Principle of Least Privilege

#### Module Permissions

```python
# ✅ GOOD: Each module has explicit permissions

class TokenRegistry:
    """Reads one tokens.json; exposes getters only."""

    def colors(self, category: str | None = None) -> dict: ...
    def color(self, category: str, name: str) -> str: ...
    # No setters, no writes: the registry never modifies tokens.json.
    # Exporters return strings; the caller decides where to write them.

    # ❌ NOT ALLOWED:
    # - Execute arbitrary commands
    # - Delete files
    # - Access other modules' data
```

#### File Permissions

```bash
# Configuration files should be readable only by owner
chmod 600 ~/.palexus/config.json

# Public documentation is world-readable
chmod 644 docs/README.md

# Executables need execute permission
chmod 755 scripts/deploy.sh
```

---

## Deployment Hardening

### Pre-Deployment Checklist

```python
class DeploymentSecurityCheck:
    """Verify security before deployment."""
    
    def check_all(self) -> List[Result]:
        """Run all security checks."""
        return [
            self.check_no_hardcoded_secrets(),
            self.check_no_dangerous_code(),
            self.check_dependencies_safe(),
            self.check_input_validation(),
            self.check_error_handling(),
            self.check_logging_safe(),
        ]
    
    def check_no_hardcoded_secrets(self) -> Result:
        """Verify no hardcoded API keys, passwords."""
        import re
        
        patterns = [
            r"password\s*=\s*['\"].*['\"]",
            r"api[_-]?key\s*=\s*['\"].*['\"]",
            r"secret\s*=\s*['\"].*['\"]",
            r"token\s*=\s*['\"]sk_.*['\"]",  # Stripe-like patterns
        ]
        
        found = []
        for file in self._get_source_files():
            content = file.read_text()
            for pattern in patterns:
                if re.search(pattern, content, re.IGNORECASE):
                    found.append(str(file))
        
        return Result(
            name="No hardcoded secrets",
            passed=len(found) == 0,
            error=f"Found in: {', '.join(found)}" if found else None
        )
```

---

### Runtime Hardening

#### Environment Variables

```bash
# Production environment should have:

# ✅ DO SET:
export PYTHONHASHSEED=0  # Deterministic hashing
export PYTHONDONTWRITEBYTECODE=1  # No .pyc files
export PYTHONUNBUFFERED=1  # Immediate output

# ❌ DON'T SET:
export PYTHONBREAKPOINT=1  # Allows debugger entry
export DEBUG=1  # May leak information
```

#### Container Hardening

```dockerfile
# Dockerfile best practices

FROM python:3.11-slim

# Run as non-root user
RUN groupadd -r palexus && useradd -r -g palexus palexus

# Install minimal dependencies
RUN pip install --no-cache-dir -e .

# Copy application
COPY --chown=palexus:palexus . /app

# Change to non-root user
USER palexus

# Don't run as PID 1 (use init)
ENTRYPOINT ["/sbin/dumb-init", "--"]
CMD ["python", "-m", "palexus"]
```

---

## Security Audit Checklist

### Code Security

- [ ] No `eval()`, `exec()`, `__import__()`, or `pickle.loads()`
- [ ] No hardcoded credentials (passwords, API keys, tokens)
- [ ] All external input is validated
- [ ] Error messages don't reveal sensitive information
- [ ] Type hints present on public methods
- [ ] Path operations prevent traversal attacks
- [ ] No XXE or injection vulnerabilities
- [ ] SQL queries use parameterized statements (if applicable)
- [ ] File operations check permissions properly
- [ ] Logging never includes secrets

### Dependency Security

- [ ] `pip audit` shows no high/critical CVEs
- [ ] All direct dependencies are pinned or ranged
- [ ] `requirements.txt` or `pyproject.toml` up-to-date
- [ ] No unused dependencies
- [ ] Third-party code reviewed for security issues
- [ ] Dependencies from official sources only

### Access Control

- [ ] Each module has minimum necessary permissions
- [ ] File permissions set correctly (600 for config, 644 for data)
- [ ] No hardcoded file paths that might be world-writable
- [ ] Environment variables don't contain secrets
- [ ] Config files have restricted permissions

### Deployment

- [ ] All tests pass (including security tests)
- [ ] Code review completed and approved
- [ ] No debug symbols in production binaries
- [ ] Logging configured for security (no secrets)
- [ ] Error handling catches and logs appropriately
- [ ] Rate limiting configured (if applicable)
- [ ] CORS configured properly (if applicable)

### Operations

- [ ] Secrets stored in secure vault (not in git)
- [ ] Credentials rotated regularly
- [ ] Security patches applied promptly
- [ ] Audit logging enabled
- [ ] Monitoring and alerting configured
- [ ] Incident response plan documented

---

## Incident Response

### Security Incident Procedures

#### If You Find a Vulnerability

1. **Don't disclose publicly** - File private security issue first
2. **Assess severity** - Is production affected? Data exposed?
3. **Create fix** - Implement patch in isolated branch
4. **Test thoroughly** - Verify fix and no regression
5. **Deploy carefully** - Consider security implications
6. **Communicate** - Inform users of patch availability

#### Vulnerability Report Template

```markdown
# Security Vulnerability Report

## Vulnerability Type
[e.g., SQL Injection, Path Traversal, etc.]

## Severity
[ ] Critical  [ ] High  [ ] Medium  [ ] Low

## Description
Clear explanation of the vulnerability and impact.

## Proof of Concept
Steps to reproduce (without actual exploitation if possible).

## Recommended Fix
Your proposed solution (if you have one).

## Timeline
- Date discovered: YYYY-MM-DD
- Date reported: YYYY-MM-DD
- Suggested fix deadline: YYYY-MM-DD
```

---

#### Incident Timeline Example

```
2026-11-20 10:00 UTC  - Vulnerability discovered in TokenRegistry
2026-11-20 10:15 UTC  - Internal security team notified
2026-11-20 11:00 UTC  - Fix implementation started
2026-11-20 14:00 UTC  - Fix tested and approved
2026-11-20 15:00 UTC  - Security patch released (v0.1.1)
2026-11-21 00:00 UTC  - Users notified via email
2026-11-22 00:00 UTC  - Post-incident review
```

---

### Post-Incident Review

```python
class IncidentReview:
    """Document security incident for future prevention."""
    
    def conduct_review(self) -> dict:
        """Analyze incident and prevent recurrence."""
        return {
            "what_happened": "Clear description of the vulnerability",
            "root_cause": "Why the vulnerability existed",
            "impact": "What was affected, how many users",
            "time_to_detect": "How long before we noticed",
            "time_to_fix": "How long to patch and deploy",
            "lessons_learned": [
                "What we can do better",
                "Process improvements",
                "Testing gaps",
            ],
            "action_items": [
                "Task 1 to prevent recurrence",
                "Task 2 for monitoring",
                "Task 3 for testing",
            ],
            "metrics": {
                "severity": "critical|high|medium|low",
                "affected_users": 0,
                "data_exposed": False,
            },
        }
```

---

## Security Resources

### Internal
- Security audit checklist (above)
- Code review guidelines (CONTRIBUTING.md)
- Incident response procedures (above)

### External
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [Python Security Best Practices](https://python.readthedocs.io/en/latest/library/security_warnings.html)
- [Bandit Security Linter](https://bandit.readthedocs.io/)

---

## Responsible Disclosure

### For Researchers Finding Vulnerabilities

1. **Don't publish** until patch is available and deployed
2. **Report privately** to maintainers
3. **Allow reasonable time** for fix and release
4. **Coordinate disclosure** timing with maintainers

### PalexusOS Security Contact

For security vulnerabilities, email:
- **security@example.com** (placeholder - add real contact)

Include:
- Vulnerability type
- Affected version(s)
- Proof of concept (if safe)
- Suggested fix (if available)

---

## Continuous Security

### Automated Security Scanning

```bash
# GitHub Actions can run these automatically

# Check for secrets
pip install detect-secrets
detect-secrets scan

# Check for vulnerabilities
pip install bandit
bandit -r palexus/

# Audit dependencies
pip-audit

# Type checking
mypy palexus/
```

---

## Summary

PalexusOS security is based on:

✅ **Least Privilege** - Each component has minimum permissions  
✅ **Defense in Depth** - Multiple layers of protection  
✅ **Secure by Default** - No hardcoded secrets or telemetry  
✅ **Input Validation** - Whitelist what's allowed  
✅ **Error Handling** - Fail securely  
✅ **Code Review** - Security-focused review before merge  
✅ **Dependency Management** - Regular audits and updates  
✅ **Incident Response** - Clear procedures if issues found  

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete security guide
