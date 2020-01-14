#!/bin/bash

### Only tested on openSUSE and Ubuntu distros
### Requires grep, tail, awk, cut, sed
### Requires VMware vSphere Perl SDK

REVISION="Revision 1.0"
REVDATE="01-14-2020"
AUTHOR="bridrod - You might even script, but only Love builds! :)"
PURPOSE="Checks Multipathing on vSphere ESXi hosts for these disk Arrays (EMC, HITACHI, XTREMIO, IBM, DELL), Dell Local Disks (including VRTX shared disks) and CD-ROM"
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
    echo "Usage: check-vsphere-lun-multipath.sh -H|--hostname -u|--username USERNAME -p|--password PASSWORD"
    echo "Usage: check-vsphere-lun-multipath.sh -h|--help"
    echo "Usage: check-vsphere-lun-multipath.sh -v|--version"
}

print_example() {
    echo ""
    echo "# e.g.: ./check-vsphere-lun-multipath.sh -H HOSTNAME -u USERNAME -p PASSWORD"
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
if [ $# -lt 6 ]; then
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
        -u)
                USERNAME=$2
                shift
                ;;
        --username)
                USERNAME=$2
                shift
                ;;
        -p)
                PASSWORD=$2
                shift
                ;;
        --password)
                PASSWORD=$2
                shift
                ;;
	*)
                echo "Unknown argument: $1"
                print_usage
                print_example
                exit $STATE_UNKNOWN
                ;;
        esac
        shift
done

old_IFS=$IFS      # save the field separator           
IFS=$'\n'     # new field separator, the end of line

VSPHERE_VERSION=`esxcli --server $HOSTNAME --username $USERNAME --password $PASSWORD system version get | grep Version | cut -f2 -d ':' | sed -e 's/ //g'`

	if [[ $VSPHERE_VERSION = "4.1.0" ]]
	then
#		echo "It's v4.1!"
		esxcli --server $HOSTNAME --username $USERNAME --password $PASSWORD nmp device list >/tmp/$HOSTNAME-vsphere_storage_multipath.txt
	else
#		echo "It's v5.x or newer!"
		esxcli --server $HOSTNAME --username $USERNAME --password $PASSWORD storage nmp device list >/tmp/$HOSTNAME-vsphere_storage_multipath.txt
	fi

###Rule to use:
#DGC = VMW_SATP_CX = VMW_PSP_MRU
#EMC = VMW_SATP_SYMM or VMW_SATP_INV = VMW_PSP_RR
#HITACHI = VMW_SATP_DEFAULT_AA = VMW_PSP_RR
#XtremIO = VMW_SATP_DEFAULT_AA = VMW_PSP_RR
#IBM = VMW_SATP_ALUA = VMW_PSP_RR
#DELL = VMW_SATP_LOCAL = VMW_PSP_FIXED
#DELL VRTX = VMW_SATP_ALUA = VMW_PSP_MRU
#DP = VMW_SATP_LOCAL = VMW_PSP_FIXED
#CD-ROM = VMW_SATP_LOCAL = VMW_PSP_FIXED
   
DGC_TOTAL_ISSUES="0"
EMC_TOTAL_ISSUES="0"
HITACHI_TOTAL_ISSUES="0"
XTREMIO_TOTAL_ISSUES="0"
IBM_TOTAL_ISSUES="0"
IBM_LOCAL_TOTAL_ISSUES="0"
DELL_TOTAL_ISSUES="0"
DP_TOTAL_ISSUES="0"
CDROM_TOTAL_ISSUES="0"
TOTAL_ISSUES="0"

awk '/Device Display Name:/ { print ; for(n=0; n<3; n++) { getline ; print $0 } }' /tmp/$HOSTNAME-vsphere_storage_multipath.txt | sed -e '/Config/d' -e 's/^[ \t]*//' | cut -f2 -d ':' | sed -e 's/^[ \t]*//' >/tmp/$HOSTNAME-vsphere_storage_multipath-filtered.txt

