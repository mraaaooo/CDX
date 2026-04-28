---
name: fortrexs-iredmail-live-sync
description: Use when syncing the live mail.fortrexs.eu iRedMail and Delta Chat configuration from the authoritative on-host repo to GitHub, especially by using the host-local tools/sync-from-live.sh workflow, verifying SSH-based git auth, staging only the intended live config drift, pushing a review branch, and cleaning obsolete stopgap branches without relying on the Windows mirror.
---

# Fortrexs iRedMail Live Sync

## Overview

This skill handles the production-safe sync of the live mail host config into
the Fortrexs `iredmail-deltachat` GitHub repo.

Use it when:
- the live host config changed and GitHub needs the current state
- the proper source of truth is the on-host repo, not the Windows mirror
- `tools/sync-from-live.sh` should refresh the repo from `/etc/*`
- git auth on the host needs to be verified or repaired
- a temporary branch created from the Windows checkout should be cleaned up

Do not use this skill for broad package upgrades or arbitrary mail-host edits.
This one is for syncing and publishing the already-existing live config.

## Workflow

### 1. Prefer the on-host repo as the source of truth

On this deployment, the authoritative repo lives on the mail host.

If that repo is available, use it instead of the Windows mirror. The Windows
checkout is a fallback and can be awkward when remote history contains
Windows-hostile paths or other drift.

### 2. Verify SSH-based git auth before syncing

Check the host-side remote and SSH access first:

```bash
cd /home/ubuntu/iredmail-deltachat
git remote -v
ssh -T github-iredmail-deltachat
```

If the repo still points at HTTPS, switch it to the SSH alias path described in
the reference file before you try to fetch or push.

### 3. Avoid sudo git and fix ownership wrinkles if needed

Run git as the normal repo owner, not through `sudo`.

If a previous sudo run left git metadata owned by `root`, repair the affected
paths before continuing. A common case on this host is:

```bash
sudo chown ubuntu:ubuntu /home/ubuntu/iredmail-deltachat/.git/FETCH_HEAD
```

### 4. Run the live sync helper

From the host-side repo:

```bash
bash tools/sync-from-live.sh
```

That helper is the supported path for copying the live config into the repo
tree.

### 5. Review and stage surgically

Inspect the result before committing:

```bash
git status --short
git diff --stat
```

Prefer:
- `git add -u` for tracked live-config drift
- explicit `git add <path>` for intentional new files

Do not sweep in backup files, one-off debug files, or unrelated binaries unless
the user explicitly wants them versioned.

### 6. Commit on a focused branch

If `main` is ahead/behind or otherwise not ready for a direct push, create a
fresh review branch:

```bash
git switch -c codex/<topic>-YYYYMMDD
git commit -m "Sync live config from mail host"
```

### 7. Push from the on-host repo

Push the review branch from the host-side repo:

```bash
git push -u origin codex/<topic>-YYYYMMDD
```

If there is an older stopgap branch from the Windows mirror, delete it only
after the proper host-side push succeeds.

### 8. Report what was synced and what was left out

Always say:
- which repo and branch were used
- which high-signal files changed
- whether any untracked backup or debug files were intentionally skipped
- whether any temporary fallback branch was deleted

## Guardrails

- Prefer `/home/ubuntu/iredmail-deltachat` over the Windows mirror.
- Verify SSH auth before trying to push.
- Do not run git through `sudo`.
- Stage only intended config files.
- Keep backup and debug artifacts out of commits unless explicitly requested.
- Clean obsolete stopgap branches only after the proper host-side push works.

## Read This Reference

For the current Fortrexs environment, also read:

- [references/live-host-repo.md](references/live-host-repo.md)
