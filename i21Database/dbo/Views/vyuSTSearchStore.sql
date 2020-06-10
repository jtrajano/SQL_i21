CREATE VIEW [dbo].[vyuSTSearchStore]
AS
SELECT DISTINCT
	   ST.*
	   , HS.intHandheldScannerId
       , CL.strLocationName
	   , R.strRegisterClass
	   , R.strSapphireIpAddress
	   , R.strSAPPHIREUserName
	   , R.strSAPPHIREPassword
	   , ISNULL(R.intSAPPHIRECheckoutPullTimePeriodId, 0) AS intSAPPHIRECheckoutPullTimePeriodId
	   , CASE
			WHEN R.intSAPPHIRECheckoutPullTimePeriodId = 1
				THEN 'Shift Close'
			WHEN R.intSAPPHIRECheckoutPullTimePeriodId = 2
				THEN 'Day Close'
			ELSE ''
		END COLLATE Latin1_General_CI_AS AS strSAPPHIRECheckoutPullTimePeriod
		, ISNULL(R.intSAPPHIRECheckoutPullTimeSetId, 0) AS intSAPPHIRECheckoutPullTimeSetId
		, CASE
			WHEN R.intSAPPHIRECheckoutPullTimeSetId = 1
				THEN 'Current Data'
			WHEN R.intSAPPHIRECheckoutPullTimeSetId = 2
				THEN 'Last Close Data'
			WHEN R.intSAPPHIRECheckoutPullTimeSetId = 3
				THEN 'Last Close Data - 1'
			WHEN R.intSAPPHIRECheckoutPullTimeSetId = 4
				THEN 'Last Close Data - 2 and on through 9'
			ELSE ''
		END COLLATE Latin1_General_CI_AS AS strSAPPHIRECheckoutPullTimeSet
	   
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
LEFT JOIN tblSTHandheldScanner HS
	ON ST.intStoreId = HS.intStoreId
LEFT JOIN tblSTRegister R 
	ON ST.intRegisterId = R.intRegisterId
JOIN tblSMCompanyLocation CL
	ON ST.intCompanyLocationId = CL.intCompanyLocationId