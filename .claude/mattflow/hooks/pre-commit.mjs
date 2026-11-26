#!/usr/bin/env node
// git pre-commit: the deterministic baseline every agent hits (Claude, OpenCode + Ollama, humans).
import { repoRoot, resolveChecks, runChecks, tail } from '../lib/core.mjs';

const root = repoRoot(process.cwd());
if (!root || process.env.MATTFLOW_SKIP_PRECOMMIT === '1') process.exit(0);
const { cmds, timeoutSec } = resolveChecks(root, 'commit');
if (!cmds.length) process.exit(0);

const results = runChecks(root, cmds, timeoutSec);
const failed = results.filter((r) => !r.ok && !r.skipped);
for (const r of results) process.stderr.write(`${r.ok ? '✓' : r.skipped ? '–' : '✗'} ${r.cmd}${r.skipped ? ' (skipped: tool not installed)' : ''} (${(r.ms / 1000).toFixed(1)}s)\n`);
if (failed.length) {
  for (const r of failed) process.stderr.write(`\n--- ${r.cmd}\n${tail(r.out, 40)}\n`);
  process.stderr.write('\nmattflow pre-commit: feedback loops red, commit aborted. Fix the cause and commit again.\n');
  process.exit(1);
}
