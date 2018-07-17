CREATE VIEW [dbo].[vyuSTSearchStore]
AS
SELECT ST.*
       , CL.strLocationName
	   , R.strRegisterClass
	   , R.strSapphireIpAddress
	   , R.ysnTransctionLog
	   , CASE
			WHEN (R.strRegisterClass = 'SAPPHIRE' OR R.strRegisterClass = 'COMMANDER') AND (R.strSapphireIpAddress IS NOT NULL AND R.strSapphireIpAddress != '')  THEN 'https://' + R.strSapphireIpAddress + '/cgi-bin/CGILink?cmd=validate&user={USR}&passwd={PWD}'
			ELSE ''
		 END AS strUrlRequestCookie
	   , CASE
			WHEN (R.strRegisterClass = 'SAPPHIRE' OR R.strRegisterClass = 'COMMANDER') AND (R.strSapphireIpAddress IS NOT NULL AND R.strSapphireIpAddress != '')  THEN 'https://' + R.strSapphireIpAddress + '/cgi-bin/CGILink?cmd=vtransset&cookie={COOKIE}&period=2&reptnum=2'
			ELSE ''
		 END AS strUrlRequestTranslog
FROM tblSTStore ST
LEFT JOIN tblSTRegister R 
	ON ST.intStoreId = R.intStoreId
JOIN tblSMCompanyLocation CL
	ON ST.intCompanyLocationId = CL.intCompanyLocationId


