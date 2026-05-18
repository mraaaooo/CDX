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
- Multitel monitor notifications use the dedicated Delta Chat sender mailbox `monitor@ruaxx.org`, not `redmine@ruaxx.org`.

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

## Slice 101 Inventory Implementation Facts

- Redmine issue `#101` branch: `mraaaooo/fortrexs-dev-plan-v1-slice-101`.
- Backend repo worktree used for the first implementation slice: `C:\tmp\fortrexs-sms-slice101`.
- New local control tables introduced in backend DB: `multitel_api_requests`, `multitel_inventory_snapshots`, `multitel_numbers`, `authorized_caller_ids`, `multitel_inventory_events`, `multitel_balance_snapshots`, `multitel_sip_accounts`, and `multitel_number_sip_assignments`.
- Production target for inventory, caller-ID policy, pricing, balance, and routing-control data is MySQL via `DATABASE_URL`; SQLite remains only the current service compatibility/local smoke-test path until a DB migration is approved.
- User requested a normalized MySQL schema and a log of every Multitel API request. Saved-response imports write `multitel_api_requests` rows with redacted metadata and response hashes; live API clients must also log every call there.
- Multitel voice-routing model is trunk SIP accounts plus FreeSWITCH, not Hosted PBX.
- User stated there are `8` Multitel trunk SIP accounts configured in the portal; track them in `multitel_sip_accounts` and DID assignments in `multitel_number_sip_assignments`. `SIP URI` destinations are not SIP accounts and should use `sip_account_id=0`.
- Non-critical pilot DID for a future approved Multitel SIP-account assignment mutation test: `447520644604`.
- Offline importer script: `backend/scripts/sync_multitel_snapshot.py`.
- Importer accepts saved Multitel inventory and balance JSON files; it does not call the live API itself in this slice.
- Follow-up commit `a678da9` adds live read-only API sync to the same importer:
  - `--live-inventory`
  - `--live-balance balance`
  - `--live-balance getbalance`
- Live sync uses `MULTITEL_USER` and `MULTITEL_PASS`, forces IPv4 by default, and logs each request in `multitel_api_requests` with method, URL without credentials, HTTP status, provider status, response hash, duration, and response payload.
- Controlled SQLite smoke test verified added, changed, removed, balance snapshot, and inventory caller-ID disable behavior.
- Saved real Multitel snapshot `/var/backups/fortrexs/multitel/20260512T094200Z/inventory.json` imported cleanly into a throwaway DB with `12` active inventory numbers and `12` active Multitel-owned authorized caller IDs.
- Read-only live test from `mail-cdx` into a temporary `/tmp` SQLite DB succeeded on 2026-05-12:
  - `v3/inventory`: HTTP `200`, provider `200`, duration `970 ms`
  - `v3/balance`: HTTP `200`, provider `200`, duration `756 ms`
  - `v3/getbalance`: HTTP `200`, provider `200`, duration `879 ms`
  - active inventory numbers imported: `12`
  - balance snapshots imported: `2`
  - temporary test files and DB under `/tmp/multitel-slice101-live-test` were removed after verification.
- MySQL migration was applied to the configured `sms_fortrexs` database on `mail-cdx` using `backend/scripts/apply_multitel_control_schema.py`.
  - New tables created: `authorized_caller_ids`, `multitel_api_requests`, `multitel_balance_snapshots`, `multitel_inventory_events`, `multitel_inventory_snapshots`, `multitel_number_sip_assignments`, `multitel_numbers`, `multitel_sip_accounts`.
  - One live read-only sync was run into MySQL after migration.
  - Post-sync MySQL verification: `12` active Multitel numbers, `12` active authorized caller IDs, `2` balance snapshots, API request rows for `v3/inventory`, `v3/balance`, and `v3/getbalance` all HTTP `200` / provider `200`.
  - Initial parser did not read nested portal routing fields, so SIP assignment tables were empty. Later evidence showed `/inventory` exposes routing under `config.forward_destination`, `config.uri`, `config.uri2`, `config.uri3`, and `status.origination.origination_trunk_name`.
  - Temporary migration files under `/tmp/multitel-slice101-apply` were removed after verification.
- Notification identity for this slice was provisioned on `mail-cdx`: mailbox `monitor@ruaxx.org`, LDAP `fortrexsServiceAccess: deltachat`, and `fortrexs-notify` sender config with display name `Fortrexs Monitor`. Config backup: `/etc/fortrexs-notify/config.json.bak-monitor-20260512`.
- Delta Chat verification for `monitor@ruaxx.org`: secure join with `mraaaooo@ruaxx.org` reached `ready`, test job `ac3fc58d-164e-458f-b615-a09555d32500` sent as `dc_message_id=16`, and the user confirmed arrival.
- Commit `cffc3d8` adds the Multitel monitor notification slice:
  - New table: `multitel_monitor_state`.
  - New script: `backend/scripts/monitor_multitel_control.py`.
  - New disabled-by-default systemd files: `multitel-control-monitor.service` and `multitel-control-monitor.timer`.
  - The monitor runs live read-only inventory/balance sync, sends through `monitor@ruaxx.org`, and suppresses duplicates with `last_notified_inventory_event_id` plus `low_balance_notified`.
  - `--dry-run` does not send notifications and does not advance monitor state.
  - `--initialize-state` baselines the current inventory/balance without sending notifications.
