CREATE VIEW [dbo].[vyuTMLeakGasCheckSearch]
AS  
	SELECT 
		strLocation = D.strLocationName
		,strCustomerNumber = B.strEntityNo
		,strCustomerName = B.strName
		,strSiteNumber = RIGHT('000'+ CAST(A.intSiteNumber AS VARCHAR(3)),3)
		,strSerialNumber = F.strSerialNumber
		,dblTotalCapacity = A.dblTotalCapacity
		,strTankType = F.strTankType
		,dtmLastLeakCheck = G.dtmLastLeakCheck
		,dtmLastGasCheck = G.dtmLastLeakCheck
		,intSiteID = A.intSiteID
		,intCustomerID = A.intCustomerID
		,intLocationId = A.intLocationId
		,intConcurrencyId = 0
	FROM tblTMSite A
	INNER JOIN tblSMCompanyLocation D
		ON A.intLocationId = D.intCompanyLocationId
	INNER JOIN tblTMCustomer E 
		ON A.intCustomerID = E.intCustomerID
	INNER JOIN tblEMEntity B 
		ON E.intCustomerNumber = B.intEntityId
	CROSS APPLY fnTMGetFirstTankSiteDeviceTable(A.intSiteID) F
	CROSS APPLY fnTMLastLeakGasCheckTable(A.intSiteID) G

GO