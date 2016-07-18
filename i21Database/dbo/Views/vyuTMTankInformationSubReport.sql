CREATE VIEW [dbo].vyuTMTankInformationSubReport  
AS 

	SELECT 
		E.intDeviceId
		,E.strSerialNumber
		,E.dblTankCapacity
		,C.intSiteNumber
		,T.strTankType
		,F.strDeviceType
		,intSiteId = C.intSiteID 
	FROM tblTMSite C 
	INNER JOIN tblTMSiteDevice D 
		ON C.intSiteID = D.intSiteID 
	INNER JOIN tblTMDevice E 
		ON D.intDeviceId = E.intDeviceId 
	INNER JOIN tblTMDeviceType F 
		ON E.intDeviceTypeId = F.intDeviceTypeId 
	LEFT JOIN tblTMTankType T 
		ON E.intTankTypeId = T.intTankTypeId 
	WHERE F.strDeviceType IN ('Tank', 'TANK') AND ysnAppliance = 0

GO