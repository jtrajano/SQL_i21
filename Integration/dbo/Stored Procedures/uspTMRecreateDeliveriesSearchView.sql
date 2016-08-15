GO
	PRINT 'START OF CREATING [uspTMRecreateDeliveriesSearchView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateDeliveriesSearchView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateDeliveriesSearchView
GO

CREATE PROCEDURE uspTMRecreateDeliveriesSearchView 
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

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMDeliveriesSearch') 
	BEGIN
		DROP VIEW vyuTMDeliveriesSearch
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF ((SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1
			AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwitmmst') = 1
		)
		BEGIN
			EXEC('
				CREATE VIEW [dbo].[vyuTMDeliveriesSearch]
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
						,strSiteNumber = RIGHT(''0000''+ CAST(C.intSiteNumber AS VARCHAR(4)),4)
						,F.dtmInvoiceDate
						,F.strBulkPlantNumber
						,strProductDelivered
						,F.strSalesPersonID
						,C.dblTotalCapacity
						,F.dblQuantityDelivered
						,F.dblCalculatedBurnRate
						,dblAverageBurnRate =CAST( CASE WHEN ISNULL(C.dblPreviousBurnRate, 0.0) = 0 THEN ((ISNULL(F.dblCalculatedBurnRate,0.0) + ISNULL(C.dblBurnRate,0.0))/2.0) ELSE (ISNULL(F.dblCalculatedBurnRate,0.0) + ISNULL(C.dblBurnRate,0.0) + C.dblPreviousBurnRate)/3.0 END AS NUMERIC(18,6))
						,dblPercentFilled = CAST( CASE WHEN ISNULL(C.dblTotalCapacity,0) = 0 THEN 0 ELSE F.dblQuantityDelivered / C.dblTotalCapacity * 100 END AS NUMERIC(18,6))
						,dblPercentIdeal = CAST( CASE WHEN ((ISNULL(C.dblTotalCapacity,0.0) * (I.vwitm_deflt_percnt/100.00)) - ISNULL(C.dblTotalReserve,0.0))  <= 0 THEN 0 ELSE F.dblQuantityDelivered / ((ISNULL(C.dblTotalCapacity,0.0) * (I.vwitm_deflt_percnt/100.00)) - ISNULL(C.dblTotalReserve,0.0)) END AS NUMERIC(18,6)) * 100
						,intConcurrencyId = 0
						,intCustomerID = C.intCustomerID
						,intSiteID = C.intSiteID
						,F.intDeliveryHistoryID
						,intLocationId = C.intLocationId
						,F.strInvoiceNumber
					FROM tblTMSite C 
					INNER JOIN tblTMCustomer E 
						ON C.intCustomerID = E.intCustomerID
					INNER JOIN vwcusmst B 
						ON E.intCustomerNumber = B.A4GLIdentity
					INNER JOIN tblTMDeliveryHistory F
						ON C.intSiteID = F.intSiteID
					INNER JOIN vwitmmst I
						ON C.intProduct = I.A4GLIdentity
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
			CREATE VIEW [dbo].[vyuTMDeliveriesSearch]
			AS  
				SELECT 
					strCustomerNumber = B.strEntityNo
					,strCustomerName = B.strName
					,strSiteNumber = RIGHT(''0000''+ CAST(C.intSiteNumber AS VARCHAR(4)),4)
					,F.dtmInvoiceDate
					,F.strBulkPlantNumber
					,strProductDelivered = I.strItemNo
					,F.strSalesPersonID
					,C.dblTotalCapacity
					,F.dblQuantityDelivered
					,F.dblCalculatedBurnRate
					,dblAverageBurnRate =CAST( CASE WHEN ISNULL(C.dblPreviousBurnRate, 0.0) = 0 THEN ((ISNULL(F.dblCalculatedBurnRate,0.0) + ISNULL(C.dblBurnRate,0.0))/2.0) ELSE (ISNULL(F.dblCalculatedBurnRate,0.0) + ISNULL(C.dblBurnRate,0.0) + C.dblPreviousBurnRate)/3.0 END AS NUMERIC(18,6))
					,dblPercentFilled = CAST( CASE WHEN ISNULL(C.dblTotalCapacity,0) = 0 THEN 0 ELSE F.dblQuantityDelivered / C.dblTotalCapacity * 100 END AS NUMERIC(18,6))
					,dblPercentIdeal = CAST( CASE WHEN ((ISNULL(C.dblTotalCapacity,0.0) * (I.dblDefaultFull/100.00)) - ISNULL(C.dblTotalReserve,0.0))  <= 0 THEN 0 ELSE F.dblQuantityDelivered / ((ISNULL(C.dblTotalCapacity,0.0) * (I.dblDefaultFull/100.00)) - ISNULL(C.dblTotalReserve,0.0)) END AS NUMERIC(18,6)) * 100
					,intConcurrencyId = 0
					,intCustomerID = C.intCustomerID
					,intSiteID = C.intSiteID
					,F.intDeliveryHistoryID
					,intLocationId = C.intLocationId
					,F.strInvoiceNumber
				FROM tblTMSite C 
				INNER JOIN tblTMCustomer E 
					ON C.intCustomerID = E.intCustomerID
				INNER JOIN tblEMEntity B 
					ON E.intCustomerNumber = B.intEntityId
				INNER JOIN tblTMDeliveryHistory F
					ON C.intSiteID = F.intSiteID
				INNER JOIN tblICItem I
					ON C.intProduct = I.intItemId
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateDeliveriesSearchView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateDeliveriesSearchView'
GO 
	EXEC ('uspTMRecreateDeliveriesSearchView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateDeliveriesSearchView'
GO

