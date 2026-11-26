// mattflow core: shared helpers for hooks, installers and the Ralph loop.
import { existsSync, readFileSync, writeFileSync, readdirSync, mkdirSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';

export const IS_WIN = process.platform === 'win32';

export async function readStdinJson() {
  if (process.stdin.isTTY) return {};
  const chunks = [];
  for await (const c of process.stdin) chunks.push(c);
  const raw = Buffer.concat(chunks).toString('utf8').trim();
  if (!raw) return {};
  try { return JSON.parse(raw); } catch { return {}; }
}

export function sh(cmd, args, opts = {}) {
  const r = spawnSync(cmd, args, { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, windowsHide: true, ...opts });
  return { code: r.status ?? (r.error ? 127 : 1), out: (r.stdout || '') + (r.stderr || ''), stdout: r.stdout || '', error: r.error };
}

export function git(root, ...args) {
  const r = sh('git', args, { cwd: root });
  return r.code === 0 ? r.stdout.trim() : null;
}

export function repoRoot(cwd) {
  return git(cwd || process.cwd(), 'rev-parse', '--show-toplevel');
}

export function hasBin(bin) {
  const r = sh(IS_WIN ? 'where' : 'which', [bin]);
  return r.code === 0 && r.stdout.trim().length > 0;
}

/** True when a repo-local copy of this hook exists and the running script isn't it (avoid double runs). */
export function deferToProjectCopy(importMetaUrl, hookFile) {
  const projectDir = process.env.CLAUDE_PROJECT_DIR;
  if (!projectDir) return false;
  const local = resolve(projectDir, '.claude', 'mattflow', 'hooks', hookFile);
  const self = resolve(fileURLToPath(importMetaUrl));
  return existsSync(local) && local.toLowerCase() !== self.toLowerCase();
}

export function readJson(p, fallback = null) {
  if (!existsSync(p)) return fallback;
  try { return JSON.parse(readFileSync(p, 'utf8')); } catch { return fallback; }
}

export function writeJson(p, data) {
  mkdirSync(dirname(p), { recursive: true });
  writeFileSync(p, JSON.stringify(data, null, 2) + '\n');
}

export function loadConfig(root) {
  return readJson(join(root, '.mattflow.json'), null);
}

function pkgManager(root) {
  if (existsSync(join(root, 'pnpm-lock.yaml'))) return 'pnpm';
  if (existsSync(join(root, 'bun.lockb')) || existsSync(join(root, 'bun.lock'))) return 'bun';
  if (existsSync(join(root, 'yarn.lock'))) return 'yarn';
  return 'npm';
}

function fileHas(p, re) {
  return existsSync(p) && re.test(readFileSync(p, 'utf8'));
}

/**
 * Detect feedback loops from the environment. Only tools the repo has opted into
 * (scripts, config files) are used, so a repo that was green stays the baseline.
 */
export function detectChecks(root) {
  const out = { typecheck: [], lint: [], test: [] };
  const pj = readJson(join(root, 'package.json'));
  if (pj) {
    const scripts = pj.scripts || {};
    const pm = pkgManager(root);
    const run = (s) => (pm === 'npm' ? `npm run -s ${s}` : `${pm} run ${s}`);
    const tc = ['typecheck', 'type-check', 'check-types', 'tsc'].find((s) => scripts[s]);
    if (tc) out.typecheck.push(run(tc));
    else if (existsSync(join(root, 'tsconfig.json')) && existsSync(join(root, 'node_modules', 'typescript'))) out.typecheck.push('npx --no-install tsc --noEmit');
    if (scripts.lint) out.lint.push(run('lint'));
    if (scripts.test && !/no test specified/.test(scripts.test)) out.test.push(run('test'));
  }
  const pyproject = join(root, 'pyproject.toml');
  const isPy = existsSync(pyproject) || existsSync(join(root, 'setup.py')) || existsSync(join(root, 'requirements.txt'));
  if (isPy) {
    if ((existsSync(join(root, 'pyrightconfig.json')) || fileHas(pyproject, /\[tool\.pyright\]/)) && hasBin('pyright')) out.typecheck.push('pyright');
    else if ((existsSync(join(root, 'mypy.ini')) || fileHas(pyproject, /\[tool\.mypy\]/)) && hasBin('mypy')) out.typecheck.push('mypy .');
    if ((existsSync(join(root, 'ruff.toml')) || existsSync(join(root, '.ruff.toml')) || fileHas(pyproject, /\[tool\.ruff/)) && hasBin('ruff')) out.lint.push('ruff check .');
    if ((existsSync(join(root, 'tests')) || existsSync(join(root, 'test'))) && hasBin('pytest')) out.test.push('pytest -q -x');
  }
  if (existsSync(join(root, 'Cargo.toml')) && hasBin('cargo')) {
    out.typecheck.push('cargo check -q');
    out.test.push('cargo test -q');
  }
  if (existsSync(join(root, 'go.mod')) && hasBin('go')) {
    out.typecheck.push('go vet ./...');
    out.test.push('go test ./...');
  }
  return out;
}

/** Resolve which commands run for a context: 'stop' | 'commit'. */
export function resolveChecks(root, context) {
  const cfg = loadConfig(root);
  const base = cfg ? { typecheck: cfg.typecheck || [], lint: cfg.lint || [], test: cfg.test || [] } : detectChecks(root);
  const withTests = cfg ? (context === 'commit' ? !!cfg.runTestsOnCommit : cfg.runTestsOnStop !== false) : false;
  const cmds = [...base.typecheck, ...base.lint, ...(withTests ? base.test : [])];
  return { cmds, timeoutSec: cfg?.timeoutSec || 180, configured: !!cfg, quality: cfg?.quality || null };
}

const ANSI = /\x1b\[[0-9;?]*[ -/]*[@-~]/g;

export function runChecks(root, cmds, timeoutSec) {
  const results = [];
  for (const cmd of cmds) {
    const started = Date.now();
    const r = sh(cmd, [], { cwd: root, shell: true, timeout: timeoutSec * 1000, env: { ...process.env, CI: '1', FORCE_COLOR: '0' } });
    const timedOut = r.error && r.error.code === 'ETIMEDOUT';
    // A tool that isn't installed on this machine is skipped, not red (e.g. ruff present in CI but not locally).
    const missing = !timedOut && r.code !== 0 && (r.code === 127 || r.code === 9009 || /No module named [\w.]+\s*$|is not recognized as an internal or external command|: command not found/m.test(r.out));
    results.push({ cmd, ok: r.code === 0 && !timedOut, skipped: missing, timedOut, ms: Date.now() - started, out: r.out.replace(ANSI, '') });
  }
  return results;
}

export function tail(text, lines = 40) {
  const arr = text.trimEnd().split(/\r?\n/);
  return (arr.length > lines ? [`… (${arr.length - lines} lines cut)`, ...arr.slice(-lines)] : arr).join('\n');
}

/** Fingerprint of HEAD + working tree, so checks only re-run when code actually changed. */
export function worktreeFingerprint(root) {
  const h = createHash('sha1');
  h.update(git(root, 'rev-parse', 'HEAD') || 'no-head');
  h.update(git(root, 'diff', 'HEAD', '--no-color', '--no-ext-diff') || '');
  const untracked = git(root, 'ls-files', '--others', '--exclude-standard') || '';
  for (const f of untracked.split('\n').filter(Boolean).slice(0, 2000)) {
    try { h.update(f + ':' + readFileSync(join(root, f)).length + ':' + createHash('sha1').update(readFileSync(join(root, f))).digest('hex')); } catch { h.update(f); }
  }
  return h.digest('hex');
}

export function gitDir(root) {
  const d = git(root, 'rev-parse', '--git-dir');
  return d ? resolve(root, d) : null;
}

/** Open local tickets: .scratch/<feature>/issues/*.md without a "Status: done" line. */
export function openTickets(root) {
  const scratch = join(root, '.scratch');
  const found = [];
  if (!existsSync(scratch)) return found;
  for (const feature of readdirSync(scratch, { withFileTypes: true })) {
    if (!feature.isDirectory()) continue;
    const dir = join(scratch, feature.name, 'issues');
    if (!existsSync(dir)) continue;
    for (const f of readdirSync(dir).filter((n) => n.endsWith('.md')).sort()) {
      const body = readFileSync(join(dir, f), 'utf8');
      if (!/^\s*\**status\**:\s*\**(done|closed|complete)/im.test(body)) found.push(`.scratch/${feature.name}/issues/${f}`);
    }
  }
  return found;
}

/** Replace or append a marker-delimited block in a text file. */
export const MARK_START = '<!-- mattflow:start -->';
export const MARK_END = '<!-- mattflow:end -->';

export function upsertBlock(file, body, { create = true } = {}) {
  const block = `${MARK_START}\n${body.trim()}\n${MARK_END}`;
  if (!existsSync(file)) {
    if (!create) return 'skipped';
    mkdirSync(dirname(file), { recursive: true });
    writeFileSync(file, block + '\n');
    return 'created';
  }
  const text = readFileSync(file, 'utf8');
  const re = new RegExp(`${MARK_START}[\\s\\S]*?${MARK_END}`);
  if (re.test(text)) {
    const next = text.replace(re, block);
    if (next === text) return 'unchanged';
    writeFileSync(file, next);
    return 'updated';
  }
  writeFileSync(file, text.replace(/\s*$/, '') + '\n\n' + block + '\n');
  return 'appended';
}

export function removeBlock(file) {
  if (!existsSync(file)) return 'missing';
  const text = readFileSync(file, 'utf8');
  const re = new RegExp(`\\n*${MARK_START}[\\s\\S]*?${MARK_END}\\n?`);
  if (!re.test(text)) return 'absent';
  writeFileSync(file, text.replace(re, '\n').replace(/\n{3,}$/, '\n'));
  return 'removed';
}
