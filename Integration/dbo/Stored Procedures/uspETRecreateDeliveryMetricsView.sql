﻿GO
	PRINT 'START OF CREATING [uspETRecreateDeliveryMetricsView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspETRecreateDeliveryMetricsView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspETRecreateDeliveryMetricsView
GO

CREATE PROCEDURE uspETRecreateDeliveryMetricsView 
AS
BEGIN
	IF OBJECT_ID('tempdb..#tblETOriginMod') IS NOT NULL DROP TABLE #tblETOriginMod

	CREATE TABLE #tblETOriginMod
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
		EXEC ('INSERT INTO #tblETOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''AG'', N''AG ACCOUNTING'', CASE ISNULL(coctl_ag, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	-- PETRO ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_pt')
	BEGIN
		EXEC ('INSERT INTO #tblETOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''PT'', N''PETRO ACCOUNTING'', CASE ISNULL(coctl_pt, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuETDeliveryMetrics')
	BEGIN
		DROP VIEW vyuETDeliveryMetrics
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
	-- AG VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblETOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vyuETDeliveryMetrics]
					AS
					SELECT 
					intDeliveryMetricsId
					,intBeginningOdometerReading
					,intEndingOdometerReading
					,dblGallonsDelivered
					,dblTotalFuelSales
					,intTotalInvoice
					,strDriverNumber COLLATE Latin1_General_CI_AS  AS strDriverNumber 
					,strTruckNumber
					,strShiftNumber
					,dtmShiftBeginDate
					,dtmShiftEndDate
					,(SELECT agsls_et_loc_no FROM agslsmst WHERE agsls_slsmn_id = A.strDriverNumber COLLATE Latin1_General_CI_AS ) AS strLocation  
					, CAST(intEndingOdometerReading-intBeginningOdometerReading as DECIMAL(18,6)) AS dblMilesPerDay 
					,dblGallonsDelivered/intTotalInvoice  AS dblGallonsPerStop 
					,dblGallonsDelivered/NULLIF(intEndingOdometerReading-intBeginningOdometerReading,0) AS dblGallonsPerMile
					FROM tblETDeliveryMetrics A
				
				')
		END
		-- PT VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblETOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vyuETDeliveryMetrics]
					AS
					SELECT 
					intDeliveryMetricsId
					,intBeginningOdometerReading
					,intEndingOdometerReading
					,dblGallonsDelivered
					,dblTotalFuelSales
					,intTotalInvoice
					,strDriverNumber COLLATE Latin1_General_CI_AS  AS strDriverNumber 
					,strTruckNumber
					,strShiftNumber
					,dtmShiftBeginDate
					,dtmShiftEndDate
					,(SELECT ptsls_et_loc_no FROM ptslsmst WHERE ptsls_slsmn_id = A.strDriverNumber COLLATE Latin1_General_CI_AS ) AS strLocation
					, CAST(intEndingOdometerReading-intBeginningOdometerReading as DECIMAL(18,6))   AS dblMilesPerDay 
					,dblGallonsDelivered/intTotalInvoice  AS dblGallonsPerStop 
					,dblGallonsDelivered/NULLIF(intEndingOdometerReading-intBeginningOdometerReading,0) AS dblGallonsPerMile
					FROM tblETDeliveryMetrics A
				')
		END
	END
	ELSE
	BEGIN
		EXEC ('CREATE VIEW [dbo].[vyuETDeliveryMetrics]
				AS
				SELECT 
				intDeliveryMetricsId
				,intBeginningOdometerReading
				,intEndingOdometerReading
				,dblGallonsDelivered
				,dblTotalFuelSales
				,intTotalInvoice
				,A.strDriverNumber COLLATE Latin1_General_CI_AS  AS strDriverNumber 
				,strTruckNumber
				,strShiftNumber
				,dtmShiftBeginDate
				,dtmShiftEndDate
			   ,C.strLocationName  AS strLocation 
			   ,CAST(intEndingOdometerReading-intBeginningOdometerReading as DECIMAL(18,6))   AS dblMilesPerDay --Odometer End - Obometer Start
			   ,dblGallonsDelivered/intTotalInvoice  AS dblGallonsPerStop --Gallons Delivered / Invoices
			   ,dblGallonsDelivered/NULLIF(intEndingOdometerReading-intBeginningOdometerReading,0) AS dblGallonsPerMile  --Gallons Delivered / (Odometer End - Odometer Start)
				FROM tblETDeliveryMetrics A
				LEFT JOIN tblEMEntity B ON A.strDriverNumber = RIGHT(RTRIM(LTRIM(B.strEntityNo)), 3)
				LEFT JOIN [tblEMEntityLocation] C ON B.intEntityId = C.intEntityId
				INNER JOIN tblARSalesperson D ON B.intEntityId = D.intEntityId
				WHERE D.strType = ''Driver''
		')
	END
END


GO
	PRINT 'END OF CREATING [uspETRecreateDeliveryMetricsView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspETRecreateDeliveryMetricsView'
GO 
	EXEC ('uspETRecreateDeliveryMetricsView')
GO 
	PRINT 'END OF EXECUTE uspETRecreateDeliveryMetricsView'
GO
