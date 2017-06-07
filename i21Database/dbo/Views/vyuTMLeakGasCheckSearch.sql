CREATE VIEW [dbo].[vyuTMLeakGasCheckSearch]
AS  
	SELECT 
		strLocation = D.strLocationName
		,strCustomerNumber = B.strEntityNo
		,strCustomerName = B.strName
		,strSiteNumber = RIGHT('0000'+ CAST(A.intSiteNumber AS VARCHAR(4)),4)
		,strSerialNumber = I.strSerialNumber
		,dblTankCapacity = I.dblTankCapacity
		,strTankType = J.strTankType
		,dtmLastLeakCheck = G.dtmLastLeakCheck
		,dtmLastGasCheck = G.dtmLastGasCheck
		,intSiteID = A.intSiteID
		,intCustomerID = A.intCustomerID
		,intLocationId = A.intLocationId
		,intConcurrencyId = 0
		,intDeviceId = I.intDeviceId
	FROM tblTMSite A
	INNER JOIN tblSMCompanyLocation D
		ON A.intLocationId = D.intCompanyLocationId
	INNER JOIN tblTMCustomer E 
		ON A.intCustomerID = E.intCustomerID
	INNER JOIN tblEMEntity B 
		ON E.intCustomerNumber = B.intEntityId
	INNER JOIN tblTMSiteDevice H
		ON A.intSiteID = H.intSiteID
	INNER JOIN tblTMDevice I
		ON H.intDeviceId = I.intDeviceId
	INNER JOIN tblARCustomer L
		ON B.intEntityId = L.[intEntityId]
	LEFT JOIN tblTMTankType J
		ON I.intTankTypeId = J.intTankTypeId
	LEFT JOIN tblTMDeviceType K
		ON I.intDeviceTypeId = K.intDeviceTypeId
	LEFT JOIN vyuTMLastLeakGasCheckTable G
		ON A.intSiteID = G.intSiteID
	WHERE ISNULL(I.ysnAppliance,0) = 0
		AND K.strDeviceType = 'Tank'
		AND A.ysnActive = 1
		AND L.ysnActive = 1

GO