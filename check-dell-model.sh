#!/bin/bash

### Only tested on openSUSE and Ubuntu distros
### Requires grep, awk, tr, sed
### Requires racadm tool found in "Dell EMC OpenManage Linux Remote Access Utilities, v9.x.x" @Dell's website

REVISION="Revision 1.0"
REVDATE="01-08-2020"
AUTHOR="bridrod - You might even script, but only Love builds! :)"
PURPOSE="Displays iDRAC Info from Dell servers"
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
    echo "Usage: check-dell-hw-idrac.sh -H|--hostname iDRAC_HOSTNAME/IP"
    echo "Usage: check-dell-hw-idrac.sh -h|--help"
    echo "Usage: check-dell-hw-idrac.sh -v|--version"
}

print_example() {
    echo ""
    echo "# e.g.: ./check-dell-hw-idrac.sh -H iDRAC_HOSTNAME/IP"
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
if [ $# -lt 2 ]; then
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

USERNAME='xxxxxxx'
PASSWORD='yyyyyyy'

array1=(`/opt/dell/srvadmin/sbin/racadm -r $HOSTNAME -u $USERNAME -p $PASSWORD getsysinfo`)
array2=(`/opt/dell/srvadmin/sbin/racadm -r $HOSTNAME -u $USERNAME -p $PASSWORD getconfig -g idracinfo`)

for i in ${array1[@]}
do
	OS_NAME=`echo $i | grep -w 'OS Name'`
	if [[ $OS_NAME = "OS Name"* ]]
	then
		OS_NAME=`echo $OS_NAME | grep 'OS Name' | awk '{$1=$2="";print}' | tr -d '"=' | sed -e 's/^[ \t]*//'`
		break		
    fi
done
for i in ${array1[@]}
do
	OS_VERSION=`echo $i | grep -w 'OS Version'`
	if [[ $OS_VERSION = "OS Version"* ]]
	then
		OS_VERSION=`echo $OS_VERSION | grep -w 'OS Version' | awk '{$1=$2="";print}' | tr -d '"=' | sed -e 's/^[ \t]*//'`
		break
    fi
done
for i in ${array1[@]}
do
	DELL_MODEL=`echo $i | grep 'System Model'`
	if [[ $DELL_MODEL = *"System Model"* ]]
	then
		DELL_MODEL=`echo $DELL_MODEL | grep 'System Model' | awk '{$1=$2="";print}' | tr -d '"=' | sed -e 's/^[ \t]*//'`
		break
    fi
done
for i in ${array1[@]}
do
	STAG=`echo $i | grep 'Service Tag'`
	if [[ $STAG = *"Service Tag"* ]]
	then
		STAG=`echo $STAG | grep 'Service Tag' | awk '{$1=$2="";print}' | tr -d '"=' | sed -e 's/^[ \t]*//'`
		break
    fi
done
for i in ${array1[@]}
do
	BIOS_FIRM_VERSION=`echo $i | grep 'System BIOS Version'`
	if [[ $BIOS_FIRM_VERSION = *"System BIOS Version"* ]]
	then
		BIOS_FIRM_VERSION=`echo $BIOS_FIRM_VERSION | grep 'System BIOS Version' | awk '{$1=$2="";print}' | tr -d '"= Version ' | sed -e 's/^[ \t]*//'`
		break
    fi
done

for i in ${array2[@]}
do
	DRAC_TYPE=`echo $i | grep 'idRacType'`
	if [[ $DRAC_TYPE = *"idRacType"* ]]
	then
		DRAC_TYPE=`echo $DRAC_TYPE | grep 'idRacType' | tr -d '"#' | tr '[a-z]' '[A-Z]'`
		break
    fi
done
for i in ${array2[@]}
do
	DRAC_VERSION=`echo $i | grep 'idRacProductInfo'`
	if [[ $DRAC_VERSION = *"idRacProductInfo"* ]]
	then
		DRAC_VERSION=`echo $DRAC_VERSION | grep 'idRacProductInfo' | awk '{$1=$2="";print}' | tr -d '"=' | sed -e 's/^[ \t]*//'`
		break
    fi
done
for i in ${array2[@]}
do
	DRAC_FIRM_VERSION=`echo $i | grep 'idRacVersionInfo'`
	if [[ $DRAC_FIRM_VERSION = *"idRacVersionInfo"* ]]
	then
		DRAC_FIRM_VERSION=`echo $DRAC_FIRM_VERSION | grep 'idRacVersionInfo' | tr -d '"=# idRacVersionInfo' | sed -e 's/^[ \t]*//'`
		break
    fi
done
for i in ${array2[@]}
do
	DRAC_BUILD=`echo $i | grep 'idRacBuildInfo'`	
	if [[ $DRAC_BUILD = *"idRacBuildInfo"* ]]
	then
		DRAC_BUILD=`echo $DRAC_BUILD | grep 'idRacBuildInfo' | tr -d '"#idRacBuildInfo= '`
		break
    fi
done
for i in ${array2[@]}
do
	DRAC_NAME=`echo $i | grep 'idRacName'`
	if [[ $DRAC_NAME = *"idRacName"* ]]
	then
		DRAC_NAME=`echo $DRAC_NAME | grep 'idRacName' | sed 's/# idRacName=//g'`		
		break
    fi	
done

IFS=$old_IFS     # restore default field separator

if [[ $DELL_MODEL = "" ]]; then
                echo "WARNING: Unable to retrieve Dell model from Server $HOSTNAME! Please check iDRAC for further details!"
                exit 1
		else
        	printf "DELL_MODEL = $DELL_MODEL"

		printf "\nDELL_MODEL = $DELL_MODEL\n"
		exit 0
fi
