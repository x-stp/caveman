# Security Policy

This repository is a personal-use security-hardened fork of
[`JuliusBrussee/caveman`](https://github.com/JuliusBrussee/caveman). Its purpose:

1. Run scanners against upstream code on a schedule.
2. Maintain a defensible verdict on whether upstream is safe to `curl | sh`.
3. Produce a pinned-install recipe (a `cosign`-signed, `sha256`-verified install)
   for personal use that does not depend on `JuliusBrussee/caveman@main` being
   honest at install time.

The current verdict and the last-audited upstream commit SHA live in
[`.audited/manifest.json`](.audited/manifest.json).

## Reporting a vulnerability

**For vulnerabilities affecting this fork** (CI workflows, scanner configs,
the audit logic):

- Open a private vulnerability report via the GitHub **Security → Report a
  vulnerability** UI on this repository.
- Or contact the maintainer through their GitHub profile.

**For vulnerabilities affecting upstream caveman**: report directly to
[`JuliusBrussee/caveman`](https://github.com/JuliusBrussee/caveman). Findings
surfaced by this fork's CI will be triaged here first, then either disclosed
coordinated with upstream or kept private if narrow to this fork.

## Audit surface

`.github/workflows/` runs on every PR and on a schedule:

| Workflow | What it checks |
|---|---|
| `zizmor.yml` | GitHub Actions workflow audit (template injection, unpinned actions, excessive perms, `pull_request_target` hazards). |
| `osv-scanner.yml` | Known-CVE scan across npm, pip, and GitHub Actions ecosystems via OSV.dev. |
| `gitleaks.yml` | Secret scanning, full history on cron, range on PR. |
| `shellcheck.yml` | Bash lint on `install.sh` and any other `*.sh`. |
| `semgrep.yml` | SAST with rulesets `p/security-audit`, `p/nodejs`, `p/python`, `p/ci`, `p/owasp-top-ten`, `p/github-actions`. |
| `dep-review.yml` | Blocks PRs introducing high-severity transitive deps. |
| `scorecard.yml` | OSSF Scorecard posture score, weekly. |
| `pin-check.yml` | Verifies every action `uses:` is pinned to a 40-char commit SHA. |
| `upstream-diff.yml` | Daily diff of upstream `main` against the last-audited SHA. Opens a `re-audit-needed` issue when install-path files change. |
| `claude-review.yml` | AI security review on PRs via [`anthropics/claude-code-security-review`](https://github.com/anthropics/claude-code-security-review). Skips fork PRs to avoid prompt-injection. |

GitHub-native features additionally enabled in repo Settings:

- Secret scanning + push protection
- Code scanning default setup (CodeQL JS/TS + Python)
- Private vulnerability reporting
- Branch protection on `main`
- "Require approval for fork PR workflows for outside collaborators"

## Supported branches

- `main` is the only actively scanned branch.
- `harden/install-path-fixes` carries Phase B rubric fixes against the upstream code.
- `audited/YYYY-MM-DD-<short-sha>` are pinned-install recipes produced by Phase C.

## Verdict rubric

Whether upstream is "safe to `curl | sh`" is judged against the 8-item rubric
in the project plan. Passing threshold: ≥ 6/8 items PASS on a specific upstream
commit SHA. Below threshold, the recommended install path is the pinned recipe
under `audited/YYYY-MM-DD-<short-sha>`, not the upstream curl-pipe.
