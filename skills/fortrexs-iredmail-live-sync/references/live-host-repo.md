# Live Host Repo

These notes capture the currently observed live-sync layout for the Fortrexs
mail host config repo.

## Authoritative host-side repo

- `/home/ubuntu/iredmail-deltachat`

Use this as the source of truth when it is reachable.

## Host-side sync helper

- `/home/ubuntu/iredmail-deltachat/tools/sync-from-live.sh`

Current helper scope includes:
- `/etc/postfix`
- `/etc/postfix-deltachat`
- `/etc/opendkim-deltachat`
- `/etc/fortrexs-deltachat`
- `/etc/dovecot`
- `/etc/netplan`
- `/etc/nftables.conf`
- `/etc/amavis`
- nginx site configs
- letsencrypt renewal configs
- `/etc/systemd/system`
- `/usr/local/bin`

## Host-side GitHub SSH path

Observed working remote form:

- `origin github-iredmail-deltachat:mraaaooo/iredmail-deltachat.git`

Observed SSH config entry:

```sshconfig
Host github-iredmail-deltachat
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_github_iredmail_deltachat
  IdentitiesOnly yes
```

Quick auth check:

```bash
ssh -T github-iredmail-deltachat
```

## Common operational wrinkle

If git was run via `sudo`, `.git/FETCH_HEAD` may become `root:root` and block
normal fetch/push. Repair it with:

```bash
sudo chown ubuntu:ubuntu /home/ubuntu/iredmail-deltachat/.git/FETCH_HEAD
```

Then continue as the normal `ubuntu` user.

## Windows fallback mirror

Fallback Windows checkout:

- `C:\Users\mraaaooo\iredmail-deltachat-history`

Treat it as a fallback only. It is not the preferred sync source when the
host-side repo is healthy.

## Commit hygiene on this host

Common items to review carefully before staging:
- `*.bak*`
- temporary rawlog or debug config files
- ad hoc uploaded snippets
- compiled helper binaries in `usr/local/bin`

Prefer `git add -u` first, then add only the intentional new files.
