#!/bin/bash

### Only tested on openSUSE and Ubuntu distros
### Requires snmpget tool found in:
###package=net-snmp for openSUSE: sudo zypper in net-snmp
###package=snmp for Ubuntu:       sudo apt-get install snmp

REVISION="Revision 1.0"
REVDATE="01-06-2020"
AUTHOR="bridrod - You might even script, but only Love builds! :)"
PURPOSE="Checks Warranty on Dell devices using Dell API/SDK v5, which requires OAuthTLS2.0 for authorization"
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
    echo "Usage: check-dell-warranty.sh -H|--hostname HOSTNAME -w|--warning <number of days> -c|--critical <number of days> -T|--type <server|chassis|switch> -C|--community 'SNMP_COMMUNITY_STRING' -V|--verbose"
    echo "Usage: check-dell-warranty.sh -h|--help"
    echo "Usage: check-dell-warranty.sh -v|--version"
}

print_example() {
    echo ""
    echo "# e.g.: ./check-dell-warranty.sh -H HOSTNAME -w 90 -c 60 -C 'SNMP_COMMUNITY_STRING'"
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
if [ $# -lt 10 ]; then
        print_usage
        print_example
		print_revision
        exit 3
fi

CRITICAL=''
WARNING=''
STAG=''
MODEL=''
WarrantyEND=''
WarrantyDate1=''
WarrantyDate2=''
DaysLeft=''
iDRACHOSTNAME=''
VERBOSE=0

date2stamp () {
    date --utc --date "$1" +%s
}

stamp2date (){
    date --utc --date "1970-01-01 $1 sec" "+%Y-%m-%d %T"
}

dateDiff (){
    case $1 in
        -s)   sec=1;      shift;;
        -m)   sec=60;     shift;;
        -h)   sec=3600;   shift;;
        -d)   sec=86400;  shift;;
        *)    sec=86400;;
    esac
    dte1=$(date2stamp $1)
    dte2=$(date2stamp $2)
    diffSec=$((dte2-dte1))
    if ((diffSec < 0)); then abs=-1; else abs=1; fi
    echo $((diffSec/sec*abs))
}

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
        -w)
                WARNING=$2
                shift
                ;;
        --warning)
                WARNING=$2
                shift
                ;;
        -c)
                CRITICAL=$2
                shift
                ;;
        --critical)
                CRITICAL=$2
                shift
                ;;
	-T)
                TYPE=$2
                shift
                ;;
        --type)
                TYPE=$2
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
         -V)
                VERBOSE=1
                shift
                ;;
        --verbose)
                VERBOSE=1
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

iDRACHOSTNAME="d-$HOSTNAME"

if [ "$TYPE" == "server" ]; then
	STAG=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -OQ -Oe -Ot $HOSTNAME '.1.3.6.1.2.1.47.1.1.1.1.11.1' | sed 's/^[^=]*=//' | sed 's/"//g' | sed '/^$/d' | sed -e 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | sed 's/\s*$//g'`
	MODEL=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -OQ -Oe -Ot $HOSTNAME '.1.3.6.1.2.1.47.1.1.1.1.13.1' | sed 's/^[^=]*=//' | sed 's/"//g' | sed '/^$/d' | sed -e 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | sed 's/\s*$//g'`

	if [ "$TYPE" == "server" ] && [ "$VERBOSE" == 1 ]; then
		echo "Server hostname=$HOSTNAME ; iDRAC hostname=$iDRACHOSTNAME"
		echo "Server STag=$STAG"
	fi

	if [ "$STAG" == "No Such Object available on this agent at this OID" ] || [ "$STAG" == "No Such Instance currently exists at this OID" ]; then
		STAG=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -OQ -Oe -Ot $iDRACHOSTNAME '.1.3.6.1.4.1.674.10892.2.1.1.11.0' | sed 's/^[^=]*=//' | sed 's/"//g' | sed '/^$/d' | sed -e 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | sed 's/\s*$//g'`
		MODEL=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -OQ -Oe -Ot $iDRACHOSTNAME '.1.3.6.1.4.1.674.10892.5.1.3.12.0' | sed 's/^[^=]*=//' | sed 's/"//g' | sed '/^$/d' | sed -e 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | sed 's/\s*$//g'`
	fi

	if [ "$STAG" == "No Such Object available on this agent at this OID" ] && [ "$VERBOSE" == 1 ]; then
		echo "iDRAC STag=$STAG"
	fi

	if [ "$STAG" == "No Such Instance currently exists at this OID" ] && [ "$VERBOSE" == 1 ]; then
		echo "iDRAC STag=$STAG"
	fi

	if [ "$MODEL" == "" ] || [ "$MODEL" == "No Such Object available on this agent at this OID" ] || [ "$MODEL" == "No Such Instance currently exists at this OID" ]; then
		MODEL="UNKNOWN"
	fi

	if [ "$MODEL" == "" ] && [ "$VERBOSE" == 1 ]; then
		echo "Device Model=$MODEL"
	fi

	if [ "$MODEL" == "No Such Object available on this agent at this OID" ] && [ "$VERBOSE" == 1 ]; then
		echo "Device Model=$MODEL"
	fi

	if [ "$MODEL" == "No Such Instance currently exists at this OID" ] && [ "$VERBOSE" == 1 ]; then
		echo "Device Model=$MODEL"
	fi

	if [ "$STAG" == "" ] || [ "$STAG" == "No Such Object available on this agent at this OID" ] || [ "$STAG" == "No Such Instance currently exists at this OID" ]; then
		echo "WARNING: Unable to retrieve Service Tag! Please check whether SNMP is working on the device! Perhaps device/firmware/OS is too old?!"
		exit 1
	fi	
