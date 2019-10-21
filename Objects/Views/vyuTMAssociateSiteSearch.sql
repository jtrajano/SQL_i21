CREATE VIEW [dbo].[vyuTMAssociateSiteSearch]
AS  
	SELECT
		intSiteId =A.intSiteID
		,intCustomerId = A.intCustomerID
		,strSiteNumber = RIGHT('000'+ CAST(A.intSiteNumber AS VARCHAR(4)),4) COLLATE Latin1_General_CI_AS
		,strBillingBy = A.strBillingBy
		,strCustomerKey = C.vwcus_key
		,strCustomerName = C.strFullCustomerName
		,strSiteAddress = A.strSiteAddress
		,strDescription = A.strDescription
		,strPhone = C.vwcus_phone
		,intParentSiteId = A.intParentSiteID
		,intConcurrencyId = A.intConcurrencyId
	FROM tblTMSite A
	INNER JOIN tblTMCustomer B
		ON A.intCustomerID = B.intCustomerID
	INNER JOIN vyuTMCustomerEntityView C
		ON B.intCustomerNumber = C.A4GLIdentity
	WHERE A.ysnActive = 1 AND C.vwcus_active_yn = 'Y'
GO