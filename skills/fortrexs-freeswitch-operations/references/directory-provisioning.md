# Directory, Domains, Address Books, and Provisioning

## Directory Model

FreeSWITCH directory XML connects users, domains, groups, variables, params, voicemail, registration, presence, and dialstrings. For multi-domain deployments, keep the domain boundary explicit everywhere:

- domain name
- user id
- context
- groups
- gateway/profile selection
- presence and message waiting behavior
- app/customer ownership

## Source of Truth

For Fortrexs systems, avoid hand-maintained duplicate user state. Prefer one canonical source:

- LDAP when mailbox/service access controls already live there.
- Dotochki/CRM database when call-center and user ownership live there.
- Generated static XML only for small stable subsets.
- XML-Curl when users, groups, permissions, or devices are dynamic.

## Directory Inspection

```bash
fs_cli -x 'user_data <user>@<domain> var effective_caller_id_number'
fs_cli -x 'user_data <user>@<domain> param password'
fs_cli -x 'group_call <group>@<domain>'
fs_cli -x 'show registrations'
```

Never print passwords or auth hashes in final reports.

## Address Books

Treat address books as application data, not native FreeSWITCH truth, unless a deployment explicitly maps them into directory/group routing.

Recommended pattern:

- App/LDAP/CRM stores contacts and ownership.
- FreeSWITCH receives only the route-time data it needs: caller, destination, domain, user/contact reachability, and policy flags.
- Maintain a lookup/audit path from FreeSWITCH UUID to app call/contact records.

## Device Provisioning

FreeSWITCH can supply the telephony side, but phone provisioning should be its own managed pipeline:

- generate vendor-specific config from canonical user/device records
- push SIP credentials securely
- configure proxy/domain, transport, codec policy, BLF/presence, voicemail, MWI, and feature keys
- rotate credentials deliberately
- verify endpoint registration after provisioning

Keep provisioning templates separate from FreeSWITCH runtime XML unless the same files are intentionally served to phones.

## Mobile Users

Mobile call delivery usually needs two independent flows:

- SIP/WebRTC/forwarding route that determines how FreeSWITCH reaches the user.
- Push notification from the app backend so the mobile app wakes and prepares for the call.

Do not make call setup depend indefinitely on push delivery. Use bounded waits, fallback routes, and event logging.
