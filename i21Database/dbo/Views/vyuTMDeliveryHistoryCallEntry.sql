CREATE VIEW [dbo].[vyuTMDeliveryHistoryCallEntry]  
AS  
	SELECT 
		intSiteID = A.intSiteID
		,strCustomerNumber = D.strEntityNo
		,strCustomerName = D.strName
		,strSiteDescription = B.strDescription
		,strSiteAddress = B.strSiteAddress
		,strSiteNumber = RIGHT('000'+ CAST(B.intSiteNumber AS NVARCHAR(4)),4)
		,strOrderNumber = A.strWillCallOrderNumber
		,strProduct = COALESCE(F.strDescription,E.strDescription)
		,strDriverName = G.strName
		,strEnteredBy = H.strUserName
		,dblPercentLeft = A.dblWillCallPercentLeft
		,dblQuantity =  CASE WHEN ISNULL(A.dblWillCallDesiredQuantity,0) = 0 THEN ISNULL(A.dblWillCallCalculatedQuantity,0) ELSE A.dblWillCallDesiredQuantity END
		,dblPrice = A.dblWillCallPrice
		,dblTotal = A.dblWillCallTotal
		,dtmRequestedDate = A.dtmWillCallRequestedDate
		,strPrinted = CASE WHEN ISNULL(A.ysnWillCallPrinted,0) = 0 THEN 'No' ELSE 'YES' END
		,intPriority = A.intWillCallPriority
		,strComments = A.strWillCallComments
		,strOrderStatus = 'Completed'
		,dtmCallInDate = A.dtmWillCallCallInDate
		,dtmDispatchedDate = A.dtmWillCallDispatch
		,intConcurrencyId = A.intConcurrencyId
		,intDispatchId = CAST(A.intWillCallDispatchId AS INT)
		,intCustomerID = B.intCustomerID
		,intCompanyLocationId  = B.intLocationId
		,strCompanyLocationName  = I.strLocationName
		,dblLocationLongitude = ISNULL(I.dblLongitude,0.0)
		,dblLocationLatitude = ISNULL(I.dblLatitude,0.0)
		,strSiteCity = B.strCity
		,strSiteZipCode = B.strZipCode
		,strSiteState = B.strState
		,strSiteCountry = B.strCountry
		,dblLongitude = B.dblLongitude
		,dblLatitude = B.dblLatitude
		,intCustomerId = B.intCustomerID
		,ysnLeakCheckRequired = A.ysnWillCallLeakCheckRequired
	FROM tblTMDeliveryHistory A
	INNER JOIN tblTMSite B
		ON A.intSiteID = B.intSiteID
	INNER JOIN tblTMCustomer C
		ON B.intCustomerID = C.intCustomerID
	INNER JOIN tblEMEntity D
		ON C.intCustomerNumber = D.intEntityId
	INNER JOIN tblICItem E
		ON B.intProduct = E.intItemId
	LEFT JOIN tblICItem F
		ON A.intWillCallSubstituteProductId = F.intItemId
	LEFT JOIN tblEMEntity G
		ON A.intWillCallDriverId = G.intEntityId
	LEFT JOIN tblSMUserSecurity H
		ON A.intWillCallUserId = H.[intEntityId]
	LEFT JOIN tblSMCompanyLocation I
		ON B.intLocationId = I.intCompanyLocationId
GO