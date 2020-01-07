#!/bin/bash

### Only tested on openSUSE and Ubuntu distros
### Requires awk, tr
### Requires snmpget tool found in:
### package=net-snmp for openSUSE: sudo zypper in net-snmp
### package=snmp for Ubuntu:       sudo apt-get install snmp

REVISION="Revision 1.0"
REVDATE="01-07-2020"
AUTHOR="bridrod - You might even script, but only Love builds! :)"
PURPOSE="Checks Hardware Status on Dell servers using the iDRAC"
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
    echo "Usage: check-dell-server.sh -H|--hostname iDRAC_HOSTNAME/IP -C|--community 'SNMP_COMMUNITY_STRING'"
    echo "Usage: check-dell-server.sh -h|--help"
    echo "Usage: check-dell-server.sh -v|--version"
}

print_example() {
    echo ""
    echo "# e.g.: ./check-dell-server.sh -H iDRAC_HOSTNAME/IP -C 'SNMP_COMMUNITY_STRING'"
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

cpu_status=""
battery_location=""
battery_status_combined=""
battery_status=""
disk_controller_name=""
disk_controller_status=""
fan_name=""
fan_speed=""
fan_status=""
memory_size=""
memory_status=""
phydisk_name=""
phydisk_status=""
powersupply_status=""
ps_involtage=""
ps_name=""
ps_status=""
server_name=""
server_tag=""
software_version=""
temperature_celsius=""
temperature_name=""
temperature_status=""
virdisk_name=""
virdisk_status=""
idrac_model=""

idrac_model=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.1.1.2.0 | awk '{$1=$2="";print}' | tr -d '". '`

if [[ "$idrac_model" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$idrac_model" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		idrac_model=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.1.1.2.0 | awk '{$1=$2="";print}' | tr -d '". '`
fi
if [[ "$idrac_model" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$server_tag" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		idrac_model=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.300.60.1.8.1.1 | awk '{$1=$2="";print}' | tr -d '". '`
fi

cpu_status=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.200.10.1.50.1 | awk '{$1=$2="";print}' | tr -d '". '`
battery_location=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.600.50.1.7.1 | awk '{$1=$2="";print}' | tr -d '". '`
battery_status_combined=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.200.10.1.52.1 | awk '{$1=$2="";print}' | tr -d '". '`
battery_status=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.600.50.1.5.1 | awk '{$1=$2="";print}' | tr -d '". '`
disk_controller_name=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.5.1.20.130.1.1.2 | awk '{$1=$2="";print}' | tr -d '". '`
disk_controller_status=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.5.1.20.130.1.1.38 | awk '{$1=$2="";print}' | tr -d '". '`
fan_name=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.700.12.1.8.1 | awk '{$1=$2="";print}' | tr -d '". '`
fan_speed=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.700.12.1.6.1 | awk '{$1=$2="";print}' | tr -d '". '`
fan_status_combined=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.200.10.1.21.1 | awk '{$1=$2="";print}' | tr -d '". '`
fan_status=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.700.12.1.5.1 | awk '{$1=$2="";print}' | tr -d '". '`
memory_size=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.1100.50.1.14.1 | awk '{$1=$2="";print}' | tr -d '". '`
memory_status=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.200.10.1.27.1 | awk '{$1=$2="";print}' | tr -d '". '`
phydisk_name=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.55 | awk '{$1=$2="";print}' | tr -d '". '`
phydisk_status=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.24 | awk '{$1=$2="";print}' | tr -d '". '`
ps_involtage=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.600.20.1.6.1 | awk '{$1=$2="";print}' | tr -d '". '`
ps_name=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.600.12.1.15.1 | awk '{$1=$2="";print}' | tr -d '". '`
ps_status_combined=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.200.10.1.9.1 | awk '{$1=$2="";print}' | tr -d '". '`
ps_status=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.600.12.1.11.1 | awk '{$1=$2="";print}' | tr -d '". '`
server_name=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.1.3.12.0 | awk '{$1=$2="";print}' | tr -d '". '`
server_tag=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.2.1.1.11.0 | awk '{$1=$2="";print}' | tr -d '". '`
software_version=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.1.3.6.0 | awk '{$1=$2="";print}' | tr -d '". '`
temperature_Celsius=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.700.20.1.6.1 | awk '{$1=$2="";print}' | tr -d '". '`
temperature_name=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.700.20.1.8.1 | awk '{$1=$2="";print}' | tr -d '". '`
temperature_status_combined=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.200.10.1.24.1 | awk '{$1=$2="";print}' | tr -d '". '`
temperature_status=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.4.700.20.1.5.1 | awk '{$1=$2="";print}' | tr -d '". '`
virdisk_name=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.36 | awk '{$1=$2="";print}' | tr -d '". '`
virdisk_status=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -Ob -OQ $HOSTNAME .1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.20 | awk '{$1=$2="";print}' | tr -d '". '`

let TOTAL_ISSUES=0

if [[ "$cpu_status" != "3" ]] && [[ "$cpu_status" != "NoSuchInstancecurrentlyexistsatthisOID" ]] && [[ "$cpu_status" != "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [[ "$cpu_status" = "3" ]] || [[ "$cpu_status" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$cpu_status" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
fi
if [[ "$cpu_status" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$cpu_status" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
		cpu_status="Not Present"
fi
if [[ "$battery_status_combined" != "3" ]] && [[ "$battery_status_combined" != "NoSuchInstancecurrentlyexistsatthisOID" ]] && [[ "$battery_status_combined" != "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [[ "$battery_status_combined" = "3" ]] || [[ "$battery_status_combined" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$battery_status_combined" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
fi
if [[ "$battery_status_combined" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$battery_status_combined" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
		battery_status_combined="Not Present"
fi
#		echo "cpu_statusTOTAL_ISSUES = $TOTAL_ISSUES"
if [[ "$disk_controller_status" != "3" ]] && [[ "$disk_controller_status" != "NoSuchInstancecurrentlyexistsatthisOID" ]] && [[ "$disk_controller_status" != "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [[ "$disk_controller_status" = "3" ]] || [[ "$disk_controller_status" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$disk_controller_status" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
fi
if [[ "$disk_controller_status" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$disk_controller_status" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
		disk_controller_status="Not Present"
fi
#		echo "cpu_statusTOTAL_ISSUES = $TOTAL_ISSUES"
if [[ "$fan_status_combined" != "3" ]] && [[ "$fan_status_combined" != "NoSuchInstancecurrentlyexistsatthisOID" ]] && [[ "$fan_status_combined" != "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [[ "$fan_status_combined" = "3" ]] || [[ "$fan_status_combined" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$fan_status_combined" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
fi
if [[ "$fan_status_combined" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$fan_status_combined" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
		fan_status_combined="Not Present"
fi
#		echo "cpu_statusTOTAL_ISSUES = $TOTAL_ISSUES"
if [[ "$memory_status" != "3" ]] && [[ "$memory_status" != "NoSuchInstancecurrentlyexistsatthisOID" ]] && [[ "$memory_status" != "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [[ "$memory_status" = "3" ]] || [[ "$memory_status" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$memory_status" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
fi
if [[ "$memory_status" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$memory_status" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
		memory_status="Not Present"
fi
#		echo "cpu_statusTOTAL_ISSUES = $TOTAL_ISSUES"
if [[ "$phydisk_status" != "3" ]] && [[ "$phydisk_status" != "NoSuchInstancecurrentlyexistsatthisOID" ]] && [[ "$phydisk_status" != "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [[ "$phydisk_status" = "3" ]] || [[ "$phydisk_status" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$phydisk_status" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
fi
if [[ "$phydisk_status" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$phydisk_status" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
		phydisk_status="Not Present"
fi
#		echo "cpu_statusTOTAL_ISSUES = $TOTAL_ISSUES"
if [[ "$ps_status_combined" != "3" ]] && [[ "$ps_status_combined" != "NoSuchInstancecurrentlyexistsatthisOID" ]] && [[ "$ps_status_combined" != "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [[ "$ps_status_combined" = "3" ]] || [[ "$ps_status_combined" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$ps_status_combined" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
fi
if [[ "$ps_status_combined" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$ps_status_combined" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
		ps_status_combined="Not Present"
fi
#		echo "cpu_statusTOTAL_ISSUES = $TOTAL_ISSUES"
if [[ "$temperature_status_combined" != "3" ]] && [[ "$temperature_status_combined" != "NoSuchInstancecurrentlyexistsatthisOID" ]] && [[ "$temperature_status_combined" != "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [[ "$temperature_status_combined" = "3" ]] || [[ "$temperature_status_combined" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$temperature_status_combined" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
fi
if [[ "$temperature_status_combined" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$temperature_status_combined" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
		temperature_status_combined="Not Present"
fi

if [[ "$virdisk_status" != "3" ]] && [[ "$virdisk_status" != "NoSuchInstancecurrentlyexistsatthisOID" ]] && [[ "$virdisk_status" != "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
fi
if [[ "$virdisk_status" = "3" ]] || [[ "$virdisk_status" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$virdisk_status" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
fi
if [[ "$virdisk_status" = "NoSuchInstancecurrentlyexistsatthisOID" ]] || [[ "$virdisk_status" = "NoSuchObjectavailableonthisagentatthisOID " ]]; then
		let TOTAL_ISSUES=TOTAL_ISSUES+0
		virdisk_status="Not Present"
fi
#		echo "cpu_statusTOTAL_ISSUES = $TOTAL_ISSUES"

#echo "TOTAL_ISSUES = $TOTAL_ISSUES ; Current Chassis Status=$drsGlobalCurrStatus"
#echo ""
#echo "OTHER (1) - UNKNOWN"
#echo "UNKNOWN (2) - UNKNOWN"
#echo "OK (3) - UP (GREEN)"
#echo "NON-CRITICAL (4) - WARNING"
#echo "CRITICAL (5) - CRITICAL"
#echo "NON-RECOVERABLE (6) - CRITICAL"
#exit

if [[ "$idrac_model" = "iDRAC6" ]] || [[ "$idrac_model" = "DRAC5" ]]; then
                echo "IGNORED: Dell Server STag=$server_tag is TOO OLD to check for Health Status using iDRAC. Oh well... :)"
		echo ""
		echo "TOTAL_ISSUES = IGNORED. Dell Server STag=$server_tag is TOO OLD to check for Health Status using iDRAC. Oh well..."
		echo ""
		echo "Dell Server STag=$server_tag"
		echo "Dell iDRAC Model = $idrac_model"
                exit 0
fi
	if [ "$TOTAL_ISSUES" == "0" ]; then
                echo "OK: Dell Server STag=$server_tag is Healthy (total issues count = $TOTAL_ISSUES) ; Dell iDRAC Model = $idrac_model \ Dell CPU Health Status = $cpu_status \ Dell Battery Health Status = $battery_status_combined \ Dell Disk Controller Health Status = $disk_controller_status \ Dell FAN Health Status = $fan_status_combined \ Dell Memory Health Status = $memory_status \ Dell Physical Disk Health Status = $phydisk_status \ Dell PowerSupply Health Status = $ps_status_combined \ Dell TEMP Health Status = $temperature_status_combined \ Dell vDisk Health Status = $virdisk_status - NOTE: Any value other than 3 means UNHEALTHY"
		echo ""
		echo "TOTAL_ISSUES = $TOTAL_ISSUES"
		echo ""
		echo "Dell Server STag=$server_tag"
		echo "Dell iDRAC Model = $idrac_model"
		echo ""
		echo "Dell CPU Health Status = $cpu_status"
		echo "Dell Battery Health Status = $battery_status_combined"
		echo "Dell Disk Controller Health Status = $disk_controller_status"
		echo "Dell FAN Health Status = $fan_status_combined"
		echo "Dell Memory Health Status = $memory_status"
		echo "Dell Physical Disk Health Status = $phydisk_status"
		echo "Dell PowerSupply Health Status = $ps_status_combined"
		echo "Dell TEMP Health Status = $temperature_status_combined"
		echo "Dell vDisk Health Status = $virdisk_status"
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
                echo "CRITICAL: Dell Server STag=$server_tag is NOT Healthy (total issues count = $TOTAL_ISSUES) ; Dell iDRAC Model = $idrac_model \ Dell CPU Health Status = $cpu_status \ Dell Battery Health Status = $battery_status_combined \ Dell Disk Controller Health Status = $disk_controller_status \ Dell FAN Health Status = $fan_status_combined \ Dell Memory Health Status = $memory_status \ Dell Physical Disk Health Status = $phydisk_status \ Dell PowerSupply Health Status = $ps_status_combined \ Dell TEMP Health Status = $temperature_status_combined \ Dell vDisk Health Status = $virdisk_status - NOTE: Any value other than 3 means UNHEALTHY"
		echo ""
		echo "TOTAL_ISSUES = $TOTAL_ISSUES"
		echo ""
		echo "Dell Server STag=$server_tag"
		echo "Dell iDRAC Model = $idrac_model"
		echo ""
		echo "Dell CPU Health Status = $cpu_status"
		echo "Dell Battery Health Status = $battery_status_combined"
		echo "Dell Disk Controller Health Status = $disk_controller_status"
		echo "Dell FAN Health Status = $fan_status_combined"
		echo "Dell Memory Health Status = $memory_status"
		echo "Dell Physical Disk Health Status = $phydisk_status"
		echo "Dell PowerSupply Health Status = $ps_status_combined"
		echo "Dell TEMP Health Status = $temperature_status_combined"
		echo "Dell vDisk Health Status = $virdisk_status"
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
