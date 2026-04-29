# Live Pattern

Current observed live example:

- host: `mail.fortrexs.eu`
- dedicated headless ops user: `cdx`
- bootstrap key source:
  - `/home/ubuntu/.ssh/authorized_keys`
- working directories:
  - `/home/cdx/bin`
  - `/home/cdx/work`
  - `/home/cdx/runbooks`
  - `/home/cdx/snapshots`
- first-pass sudo policy:
  - `cdx ALL=(ALL) NOPASSWD: ALL`
- local SSH alias on this workstation:
  - `mail-cdx`
- local SSH config path on this workstation:
  - `C:\Users\mraaaooo\.ssh\config`

Testing note:

- in a sandboxed Codex desktop process, plain `ssh mail-cdx ...` may consult a
  different HOME directory
- in that case, test with:
  - `ssh -F C:\Users\mraaaooo\.ssh\config mail-cdx whoami`

Operational note:

- this pattern intentionally favors reliability on a single admin-owned host
- tighten the sudo scope later only after the recurring command set is better
  understood
