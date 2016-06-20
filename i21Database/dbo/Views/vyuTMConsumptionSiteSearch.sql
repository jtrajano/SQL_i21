CREATE VIEW [dbo].[vyuTMConsumptionSiteSearch]
AS  
	SELECT 
	strKey = C.strEntityNo
	,strCustomerName = C.strName
	,strPhone = G.strPhone
	,intCustomerID = B.intCustomerID 
	,strDescription = A.strDescription
	,strLocation = E.strLocationName
	,strAddress = A.strSiteAddress
	,intSiteID = A.intSiteID
	,intSiteNumber = A.intSiteNumber
	,intConcurrencyId = A.intConcurrencyId
	,strCity = A.strCity
	,strBillingBy = A.strBillingBy
	--,strSerialNumbers = REPLACE((SELECT Y.strSerialNumber + ', '
	--					FROM tblTMSiteDevice Z
	--					INNER JOIN tblTMDevice Y
	--						ON Z.intDeviceId = Y.intDeviceId
	--					WHERE Z.intSiteID = A.intSiteID
	--						AND RTRIM(ISNULL(strSerialNumber,''))<> ''
	--						AND Y.intDeviceTypeId = (SELECT TOP 1 intDeviceTypeId FROM tblTMDeviceType WHERE strDeviceType = 'Tank')
	--					ORDER BY Z.intSiteDeviceID
	--					FOR XML PATH ('')) + '#@$',', #@$','')
	,strSerialNumber = J.strSerialNumber
	,A.intLocationId
	,ysnSiteActive = ISNULL(A.ysnActive,0)
	,strFillMethod = H.strFillMethod
	,strItemNo = ISNULL(I.strItemNo,'')
	,dtmLastDeliveryDate = A.dtmLastDeliveryDate
	,dtmNextDeliveryDate = A.dtmNextDeliveryDate
	,dblEstimatedPercentLeft = ISNULL(A.dblEstimatedPercentLeft,0.0)
	,intCntId = CAST((ROW_NUMBER()OVER (ORDER BY A.intSiteID)) AS INT)
	,strContactEmailAddress = G.strEmail
	,strFillGroup = K.strFillGroupCode
	,strFillDescription = K.strDescription
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B
		ON A.intCustomerID = B.intCustomerID
	INNER JOIN tblEMEntity C
		ON B.intCustomerNumber = C.intEntityId
	INNER JOIN tblARCustomer D
		ON C.intEntityId = D.intEntityCustomerId
	LEFT JOIN tblSMCompanyLocation E
		ON A.intLocationId = E.intCompanyLocationId
	INNER JOIN [tblEMEntityToContact] F
		ON D.intEntityCustomerId = F.intEntityId 
			and F.ysnDefaultContact = 1
	INNER JOIN tblEMEntity G 
		ON F.intEntityContactId = G.intEntityId
	LEFT JOIN tblICItem I
		ON A.intProduct = I.intItemId
	LEFT JOIN tblTMFillMethod H
		ON A.intFillMethodId = H.intFillMethodId
	LEFT JOIN tblTMFillGroup K
		ON A.intFillGroupId = K.intFillGroupId
	LEFT JOIN (
					SELECT Y.strSerialNumber 
						,Z.intSiteID
					FROM tblTMSiteDevice Z
					INNER JOIN tblTMDevice Y
						ON Z.intDeviceId = Y.intDeviceId
					INNER JOIN tblTMDeviceType X
						ON Y.intDeviceTypeId = X.intDeviceTypeId
					WHERE X.strDeviceType = 'Tank'
				) J
					ON A.intSiteID = J.intSiteID
	WHERE ISNULL(D.ysnActive,0) = 1
GO