awk '{
if (NR % 3)
printf("%s;",$0)
else
printf("%s\n",$0)
}' /tmp/$HOSTNAME-vsphere_storage_multipath-filtered.txt >/tmp/$HOSTNAME-vsphere_storage_multipath-filtered2.txt

array1=( $( < /tmp/$HOSTNAME-vsphere_storage_multipath-filtered2.txt ) )

for i in ${array1[@]}
do
	DEVICE_NAME=`echo $i | awk -F';' '{ print $1 }'`
	STORAGE_ARRAY_TYPE=`echo $i | awk -F';' '{ print $2 }'`
	PATH_SELECTION_POLICY=`echo $i | awk -F';' '{ print $3 }'`
	if [[ $DEVICE_NAME = *"DGC"* ]]
	then
	if [[ $STORAGE_ARRAY_TYPE != "VMW_SATP_CX" ]] || [[ $PATH_SELECTION_POLICY != "VMW_PSP_MRU" ]]
	then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
		let DGC_TOTAL_ISSUES=DGC_TOTAL_ISSUES+1
	fi
	fi
	if [[ $DEVICE_NAME = *"EMC"* ]]
	then
   	if [[ $STORAGE_ARRAY_TYPE = "VMW_SATP_SYMM" ]] && [[ $PATH_SELECTION_POLICY != "VMW_PSP_RR" ]] || [[ $STORAGE_ARRAY_TYPE = "VMW_SATP_INV" ]] && [[ $PATH_SELECTION_POLICY != "VMW_PSP_RR" ]]
	then
	DEVICE=`echo $DEVICE_NAME | awk -F'(' '{ print $2 }' | sed -e 's/ (,*//'`
	if [[ $VSPHERE_VERSION = "4.1.0" ]]
	then
		SIZE=`esxcli --server $HOSTNAME --username $USERNAME --password $PASSWORD corestorage device list | grep -A1 "$DEVICE" | tail -1 | awk -F': ' '{ print $2 }'`
	else
		SIZE=`esxcli --server $HOSTNAME --username $USERNAME --password $PASSWORD storage nmp device list | tail -1 | awk -F': ' '{ print $2 }'`
	fi
	if [[ $SIZE > "5" ]]
	then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
		let EMC_TOTAL_ISSUES=EMC_TOTAL_ISSUES+1
        fi
        fi
        fi
	if [[ $DEVICE_NAME = *"HITACHI"* ]]
	then
	if [[ $STORAGE_ARRAY_TYPE != "VMW_SATP_DEFAULT_AA" ]] || [[ $PATH_SELECTION_POLICY != "VMW_PSP_RR" ]]
	then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
		let HITACHI_TOTAL_ISSUES=HITACHI_TOTAL_ISSUES+1
	fi
	fi
	if [[ $DEVICE_NAME = *"XtremIO"* ]]
	then
	if [[ $STORAGE_ARRAY_TYPE != "VMW_SATP_DEFAULT_AA" ]] || [[ $PATH_SELECTION_POLICY != "VMW_PSP_RR" ]]
	then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
		let XTREMIO_TOTAL_ISSUES=XTREMIO_TOTAL_ISSUES+1
	fi
	fi	
	if [[ $DEVICE_NAME = *"IBM Fibre"* ]]
	then
	if [[ $STORAGE_ARRAY_TYPE != "VMW_SATP_ALUA" ]] || [[ $PATH_SELECTION_POLICY != "VMW_PSP_RR" ]]
	then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
		let IBM_TOTAL_ISSUES=IBM_TOTAL_ISSUES+1
	fi
	fi
	if [[ $DEVICE_NAME = *"IBM Disk"* ]]
	then
	if [[ $STORAGE_ARRAY_TYPE != "VMW_SATP_LOCAL" ]] || [[ $PATH_SELECTION_POLICY != "VMW_PSP_FIXED" ]]
	then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
		let IBM_TOTAL_ISSUES=IBM_TOTAL_ISSUES+1
	fi
	fi
	if [[ $DEVICE_NAME = *"DELL"* ]]
	then
   	if [[ $STORAGE_ARRAY_TYPE = "VMW_SATP_LOCAL" ]] && [[ $PATH_SELECTION_POLICY != "VMW_PSP_FIXED" ]] || [[ $STORAGE_ARRAY_TYPE = "VMW_SATP_ALUA" ]] && [[ $PATH_SELECTION_POLICY != "VMW_PSP_MRU" ]]

	then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
		let DELL_TOTAL_ISSUES=DELL_TOTAL_ISSUES+1
	fi
	fi
	if [[ $DEVICE_NAME = *"DP"* ]]
	then
	if [[ $STORAGE_ARRAY_TYPE != "VMW_SATP_LOCAL" ]] || [[ $PATH_SELECTION_POLICY != "VMW_PSP_FIXED" ]]
	then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
		let DP_TOTAL_ISSUES=DP_TOTAL_ISSUES+1
	fi
	fi
	if [[ $DEVICE_NAME = *"CD-ROM"* ]]
	then
	if [[ $STORAGE_ARRAY_TYPE != "VMW_SATP_LOCAL" ]] || [[ $PATH_SELECTION_POLICY != "VMW_PSP_FIXED" ]]
	then
		let TOTAL_ISSUES=TOTAL_ISSUES+1
		let CDROM_TOTAL_ISSUES=CDROM_TOTAL_ISSUES+1
	fi
	fi
