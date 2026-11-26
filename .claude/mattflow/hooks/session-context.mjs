#!/usr/bin/env node
// SessionStart: print a compact repo briefing (stdout becomes session context). Silent outside git repos.
import { existsSync, readdirSync } from 'node:fs';
import { join, basename } from 'node:path';
import { readStdinJson, repoRoot, git, gitDir, resolveChecks, openTickets, deferToProjectCopy, worktreeFingerprint, readJson, writeJson } from '../lib/core.mjs';

if (deferToProjectCopy(import.meta.url, 'session-context.mjs')) process.exit(0);

const input = await readStdinJson();
const root = repoRoot(input.cwd || process.env.CLAUDE_PROJECT_DIR || process.cwd());
if (!root) process.exit(0);

// Baseline for the Stop hook: checks only run once this session has changed something.
if (input.session_id) {
  try {
    const stateFile = join(gitDir(root) || join(root, '.git'), 'mattflow-state.json');
    const state = readJson(stateFile, {});
    const base = Object.fromEntries(Object.entries(state.base || {}).slice(-19));
    base[input.session_id] = base[input.session_id] || worktreeFingerprint(root);
    writeJson(stateFile, { ...state, base });
  } catch {}
}

const branch = git(root, 'rev-parse', '--abbrev-ref', 'HEAD') || '?';
const dirty = (git(root, 'status', '--porcelain') || '').split('\n').filter(Boolean).length;
const { cmds, configured, quality } = resolveChecks(root, 'stop');
const adrDir = join(root, 'docs', 'adr');
const adrs = existsSync(adrDir) ? readdirSync(adrDir).filter((f) => f.endsWith('.md')).length : 0;
const tick = (p) => (existsSync(join(root, p)) ? '✓' : '✗');
const trackerSet = existsSync(join(root, 'docs', 'agents', 'issue-tracker.md'));
const tickets = openTickets(root);

const lines = [
  `[mattflow] ${basename(root)} @ ${branch} · ${dirty} uncommitted · quality bar: ${quality || 'undeclared (ask once, record in .mattflow.json "quality")'}`,
  'flow: /grill-with-docs → /to-spec → /to-tickets → /implement (fresh context per ticket) → /code-review → /retro',
  `docs: CONTEXT.md ${tick('CONTEXT.md')} · ADRs ${adrs} · CODING_STANDARDS.md ${tick('CODING_STANDARDS.md')} · tracker ${trackerSet ? '✓' : '✗ (suggest /setup-matt-pocock-skills)'}`,
  `feedback loops (run on Stop${configured ? ', .mattflow.json' : ', auto-detected'}): ${cmds.length ? cmds.join(' · ') : 'none found (suggest adding typecheck/lint/test scripts or .mattflow.json)'}`,
];
if (tickets.length) lines.push(`open tickets: ${tickets.length} (next: ${tickets[0]})`);
process.stdout.write(lines.join('\n') + '\n');
