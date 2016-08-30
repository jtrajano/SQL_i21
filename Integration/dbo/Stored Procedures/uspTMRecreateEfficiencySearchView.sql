GO
	PRINT 'START OF CREATING [uspTMRecreateEfficiencySearchView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateEfficiencySearchView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateEfficiencySearchView
GO

CREATE PROCEDURE uspTMRecreateEfficiencySearchView 
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

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMEfficiencySearch') 
	BEGIN
		DROP VIEW vyuTMEfficiencySearch
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
		IF (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') = 1
		BEGIN
			EXEC('
				CREATE VIEW [dbo].[vyuTMEfficiencySearch]
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
						,dblTotalCapacity = C.dblTotalCapacity
						,dblSales = ISNULL(I.dblSales,0.0)
						,dblQtyDelivered = ISNULL(I.dblQuantityDelivered,0.0)
						,dblQtyChangePercent = ISNULL(I.dblChangePercent,0.0)
						,intNumberOfDeliveries = CAST(ISNULL(I.intDeliveries,0.0) AS INT)
						,dblAverageQtyDelivered = ISNULL(I.dblAverageQtyDelivered,0.0)
						,dblAverageSales = ISNULL(I.dblAverageSales,0.0)
						,dblEfficiency = ISNULL(I.dblEfficiency,0.0)
						,dblAverageBurnRate = ISNULL(I.dblAverageBurnRate,0.0)
						,dblLastSales = ISNULL(I.dblLastSales,0.0)
						,dblLastQtyDelivered = ISNULL(I.dblLastQuantityDelivered,0.0)
						,dblLastQtyChangePercent = ISNULL(I.dblLastChangePercent,0.0)
						,intLastNumberOfDeliveries = CAST(ISNULL(I.intLastDeliveries,0.0) AS INT)
						,dblLastAverageQtyDelivered = ISNULL(I.dblLastAverageQtyDelivered,0.0)
						,dblLastAverageSales = ISNULL(I.dblLastAverageSales,0.0)
						,dblLastEfficiency = ISNULL(I.dblLastEfficiency,0.0)
						,dblLastAverageBurnRate = ISNULL(I.dblLast2AverageBurnRate,0.0)
						,dblLast2Sales = ISNULL(I.dblLast2Sales,0.0)
						,dblLast2QtyDelivered = ISNULL(I.dblLast2QuantityDelivered,0.0)
						,intLast2NumberOfDeliveries = CAST(ISNULL(I.intLast2Deliveries,0.0) AS INT)
						,dblLast2AverageQtyDelivered = ISNULL(I.dblLast2AverageQtyDelivered,0.0)
						,dblLast2AverageSales = ISNULL(I.dblLast2AverageSales,0.0)
						,dblLast2Efficiency = ISNULL(I.dblLast2Efficiency,0.0)
						,dblLast2AverageBurnRate = ISNULL(I.dblLast2AverageBurnRate,0.0)
						,intConcurrencyId = 0
						,intCustomerID = C.intCustomerID
						,intSiteID = C.intSiteID
						,intCntId = CAST((ROW_NUMBER() OVER (ORDER BY C.intSiteID)) AS INT)
						,intLocationId = C.intLocationId
					FROM tblTMSite C 
					INNER JOIN tblTMCustomer E 
						ON C.intCustomerID = E.intCustomerID
					INNER JOIN vwcusmst B 
						ON E.intCustomerNumber = B.A4GLIdentity
					LEFT JOIN tblTMFillMethod F
						ON C.intFillMethodId = F.intFillMethodId
					OUTER APPLY (SELECT * FROM [fnTMGetSiteEfficiencyTable](C.intSiteID)) I
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
			CREATE VIEW [dbo].[vyuTMEfficiencySearch]
			AS  
				SELECT 
					strCustomerNumber = B.strEntityNo
					,strCustomerName = B.strName
					,strSiteNumber = RIGHT(''000''+ CAST(C.intSiteNumber AS VARCHAR(3)),3)
					,strSiteAddress = C.strSiteAddress
					,strFillMethod = F.strFillMethod
					,dblTotalCapacity = C.dblTotalCapacity
					,dblSales = ISNULL(I.dblSales,0.0)
					,dblQtyDelivered = ISNULL(I.dblQuantityDelivered,0.0)
					,dblQtyChangePercent = ISNULL(I.dblChangePercent,0.0)
					,intNumberOfDeliveries = CAST(ISNULL(I.intDeliveries,0.0) AS INT)
					,dblAverageQtyDelivered = ISNULL(I.dblAverageQtyDelivered,0.0)
					,dblAverageSales = ISNULL(I.dblAverageSales,0.0)
					,dblEfficiency = ISNULL(I.dblEfficiency,0.0)
					,dblAverageBurnRate = ISNULL(I.dblAverageBurnRate,0.0)
					,dblLastSales = ISNULL(I.dblLastSales,0.0)
					,dblLastQtyDelivered = ISNULL(I.dblLastQuantityDelivered,0.0)
					,dblLastQtyChangePercent = ISNULL(I.dblLastChangePercent,0.0)
					,intLastNumberOfDeliveries = CAST(ISNULL(I.intLastDeliveries,0.0) AS INT)
					,dblLastAverageQtyDelivered = ISNULL(I.dblLastAverageQtyDelivered,0.0)
					,dblLastAverageSales = ISNULL(I.dblLastAverageSales,0.0)
					,dblLastEfficiency = ISNULL(I.dblLastEfficiency,0.0)
					,dblLastAverageBurnRate = ISNULL(I.dblLast2AverageBurnRate,0.0)
					,dblLast2Sales = ISNULL(I.dblLast2Sales,0.0)
					,dblLast2QtyDelivered = ISNULL(I.dblLast2QuantityDelivered,0.0)
					,intLast2NumberOfDeliveries = CAST(ISNULL(I.intLast2Deliveries,0.0) AS INT)
					,dblLast2AverageQtyDelivered = ISNULL(I.dblLast2AverageQtyDelivered,0.0)
					,dblLast2AverageSales = ISNULL(I.dblLast2AverageSales,0.0)
					,dblLast2Efficiency = ISNULL(I.dblLast2Efficiency,0.0)
					,dblLast2AverageBurnRate = ISNULL(I.dblLast2AverageBurnRate,0.0)
					,intConcurrencyId = 0
					,intCustomerID = C.intCustomerID
					,intSiteID = C.intSiteID
					,intCntId = CAST((ROW_NUMBER() OVER (ORDER BY C.intSiteID)) AS INT)
					,intLocationId = C.intLocationId
				FROM tblTMSite C 
				INNER JOIN tblTMCustomer E 
					ON C.intCustomerID = E.intCustomerID
				INNER JOIN tblEMEntity B 
					ON E.intCustomerNumber = B.intEntityId
				LEFT JOIN tblTMFillMethod F
					ON C.intFillMethodId = F.intFillMethodId
				OUTER APPLY (SELECT * FROM [fnTMGetSiteEfficiencyTable](C.intSiteID)) I
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateEfficiencySearchView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateEfficiencySearchView'
GO 
	EXEC ('uspTMRecreateEfficiencySearchView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateEfficiencySearchView'
GO

