# Nagios
Monitoring script for Dell Hardware Status using SNMP protocol.

# Targets
Targets tested:

Dell PowerEdge servers of generation 11, 12, 13 and 14 (rackmounts and blades);

It might work with other Dell models too. So, feel free to modify it to fit your needs.

## How it works
It pulls through SNMP, the specific Dell OID for device health (CPU, battery, disk controller, fan, memory, power supply, STag, temperature, VDisks, etc).

## Requirements
SNMP to be working (Dell iDRAC);

**Note:** This is a linux script tested under openSUSE and Ubuntu distros

Requires **awk**, **tr** and **snmpget** tool. snmpget can be found in:

package=**net-snmp** for openSUSE: ***sudo zypper in net-snmp***

package=**snmp** for Ubuntu:       ***sudo apt-get install snmp***

## Usage
    ./check-dell-server.sh -H iDRAC_HOSTNAME/IP -C 'SNMP_COMMUNITY_STRING'
    
Usage:

check-dell-server.sh [options]

-H|--hostname HOSTNAME or IP to pull SNMP from

-C|--community 'SNMP_COMMUNITY_STRING'

-h|--help

-v|--version

## Help
    ./check-dell-server.sh -h|--help

## Version
    ./check-dell-server.sh -v|--version"

### Sample Output
	OK: Dell Server STag=xxxxxxx is Healthy (total issues count = 0) ; Dell iDRAC Model = iDRAC7 \ Dell CPU Health Status = 3 \ Dell Battery Health Status = 3 \ Dell Disk Controller Health Status = Not Present \ Dell FAN Health Status = Not Present \ Dell Memory Health Status = 3 \ Dell Physical Disk Health Status = Not Present \ Dell PowerSupply Health Status = Not Present \ Dell TEMP Health Status = 3 \ Dell vDisk Health Status = Not Present - NOTE: Any value other than 3 means UNHEALTHY

TOTAL_ISSUES = 0

Dell Server STag=xxxxxxx
Dell iDRAC Model = iDRAC7

Dell CPU Health Status = 3
Dell Battery Health Status = 3
Dell Disk Controller Health Status = Not Present
Dell FAN Health Status = Not Present
Dell Memory Health Status = 3
Dell Physical Disk Health Status = Not Present
Dell PowerSupply Health Status = Not Present
Dell TEMP Health Status = 3
Dell vDisk Health Status = Not Present

Dell Status Legend:
OTHER (1) - UNKNOWN
UNKNOWN (2) - UNKNOWN
OK (3) - UP (GREEN)
NON-CRITICAL (4) - WARNING
CRITICAL (5) - CRITICAL
NON-RECOVERABLE (6) - CRITICAL

NOTE: Any value other than 3 means UNHEALTHY
