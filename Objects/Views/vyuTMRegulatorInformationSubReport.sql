CREATE VIEW [dbo].vyuTMRegulatorInformationSubReport  
AS 
	
	SELECT 
		E.strManufacturerId
		,E.strManufacturerName
		,C.dtmManufacturedDate
		,C.strDescription
		,intSiteId = A.intSiteID
	FROM tblTMSite A 
	INNER JOIN tblTMSiteDevice B 
		ON A.intSiteID = B.intSiteID
	INNER JOIN tblTMDevice C
		ON B.intDeviceId = C.intDeviceId
	INNER JOIN 	tblTMDeviceType D
		ON C.intDeviceTypeId = D.intDeviceTypeId
	LEFT JOIN tblTMManufacturer E
		ON C.intManufacturerId = E.intManufacturerId
	WHERE D.strDeviceType = 'Regulator'

GO