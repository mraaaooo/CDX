# Troubleshooting Runbook

## Incident Triage

Start with:

```bash
fs_cli -x 'status'
fs_cli -x 'show calls'
fs_cli -x 'show channels'
fs_cli -x 'sofia status'
tail -n 300 /var/log/freeswitch/freeswitch.log
```

For a call UUID:

```bash
fs_cli -x 'uuid_dump <uuid>'
fs_cli -x 'uuid_exists <uuid>'
fs_cli -x 'uuid_getvar <uuid> hangup_cause'
```

## SIP Trace

Use SIP trace narrowly and turn it off after capture:

```bash
fs_cli -x 'sofia global siptrace on'
fs_cli -x 'sofia profile <profile> siptrace on'
fs_cli -x 'sofia profile <profile> siptrace off'
fs_cli -x 'sofia global siptrace off'
```

Prefer targeted profile trace when possible.

## Common Failure Areas

- Gateway `REGED` but outbound call fails: inspect provider response, auth realm, From/Contact, dialed format, ACL, and codec/media negotiation.
- Call stuck in early media: inspect bridge variables, early media settings, B-leg state, and `bridge_answer_timeout`.
- A-leg orphaned after B-leg ends: inspect `hangup_after_bridge`, dialplan continuation, and hangup hooks.
- Recording missing: inspect `record_session` path, directory ownership, `RECORD_*` vars, record stop event, CDR UUID, and app storage sync.
- App callback missing: inspect dialplan hook, DNS/TLS/API timeout, app logs, and idempotency by UUID.
- Directory user not found: inspect domain, context, XML include, XML-Curl response, `user_data`, and registration domain.

## Rollback Pattern

- Restore only the file(s) edited for the change.
- Validate XML.
- Use `reloadxml` or narrow Sofia/gateway command when possible.
- Confirm profile/gateway state and live calls.
- Keep logs and diffs for post-incident review.

## Reporting

When reporting a production FreeSWITCH finding, include:

- host and timestamp
- FreeSWITCH version
- profile/context/gateway
- call UUIDs
- A-leg/B-leg channels
- relevant timestamps
- exact live config paths
- proposed diff or rollback path
- test performed after change
