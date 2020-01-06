# Nagios
Monitoring Script for Dell Warranty

Dell has moved to a more secure method for obtaining information on devices (including warranty info). They moved away from API key (v4) to OAuthTLS2.0 (v5).

The deadline to continue using the v4 of the API key was Dec, 15th 2019.

In order to continue pulling device information from Dell's website it now requires v5. For that, you need to:

1.	Submit a new request to obtain updated API credentials on TechDirect portal - https://techdirect.dell.com/portal.30/Login.aspx
2.  Obtain credentials "Client_ID" and "Client_Secret" from Dell. Using credentials, generate Bearer token, which will be valid for 3600 seconds.

For further details refer to SDK available on your Dell TechDirect account.