done

IFS=$old_IFS     # restore default field separator 

	if [ "$TOTAL_ISSUES" != "0" ]; then
		ISSUES="1"
        echo "CRITICAL: Either The Storage Array Type or The Path Selection Policy is wrong from at least one of the datastores. Total issues count = $TOTAL_ISSUES"
        echo "CRITICAL: Either The Storage Array Type or The Path Selection Policy is wrong from at least one of the datastores. Total issues count = $TOTAL_ISSUES. Issues per device as follows: DGC_TOTAL_ISSUES = $DGC_TOTAL_ISSUES; EMC_TOTAL_ISSUES = $EMC_TOTAL_ISSUES; HITACHI_TOTAL_ISSUES = $HITACHI_TOTAL_ISSUES; XTREMIO_TOTAL_ISSUES = $XTREMIO_TOTAL_ISSUES; IBM_TOTAL_ISSUES = $IBM_TOTAL_ISSUES; IBM_LOCAL_TOTAL_ISSUES = $IBM_LOCAL_TOTAL_ISSUES; DELL_TOTAL_ISSUES = $DELL_TOTAL_ISSUES; DP_TOTAL_ISSUES = $DP_TOTAL_ISSUES; CDROM_TOTAL_ISSUES = $CDROM_TOTAL_ISSUES"
		exit 2
	else
		ISSUES="0"
        echo "OK: All Storage Array Types and Path Selection Policies are correct for all datastores. Total issues count = $TOTAL_ISSUES"
		echo "OK: All Storage Array Types and Path Selection Policies are correct for all datastores. Total issues count = $TOTAL_ISSUES. Issues per device as follows: DGC_TOTAL_ISSUES = $DGC_TOTAL_ISSUES; EMC_TOTAL_ISSUES = $EMC_TOTAL_ISSUES; HITACHI_TOTAL_ISSUES = $HITACHI_TOTAL_ISSUES; XTREMIO_TOTAL_ISSUES = $XTREMIO_TOTAL_ISSUES; IBM_TOTAL_ISSUES = $IBM_TOTAL_ISSUES; IBM_LOCAL_TOTAL_ISSUES = $IBM_LOCAL_TOTAL_ISSUES; DELL_TOTAL_ISSUES = $DELL_TOTAL_ISSUES; DP_TOTAL_ISSUES = $DP_TOTAL_ISSUES; CDROM_TOTAL_ISSUES = $CDROM_TOTAL_ISSUES"
		exit 0
    fi
