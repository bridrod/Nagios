# Nagios
Monitoring Script for Dell Warranty; It pulls the Service Tag (STag) from target using OS or Device SNMP. The following is supported/tested:

1. From server OS (VMWare ESXi) or the iDRAC automatically as a backup (in case SNMP under the OS doesn't work);
2. From Chassis;
3. From Switch;

## Info
Dell has moved to a more secure method for obtaining information on devices (including warranty info). They moved away from API key (v4) to OAuthTLS2.0 (v5).

The deadline to continue using the v4 of the API key was Dec, 15th 2019.

In order to continue pulling device information from Dell's website it now requires v5. For that, you need to:


1. Submit a new request to obtain updated API credentials on TechDirect portal - https://techdirect.dell.com/portal.30/Login.aspx;

2. Obtain credentials "Client_ID" and "Client_Secret" from Dell (The script will need to be edited to update these variables);
 
 
 **Note:** FYI, each generated Bearer token will be valid for 3600 seconds.

For further details, please refer to SDK available on your Dell TechDirect account.

**Note:** In some cases, grabbing the STag might not be possible due to firewall, misconfigured/disabled SNMP settings in the Server OS or some other odd reason. To work around that, I enabled the option to pull it from the iDRAC automatically when type=server is selected and the script fails to pull from the Server OS. For that to work, you should have your iDRAC registered in DNS and using a pattern (i.e.: idrac-hostname). For this script we use "d-hostname". Feel free to modify it.

## Requirements
SNMP to be working (Server OS/Dell iDRAC, Dell Chassis, or Dell Switch);

**Note:** This is a linux script tested under openSUSE and Ubuntu distros

Requires **sed** and **snmpget** tool. snmpget can be found in:

package=**net-snmp** for openSUSE: ***sudo zypper in net-snmp***

package=**snmp** for Ubuntu:       ***sudo apt-get install snmp***

**Note:** Edit script and change the following lines (to match your environment):

iDRACHOSTNAME="d-$HOSTNAME" (optional; In case you are checking warranty against servers)

client_id='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

client_secret='yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'

## Usage
    ./check-dell-warranty.sh -H|--hostname HOSTNAME -w|--warning <number of days> -c|--critical <number of days> -T|--type <server|chassis|switch> -C|--community 'SNMP_COMMUNITY_STRING'
    
Usage:

check-dell-warranty.sh [options]

-H|--hostname HOSTNAME to pull SNMP 

-w|--warning <number of days>
	
-c|--critical <number of days>
	
-T|--type <server|chassis|switch>

-C|--community 'SNMP_COMMUNITY_STRING'

-h|--help

-V|--version

Tested with Dell PowerEdge servers Gen 11, 12, 13 and 14 (rackmounts and blades), Dell Chassis (M1000e and VRTX) and Dell PowerEdge M I/O Aggregator (IOA) but it might work with other models too.

## Help
    ./check-dell-warranty.sh -h|--help

## Version
    ./check-dell-warranty.sh -V|--version"

### Sample Output
	CRITICAL: Device Dell PowerEdge M I/O Aggregator is out of warranty! Time to decommission or extend the warranty ASAP! Dell with Service Tag = xxxxxxx \ Dell Support Warranty End Date = 2020-01-02T05:59:59.999Z \ Days Left = -3|Days_Left=-3;90;30;0;365
	Dell PowerEdge M I/O Aggregator with Service Tag = xxxxxxx \ Dell Support Warranty End Date = 2020-01-02T05:59:59.999Z \ Days Left = -3
		
	Warranty Date1 (Now) is 2020-01-06
	Warranty Date2 (End) is 2020-01-02T05:59:59.999Z
	Warranty End Date (Collection):
	2020-01-02T05:59:59.999Z
	
	Dell device with Service Tag = xxxxxxx
	Days Left = -3
	
	Warranty Date1 (Now) is 1578286800
	Warranty Date1HUMAN (Now) is 2020-01-06
	Warranty Date2 (End) is 1577944799
	Warranty Date2HUMAN (End) is 2020-01-02T05:59:59.999Z
	Warranty End Date (Collection) = 2020-01-02T05:59:59.999Z
	Ship Date is 2015-07-27T05:00:00Z
