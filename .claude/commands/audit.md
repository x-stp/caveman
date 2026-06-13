---
description: Run the local security scanner chain over the current working tree and summarize findings in one table.
---

Run the local security scanner chain over the working tree. Each scanner runs even if a previous one failed (no fail-fast).

Sequence:

1. `osv-scanner --recursive --skip-git .`
2. `gitleaks detect --no-git --redact`
3. `shellcheck install.sh install.ps1 src/hooks/*.sh` — skip files that don't exist; do not fail the chain on a missing file.
4. `zizmor --offline .github/workflows/`
5. `semgrep scan --config=p/security-audit --config=p/nodejs --config=p/python --config=p/ci --config=p/owasp-top-ten --config=p/github-actions --metrics=off --quiet .`

After all five finish, write `$(date -u +%FT%TZ) > .audit-stamp` so the SessionStart banner picks up the new run.

Output a single summary table:

| Tool | Status | Findings (count by severity) | Top 3 findings |
|---|---|---|---|
| osv-scanner | OK | 0 | — |
| gitleaks | OK | 1 (info) | `<fingerprint>: <file>:<line>` |
| shellcheck | OK | 2 (warning) | … |
| zizmor | OK | 0 | — |
| semgrep | OK | 5 (info) | … |

End with one line: `clean` if every tool reports 0 critical and 0 high, else `findings present — review scanner output`.

Print only the table + verdict line. No extra commentary.

If a scanner is missing locally, mark its status `NOT_INSTALLED` and continue. Suggest the install command (`brew install <tool>`) in a footer below the verdict.
