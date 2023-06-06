CREATE VIEW [dbo].[vyuTMTankMonitorStatusSearch]
AS
SELECT		a.intDeviceId,
			a.strSerialNumber,
			strIPAddress,
			strPortNumber,
			CASE
				WHEN intPollingIntervalMinute IS NULL
				THEN ''
				ELSE CONVERT(NVARCHAR(10), intPollingIntervalMinute, 0) + ' Mins'
				END AS strPollingIntervalMinute,
			ISNULL(b.ysnInternetConnectivity, 0) as ysnInternetConnectivity,
			ISNULL(b.ysnATGConnectivity, 0) as ysnATGConnectivity,
			b.dtmDate,
			a.strTMSAppFileVersion
FROM		tblTMDevice a
LEFT JOIN	(	SELECT		intDeviceId,
							ysnInternetConnectivity,
							ysnATGConnectivity,
							dtmDate
				FROM		tblTMTankMonitorStatus
				WHERE		intTankMonitorStatusId IN (	SELECT		MAX(intTankMonitorStatusId) 
														FROM		tblTMTankMonitorStatus
														GROUP BY	intDeviceId)) b
ON			a.intDeviceId = b.intDeviceId AND
			DATEDIFF(MINUTE, b.dtmDate, GETDATE()) <= 2
WHERE		a.intDeviceTypeId = 4