---
name: fortrexs-headless-ops-user
description: Use when provisioning or repairing a dedicated Fortrexs SSH user for Codex-style headless server operations, especially when you need to create the user, install authorized_keys, grant sudo deliberately, create a stable working home layout, verify direct login and passwordless sudo, and document the result without losing the exact live pattern.
---

# Fortrexs Headless Ops User

## Overview

This skill handles the setup of a dedicated Linux SSH user for Codex-style
headless work on a Fortrexs server.

Use it when:
- a host should stop relying on a generic bootstrap user such as `ubuntu`
- you want a dedicated account like `cdx`
- the same accepted SSH key should be reused for the new account
- a stable home layout is needed for scripts, notes, snapshots, or long-running
  maintenance work
- the sudo policy should be created and verified along with direct SSH login
- a local SSH alias should be added so the daily login path is short and stable

Do not use this skill for generic Linux user administration at large scale.
This one is for deliberate, host-by-host provisioning of a dedicated ops user.

## Workflow

### 1. Pick the username explicitly

Do not improvise the login name. Confirm it first.

Current live preference on `mail.fortrexs.eu`:
- `cdx`

### 2. Reuse a known-good SSH key path when possible

If the current bootstrap user already accepts the right key, prefer copying its
`authorized_keys` file to the new account instead of introducing a new key at
the same time.

Current working pattern:
- source user: `ubuntu`
- source file: `/home/ubuntu/.ssh/authorized_keys`

### 3. Create the user and a small working home layout

Provision the user with a normal shell and create:
- `~/.ssh`
- `~/bin`
- `~/work`
- `~/runbooks`
- `~/snapshots`

### 4. Grant sudo deliberately

For first-pass headless operations on a single admin-owned host, reliability may
matter more than perfect least-privilege.

Current live first-pass pattern on `mail.fortrexs.eu`:

```sudoers
cdx ALL=(ALL) NOPASSWD: ALL
```

If the user explicitly wants tighter scoping, narrow it in a follow-up pass
after the recurring command set is better understood.

### 5. Verify with real login, not just file existence

Always test both:

```bash
ssh ... cdx@host whoami
ssh ... cdx@host sudo whoami
```

The target state is:
- direct login returns the user name
- `sudo whoami` returns `root` without a password prompt

### 6. Document the host-side change

Record:
- which host was changed
- which username was created
- where the key came from
- what sudo policy was granted
- how login and sudo were verified

### 7. Add a local SSH alias for the new path

If the same workstation will connect to the host regularly, add a local SSH
config alias so the day-to-day command is short and memorable.

Current live example on this workstation:

```sshconfig
Host mail-cdx
    HostName mail.fortrexs.eu
    User cdx
    IdentityFile C:\Users\mraaaooo\.ssh\mraaaooo.pem
    IdentitiesOnly yes
```

Then verify:

```bash
ssh mail-cdx whoami
ssh mail-cdx sudo whoami
```

If you are testing from a sandboxed Codex desktop context, the active process
may not use the same HOME directory as the human workstation user. In that
case, verify with the explicit config path:

```bash
ssh -F C:\Users\mraaaooo\.ssh\config mail-cdx whoami
ssh -F C:\Users\mraaaooo\.ssh\config mail-cdx sudo whoami
```

If `ssh -G -F ... mail-cdx` resolves the alias correctly but the connect still
fails, that points more to local sandbox/network policy than to a bad alias.

### 8. Keep the rollout reusable

If this pattern is intended to recur:
- save the skill in the working repo
- mirror it to the shared repo if requested
- install the local `.codex` copy
- update the wiki skills page

## Guardrails

- Prefer copying a proven `authorized_keys` set over inventing a new key in the
  same change.
- Verify live SSH and live sudo after provisioning.
- Prefer creating a local SSH alias once the dedicated user works.
- Be explicit when the sudo policy is intentionally broad.
- Document the host-specific username and layout so the pattern is repeatable.

## Read These References

- [references/live-pattern.md](references/live-pattern.md)
- [scripts/provision_headless_ops_user.sh](scripts/provision_headless_ops_user.sh)