fi

if [ "$TYPE" == "chassis" ]; then
    STAG=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -OQ -Oe -Ot $HOSTNAME '.1.3.6.1.4.1.674.10892.2.1.1.6.0' | sed 's/^[^=]*=//' | sed 's/"//g' | sed '/^$/d' | sed -e 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | sed 's/\s*$//g'`
    MODEL=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -OQ -Oe -Ot $HOSTNAME '.1.3.6.1.4.1.674.10892.2.1.1.2.0' | sed 's/^[^=]*=//' | sed 's/"//g' | sed '/^$/d' | sed -e 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | sed 's/\s*$//g'`

	if [ "$TYPE" == "chassis" ] && [ "$VERBOSE" == 1 ]; then
		echo "Chassis STag=$STAG"
	fi
		
	if [ "$MODEL" == "" ] || [ "$MODEL" == "No Such Object available on this agent at this OID" ] || [ "$MODEL" == "No Such Instance currently exists at this OID" ]; then
		MODEL="UNKNOWN"
	fi

	if [ "$MODEL" == "" ] && [ "$VERBOSE" == 1 ]; then
		echo "Device Model=$MODEL"
	fi

	if [ "$MODEL" == "No Such Object available on this agent at this OID" ] && [ "$VERBOSE" == 1 ]; then
		echo "Device Model=$MODEL"
	fi

	if [ "$MODEL" == "No Such Instance currently exists at this OID" ] && [ "$VERBOSE" == 1 ]; then
		echo "Device Model=$MODEL"
	fi

	if [ "$STAG" == "" ] || [ "$STAG" == "No Such Object available on this agent at this OID" ] || [ "$STAG" == "No Such Instance currently exists at this OID" ]; then
		echo "WARNING: Unable to retrieve Service Tag! Please check whether SNMP is working on the device! Perhaps device/firmware/OS is too old?!"
		exit 1
	fi	
fi

