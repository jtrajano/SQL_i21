CREATE VIEW [dbo].[vyuTMDeviceSearch]
AS  
	SELECT 
		strSerialNumber = A.strSerialNumber
		,strDeviceType = D.strDeviceType
		,strManufacturerID = A.strManufacturerID
		,strManufacturerName = A.strManufacturerName
		,strInventoryStatusType = E.strInventoryStatusType
		,strSiteNumber = RIGHT('000'+ CAST(C.intSiteNumber AS VARCHAR(4)),4)
		,strSiteAddress = C.strSiteAddress
		,strCustomerID = G.strEntityNo
		,strCustomerName = G.strName
		,strOwnership = A.strOwnership
		,intDeviceId = A.intDeviceId
		,strLocationName = H.strLocationName
		,dblTankCapacity = A.dblTankCapacity
		,intLocationId = A.intLocationId
		,strSiteCity = C.strCity
		,strSiteState = C.strState
		,strSiteZip = C.strZipCode
		,dtmPurchaseDate = A.dtmPurchaseDate
		,dblPurchasePrice = A.dblPurchasePrice
		,dtmManufacturedDate = A.dtmManufacturedDate 
		,strTankType = I.strTankType
		,dblEstimatedGalsInTank = A.dblEstimatedGalTank
		,strLeaseNumber = K.strLeaseNumber
		,intLeaseId  = K.intLeaseId
		,intConcurrencyId = 0
	FROM tblTMDevice A
	LEFT JOIN tblTMSiteDevice B
		ON A.intDeviceId = B.intDeviceId
	LEFT JOIN tblTMSite C
		ON B.intSiteID = C.intSiteID
	LEFT JOIN tblTMDeviceType D
		ON A.intDeviceTypeId = D.intDeviceTypeId
	LEFT JOIN tblTMInventoryStatusType E
		ON A.intInventoryStatusTypeId = E.intInventoryStatusTypeId
	LEFT JOIN tblTMCustomer F
		ON C.intCustomerID = F.intCustomerID
	LEFT JOIN tblEMEntity G
		ON F.intCustomerNumber = G.intEntityId
	LEFT JOIN tblSMCompanyLocation H
		ON A.intLocationId = H.intCompanyLocationId
	LEFT JOIN tblTMTankType I
		ON A.intTankTypeId = I.intTankTypeId
	LEFT JOIN tblTMLeaseDevice J
		ON A.intDeviceId = J.intDeviceId
	LEFT JOIN tblTMLease K
		ON J.intLeaseId = K.intLeaseId
	WHERE A.ysnAppliance <> 1
	
GO