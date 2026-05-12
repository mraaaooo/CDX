# Installation and Live Inspection

## Installation Policy

- For new installs, check current official docs and repositories first. The books predate Debian 12 and modern packaging changes.
- Prefer OS packages for production unless there is a specific module/source patch requirement.
- Record installation provenance: package repo, package versions, source tag if compiled, module list, service unit, runtime user, and directory layout.
- Keep custom config in version control, but never put secrets, SIP passwords, or recording data in Git.

## Baseline Layout to Inspect

Common paths differ by package/build. Check all of these before assuming:

- Config: `/etc/freeswitch`
- Logs: `/var/log/freeswitch`
- Runtime/db: `/var/lib/freeswitch`, `/run/freeswitch`, `/usr/share/freeswitch`
- Recordings: `$${recordings_dir}`, often `/var/lib/freeswitch/recordings`
- Scripts: `/usr/share/freeswitch/scripts`, `/etc/freeswitch/scripts`, or local custom paths
- Modules: package module directory or build prefix module directory

The FreeSWITCH binary supports alternate directories such as `-conf`, `-log`, `-db`, `-mod`, `-scripts`, `-recordings`, and `-storage`; verify process arguments and systemd unit.

## Read-Only Host Audit

Use `fs_collect_readonly.sh` or manually collect:

```bash
hostname -f
date -Is
systemctl status freeswitch --no-pager
systemctl cat freeswitch
ps -eo pid,user,group,args | grep '[f]reeswitch'
fs_cli -x 'version'
fs_cli -x 'status'
fs_cli -x 'show calls'
fs_cli -x 'show channels'
fs_cli -x 'show registrations'
fs_cli -x 'sofia status'
fs_cli -x 'show modules'
```

Then inspect config/includes:

```bash
find /etc/freeswitch -maxdepth 5 -type f | sort
grep -RIn '<X-PRE-PROCESS\|include\|profile name\|gateway name\|record_session\|execute_on\|api_on\|hangup_after_bridge' /etc/freeswitch
```

## Safety Checks Before Change

- Take timestamped backups of edited files only.
- Validate XML with `xmllint --noout` or equivalent before `reloadxml`.
- If a change touches Sofia profile XML, decide whether `reloadxml`, `sofia profile <name> rescan`, `sofia profile <name> restart`, or gateway-level action is required.
- Verify after change with `fs_cli -x 'status'`, `fs_cli -x 'show calls'`, `fs_cli -x 'sofia status'`, and gateway-specific status.

## Commit/Config Hygiene

- Separate live emergency patches from repo reconciliation.
- Capture exact live diff before changing.
- Do not normalize unrelated line endings/includes during production fixes.
- Prefer one narrow operational change per reload.
