CREATE VIEW [dbo].[vyuTMCustomerConsumptionSiteInfo]  
AS  
	SELECT 
		intSiteId = B.intSiteID
		,intCustomerId = B.intCustomerID
		,strCustomerNumber = D.strEntityNo
		,strCustomerName = D.strName
		,strSiteAddress = B.strSiteAddress
		,strSiteCity = B.strCity
		,strSiteState = B.strState
		,strSiteZip = B.strZipCode
		,intCompanyLocationId  = B.intLocationId
		,strCompanyLocationName  = I.strLocationName
		,dblLongitude = B.dblLongitude
		,dblLatitude = B.dblLatitude
		,strSiteDescription = B.strDescription
		,dblSiteTotalCapacity = B.dblTotalCapacity
		,dtmSiteRunOutDate = B.dtmRunOutDate
		,dblSiteEstimatedPercentLeft = B.dblEstimatedPercentLeft
		,strSiteComment = B.strComment
		,strSiteInstruction = B.strInstruction
		,B.ysnActive
		,strDriverNumber = J.strEntityNo
		,strDriverName = J.strName
		,B.intRouteId 
		,strRoute = K.strRouteId
	FROM tblTMSite B
	INNER JOIN tblTMCustomer C
		ON B.intCustomerID = C.intCustomerID
	INNER JOIN tblEMEntity D
		ON C.intCustomerNumber = D.intEntityId
	LEFT JOIN tblSMCompanyLocation I
		ON B.intLocationId = I.intCompanyLocationId
	LEFT JOIN tblEMEntity J
		ON B.intDriverID = J.intEntityId
	LEFT JOIN tblTMRoute K
		ON B.intRouteId = K.intRouteId
GO