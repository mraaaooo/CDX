# Sofia, Dialplan, and Routing

## Sofia Profiles and Gateways

Inspect both XML and runtime state. Runtime state wins during incident response.

Useful commands:

```bash
fs_cli -x 'sofia status'
fs_cli -x 'sofia status profile internal'
fs_cli -x 'sofia status profile external'
fs_cli -x 'sofia status gateway <gateway>'
fs_cli -x 'sofia profile <profile> gwlist up'
```

Gateway states such as `REGED`, `NOREG`, and ping/registration behavior are implemented in `mod_sofia`; verify exact behavior in source when diagnosing edge states.

## Dialplan Change Pattern

1. Identify context/profile that actually receives the call.
2. Trace `destination_number`, caller profile, domain, and exported variables.
3. Keep route changes local to one extension/context unless a shared include is deliberately targeted.
4. Prefer explicit timeouts on bridge/originate legs.
5. Validate XML before `reloadxml`.
6. Test with `uuid_dump`, `show channels`, and logs for a real call UUID.

## Bridge and Originate Guardrails

For outbound gateway legs, usually consider:

- `hangup_after_bridge=true`: stop dialplan continuation and clean up A-leg after bridge ends.
- `originate_timeout=<seconds>`: global originate attempt bound.
- `[leg_timeout=<seconds>]endpoint`: per-destination bound.
- `bridge_answer_timeout=<seconds>`: bound early-media-without-answer cases during bridge.
- `continue_on_fail=<causes>`: only when later dialplan logic explicitly handles those failures.
- `ignore_early_media=true`: useful for simultaneous multi-endpoint routes where early media can prematurely pick a leg.

For v1.10.12 source verification:

- `bridge_answer_timeout`: `src/switch_ivr_bridge.c`
- `originate_timeout`: `src/switch_ivr_originate.c`
- `leg_timeout`: `src/switch_ivr_originate.c`
- bridge app/dialstring parsing: `src/mod/applications/mod_dptools/mod_dptools.c`

## Dialstring Patterns

- Comma-separated endpoints race simultaneously; first answered/selected leg wins.
- Pipe-separated endpoints try sequentially.
- Enterprise originate uses `:_:`, with each sub-originate evaluated as its own originate.
- `{var=value}` applies to an originate string; `[var=value]` applies to a specific leg.
- In complex routes, set `ringback` deliberately; early media behavior otherwise drives user experience.

## Dynamic Routing

Choose the integration point by blast radius:

- Static XML: stable, small, manually reviewed routes.
- XML-Curl dialplan: app/database-driven route decisions at call time.
- Lua/JavaScript: local procedural logic with bounded dependencies.
- ESL outbound/inbound: external call-control worker, useful for complex workflows.
- HTTAPI: web-driven IVR/call-control markup when web app ownership is desired.

Do not put slow external API calls directly in critical hangup or bridge paths without timeouts and failure logging.

## Interconnecting FreeSWITCH Installations

- Decide whether interconnect is SIP trunk, user registration, gateway, or app-level transfer.
- Normalize caller ID, number format, SIP headers, codecs, and media/NAT assumptions at the boundary.
- Add loop prevention: route labels, max forwards, prefix rules, or custom headers.
- Monitor both signaling and media: SIP status alone is insufficient.
