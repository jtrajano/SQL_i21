CREATE VIEW [dbo].vyuTMRegulatorInformationSubReport  
AS 
	
	SELECT 
		C.strManufacturerID
		,C.strManufacturerName
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
	WHERE D.strDeviceType = 'Regulator'

GO