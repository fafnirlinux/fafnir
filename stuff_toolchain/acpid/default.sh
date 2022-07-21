#!/bin/sh
#@ Default acpi script that takes an entry for all actions

log() {
	logger -t /etc/acpi/default.sh "${*}"
}

unhandled() {
	t=${1}
	shift
	log "ACPI: no handler for event ${t}, data: ${*}"

}

set ${*}

# In order to not cumulate actions of ACPI event they should be detached via
#	( ACTION ) </dev/null >/dev/null 2>&1 &
# (At least setting volume or other things which depend on hardware which might
# block and cause the script not to return for a while.)
case "${1}" in
button/power)
	case "${2}" in
	PWRF)
		/sbin/init 0;;
	*)
		unhandled "${#}: ${@}";;
	esac
	;;
*)
	unhandled "${#}: $@";;
esac
