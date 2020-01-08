# Nagios
New monitoring script for Dell Ship Date using SNMP protocol.

# Targets
Targets tested:

OS=VMWare ESXi;

Dell PowerEdge servers of generation 11, 12, 13 and 14 (rackmounts and blades);

Dell Chassis (M1000e and VRTX)

Dell PowerEdge M I/O Aggregator (IOA)

It might work with other models/OSes too. So, feel free to modify it to fit your needs.

For example, for windows OS running on blade, you might need OID=.1.3.6.1.4.1.674.10892.1.300.80.1.13.x instead

## How it works
It pulls through SNMP, the Service Tag (STag) from target device or server and uses that to pull Shipping information.

There are three options (server|chassis|switch) to choose from (the following is supported/tested):

1. For **server**, it pulls from the server OS (VMWare ESXi) and in case that does not work, it tries through the iDRAC automatically as a backup option;
2. From **chassis**;
3. From **switch**;

## Info
Dell has moved to a more secure method for obtaining information on devices (including warranty info). They moved away from API key (v4) to OAuthTLS2.0 (v5).

The deadline to continue using the v4 of the API key was Dec, 15th 2019.

In order to continue pulling device information from Dell's website it now requires v5. For that, you need to:


1. Submit a new request to obtain updated API credentials on TechDirect portal - https://techdirect.dell.com/portal.30/Login.aspx;

2. Obtain credentials "Client_ID" and "Client_Secret" from Dell (The script will need to be edited to update these variables);
 
 
 **Note:** FYI, each generated Bearer token will be valid for 3600 seconds.

For further details, please refer to SDK available on your Dell TechDirect account.

**Note:** In some cases, grabbing the STag might not be possible due to firewall, misconfigured/disabled SNMP settings in the Server OS or some other odd reason. To work around that, I enabled the option to pull it from the iDRAC automatically when type=server is selected and if the script fails to pull from the Server OS. For that to work, you should have your iDRAC registered in DNS and using a pattern (i.e.: idrac-hostname). For this script we use "idrac-hostname". Feel free to modify it.

## Requirements
SNMP to be working (Server OS/Dell iDRAC, Dell Chassis, or Dell Switch);

**Note:** This is a linux script tested under openSUSE and Ubuntu distros

Requires **sed** and **snmpget** tool. snmpget can be found in:

package=**net-snmp** for openSUSE: ***sudo zypper in net-snmp***

package=**snmp** for Ubuntu:       ***sudo apt-get install snmp***

**Note:** Edit script and change the following lines (to match your environment):

iDRACHOSTNAME="idrac-$HOSTNAME" (this part is optional; SNMP needs to be configured properly in iDRAC. The script will try to check warranty against the iDRAC automatically if the script fails to check against the server OS)

client_id='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

client_secret='yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'

## Usage
    ./check-dell-shipdate-idrac.sh -H|--hostname HOSTNAME -w|--warning <number of days> -c|--critical <number of days> -T|--type <server|chassis|switch> -C|--community 'SNMP_COMMUNITY_STRING'
    
Usage:

check-dell-shipdate-idrac.sh [options]

-H|--hostname HOSTNAME to pull SNMP 

-w|--warning <number of days>
	
-c|--critical <number of days>
	
-T|--type <server|chassis|switch>

-C|--community 'SNMP_COMMUNITY_STRING'

-h|--help

-v|--version

-V|--verbose

## Help
    ./check-dell-shipdate-idrac.sh -h|--help

## Version
    ./check-dell-shipdate-idrac.sh -v|--version"

### Sample Output
	OK: Device=HOSTNAME with STag=xxxxxxx was shipped in 2010-03-20, so the ship date=03-20-2010

## Troubleshooting

Use the Verbose option to print extra info including the Service Tag
