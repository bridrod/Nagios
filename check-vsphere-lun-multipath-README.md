# Nagios
Monitoring script for checking vSphere ESXi multipathing on multiple disk arrays (EMC, HITACHI, XTREMIO, IBM, DELL) Dell Local Disks and CD-ROM

# Targets
Targets tested: CLARiiON, VNX, DMX, VSP, 

It might work with other disk arrays too. So, feel free to modify it to fit your needs.

## How it works
It pulls info from iDRAC using RACADM tool.

## Requirements
Dell iDRAC configured to accept RACADM calls (Remote RACADM enabled);

**Note:** This is a linux script tested under openSUSE and Ubuntu distros

Requires **grep**, **awk**, **tr** and **sed**:

Requires racadm tool found in "Dell EMC OpenManage Linux Remote Access Utilities, v9.x.x" @Dell's website

## Usage
    ./check-dell-hw-idrac.sh -H iDRAC_HOSTNAME/IP
    
Usage:

check-dell-hw-idrac.sh [options]

-H|--hostname iDRAC HOSTNAME or IP to pull info from

-h|--help

-v|--version

## Help
    ./check-dell-hw-idrac.sh -h|--help

## Version
    ./check-dell-hw-idrac.sh -v|--version"

### Sample Output
	OS_NAME = VMware ESXi 6.5.0 build-8935087 \\ OS_VERSION = 6.5.0 Update 2 Patch 54 (build-8935087) Kernel 6.5.0 (x86_64) \\ SERVER = xxxxxxxxxx.domain \\ DELL_MODEL = PowerEdge M620 \\ STAG = xxxxxxx \\ BIOS_FIRM_VERSION = 2.7.0 \\ DRAC_VERSION = Dell Remote Access Controller \\ DRAC_FIRM_VERSION = 2.63.60.62
	
	OS_NAME = VMware ESXi 6.5.0 build-8935087
	OS_VERSION = 6.5.0 Update 2 Patch 54 (build-8935087) Kernel 6.5.0 (x86_64)
	SERVER = xxxxxxxxxx.domain
	DELL_MODEL = PowerEdge M620
	STAG = xxxxxxx
	BIOS_FIRM_VERSION = 2.7.0
	DRAC_TYPE = IDRACTYPE=17
	DRAC_VERSION = Dell Remote Access Controller
	DRAC_FIRM_VERSION = 2.63.60.62
	DRAC_BUILD = 01
	DRAC_NAME = iDRAC-xxxxxxxxxx
