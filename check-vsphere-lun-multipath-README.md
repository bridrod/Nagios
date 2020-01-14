# Nagios
Monitoring script for checking vSphere ESXi multipathing on multiple disk arrays (EMC, HITACHI, XTREMIO, IBM, DELL) Dell Local Disks and CD-ROM, based on the following path policies:

#DGC = VMW_SATP_CX = VMW_PSP_MRU

#EMC = VMW_SATP_SYMM or VMW_SATP_INV = VMW_PSP_RR

#HITACHI = VMW_SATP_DEFAULT_AA = VMW_PSP_RR

#XtremIO = VMW_SATP_DEFAULT_AA = VMW_PSP_RR

#IBM = VMW_SATP_ALUA = VMW_PSP_RR

#DELL = VMW_SATP_LOCAL = VMW_PSP_FIXED

#DELL VRTX = VMW_SATP_ALUA = VMW_PSP_MRU

#DP = VMW_SATP_LOCAL = VMW_PSP_FIXED

#CD-ROM = VMW_SATP_LOCAL = VMW_PSP_FIXED

# Targets
Targets tested: EMC = CLARiiON, DMX, VMAX, vPLEX, XtremIO; Hitach = VSP (1000, 1500); IBM = DS8870; Dell VRTX (shared disks), Local disks and CD-ROM

It might work with other disk arrays too. So, feel free to modify it to fit your needs.

## How it works
It uses ESXCLI from VMware vSphere Perl SDK.

## Requirements
VMware vSphere Perl SDK. Tested with v5.5.0 through v6.7.0;

**Note:** This is a linux script tested under openSUSE and Ubuntu distros

Requires **grep**, **awk**, **tail**, **cut** and **sed**:

## Usage
    ./check-vsphere-lun-multipath.sh -H|--hostname -u|--username USERNAME -p|--password PASSWORD
    
Usage:

check-vsphere-lun-multipath.sh [options]

-H|--hostname HOSTNAME or IP to pull info from

-h|--help

-v|--version

## Help
    ./check-vsphere-lun-multipath.sh -h|--help

## Version
    ./check-vsphere-lun-multipath.sh -v|--version"

### Sample Output
	OK: All Storage Array Types and Path Selection Policies are correct for all datastores. Total issues count = 0
	OK: All Storage Array Types and Path Selection Policies are correct for all datastores. Total issues count = 0. Issues per device as follows: DGC_TOTAL_ISSUES = 0; EMC_TOTAL_ISSUES = 0; HITACHI_TOTAL_ISSUES = 0; XTREMIO_TOTAL_ISSUES = 0; IBM_TOTAL_ISSUES = 0; IBM_LOCAL_TOTAL_ISSUES = 0; DELL_TOTAL_ISSUES = 0; DP_TOTAL_ISSUES = 0; CDROM_TOTAL_ISSUES = 0
