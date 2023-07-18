CREATE VIEW [dbo].[vyuTMDeliverySite]
AS  
	SELECT 
		strKey = C.strEntityNo
		,strCustomerName = C.strName
		,intCustomerID = B.intCustomerID 
		,strDescription = A.strDescription
		,strLocation = F.strLocationName
		,strAddress = F.strAddress
		,intSiteID = A.intSiteID
		,intSiteNumber = A.intSiteNumber
		,intConcurrencyId = A.intConcurrencyId
		,strCity = F.strCity
		,strBillingBy = A.strBillingBy
		,F.intEntityLocationId
		,F.strState
		,F.strCountry
		,G.strItemNo
		,strItemDescription = G.strDescription
	FROM tblTMSite A WITH(NOLOCK)
	INNER JOIN tblTMCustomer B
		ON A.intCustomerID = B.intCustomerID
	INNER JOIN tblEMEntity C
		ON B.intCustomerNumber = C.intEntityId
	INNER JOIN tblARCustomer D
		ON C.intEntityId = D.[intEntityId]
	INNER JOIN tblEMEntityLocationConsumptionSite E
		ON A.intSiteID = E.intSiteID
	INNER JOIN tblEMEntityLocation F
		ON E.intEntityLocationId = F.intEntityLocationId
	INNER JOIN tblICItem G
		ON A.intProduct = G.intItemId


GO