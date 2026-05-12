# Source and Dating Policy

## Book Sources Used

Use these books as dated background, not as current package/module truth:

- `FreeSWITCH权威指南`, Du Jinfang and Zhang Lingkao, paper edition 2014.
- `FreeSWITCH 1.6 Cookbook`, second edition July 2015, Packt.
- `Mastering FreeSWITCH`, first published July 2016, Packt.
- `FreeSWITCH 1.8 - VoIP and WebRTC with FreeSWITCH`, first published July 2017, Packt.

The durable value from these books is conceptual:

- FreeSWITCH is an event-driven media server with modular endpoints, apps, APIs, and XML configuration.
- Dialplan behavior depends on condition matching, action order, channel variables, and bridge/originate semantics.
- Sofia profile/gateway design, NAT handling, codec negotiation, security, and traces must be understood together.
- XML-Curl/ESL/HTTAPI are strong integration points when static XML is not enough.
- CDR and recording pipelines must be designed as data pipelines, not just dialplan snippets.
- Multi-tenant/domain deployments require consistent domain, directory, profile, and routing boundaries.

## Currency Rules

- Treat Debian, package repository, module names, compile flags, WebRTC/Verto details, TLS defaults, codec defaults, and JavaScript examples from the books as stale until verified.
- Treat Sofia, dialplan, event, XML-Curl, recording, CDR, and troubleshooting concepts as useful, then verify exact variable names and side effects from source/docs.
- The observed FreeSWITCH RU host was FreeSWITCH 1.10.12. For similar hosts, inspect the exact version before assuming v1.10.12 behavior.

## Upstream References

Primary public references:

- Official docs: `https://developer.signalwire.com/freeswitch/`
- Source repo: `https://github.com/signalwire/freeswitch`
- v1.10.12 source tag: `https://github.com/signalwire/freeswitch/tree/v1.10.12`

When exact behavior matters, inspect the matching source tag or host-local package source. Key v1.10.12 code landmarks:

- Bridge loop and `bridge_answer_timeout`: `src/switch_ivr_bridge.c`
- Originate globals, `originate_timeout`, per-leg `leg_timeout`: `src/switch_ivr_originate.c`
- Dialplan apps, `record_session`, bridge wrappers: `src/mod/applications/mod_dptools/mod_dptools.c`
- Recording media bug, `RECORD_STEREO`, `RECORD_MIN_SEC`, record stop events: `src/switch_ivr_async.c`
- File recording post-process path: `src/switch_ivr_play_say.c`
- Sofia profile/gateway structures, gateway states, registration events: `src/mod/endpoints/mod_sofia/mod_sofia.h`
- Sofia endpoint behavior and recording follow-transfer cases: `src/mod/endpoints/mod_sofia/sofia.c`
- XML-Curl binding parsing and request controls: `src/mod/xml_int/mod_xml_curl/mod_xml_curl.c`
- Event socket listener defaults and ACL/password parsing: `src/mod/event_handlers/mod_event_socket/mod_event_socket.c`
- CSV CDR leg filtering, template expansion, rotate API: `src/mod/event_handlers/mod_cdr_csv/mod_cdr_csv.c`
- JSON CDR file/HTTP behavior and B-leg logging option: `src/mod/event_handlers/mod_json_cdr/mod_json_cdr.c`

## Source-First Verification Pattern

1. Get live version: `fs_cli -x 'version'`.
2. Find the matching source tag or distro source package.
3. `rg` for the variable, app, API command, or event name.
4. Read the source around parsing and around runtime use.
5. Compare with live config and logs.
6. Only then propose a production change.
