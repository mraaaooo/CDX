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

Operational note:

- this pattern intentionally favors reliability on a single admin-owned host
- tighten the sudo scope later only after the recurring command set is better
  understood
