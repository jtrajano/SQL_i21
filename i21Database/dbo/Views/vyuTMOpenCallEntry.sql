﻿CREATE VIEW [dbo].[vyuTMOpenCallEntry]  
AS  
	SELECT 
		intSiteID = A.intSiteID
		,strCustomerNumber = D.strEntityNo
		,strCustomerName = D.strName
		,strSiteDescription = B.strDescription
		,strSiteAddress = B.strSiteAddress
		,strSiteNumber = RIGHT('000'+ CAST(B.intSiteNumber AS NVARCHAR(4)),4)
		,strOrderNumber = A.strOrderNumber
		,strProduct = COALESCE(F.strDescription,E.strDescription)
		,strDriverName = G.strName
		,strEnteredBy = H.strUserName
		,dblPercentLeft = A.dblPercentLeft
		,dblQuantity =  CASE WHEN ISNULL(A.dblMinimumQuantity,0) = 0 THEN ISNULL(A.dblQuantity,0) ELSE A.dblMinimumQuantity END
		,dblPrice = A.dblPrice
		,dblTotal = A.dblTotal
		,dtmRequestedDate = A.dtmRequestedDate
		,strPrinted = CASE WHEN ISNULL(A.ysnCallEntryPrinted,0) = 0 THEN 'No' ELSE 'YES' END
		,intPriority = A.intPriority
		,strComments = A.strComments
		,strOrderStatus = A.strWillCallStatus
		,dtmCallInDate = A.dtmCallInDate
		,dtmDispatchedDate = A.dtmDispatchingDate
		,intConcurrencyId = A.intConcurrencyId
		,intDispatchId = A.intDispatchID
		,intCustomerID = B.intCustomerID
		,intLocationId = B.intLocationId
		,strLocation = B.strLocation
	FROM tblTMDispatch A
	INNER JOIN tblTMSite B
		ON A.intSiteID = B.intSiteID
	INNER JOIN tblTMCustomer C
		ON B.intCustomerID = C.intCustomerID
	INNER JOIN tblEntity D
		ON C.intCustomerNumber = D.intEntityId
	INNER JOIN tblICItem E
		ON B.intProduct = E.intItemId
	LEFT JOIN tblICItem F
		ON A.intSubstituteProductID = F.intItemId
	LEFT JOIN tblEntity G
		ON A.intDriverID = G.intEntityId
	LEFT JOIN tblSMUserSecurity H
		ON A.intUserID = H.[intEntityUserSecurityId]
GO