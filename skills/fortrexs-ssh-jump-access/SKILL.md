---
name: fortrexs-ssh-jump-access
description: Use when provisioning or repairing dedicated Fortrexs SSH jump access across multiple EC2 hosts through mail.fortrexs.eu, especially when you need a separate fleet key, source-restricted authorized_keys entries, ProxyJump aliases, and a documented host-to-alias map for cdx2-style headless ops.
---

# Fortrexs SSH Jump Access

## Overview

This skill handles the Fortrexs pattern where a dedicated ops user such as
`cdx2` should reach multiple EC2 hosts through `mail.fortrexs.eu` instead of
connecting directly with older bootstrap users.

Use it when:
- a separate fleet SSH key should be created for jump access
- the target hosts should accept that key only from the mail host's private or
  public source IP, depending on the route
- the target user should get passwordless `sudo` for headless ops
- local SSH aliases should route through `mail-cdx` with `ProxyJump`
- one or more hosts still need bootstrap-user discovery and should be called out
  honestly

Do not use this skill for a single standalone server unless the jump-host
pattern is explicitly part of the request. For one host, prefer
`fortrexs-headless-ops-user`.

## Workflow

### 1. Confirm the jump source first

Before touching target hosts, verify which address the target will actually see
from `mail.fortrexs.eu`.

Current live pattern:
- jump alias: `mail-cdx`
- observed private source IP: `10.10.0.191`
- observed public A record:
  - `3.126.131.133`

Use the `authorized_keys` restriction that matches the route:
- private target path:
  - `from="10.10.0.191"`
- public target path:
  - `from="3.126.131.133"`

### 2. Use a dedicated fleet key

Do not reuse the broad admin bootstrap key for day-to-day fleet ops if a
separate `cdx2`-style key can be introduced.

Current live pattern on this workstation:
- private key:
  - `C:\Users\mraaaooo\.ssh\cdx2_fortrexs_jump_ed25519`
- public key:
  - `C:\Users\mraaaooo\.ssh\cdx2_fortrexs_jump_ed25519.pub`

### 3. Provision the target user on each reachable host

For each confirmed host:
- create or repair the user (`cdx2`)
- ensure `/bin/bash`
- create:
  - `~/.ssh`
  - `~/bin`
  - `~/work`
  - `~/runbooks`
  - `~/snapshots`
- write one restricted key line into `authorized_keys`
- grant:

```sudoers
cdx2 ALL=(ALL) NOPASSWD: ALL
```

The current live provisioning script for this pattern is:
- `scripts/provision_cdx2_jump_hosts.ps1`

### 4. Route aliases to the address that matches the chosen jump path

For internal VPC targets:
- local client connects to the target's private IP
- `ProxyJump mail-cdx`
- target host sees the source as the mail host's private IP

That is what makes the `from="10.10.0.191"` restriction useful.

For external targets:
- local client connects to the target's public IP or public FQDN
- `ProxyJump mail-cdx`
- target host sees the source as the mail host's public IP

That is what makes the `from="3.126.131.133"` restriction useful.

Add aliases in:
- `C:\Users\mraaaooo\.ssh\config`
- `C:\Users\mraaaooo\.codex\tmp\ssh\config`

Each alias should set:
- `User cdx2`
- `HostName <private-ip-or-public-ip>`
- `ProxyJump mail-cdx`
- `IdentityFile C:/Users/mraaaooo/.ssh/cdx2_fortrexs_jump_ed25519`
- `IdentitiesOnly yes`

### 5. Verify both the config and the path

First verify alias expansion locally:

```bash
ssh -G -F C:\Users\mraaaooo\.codex\tmp\ssh\config files-cdx2
```

Then verify live login and sudo when command approval allows:

```bash
ssh -F C:\Users\mraaaooo\.codex\tmp\ssh\config files-cdx2 whoami
ssh -F C:\Users\mraaaooo\.codex\tmp\ssh\config files-cdx2 sudo -n whoami
```

### 6. Keep blocked hosts explicit

If one host still lacks a working bootstrap user or key:
- do not fake completion
- keep it out of the installed alias set if access is unverified
- document the best current human name for communication anyway

## Guardrails

- Use a separate fleet key for jump access instead of leaving everything on the
  original bootstrap key forever.
- Prefer `authorized_keys` source restriction over undocumented tribal
  assumptions about where access "should" come from.
- Route aliases to private IPs for internal targets and public IPs for external
  targets, matching the `from=` source restriction you actually installed.
- Do not claim a target is ready until the bootstrap path or the jump path has
  been verified.

## Read These References

- [references/current-fleet-map.md](references/current-fleet-map.md)
- [scripts/provision_cdx2_jump_hosts.ps1](scripts/provision_cdx2_jump_hosts.ps1)
