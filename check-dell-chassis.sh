#!/bin/bash

### Only tested on openSUSE and Ubuntu distros
### Requires awk, tr
### Requires snmpget tool found in:
### package=net-snmp for openSUSE: sudo zypper in net-snmp
### package=snmp for Ubuntu:       sudo apt-get install snmp

REVISION="Revision 1.0"
REVDATE="01-07-2020"
AUTHOR="bridrod - You might even script, but only Love builds! :)"
PURPOSE="Checks Hardware Status on Dell chassis using the Chassis Management Controller (CMC)"
LICENSE="Distributed under GNU General Public License (GPL) v3.0 - http://www.fsf.org/licenses/gpl.txt"

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2

print_revision() {
    echo ""
    echo "$REVISION - $REVDATE - by $AUTHOR"
    echo "$LICENSE"
    echo ""
}

print_usage() {
    echo "Usage: check-dell-chassis.sh -H|--hostname CMC_HOSTNAME/IP -C|--community 'SNMP_COMMUNITY_STRING'"
    echo "Usage: check-dell-chassis.sh -h|--help"
    echo "Usage: check-dell-chassis.sh -v|--version"
}

print_example() {
    echo ""
    echo "# e.g.: ./check-dell-chassis.sh -H CMC_HOSTNAME/IP -C 'SNMP_COMMUNITY_STRING'"
}

print_help() {
    print_revision
    echo ""
    echo "$PURPOSE"
    echo ""
    print_usage
    echo ""
}

### Make sure the correct number of command line arguments have been supplied (each space will count as a parameter)
if [ $# -lt 4 ]; then
        print_usage
        print_example
		print_revision
        exit 3
fi


exitstatus=$STATE_WARNING #default
while test -n "$1"; do
        case "$1" in
        --help)
                print_help
                exit $STATE_OK
                ;;
        -h)
                print_help
                exit $STATE_OK
                ;;
        --version)
                print_revision $PROGNAME $VERSION
                exit $STATE_OK
                ;;
        -v)
                print_revision $PROGNAME $VERSION
                exit $STATE_OK
                ;;
        -H)
                HOSTNAME=$2
                shift
                ;;
        --hostname)
                HOSTNAME=$2
                shift
                ;;
         -C)
                COMMUNITY=$2
                shift
                ;;
        --community)
                COMMUNITY=$2
                shift
                ;;
        *)
                print_usage
                print_example
                exit $STATE_UNKNOWN
                ;;
        esac
        shift
done

ChassisTag=""
drsGlobalCurrStatus=""
drsIOMCurrStatus=""
drsKVMCurrStatus=""
drsRedCurrStatus=""
drsPowerCurrStatus=""
drsFanCurrStatus=""
drsBladeCurrStatus=""
drsTempCurrStatus=""
drsCMCCurrStatus=""

ChassisTag=`snmpget -v2c -c '$COMMUNITY' -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.1.1.6.0 -t 45 | awk '{$1=$2="";print}' | tr -d \'\"\.\ \'`
drsGlobalCurrStatus=`snmpget -v2c -c '$COMMUNITY' -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.3.1.1.0 -t 45 | awk '{$1=$2="";print}' | tr -d \'\"\.\ \'`
drsIOMCurrStatus=`snmpget -v2c -c '$COMMUNITY' -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.3.1.2.0 -t 45 | awk '{$1=$2="";print}' | tr -d \'\"\.\ \'`
drsKVMCurrStatus=`snmpget -v2c -c '$COMMUNITY' -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.3.1.3.0 -t 45 | awk '{$1=$2="";print}' | tr -d \'\"\.\ \'`
drsRedCurrStatus=`snmpget -v2c -c '$COMMUNITY' -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.3.1.4.0 -t 45 | awk '{$1=$2="";print}' | tr -d \'\"\.\ \'`
drsPowerCurrStatus=`snmpget -v2c -c '$COMMUNITY' -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.3.1.5.0 -t 45 | awk '{$1=$2="";print}' | tr -d \'\"\.\ \'`
drsFanCurrStatus=`snmpget -v2c -c '$COMMUNITY' -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.3.1.6.0 -t 45 | awk '{$1=$2="";print}' | tr -d \'\"\.\ \'`
drsBladeCurrStatus=`snmpget -v2c -c '$COMMUNITY' -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.3.1.7.0 -t 45 | awk '{$1=$2="";print}' | tr -d \'\"\.\ \'`
drsTempCurrStatus=`snmpget -v2c -c '$COMMUNITY' -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.3.1.8.0 -t 45 | awk '{$1=$2="";print}' | tr -d \'\"\.\ \'`
drsCMCCurrStatus=`snmpget -v2c -c '$COMMUNITY' -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.3.1.9.0 -t 45 | awk '{$1=$2="";print}' | tr -d \'\"\.\ \'`

let TOTAL_ISSUES=0
if [ "$drsIOMCurrStatus" != "3" ]; then
        let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [ "$drsKVMCurrStatus" != "3" ]; then
        let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [ "$drsRedCurrStatus" != "3" ]; then
        let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [ "$drsPowerCurrStatus" != "3" ]; then
        let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [ "$drsFanCurrStatus" != "3" ]; then
        let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [ "$drsBladeCurrStatus" != "3" ]; then
        let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [ "$drsTempCurrStatus" != "3" ]; then
        let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [ "$drsCMCCurrStatus" != "3" ]; then
        let TOTAL_ISSUES=TOTAL_ISSUES+1
