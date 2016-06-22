GO
	PRINT 'START OF CREATING [uspTMRecreateOutOfRangeBurnRateSearchView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateOutOfRangeBurnRateSearchView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateOutOfRangeBurnRateSearchView
GO

CREATE PROCEDURE uspTMRecreateOutOfRangeBurnRateSearchView 
AS
BEGIN
	IF OBJECT_ID('tempdb..#tblTMOriginMod') IS NOT NULL DROP TABLE #tblTMOriginMod

	CREATE TABLE #tblTMOriginMod
	(
		 intModId INT IDENTITY(1,1)
		, strDBName nvarchar(50) NOT NULL 
		, strPrefix NVARCHAR(5) NOT NULL UNIQUE
		, strName NVARCHAR(30) NOT NULL UNIQUE
		, ysnUsed BIT NOT NULL 
	)

	-- AG ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ag')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''AG'', N''AG ACCOUNTING'', CASE ISNULL(coctl_ag, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	-- PETRO ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_pt')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''PT'', N''PETRO ACCOUNTING'', CASE ISNULL(coctl_pt, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMOutOfRangeBurnRateSearch') 
	BEGIN
		DROP VIEW vyuTMOutOfRangeBurnRateSearch
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1
		BEGIN
			EXEC('
				CREATE VIEW [dbo].[vyuTMOutOfRangeBurnRateSearch]
				AS
				SELECT 
						strCustomerNumber = B.vwcus_key COLLATE Latin1_General_CI_AS 
						,strCustomerName = (CASE WHEN B.vwcus_co_per_ind_cp = ''C''   
												THEN RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init) + RTRIM(B.vwcus_name_suffix)   
											ELSE  
												CASE WHEN B.vwcus_first_name IS NULL OR RTRIM(B.vwcus_first_name) = ''''  
													THEN RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix)    
												ELSE
													RTRIM(B.vwcus_last_name) + RTRIM(B.vwcus_name_suffix) + '', '' + RTRIM(B.vwcus_first_name) + RTRIM(B.vwcus_mid_init)    
												END   
											END) COLLATE Latin1_General_CI_AS 
						,strSiteNumber = RIGHT(''000''+ CAST(C.intSiteNumber AS VARCHAR(3)),3)
						,strSiteAddress = C.strSiteAddress
						,strFillMethod = F.strFillMethod
						,dblCalculatedBurnRate = A.dblCalculatedBurnRate
						,dblBurnRate = A.dblBurnRateAfterDelivery
						,dblWinterDailyUse = A.dblWinterDailyUsageBetweenDeliveries 
						,dblSummerDailyUse = A.dblSummerDailyUsageBetweenDeliveries 
						,dtmInvoiceDate = A.dtmInvoiceDate
						,intCntId = CAST((ROW_NUMBER() OVER (ORDER BY A.intDeliveryHistoryID)) AS INT)
						,intLocationId = C.intLocationId
						,intCustomerID = C.intCustomerID
						,dtmDateSync = D.dtmDateSync
						,intConcurrencyId = 0
						,intSiteID = C.intSiteID
					FROM tblTMDeliveryHistory  A
					INNER JOIN tblTMSite C 
						ON C.intSiteID = A.intSiteID 
					INNER JOIN (SELECT DISTINCT intSiteID, dtmDateSync FROM tblTMSyncOutOfRange) AS D 
						ON C.intSiteID = D.intSiteID AND DATEADD(dd, DATEDIFF(dd, 0, A.dtmLastUpdated),0) = DATEADD(dd, DATEDIFF(dd, 0, D.dtmDateSync),0)
					INNER JOIN tblTMCustomer E 
						ON C.intCustomerID = E.intCustomerID
					INNER JOIN vwcusmst B 
						ON E.intCustomerNumber = B.A4GLIdentity
					LEFT JOIN tblTMFillMethod F
						ON C.intFillMethodId = F.intFillMethodId
				')
		END
		ELSE
		BEGIN
			GOTO TMNoOrigin
		END
	END
	ELSE
	BEGIN
		TMNoOrigin:
		EXEC ('
			CREATE VIEW [dbo].[vyuTMOutOfRangeBurnRateSearch]
			AS  
				SELECT 
					strCustomerNumber = B.strEntityNo
					,strCustomerName = B.strName
					,strSiteNumber = RIGHT(''000''+ CAST(C.intSiteNumber AS VARCHAR(3)),3)
					,strSiteAddress = C.strSiteAddress
					,strFillMethod = F.strFillMethod
					,dblCalculatedBurnRate = A.dblCalculatedBurnRate
					,dblBurnRate = A.dblBurnRateAfterDelivery
					,dblWinterDailyUse = A.dblWinterDailyUsageBetweenDeliveries 
					,dblSummerDailyUse = A.dblSummerDailyUsageBetweenDeliveries 
					,dtmInvoiceDate = A.dtmInvoiceDate
					,intCntId = CAST((ROW_NUMBER() OVER (ORDER BY A.intDeliveryHistoryID)) AS INT)
					,intLocationId = C.intLocationId
					,intCustomerID = C.intCustomerID
					,dtmDateSync = D.dtmDateSync
					,intConcurrencyId = 0
					,intSiteID = C.intSiteID
				FROM tblTMDeliveryHistory  A
				INNER JOIN tblTMSite C 
					ON C.intSiteID = A.intSiteID 
				INNER JOIN (SELECT DISTINCT intSiteID, dtmDateSync FROM tblTMSyncOutOfRange) AS D 
					ON C.intSiteID = D.intSiteID AND DATEADD(dd, DATEDIFF(dd, 0, A.dtmCreatedDate),0) = DATEADD(dd, DATEDIFF(dd, 0, D.dtmDateSync),0)
				INNER JOIN tblTMCustomer E 
					ON C.intCustomerID = E.intCustomerID
				INNER JOIN tblEMEntity B 
					ON E.intCustomerNumber = B.intEntityId
				LEFT JOIN tblTMFillMethod F
					ON C.intFillMethodId = F.intFillMethodId
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateOutOfRangeBurnRateSearchView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateOutOfRangeBurnRateSearchView'
GO 
	EXEC ('uspTMRecreateOutOfRangeBurnRateSearchView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateOutOfRangeBurnRateSearchView'
GO

