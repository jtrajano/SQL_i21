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
			c.dtmDateTime as dtmDate,
			a.strTMSAppFileVersion,
			ISNULL(d.strDescription, '') as strDescription,
			d.ysnCompanySite,
			d.intCustomerID,
			d.intSiteID,
			d.intCompanyLocationId
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
LEFT JOIN	(	SELECT		dtmDateTime,
							strSerialNumber
				FROM		tblTMTankReading
				WHERE		intTankReadingId IN (	SELECT		MAX(intTankReadingId)
													FROM		tblTMTankReading
													GROUP BY	strSerialNumber)) c
ON			a.strSerialNumber = c.strSerialNumber
LEFT JOIN	(
				SELECT		a.intDeviceId, 
							c.ysnCompanySite,
							c.intCustomerID,
							d.strLocationName AS strDescription,
							MIN(c.intSiteID) as intSiteID,
							c.intLocationId as intCompanyLocationId
				FROM		tblTMDeviceTankMonitor a
				INNER JOIN	tblTMSiteDeviceTankMonitor b
				ON			a.intDeviceTankMonitorId = b.intDeviceTankMonitorId
				INNER JOIN	tblTMSite c
				ON			c.intSiteID = b.intSiteId
				LEFT JOIN tblSMCompanyLocation d
				ON			c.intLocationId = d.intCompanyLocationId
				LEFT JOIN tblTMCustomer e
				ON			c.intCustomerID = e.intCustomerID
				LEFT JOIN tblEMEntity f
				ON			e.strOriginCustomerKey = f.strEntityNo
				WHERE		c.ysnCompanySite = 1
				GROUP BY	d.strLocationName,
							a.intDeviceId,
							c.ysnCompanySite,
							c.intCustomerID,
							f.strName,
							c.intLocationId

				UNION
				
				SELECT		a.intDeviceId, 
							c.ysnCompanySite,
							c.intCustomerID,
							f.strName AS strDescription,
							MIN(c.intSiteID) as intSiteID,
							c.intLocationId as intCompanyLocationId
				FROM		tblTMDeviceTankMonitor a
				INNER JOIN	tblTMSiteDeviceTankMonitor b
				ON			a.intDeviceTankMonitorId = b.intDeviceTankMonitorId
				INNER JOIN	tblTMSite c
				ON			c.intSiteID = b.intSiteId
				LEFT JOIN tblSMCompanyLocation d
				ON			c.intLocationId = d.intCompanyLocationId
				LEFT JOIN tblTMCustomer e
				ON			c.intCustomerID = e.intCustomerID
				LEFT JOIN tblEMEntity f
				ON			e.strOriginCustomerKey = f.strEntityNo
				WHERE		c.ysnCompanySite = 0
				GROUP BY	d.strLocationName,
							a.intDeviceId,
							c.ysnCompanySite,
							c.intCustomerID,
							f.strName,
							c.intLocationId
				
			) d
ON			a.intDeviceId = d.intDeviceId
WHERE		a.intDeviceTypeId = 4