if [ "$TYPE" == "switch" ]; then
        STAG=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -OQ -Oe -Ot $HOSTNAME '.1.3.6.1.4.1.674.10895.3000.1.2.100.8.1.4.1' | sed 's/^[^=]*=//' | sed 's/"//g' | sed '/^$/d' | sed -e 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | sed 's/\s*$//g'`
        MODEL=`snmpget -v2c -c $COMMUNITY -m '' -M '' -On -OQ -Oe -Ot $HOSTNAME '.1.3.6.1.4.1.674.10895.3000.1.2.100.1.0' | sed 's/^[^=]*=//' | sed 's/"//g' | sed '/^$/d' | sed -e 's/^[ \t]*//' | sed '/^[[:space:]]*$/d' | sed 's/\s*$//g'`

	if [ "$TYPE" == "switch" ] && [ "$VERBOSE" == 1 ]; then
		echo "Switch STag=$STAG"
	fi

	if [ "$MODEL" == "" ] || [ "$MODEL" == "No Such Object available on this agent at this OID" ] || [ "$MODEL" == "No Such Instance currently exists at this OID" ]; then
		MODEL="UNKNOWN"
	fi

	if [ "$MODEL" == "" ] && [ "$VERBOSE" == 1 ]; then
		echo "Device Model=$MODEL"
	fi

	if [ "$MODEL" == "No Such Object available on this agent at this OID" ] && [ "$VERBOSE" == 1 ]; then
		echo "Device Model=$MODEL"
	fi

	if [ "$MODEL" == "No Such Instance currently exists at this OID" ] && [ "$VERBOSE" == 1 ]; then
		echo "Device Model=$MODEL"
	fi

	if [ "$STAG" == "" ] || [ "$STAG" == "No Such Object available on this agent at this OID" ] || [ "$STAG" == "No Such Instance currently exists at this OID" ]; then
		echo "WARNING: Unable to retrieve Service Tag! Please check whether SNMP is working on the device! Perhaps device/firmware/OS is too old?!"
		exit 1
	fi	
fi

#echo "community=$COMMUNITY"
#echo "stag=$STAG"
#echo "model=$MODEL"

client_id='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
client_secret='yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'
grant_type='client_credentials'
url_token='https://apigtwb2c.us.dell.com/auth/oauth/v2/token'
url_warranty1='https://apigtwb2c.us.dell.com/PROD/sbil/eapi/v5/asset-entitlements/'
url_warranty2='https://apigtwb2c.us.dell.com/PROD/sbil/eapi/v5/assets/'
access_token=`curl -X POST -d "client_id=$client_id&client_secret=$client_secret&grant_type=$grant_type" $url_token 2>&1 | sed 's/",/",\n/g' | grep access_token | sed 's/  "access_token":"//g' | sed 's/",//g'`

if [ "$VERBOSE" == 1 ]; then
	warranty_output=`curl -H "Authorization: Bearer $access_token" $url_warranty1?servicetags=$STAG`
	else
	warranty_output=`curl -H "Authorization: Bearer $access_token" $url_warranty1?servicetags=$STAG 2>/dev/null`
fi

#warranty_output=`curl -H "Authorization: Bearer $access_token" $url_warranty1?servicetags=$STAG 2>/dev/null`
WarrantyEND=`curl -H "Authorization: Bearer $access_token" $url_warranty1?servicetags=$STAG 2>&1 | sed 's/",/",\n/g' | sed 's/",//g' | sed 's/^.*endDate/endDate/' | grep endDate | sed 's/endDate":"//g' | tail -1`
ShipDate=`curl -H "Authorization: Bearer $access_token" $url_warranty1?servicetags=$STAG 2>&1 | sed 's/",/",\n/g' | sed 's/",//g' | sed 's/^.*shipDate/shipDate/' | grep shipDate | sed 's/shipDate":"//g'`
WarrantyDate1HUMAN=`date +%Y-%m-%d`
WarrantyDate1=`date --date "$WarrantyDate1HUMAN" +%s`
WarrantyDate2HUMAN=`echo $WarrantyEND | cut -d ' ' -f 1`
WarrantyDate2=`date --date "$WarrantyDate2HUMAN" +%s`
ShipDate2Human=`echo $ShipDate | cut -d ' ' -f 1`
diff=$((WarrantyDate2-WarrantyDate1))
DaysLeft=`echo $((diff/86400))`

let DaysLeft=DaysLeft+0

if [[ $DaysLeft = "" ]]; then
                echo "WARNING: Unable to retrieve Dell warranty for $HOSTNAME! Please check whether SNMP is working on the device!"
                exit 1
fi

	if [ "$DaysLeft" -gt "$WARNING" ]; then
                echo "OK: Device $MODEL is under warranty and has enough days left! Dell with Service Tag = $STAG \ Dell Support Warranty End Date = $WarrantyDate2HUMAN \ Days Left = $DaysLeft|Days_Left=$DaysLeft;90;30;0;365"
				printf "$MODEL with Service Tag = $STAG \ Dell Support Warranty End Date = $WarrantyDate2HUMAN \ Days Left = $DaysLeft\n"
				printf "\nWarranty Date1 (Now) is $WarrantyDate1HUMAN\n"
				printf "Warranty Date2 (End) is $WarrantyDate2HUMAN\n"
				printf "Warranty End Date (Collection):\n"
				printf "$WarrantyEND\n"
				printf "\nDell device with Service Tag = $STAG\n"
				printf "Days Left = $DaysLeft\n\n"
				echo "Warranty Date1 (Now) is $WarrantyDate1"
				echo "Warranty Date1HUMAN (Now) is $WarrantyDate1HUMAN"
				echo "Warranty Date2 (End) is $WarrantyDate2"
				echo "Warranty Date2HUMAN (End) is $WarrantyDate2HUMAN"
				echo "Warranty End Date (Collection) = $WarrantyEND"
				echo "Ship Date is $ShipDate2Human"
                exit 0
	fi
    if [ "$DaysLeft" -gt "$CRITICAL" ] && [ "$DaysLeft" -le "$WARNING" ]; then
                echo "WARNING: Device $MODEL is still under warranty but it is below the WARNING alert threshold of $WARNING days! Dell with Service Tag = $STAG \ Dell Support Warranty End Date = $WarrantyDate2HUMAN \ Days Left = $DaysLeft|Days_Left=$DaysLeft;90;30;0;365"
				printf "$MODEL with Service Tag = $STAG \ Dell Support Warranty End Date = $WarrantyDate2HUMAN \ Days Left = $DaysLeft\n"
				printf "\nWarranty Date1 (Now) is $WarrantyDate1HUMAN\n"
				printf "Warranty Date2 (End) is $WarrantyDate2HUMAN\n"
				printf "Warranty End Date (Collection):\n"
				printf "$WarrantyEND\n"
				printf "\nDell device with Service Tag = $STAG\n"
				printf "Days Left = $DaysLeft\n\n"
				echo "Warranty Date1 (Now) is $WarrantyDate1"
				echo "Warranty Date1HUMAN (Now) is $WarrantyDate1HUMAN"
				echo "Warranty Date2 (End) is $WarrantyDate2"
				echo "Warranty Date2HUMAN (End) is $WarrantyDate2HUMAN"
				echo "Warranty End Date (Collection) = $WarrantyEND"
				echo "Ship Date is $ShipDate2Human"
                exit 1
	fi
    if [ "$DaysLeft" -le "$CRITICAL" ] && [ "$DaysLeft" -gt "0" ]; then
                echo "CRITICAL: Device $MODEL is still under warranty but it is below the CRITICAL alert threshold of $CRITICAL days! Dell with Service Tag = $STAG \ Dell Support Warranty End Date = $WarrantyDate2HUMAN \ Days Left = $DaysLeft|Days_Left=$DaysLeft;90;30;0;365"
				printf "$MODEL with Service Tag = $STAG \ Dell Support Warranty End Date = $WarrantyDate2HUMAN \ Days Left = $DaysLeft\n"
				printf "\nWarranty Date1 (Now) is $WarrantyDate1HUMAN\n"
				printf "Warranty Date2 (End) is $WarrantyDate2HUMAN\n"
				printf "Warranty End Date (Collection):\n"
				printf "$WarrantyEND\n"
				printf "\nDell device with Service Tag = $STAG\n"
				printf "Days Left = $DaysLeft\n\n"
				echo "Warranty Date1 (Now) is $WarrantyDate1"
				echo "Warranty Date1HUMAN (Now) is $WarrantyDate1HUMAN"
				echo "Warranty Date2 (End) is $WarrantyDate2"
				echo "Warranty Date2HUMAN (End) is $WarrantyDate2HUMAN"
				echo "Warranty End Date (Collection) = $WarrantyEND"
				echo "Ship Date is $ShipDate2Human"
				exit 2
	fi
	if [ "$DaysLeft" -le "0" ]; then
                echo "CRITICAL: Device $MODEL is out of warranty! Time to decommission or extend the warranty ASAP! Dell with Service Tag = $STAG \ Dell Support Warranty End Date = $WarrantyDate2HUMAN \ Days Left = $DaysLeft|Days_Left=$DaysLeft;90;30;0;365"
				printf "$MODEL with Service Tag = $STAG \ Dell Support Warranty End Date = $WarrantyDate2HUMAN \ Days Left = $DaysLeft\n"
				printf "\nWarranty Date1 (Now) is $WarrantyDate1HUMAN\n"
				printf "Warranty Date2 (End) is $WarrantyDate2HUMAN\n"
				printf "Warranty End Date (Collection):\n"
				printf "$WarrantyEND\n"
				printf "\nDell device with Service Tag = $STAG\n"
				printf "Days Left = $DaysLeft\n\n"
				echo "Warranty Date1 (Now) is $WarrantyDate1"
				echo "Warranty Date1HUMAN (Now) is $WarrantyDate1HUMAN"
				echo "Warranty Date2 (End) is $WarrantyDate2"
				echo "Warranty Date2HUMAN (End) is $WarrantyDate2HUMAN"
				echo "Warranty End Date (Collection) = $WarrantyEND"
				echo "Ship Date is $ShipDate2Human"
                exit 2
    fi
