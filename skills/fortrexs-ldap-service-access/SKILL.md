---
name: fortrexs-ldap-service-access
description: Use when changing Fortrexs mailbox-user LDAP service grants on mail.fortrexs.eu, especially fortrexsServiceAccess values such as deltachat, sms, nextcloud, wiki, or freeswitch, and when you need to discover the exact DN, build LDIF safely, apply the change through the supported iRedAdmin LDAP bind, and verify the result without committing secrets.
---

# Fortrexs LDAP Service Access

## Overview

This skill handles production-safe service-access changes for live mailbox
users in the Fortrexs LDAP directory on `mail.fortrexs.eu`.

Use it for narrow changes such as:
- granting `fortrexsServiceAccess: deltachat`
- granting `fortrexsServiceAccess: sms`
- checking whether a mailbox already has a given service flag
- confirming the exact mailbox DN before an LDAP modification

Do not use this skill for schema design, password resets, or broad directory
refactors. This one is for precise user-entry changes.

## Workflow

### 1. Confirm the exact mailbox identity

Typos are common and they are dangerous here. If the requested mailbox looks
uncertain, verify the exact address before you touch LDAP.

### 2. Read the live write-capable LDAP bind from iRedAdmin

On this deployment, the supported admin bind is stored in:

- `/opt/www/iredadmin/settings.py`

Read only the keys you need:

```bash
sudo grep -n -E 'ldap_bind_dn|ldap_bind_password' /opt/www/iredadmin/settings.py
```

Treat the password as live production secret material:
- do not commit it
- do not write it into repo docs
- avoid echoing it into chat unless the user explicitly asks

### 3. Find the exact DN before editing

Start with a normal LDAP query:

```bash
ldapsearch -x -D '<bind-dn>' -w '<bind-password>' -H ldap://127.0.0.1:389 -LLL \
  -b 'o=domains,dc=fortrex,dc=eu' \
  '(|(mail=user@example.com)(shadowAddress=user@example.com))' \
  dn mail fortrexsServiceAccess enabledService
```

If the normal search is empty or suspicious, use the host-local fallback that
proved more reliable on this deployment:

```bash
sudo slapcat | sed -n '/^dn: mail=user@example.com,/,/^$/p'
```

### 4. Build the smallest possible LDIF

For additive service access, prefer `add:` against the existing multi-value
attribute:

```ldif
dn: mail=user@example.com,ou=Users,domainName=example.com,o=domains,dc=fortrex,dc=eu
changetype: modify
add: fortrexsServiceAccess
fortrexsServiceAccess: deltachat
```

For multiple users, stack separate LDIF records in one file.

Do not replace the whole `fortrexsServiceAccess` attribute unless the user
explicitly asked for a full rewrite.

### 5. Apply through the iRedAdmin LDAP bind

On this host, `ldapmodify -Y EXTERNAL -H ldapi:///` can still fail with:

```text
ldap_modify: Insufficient access (50)
```

If that happens, use the supported iRedAdmin admin bind instead:

```bash
ldapmodify -x -D '<bind-dn>' -w '<bind-password>' -H ldap://127.0.0.1:389 -f /tmp/change.ldif
```

### 6. Verify immediately after the write

Always verify the exact entries you touched:

```bash
ldapsearch -x -D '<bind-dn>' -w '<bind-password>' -H ldap://127.0.0.1:389 -LLL \
  -b 'o=domains,dc=fortrex,dc=eu' \
  '(|(mail=user1@example.com)(mail=user2@example.com))' \
  dn mail fortrexsServiceAccess
```

### 7. Clean up temporary files

If you copied an LDIF to the host, remove it after verification.

## Guardrails

- Prefer additive changes over destructive ones.
- Never remove existing service flags unless the user explicitly asked for that.
- Verify the mailbox DN before editing.
- Verify the final service flags after editing.
- Do not commit LDAP bind passwords or other secrets.

## Read This Reference

When working against the current production Fortrexs mail host, also read:

- [references/live-mailhost.md](references/live-mailhost.md)
