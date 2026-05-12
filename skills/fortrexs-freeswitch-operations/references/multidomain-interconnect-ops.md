# Multi-Domain, Multi-Gateway, and Interconnect Operations

## Domain Boundaries

In multi-domain systems, every route should make these explicit:

- SIP profile
- FreeSWITCH context
- domain name
- user directory source
- gateway pool
- caller ID policy
- number normalization policy
- recording/CDR ownership
- app callback target

Avoid routes that depend on global variables when the same host serves multiple tenants/domains.

## Gateway Pools

For each gateway:

- document provider, profile, registration mode, realm/proxy, transport, codecs, auth, caller ID rules, and failover order
- monitor registration and OPTIONS ping state
- track failure causes separately for upstream rejection, local timeout, media/NAT failure, and auth failure
- use per-leg timeouts and route labels

Prefer explicit gateway groups in application data or generated XML rather than hidden dialplan copy/paste.

## Number Normalization

Normalize at ingress:

- strip presentation-only punctuation
- apply country/region rules
- decide E.164 vs local format
- preserve original dialed digits in a variable for audit
- route on normalized number, not raw user input

Normalize again at each provider boundary if the provider expects a different format.

## Codec and Media Optimization

- Inspect what each side actually offers in SDP.
- Avoid unnecessary transcoding in high-volume routes.
- Use codec policy per profile/gateway when provider behavior differs.
- NAT/RTP issues need SIP trace plus RTP/media evidence.
- Do not assume WebRTC/Verto behavior from old books; verify against current modules and browser/app stack.

## Interconnect Safety

- Use explicit route tags/custom headers to prevent loops.
- Bound bridge/originate attempts.
- Decide whether failover should be sequential, simultaneous, or enterprise originate.
- Monitor call outcomes by gateway and cause.
- Keep emergency bypass route documented.
