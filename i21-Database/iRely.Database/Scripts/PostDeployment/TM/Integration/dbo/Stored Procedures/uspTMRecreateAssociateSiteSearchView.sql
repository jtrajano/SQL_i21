GO
	PRINT 'START OF CREATING [uspTMRecreateAssociateSiteSearchView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateAssociateSiteSearchView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateAssociateSiteSearchView
GO


CREATE PROCEDURE uspTMRecreateAssociateSiteSearchView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMAssociateSiteSearch')
	BEGIN
		DROP VIEW vyuTMAssociateSiteSearch
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
	)
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMAssociateSiteSearch]
			AS  
				SELECT
					intSiteId = A.intSiteID
					,intCustomerId = A.intCustomerID
					,strSiteNumber = RIGHT(''000''+ CAST(A.intSiteNumber AS VARCHAR(4)),4)
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
				INNER JOIN vwcusmst C
					ON B.intCustomerNumber = C.A4GLIdentity
				WHERE A.ysnActive = 1 AND C.vwcus_active_yn = ''Y''
		')
	END
	ELSE
	BEGIN
		EXEC('
			CREATE VIEW [dbo].[vyuTMAssociateSiteSearch]
			AS  
				SELECT
					intSiteId =A.intSiteID
					,intCustomerId = A.intCustomerID
					,strSiteNumber = RIGHT(''000''+ CAST(A.intSiteNumber AS VARCHAR(4)),4)
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
				WHERE A.ysnActive = 1 AND C.vwcus_active_yn = ''Y''
		')
	END
END
GO
	PRINT 'END OF CREATING [uspTMRecreateAssociateSiteSearchView] SP'
GO
	PRINT 'START OF Execute [uspTMRecreateAssociateSiteSearchView] SP'
GO
	EXEC ('uspTMRecreateAssociateSiteSearchView')
GO
	PRINT 'END OF Execute [uspTMRecreateAssociateSiteSearchView] SP'
GO