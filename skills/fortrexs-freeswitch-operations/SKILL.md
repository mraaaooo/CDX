---
name: fortrexs-freeswitch-operations
description: Use when installing, inspecting, developing, interconnecting, routing, recording, provisioning, or operating Fortrexs FreeSWITCH systems, including Sofia profiles and gateways, multi-domain dialplans, dynamic routing, CDR and recording management, user directory/address book integration, device provisioning, mobile-app call notifications, ESL/XML-Curl/HTTAPI integrations, and production troubleshooting.
---

# Fortrexs FreeSWITCH Operations

## Authority Order

Use this skill with a strict evidence order:

1. Live installation evidence from the target host.
2. Matching upstream source code for the running FreeSWITCH version.
3. Current official SignalWire/FreeSWITCH docs.
4. Dated book knowledge as architectural and operational background.

Do not apply an old book recipe directly to a modern host without checking the
running version, module availability, source behavior, and current packaging.

## Core Rules

- Prefer read-only inspection before changing production FreeSWITCH.
- Treat `reloadxml`, profile rescans, gateway restarts, and Sofia profile restarts as production actions.
- Avoid full FreeSWITCH service restarts unless the user explicitly approves the risk/window.
- Before editing XML, identify the active include path and runtime-loaded profile/dialplan names.
- Validate XML before `reloadxml`.
- After any XML or Sofia change, verify `status`, `show calls`, `sofia status`, active profiles, and affected gateways.
- Do not delete recordings, CDRs, voicemail, or gateway/user registrations unless explicitly approved.
- For exact behavior, inspect source code for the running version rather than relying on memory.

## Initial Inspection Checklist

Run the least invasive commands first:

```bash
fs_cli -x 'version'
fs_cli -x 'status'
fs_cli -x 'show calls'
fs_cli -x 'show channels'
fs_cli -x 'sofia status'
fs_cli -x 'module_exists mod_sofia'
fs_cli -x 'module_exists mod_event_socket'
fs_cli -x 'module_exists mod_xml_curl'
```

Then inspect files:

```bash
find /etc/freeswitch -maxdepth 4 -type f | sort
grep -RIn "record_session\|hangup_after_bridge\|bridge_answer_timeout\|originate_timeout\|leg_timeout\|execute_on\|curl\|gateway" /etc/freeswitch
```

Prefer the bundled read-only collector when available:

```bash
scripts/fs_collect_readonly.sh /tmp/fs-audit
```

## Live Test Calling

Treat carrier-loop test calls as production actions. Before originating a live
test call:

1. Confirm the user asked for the live call and identify the exact source
   gateway, destination number, caller ID, timeout, and expected return route.
2. Verify `fs_cli -x 'status'`, `fs_cli -x 'show calls'`, and the relevant
   `fs_cli -x 'sofia status gateway <name>'` outputs first.
3. Prefer a synchronous `originate` for diagnostics so FreeSWITCH returns the
   immediate result. Use `bgapi originate` only when the caller explicitly needs
   an async job.
4. Use an explicit `origination_uuid` and quote commands so the local shell does
   not pass literal variables such as `$uuid` to the remote host.
5. After the call, verify `cdr-csv/Master.csv`, FreeSWITCH log excerpts, any
   recording path, and the PBX recording finalizer log before reporting success.

For the Dotochki MTT-to-SIPNET carrier-loop test on `fs-debian12-25gb`, use the
guarded helper:

```bash
scripts/fs_test_call_mtt_to_sipnet.sh --execute
```

The helper is dry-run by default and prints the exact `fs_cli` command unless
`--execute` is provided.

## Reference Selection

- Installation, source builds, packaging, and live audits:
  - [references/installation-and-live-inspection.md](references/installation-and-live-inspection.md)
- Sofia profiles, gateways, dynamic routing, dialstrings, and dialplan changes:
  - [references/sofia-dialplan-routing.md](references/sofia-dialplan-routing.md)
- User directory, domains, address books, and end-user device provisioning:
  - [references/directory-provisioning.md](references/directory-provisioning.md)
- Call recordings, CDRs, recording storage, and playback integrations:
  - [references/recordings-cdr.md](references/recordings-cdr.md)
- ESL, XML-Curl, HTTAPI, app callbacks, and mobile notifications:
  - [references/events-app-integration.md](references/events-app-integration.md)
- Multi-domain, multi-gateway, interconnect, and optimization patterns:
  - [references/multidomain-interconnect-ops.md](references/multidomain-interconnect-ops.md)
- Fortrexs fs.fortrexs.eu / Multitel migration facts, branch names, backup locations, and safe rollout notes:
  - [references/fortrexs-multitel-fs-fx-eu.md](references/fortrexs-multitel-fs-fx-eu.md)
- Troubleshooting, SIP traces, runtime safety, and rollback:
  - [references/troubleshooting-runbook.md](references/troubleshooting-runbook.md)
- Book/source dating policy and upstream code landmarks:
  - [references/source-and-dating.md](references/source-and-dating.md)

## Fortrexs Defaults

- For FreeSWITCH RU/Dotochki work, assume the current production baseline may differ from GitHub/repo config. Compare before patching.
- For call-recording integrations, prefer a small FreeSWITCH finalizer plus app-side pull/sync storage over network transfer inside the hangup hook.
- For mobile users, separate call routing from app notification delivery. Use FreeSWITCH events/callbacks to inform the app layer; do not block call setup on push notification success.
- For dynamic users and multi-domain directory work, prefer a canonical app/LDAP/database source and generate or serve FreeSWITCH directory XML from that source.

## Change Pattern

1. State the current live evidence.
2. State the exact source/docs basis for the proposed behavior.
3. Prepare a narrow diff or script.
4. Validate offline first.
5. Apply with a rollback copy.
6. Reload the narrowest possible component.
7. Verify calls, Sofia, gateways, recordings/CDRs, and app callbacks.
8. Record the result in Redmine/wiki when the change affects production behavior.
