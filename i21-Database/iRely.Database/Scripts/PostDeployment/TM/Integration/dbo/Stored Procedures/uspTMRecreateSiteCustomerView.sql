GO
	PRINT 'START OF CREATING [uspTMRecreateSiteCustomerView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateSiteCustomerView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateSiteCustomerView
GO

CREATE PROCEDURE uspTMRecreateSiteCustomerView 
AS
BEGIN
	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMSiteCustomer')
	BEGIN
		DROP VIEW [vyuTMSiteCustomer]
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1 
	)
	BEGIN

		EXEC ('
				CREATE VIEW [dbo].[vyuTMSiteCustomer]
				AS  
					SELECT 
						A.intSiteID
						,A.intCustomerID
						,B.intCurrentSiteNumber
						,strName = (CASE WHEN C.vwcus_co_per_ind_cp = ''C''   
									THEN    RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_first_name) 
											+ RTRIM(C.vwcus_mid_init) + RTRIM(C.vwcus_name_suffix)   
									ELSE    CASE WHEN C.vwcus_first_name IS NULL OR RTRIM(C.vwcus_first_name) = ''''  
											THEN     RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_name_suffix)    
											ELSE     RTRIM(C.vwcus_last_name) + RTRIM(C.vwcus_name_suffix) + '', '' + RTRIM(C.vwcus_first_name) + RTRIM(C.vwcus_mid_init)    
											END   
									END  ) COLLATE Latin1_General_CI_AS
						,strEntityNo = C.vwcus_key COLLATE Latin1_General_CI_AS
						,A.intConcurrencyId
					FROM tblTMSite A
					INNER JOIN tblTMCustomer B
						ON A.intCustomerID = B.intCustomerID
					INNER JOIN vwcusmst C
						ON B.intCustomerNumber = C.A4GLIdentity
				
			')
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vyuTMSiteCustomer]
			AS  
				SELECT 
					A.intSiteID
					,A.intCustomerID
					,B.intCurrentSiteNumber
					,C.strName
					,C.strEntityNo
					,A.intConcurrencyId
				FROM tblTMSite A
				INNER JOIN tblTMCustomer B
					ON A.intCustomerID = B.intCustomerID
				INNER JOIN tblEMEntity C
					ON B.intCustomerNumber = C.intEntityId
			
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateSiteCustomerView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateSiteCustomerView'
GO 
	EXEC ('uspTMRecreateSiteCustomerView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateSiteCustomerView'
GO