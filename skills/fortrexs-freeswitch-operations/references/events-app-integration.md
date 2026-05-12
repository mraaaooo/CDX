# Events and App Integration

## Integration Choices

- ESL inbound: external controller connects to FreeSWITCH event socket and issues commands.
- ESL outbound: FreeSWITCH connects a call to an external controller for per-call logic.
- XML-Curl: FreeSWITCH asks a web app for config, dialplan, directory, or phrases.
- HTTAPI: web app returns call-control markup.
- Web callbacks from dialplan/hangup hooks: simple, but must be bounded and observable.
- CDR HTTP modules: useful for reporting, not usually for real-time call control.

## Event Socket

For v1.10.12, event socket config parsing is in:

- `src/mod/event_handlers/mod_event_socket/mod_event_socket.c`

Default behavior from source includes localhost listener defaults if config is absent. Always inspect live `event_socket.conf.xml`; do not rely on defaults.

Security rules:

- Bind to localhost unless remote access is deliberately required.
- Use ACLs.
- Rotate the default password.
- Do not expose 8021 publicly.
- Log and monitor controller disconnects.

## XML-Curl

For v1.10.12, binding parsing is in:

- `src/mod/xml_int/mod_xml_curl/mod_xml_curl.c`

Important controls to verify in live config/source:

- `gateway-url`
- `bindings`
- `gateway-credentials`
- `auth-scheme`
- `method`
- `timeout`
- SSL CA/host verification settings
- response size limit
- selected post variables

Use XML-Curl for dynamic directory/dialplan only when the web service is reliable and has clear fallback behavior.

## App Callbacks

When using dialplan callbacks such as start/answer/finish:

- include UUID, direction, domain/profile, caller, callee, gateway, hangup cause, timestamps, and recording path when applicable
- enforce a short timeout
- make callback idempotent
- log callback result with enough data to correlate against `uuid_dump`
- do not block call teardown on a slow app response

## Mobile Notifications

For calls aimed at mobile users:

- FreeSWITCH event/callback tells the app backend about a candidate inbound call.
- App backend sends FCM/APNs/Delta Chat notification as appropriate.
- FreeSWITCH route uses bounded waiting or parallel fallback.
- App registration tokens and SIP/WebRTC registrations are separate health signals.

The call should still have a deterministic outcome if push notification fails.