fi

#echo "TOTAL_ISSUES = $TOTAL_ISSUES ; Current Chassis Status=$drsGlobalCurrStatus"
#echo ""
#echo "OTHER (1) - UNKNOWN"
#echo "UNKNOWN (2) - UNKNOWN"
#echo "OK (3) - UP (GREEN)"
#echo "NON-CRITICAL (4) - WARNING"
#echo "CRITICAL (5) - CRITICAL"
#echo "NON-RECOVERABLE (6) - CRITICAL"
#exit

	if [ "$TOTAL_ISSUES" == "0" ]; then
                echo "OK: Dell Chassis STag=$ChassisTag is Healthy (total issues count = $TOTAL_ISSUES) ; Dell Chassis Global Health Status = $drsGlobalCurrStatus \ Dell Chassis IOM Health Status = $drsIOMCurrStatus \ Dell Chassis KVM Health Status = $drsKVMCurrStatus \ Dell Chassis RED Health Status = $drsRedCurrStatus \ Dell Chassis POWER Health Status = $drsPowerCurrStatus \ Dell Chassis FAN Health Status = $drsFanCurrStatus \ Dell Chassis BLADE Health Status = $drsBladeCurrStatus \ Dell Chassis TEMP Health Status = $drsTempCurrStatus \ Dell Chassis CMC Health Status = $drsCMCCurrStatus - NOTE: Any value other than 3 means UNHEALTHY"
		echo ""
		echo "TOTAL_ISSUES = $TOTAL_ISSUES"
		echo ""
		echo "Dell Chassis STag=$ChassisTag"
		echo "Dell Chassis Global Health Status = $drsGlobalCurrStatus"
		echo ""
		echo "Dell Chassis IOM Health Status = $drsIOMCurrStatus"
		echo "Dell Chassis KVM Health Status = $drsKVMCurrStatus"
		echo "Dell Chassis RED Health Status = $drsRedCurrStatus"
		echo "Dell Chassis POWER Health Status = $drsPowerCurrStatus"
		echo "Dell Chassis FAN Health Status = $drsFanCurrStatus"
		echo "Dell Chassis BLADE Health Status = $drsBladeCurrStatus"
		echo "Dell Chassis TEMP Health Status = $drsTempCurrStatus"
		echo "Dell Chassis CMC Health Status = $drsCMCCurrStatus"
		echo ""
		echo "Dell Status Legend:"
		echo "OTHER (1) - UNKNOWN"
		echo "UNKNOWN (2) - UNKNOWN"
		echo "OK (3) - UP (GREEN)"
		echo "NON-CRITICAL (4) - WARNING"
		echo "CRITICAL (5) - CRITICAL"
		echo "NON-RECOVERABLE (6) - CRITICAL"
		echo ""
		echo "NOTE: Any value other than 3 means UNHEALTHY"
                exit 0

	fi
        if [ "$TOTAL_ISSUES" -gt "0" ]; then
                echo "CRITICAL: Dell Chassis STag=$ChassisTag is NOT Healthy (total issues count = $TOTAL_ISSUES) ; Dell Chassis Global Health Status = $drsGlobalCurrStatus \ Dell Chassis IOM Health Status = $drsIOMCurrStatus \ Dell Chassis KVM Health Status = $drsKVMCurrStatus \ Dell Chassis RED Health Status = $drsRedCurrStatus \ Dell Chassis POWER Health Status = $drsPowerCurrStatus \ Dell Chassis FAN Health Status = $drsFanCurrStatus \ Dell Chassis BLADE Health Status = $drsBladeCurrStatus \ Dell Chassis TEMP Health Status = $drsTempCurrStatus \ Dell Chassis CMC Health Status = $drsCMCCurrStatus - NOTE: Any value other than 3 means UNHEALTHY"
		echo ""
		echo "TOTAL_ISSUES = $TOTAL_ISSUES"
		echo ""
		echo "Dell Chassis STag=$ChassisTag"
		echo "Dell Chassis Global Health Status = $drsGlobalCurrStatus"
		echo ""
		echo "Dell Chassis IOM Health Status = $drsIOMCurrStatus"
		echo "Dell Chassis KVM Health Status = $drsKVMCurrStatus"
		echo "Dell Chassis RED Health Status = $drsRedCurrStatus"
		echo "Dell Chassis POWER Health Status = $drsPowerCurrStatus"
		echo "Dell Chassis FAN Health Status = $drsFanCurrStatus"
		echo "Dell Chassis BLADE Health Status = $drsBladeCurrStatus"
		echo "Dell Chassis TEMP Health Status = $drsTempCurrStatus"
		echo "Dell Chassis CMC Health Status = $drsCMCCurrStatus"
		echo ""
		echo "Dell Status Legend:"
		echo "OTHER (1) - UNKNOWN"
		echo "UNKNOWN (2) - UNKNOWN"
		echo "OK (3) - UP (GREEN)"
		echo "NON-CRITICAL (4) - WARNING"
		echo "CRITICAL (5) - CRITICAL"
		echo "NON-RECOVERABLE (6) - CRITICAL"
		echo ""
		echo "NOTE: Any value other than 3 means UNHEALTHY"
		exit 2
	fi