- Production validation on `mail-cdx` on 2026-05-13:
  - `multitel_monitor_state` was created in MySQL; no other new control table was missing.
  - An initial malformed credential-shell dry run produced false remove/restore events; importer was hardened to refuse failed provider responses before snapshot/event writes.
  - Corrected live dry run: `seen=12`, `removed=0`, `restored=12`, `balance_snapshots=2`.
  - Monitor state initialized at `last_notified_inventory_event_id=36`, latest balance `62.53517`, `low_balance_notified=0`.
  - Installed `/opt/multitel-sms` dry run after baseline: `seen=12`, `removed=0`, `restored=0`, `notifications=[]`.
  - Files installed on `mail-cdx` with backup `/var/backups/fortrexs/multitel-monitor-20260513T090550Z`.
- Commit `4b17dc0` adds unattended systemd credential loading for the monitor:
  - `multitel-control-monitor.service` uses `LoadCredential=multitel.cred:/root/multitel.cred`.
  - Manual systemd run succeeded on `mail-cdx`: `seen=12`, `removed=0`, `notifications=[]`.
  - `multitel-control-monitor.timer` was enabled on 2026-05-13; next observed run was `2026-05-14 08:21:21 UTC`.
- Commit `5ffa6b4` adds `backend/scripts/import_multitel_sip_assignments.py` for operator-confirmed SIP-account and DID-assignment imports:
  - Dry-run by default; `--apply` is required for DB writes.
  - Does not call or mutate Multitel.
  - Validates assignment DIDs against `multitel_numbers`.
  - Live dry-run on `mail-cdx` with one sample SIP account and one sample DID assignment reported `sip_accounts_created=1`, `assignments_created=1`, and `assignment_errors=[]`.
  - Installed at `/opt/multitel-sms/scripts/import_multitel_sip_assignments.py`.
- Follow-up live reconciliation on 2026-05-18:
  - `sync_multitel_snapshot.py` now normalizes nested `/inventory` routing fields and maps `forward_destination` `7` to `SIP Account`, `1` to `SIP URI`, and `15` to `Hosted PBX`.
  - Operator seed import supports `--allow-non-inventory` for inactive historical DIDs and `--deactivate-missing-sip-accounts` when the seed is a complete account list.
  - Live MySQL final state: `13` total Multitel number rows, `12` active inventory numbers, `11` total SIP account rows, `8` active SIP accounts, `13` total DID assignment rows, `12` active assignments, and `12` active inventory caller IDs.
  - Historical DID `14378879076` is stored inactive with inactive assignment to SIP account `1240312572`; this preserves the old FreeSWITCH gateway evidence without claiming it is in current Multitel inventory.
  - Inactive pseudo SIP-account audit rows from the first parser run: `+12134603576@109.235.246.101`, `0`, and `user1@vpbx400204210.mangosip.ru`.
  - Live DB backup before final reconcile: `/var/backups/fortrexs/multitel/db-before-final-routing-reconcile-20260518T043408Z.json`.
  - Local SQLite compatibility DB was reconciled too; backup: `/var/lib/multitel-sms/multitel-sms.sqlite3.bak-before-control-reconcile-20260518T045235Z`.
- Redmine issue `#100` pricing foundation on 2026-05-18:
  - Pricing/routing schema is vendor-normalized, not Multitel-only: `iptel_vendors`, `iptel_rate_imports`, and `iptel_termination_rates`.
  - `iptel_vendors.id=1` is reserved/seeded for `vendor_key=multitel`, `display_name=Multitel`.
  - Supplied combined Multitel customer prices CSV was saved at `/var/backups/fortrexs/multitel/rates/customer_prices_combined_20260511.csv`, SHA256 `e1cac8666db4005d692cf1d09ae5788bdb51359fae2c7ee95f52bd97e3b69cf9`.
  - Live MySQL pricing import: `iptel_rate_imports.id=1`, `vendor_id=1`, `rate_plan=outbound_termination_combined`, `row_count=54984`, active.
  - Full CSV characteristics: `54984` rows, `237` ISO labels, `6274` rows with blank ISO, `5` duplicate prefixes, prefix length range `1..11`.
  - Offline evaluator script: `/opt/multitel-sms/scripts/evaluate_multitel_route.py`. It uses active vendor/rate-plan imports, longest-prefix match, authorized caller IDs, EU/EEA Origin bucket, Local bucket, International bucket, and `Price` fallback for unknown caller country.
  - Live MySQL sample evaluation for `33612345678`: selected caller ID `3726346125` (`EE`) for `Origin` bucket, rate `0.082000`; explicit `33612345678*12136995776` selected US caller ID `12136995776` for `International` bucket, rate `0.230400`; `33612345678#` parsed as `withhold_cli` and selected an owned Multitel inventory caller ID.
  - DB backup before rate import: `/var/backups/fortrexs/multitel/db-before-rate-import-20260518T063826Z.json`.
- Inventory-imported caller IDs use `source=multitel_inventory`, `allow_explicit_use=true`, and `allow_auto_selection=true`.
- Customer-provided caller IDs must use a separate source such as `customer_verified_external`; inventory imports only disable caller IDs whose source is `multitel_inventory`.

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
