#!/usr/bin/env node
// PreToolUse (Bash|PowerShell): block one-way-door git commands. Exit 2 = blocked, stderr goes to the agent.
// Based on mattpocock/skills git-guardrails-claude-code, extended: plain feature-branch pushes are allowed
// (two-way door); force/delete/mirror pushes, pushes to main/master, and hook bypasses are blocked.
import { readStdinJson, git, deferToProjectCopy } from '../lib/core.mjs';

if (deferToProjectCopy(import.meta.url, 'git-guardrails.mjs')) process.exit(0);

const PROTECTED = new Set(['main', 'master']);
const input = await readStdinJson();
const command = String(input?.tool_input?.command || '');
if (!/\bgit\b/.test(command)) process.exit(0);
const cwd = input.cwd || process.env.CLAUDE_PROJECT_DIR || process.cwd();

// Judge each chained git invocation on its own, with quoted text (commit messages) blanked out.
const segments = command
  .replace(/"(?:[^"\\]|\\.)*"|'[^']*'/g, '""')
  .split(/&&|\|\||;|\||\r?\n/)
  .map((s) => s.trim())
  .filter((s) => /\bgit\b/.test(s));

const rules = [
  [/\bpush\b.*(\s--force|\s-[a-zA-Z]*f\b|\s--mirror\b|\s--delete\b|\s-d\b|\s\+\S|\s:\S)/, 'force/delete/mirror push rewrites or removes remote history'],
  [/\breset\b.*--hard\b/, 'git reset --hard discards work'],
  [/\bclean\b.*\s-[a-zA-Z]*f/, 'git clean -f deletes untracked files'],
  [/\bbranch\b.*(\s-[a-zA-Z]*D\b|--delete\s+--force|--force\s+--delete)/, 'git branch -D force-deletes a branch'],
  [/\bcheckout\b.*\s(--\s+)?\.(\s|$)/, 'git checkout . discards working-tree changes'],
  [/\bstash\s+(drop|clear)\b/, 'git stash drop/clear deletes stashed work'],
  [/\b(commit|merge|push|rebase|am)\b.*--no-verify\b/, '--no-verify skips the feedback loops'],
  [/\bcommit\b.*\s-[a-zA-Z]*n[a-zA-Z]*\b/, 'git commit -n skips the feedback loops'],
  [/\bconfig\b.*core\.hooksPath/, 'changing core.hooksPath disables the feedback loops'],
  [/\b(filter-branch|filter-repo)\b/, 'history rewrite'],
];

for (const seg of segments) {
  for (const [re, why] of rules) if (re.test(seg)) block(seg, why);

  if (/\brestore\b/.test(seg) && /\s\.(\s|$)/.test(seg) && (!/--staged|\s-S\b/.test(seg) || /--worktree|\s-W\b/.test(seg))) {
    block(seg, 'git restore . discards working-tree changes');
  }

  if (/\bpush\b/.test(seg)) {
    const refs = seg.replace(/^.*?\bpush\b/, '').trim().split(/\s+/).filter((a) => a && !a.startsWith('-'));
    const targets = refs.slice(1).map((r) => r.split(':').pop().replace(/^refs\/heads\//, ''));
    if (targets.some((t) => PROTECTED.has(t))) block(seg, 'pushing to main/master');
    if (refs.length <= 1) {
      const branch = git(cwd, 'rev-parse', '--abbrev-ref', 'HEAD');
      if (PROTECTED.has(branch)) block(seg, `pushing the current branch (${branch})`);
    }
  }
}
process.exit(0);

function block(seg, why) {
  process.stderr.write(
    `BLOCKED by mattflow git-guardrails: \`${seg}\` (${why}). This is a one-way door the human has reserved. ` +
      'Stop and ask the human to run it, or use a reversible alternative (new branch, git stash, git revert).\n',
  );
  process.exit(2);
}
