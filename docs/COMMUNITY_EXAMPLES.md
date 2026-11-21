# Community Examples

Integrations that people have built with PalexusOS and want to share.

**There are none yet.** An earlier version of this page described invented
"real-world" scenarios against an API that did not exist; it was removed.
For working recipes maintained alongside the code, see:

- [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md): CSS and shell exports, gates
  in CI, custom gates, result reporting, driving the boot sequence
- [`examples/`](../examples/): one runnable script per module, tested in CI

---

## Add yours

If you use PalexusOS somewhere (a web app themed from `tokens.json`, a CI
pipeline built on `GateRegistry`, an installer), add a section here by pull
request:

```markdown
### <What it does> — <your name or project>

**Problem**: one or two sentences.

**How it uses PalexusOS**: which modules and commands.

    <the smallest code or config that shows it>

**Link**: <repository or write-up, if public>
```

Requirements:

- It is something you actually run, not a sketch.
- The snippet works against the current `main` (check signatures in
  [API_REFERENCE.md](API_REFERENCE.md)).
- No secrets, internal hostnames or personal data in the snippet.

Ideas that would help others: Figma or Style Dictionary sync for
`tokens.json`, a GTK or Qt theme generated from the tokens, gates for a
project other than PalexusOS, the boot sequence wired to a real greeter.
