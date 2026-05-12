#!/usr/bin/env bash
set -u

out="${1:-/tmp/freeswitch-readonly-audit-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$out"

run() {
  name="$1"
  shift
  {
    printf '$'
    printf ' %q' "$@"
    printf '\n\n'
    "$@" 2>&1
  } >"$out/$name.txt"
}

fsx() {
  name="$1"
  cmd="$2"
  run "$name" fs_cli -x "$cmd"
}

run hostname hostname -f
run date date -Is
run process ps -eo pid,user,group,args
run service-status systemctl status freeswitch --no-pager
run service-unit systemctl cat freeswitch

fsx version "version"
fsx status "status"
fsx show-calls "show calls"
fsx show-channels "show channels"
fsx show-registrations "show registrations"
fsx show-modules "show modules"
fsx sofia-status "sofia status"
fsx module-sofia "module_exists mod_sofia"
fsx module-event-socket "module_exists mod_event_socket"
fsx module-xml-curl "module_exists mod_xml_curl"
fsx module-cdr-csv "module_exists mod_cdr_csv"
fsx module-json-cdr "module_exists mod_json_cdr"

if [ -d /etc/freeswitch ]; then
  run config-files find /etc/freeswitch -maxdepth 5 -type f
  run config-interesting grep -RIn "record_session\|hangup_after_bridge\|bridge_answer_timeout\|originate_timeout\|leg_timeout\|execute_on\|api_on\|gateway\|xml_curl\|event_socket" /etc/freeswitch
fi

printf 'Read-only audit written to %s\n' "$out"
