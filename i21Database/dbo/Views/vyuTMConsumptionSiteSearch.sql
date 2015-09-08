CREATE VIEW [dbo].[vyuTMConsumptionSiteSearch]
AS  
	SELECT 
	strKey = C.strEntityNo
	,strCustomerName = C.strName
	,strPhone = (CASE WHEN CHARINDEX('x', G.strPhone) > 0 THEN SUBSTRING(SUBSTRING(G.strPhone,1,15), 0, CHARINDEX('x',G.strPhone)) ELSE SUBSTRING(G.strPhone,1,15)END)
	,intCustomerID = B.intCustomerID 
	,strDescription = A.strDescription
	,strLocation = E.strLocationName
	,strAddress = A.strSiteAddress
	,intSiteID = A.intSiteID
	,intSiteNumber = A.intSiteNumber
	,intConcurrencyId = A.intConcurrencyId
	,strCity = A.strCity
	,strBillingBy = A.strBillingBy
	,strSerialNumbers = REPLACE((SELECT Y.strSerialNumber + ', '
						FROM tblTMSiteDevice Z
						INNER JOIN tblTMDevice Y
							ON Z.intDeviceId = Y.intDeviceId
						WHERE Z.intSiteID = A.intSiteID
							AND RTRIM(ISNULL(strSerialNumber,''))<> ''
						ORDER BY Z.intSiteDeviceID
						FOR XML PATH ('')) + '#@$',', #@$','')
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B
		ON A.intCustomerID = B.intCustomerID
	INNER JOIN tblEntity C
		ON B.intCustomerNumber = C.intEntityId
	INNER JOIN tblARCustomer D
		ON C.intEntityId = D.intEntityCustomerId
	LEFT JOIN tblSMCompanyLocation E
		ON A.intLocationId = E.intCompanyLocationId
	INNER JOIN tblEntityToContact F
		ON D.intEntityCustomerId = F.intEntityId 
			and F.ysnDefaultContact = 1
	INNER JOIN tblEntity G 
		ON F.intEntityContactId = G.intEntityId
	WHERE ISNULL(D.ysnActive,0) = 1
GO