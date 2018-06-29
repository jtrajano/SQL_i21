CREATE VIEW [dbo].[vyuTMWorkOrder]  
AS  
	SELECT 
		strCustomerNumber = G.strEntityNo
		,strCustomerName = G.strName
		,strWorkStatus = C.strWorkStatus
		,strSiteNumber = RIGHT('000'+ CAST(A.intSiteNumber AS NVARCHAR(4)),4)
		,strLocation = E.strLocationName
		,strWorkOrderCategory = D.strWorkOrderCategory
		,dtmDateCreated = DATEADD(dd, DATEDIFF(dd, 0, B.dtmDateCreated),0)
		,dtmDateScheduled = DATEADD(dd, DATEDIFF(dd, 0, B.dtmDateScheduled),0)
		,dtmDateClosed = DATEADD(dd, DATEDIFF(dd, 0, B.dtmDateClosed),0)
		,strAddress = REPLACE(RTRIM(ISNULL(A.strSiteAddress,'')) ,CHAR(13),' ') + ', ' + RTRIM(ISNULL(A.strCity,'')) + ', ' + RTRIM(ISNULL(A.strState,'')) + ', ' + RTRIM(ISNULL(A.strZipCode,'')) 
		,strCloseReason = H.strCloseReason
		,strPerformerName = I.strName
		,A.strDescription
		,intWorkOrderID = B.intWorkOrderID
		,strEnteredBy = K.strUserName
		,B.strComments
		,B.strAdditionalInfo
		,L.strItemNo
		,strItemDescription = L.strDescription
		,intSiteID = A.intSiteID
		,A.intCustomerID
		,A.intConcurrencyId
		,A.intLocationId
	
	FROM tblTMSite A
	INNER JOIN tblTMWorkOrder B
		ON A.intSiteID = B.intSiteID
	LEFT JOIN tblTMWorkStatusType C
		ON B.intWorkStatusTypeID = C.intWorkStatusID
	LEFT JOIN tblTMWorkOrderCategory D
		ON B.intWorkOrderCategoryId = D.intWorkOrderCategoryId
	INNER JOIN tblSMCompanyLocation E
		ON A.intLocationId = E.intCompanyLocationId
	INNER JOIN tblTMCustomer F
		ON A.intCustomerID = F.intCustomerID
	INNER JOIN tblEMEntity G
		ON F.intCustomerNumber = G.intEntityId
	LEFT JOIN tblTMWorkCloseReason H
		ON B.intCloseReasonID = H.intCloseReasonID
	LEFT JOIN tblEMEntity I
		ON B.intPerformerID = I.intEntityId
	LEFT JOIN tblEMEntity J
		ON B.intEnteredByID = J.intEntityId
	LEFT JOIN tblSMUserSecurity K
		ON J.intEntityId = K.[intEntityId]
	LEFT JOIN tblICItem L
		ON A.intProduct = L.intItemId
	
		
	

GO