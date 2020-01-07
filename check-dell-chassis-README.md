# Nagios
Monitoring script for Dell Chassis Hardware Status using SNMP protocol and Chassis Management Controller (CMC).

# Targets
Targets tested:

Dell M1000e and VRTX Chassis;

It might work with other Dell Chassis too. So, feel free to modify it to fit your needs.

## How it works
It pulls through SNMP, the specific Dell OID for device health (IOM, fan, KVM, power supply, STag, temperature, CMC, etc).

## Requirements
SNMP to be working (Dell CMC);

**Note:** This is a linux script tested under openSUSE and Ubuntu distros

Requires **awk**, **tr** and **snmpget** tool. snmpget can be found in:

package=**net-snmp** for openSUSE: ***sudo zypper in net-snmp***

package=**snmp** for Ubuntu:       ***sudo apt-get install snmp***

## Usage
    ./check-dell-chassis.sh -H CMC_HOSTNAME/IP -C 'SNMP_COMMUNITY_STRING'
    
Usage:

check-dell-chassis.sh [options]

-H|--hostname HOSTNAME or IP to pull SNMP from

-C|--community 'SNMP_COMMUNITY_STRING'

-h|--help

-v|--version

## Help
    ./check-dell-chassis.sh -h|--help

## Version
    ./check-dell-chassis.sh -v|--version"

### Sample Output
	OK: Dell Chassis STag=xxxxxxx is Healthy (total issues count = 0) ; Dell Chassis Global Health Status = 3 \ Dell Chassis IOM Health Status = 3 \ Dell Chassis KVM Health Status = 3 \ Dell Chassis RED Health Status = 3 \ Dell Chassis POWER Health Status = 3 \ Dell Chassis FAN Health Status = 3 \ Dell Chassis BLADE Health Status = 3 \ Dell Chassis TEMP Health Status = 3 \ Dell Chassis CMC Health Status = 3 - NOTE: Any value other than 3 means UNHEALTHY
	
	TOTAL_ISSUES = 0
	
	Dell Chassis STag=xxxxxxx
	Dell Chassis Global Health Status = 3
	
	Dell Chassis IOM Health Status = 3
	Dell Chassis KVM Health Status = 3
	Dell Chassis RED Health Status = 3
	Dell Chassis POWER Health Status = 3
	Dell Chassis FAN Health Status = 3
	Dell Chassis BLADE Health Status = 3
	Dell Chassis TEMP Health Status = 3
	Dell Chassis CMC Health Status = 3
	
	Dell Status Legend:
	OTHER (1) - UNKNOWN
	UNKNOWN (2) - UNKNOWN
	OK (3) - UP (GREEN)
	NON-CRITICAL (4) - WARNING
	CRITICAL (5) - CRITICAL
	NON-RECOVERABLE (6) - CRITICAL
	
	NOTE: Any value other than 3 means UNHEALTHY
