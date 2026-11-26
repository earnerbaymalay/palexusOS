# Engineering workflow (Matt Pocock / AI Hero)

The human owns **strategy** (module boundaries, interfaces, what ships). You own **tactics** inside those boundaries. Care about the design of the code every change.

## Main flow
1. **Grill** before building anything fuzzy: run `/grill-with-docs` in a repo (`/grill-me` outside one). Ask in rounds of numbered questions, each with your recommended answer. Look facts up yourself; put decisions to the human.
2. **Spec + tickets** for multi-session work: `/to-spec`, then `/to-tickets` (tracer-bullet tickets with blocking edges). Keep steps 1-2 in one context window.
3. **Implement** one ticket per fresh context: `/implement` drives `/tdd` (red → green, one slice at a time, at agreed seams).
4. **Review** on two axes, Standards and Spec: `/code-review`. Rate **merge danger**: one-way vs two-way door × blast radius.
5. **Retro**: `/retro` turns each repeated review comment into a deterministic check (lint rule, type, test, hook).

Unsure which skill fits → `/ask-matt`. First time in a repo → `/setup-matt-pocock-skills`.

## Leading words
- **Tracer bullets**: thin vertical slices through every layer, each demoable on its own. Build the end-to-end path first, then widen.
- **Shared language**: read `CONTEXT.md`; name code, tests and messages with its terms; record hard-to-reverse decisions as ADRs in `docs/adr/`.
- **Deep modules**: a lot of behaviour behind a small interface; test through that interface; keep related changes local.
- **Feedback loops**: typecheck often, run single test files often, run the full suite once at the end. Choose determinism: a lint rule beats a reminder. Commit only with every check green, hooks included.
- **Smart zone**: keep context small (~120-150k tokens is the edge). At a phase boundary pick, in order: continue → `/clear` → `/handoff` → subagent → `/compact <focus>`.
- **Small steps**: tackle the riskiest unknown first; prototype (`/prototype`) when a question can't be settled on paper.
- **Quality bar**: follow the repo's declared bar (prototype, production or library). Ask once if it is undeclared.

## Agent-facing docs
`CLAUDE.md` / `AGENTS.md` hold navigation pointers only. Coding rules live in `CODING_STANDARDS.md` (read at review time). Write positive instructions; cut any line that doesn't change behaviour.
