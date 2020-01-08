
# Nagios
Monitoring script for displaying Dell Model from iDRAC.

# Targets
Targets tested:

Dell PowerEdge servers of generation 11, 12, 13 and 14 (rackmounts and blades);

It might work with other Dell models too. So, feel free to modify it to fit your needs.

## How it works
It pulls info from iDRAC using RACADM tool.

## Requirements
Dell iDRAC configured to accept RACADM calls (Remote RACADM enabled);

**Note:** This is a linux script tested under openSUSE and Ubuntu distros

Requires **grep**, **awk**, **tr** and **sed**:

Requires racadm tool found in "Dell EMC OpenManage Linux Remote Access Utilities, v9.x.x" @Dell's website

## Usage
    ./check-dell-model.sh -H iDRAC_HOSTNAME/IP
    
Usage:

check-dell-model.sh [options]

-H|--hostname iDRAC HOSTNAME or IP to pull info from

-h|--help

-v|--version

## Help
    ./check-dell-model.sh -h|--help

## Version
    ./check-dell-model.sh -v|--version"

### Sample Output
	DELL_MODEL = PowerEdge M620 (short output)
  	DELL_MODEL = PowerEdge M620 (long output)
