# Fortrexs fs.fortrexs.eu / Multitel Migration Facts

Use this reference when working on `fs-cdx2` / `fs.fortrexs.eu` Multitel routing, X-DID routing, caller-ID policy, or the Fortrexs development plan in Redmine.

Do not store or repeat Multitel credentials, Redmine API keys, SIP passwords, full API response bodies, or customer PII in this skill.

## Repos And Branches

- FreeSWITCH config repo in WSL: `/home/fortrexs/fs_fx_eu_config`.
- Windows path: `\\wsl$\Amazon2\home\fortrexs\fs_fx_eu_config`.
- User requested branch prefix: `mraaaooo/`, not `codex/`.
- First implementation branch for Redmine issue `#102`: `mraaaooo/fortrexs-dev-plan-v1-slice-102`.

## Live Hosts And Services

- FreeSWITCH host: `fs-cdx2` / `fs.fortrexs.eu`.
- Mail/API helper host: `mail-cdx` / `mail.fortrexs.eu`.
- Multitel API calls must be made from `mail.fortrexs.eu` with IPv4 forced; known egress IPv4 on 2026-05-12 was `3.126.131.133`.
- Multitel credentials live on `mail-cdx` at `/root/multitel.cred`; never print the file.
- Multitel SMS/backend service on `mail-cdx`: `multitel-sms.service`.
- Multitel backend root: `/opt/multitel-sms`.
- Multitel backend data dir: `/var/lib/multitel-sms`.
- Current backend DB default: `/var/lib/multitel-sms/multitel-sms.sqlite3`.
- Delta Chat / Redmine notification bridge: `fortrexs-notify.service`.
- Notification bridge root: `/opt/fortrexs-notify`.
- Notification bridge config: `/etc/fortrexs-notify/config.json`; treat as secret-bearing.
- Notification bridge state: `/var/lib/fortrexs-notify/state.sqlite`.

## FreeSWITCH Baseline 2026-05-12

Collected from `fs-cdx2` at `2026-05-12T09:25:39Z`:

- Hostname: `fs.fortrexs.eu`.
- Version: `FreeSWITCH 1.10.12-release-10222002881-a88d069d6f`.
- Uptime: about 1 day 14 hours.
- Sessions since startup: `2588`.
- Current calls at baseline: `1` call / `2` channels, internal `5000` to `5001`.
- Loaded modules checked true: `mod_sofia`, `mod_event_socket`, `mod_xml_curl`.
- Profiles running: `internal`, `external`, `ldap-pilot`.
- Aliases: `fs.fortrexs.eu -> internal`, `dt.fortrexs.eu -> internal`.

Registered Multitel gateways at baseline:

| Gateway | SIP account / proxy | State |
| --- | --- | --- |
| `48732080442` | `1283118310@sbc-de.multitel.net` | `REGED` |
| `447441910780` | `1615686357@sbc-de.multitel.net` | `REGED` |
| `380947105854` | `2062329994@sbc-de.multitel.net` | `REGED` |
| `3726346125` | `3489724403@sbc-de.multitel.net` | `REGED` |
| `14378879076` | `1240312572@sbc-de.multitel.net` | `REGED` |
| `12136995776` | `2151250795@sbc-de.multitel.net` | `REGED` |
| `12133201993` | `2940414091@sbc-de.multitel.net` | `REGED` |

## Baseline Backups 2026-05-12

FreeSWITCH live config backup:

- Path: `/var/backups/fortrexs/freeswitch/etc-freeswitch-baseline-20260512T092700Z.tar.gz`
- Size: `3.8M`
- SHA256: `f884dbeee48d715ec6d4f2a5e31f8c43c64f990149ccf0924ab79d771d82d064`
- Restore pattern: copy aside current `/etc/freeswitch`, then extract this archive with `tar -C /etc -xzf <archive>` during an approved maintenance window.

Multitel/API and app baseline snapshot on `mail-cdx`:

- Directory: `/var/backups/fortrexs/multitel/20260512T094200Z`
- `inventory.json`: `11456` bytes, SHA256 `61261501ecd07e90be9f4cc78fdd6ef6e242ec07b5d59321565213ab06c32dfc`
- `balance.json`: `114` bytes, SHA256 `84af45d680f142c0d7529d6f99c5ae761648b942a1bbff464ffe3fc6b05b1017`
- `getbalance.json`: `101` bytes, SHA256 `b82d665eae9eb4d2a3e35f0491ef89716edcc3f630cdd7a650164c5818d15432`
- `multitel-sms.sqlite3`: `2.2M`, SHA256 `68d48f226f357cafc6fdb6394786dde5f4583396129943cb09f0b85dfb5daf23`
- `fortrexs-notify-config.json`: `1.8K`, SHA256 `9744359ff2fc1a38f7794affd0e2d8b84c5ae7d00f06f616f0ed4fd7c2287dec`
- `fortrexs-notify-state.sqlite`: `52K`, SHA256 `40225458fd6e5eaebe2c1fa319c4e78702990e84926aa94b0f44a94816aa815d`

## Safe Rollout Rules

- First slice is Redmine issue `#102`: restore point and baseline only.
- No `reloadxml`, Sofia rescan/restart, gateway restart, or service restart during baseline collection.
- Put useful non-secret findings into this reference as they are discovered.
- Keep Redmine updated with evidence and residual risk after each slice.
- Use read-only data import before live routing.
- Use FreeSWITCH shadow mode before live outbound route changes.
- Pilot one extension/context for outbound changes.
- Pilot one DID for X-DID inbound routing.
- Pilot one non-critical DID for Multitel portal/API SIP-account changes.
- Decommission old gateways last, one at a time, after a cooling period.
