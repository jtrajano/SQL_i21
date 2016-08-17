GO
	PRINT 'START OF CREATING [uspTMRecreateOriginDegreeOptionView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateOriginDegreeOptionView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateOriginDegreeOptionView
GO

CREATE PROCEDURE uspTMRecreateOriginDegreeOptionView 
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

	

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMOriginDegreeOption')
	BEGIN
		DROP VIEW vyuTMOriginDegreeOption
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
	-- AG VIEW
		IF  (((SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1)
			AND EXISTS(SELECT TOP 1 1 FROM sys.objects where name = 'adctlmst'))
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vyuTMOriginDegreeOption]  
					AS  
					SELECT  
						vwctl_ser_dt_desc_1 = ISNULL(adctl_ser_dt_desc_1,'''')
						,vwctl_ser_dt_desc_2 = ISNULL(adctl_ser_dt_desc_2,'''')
						,vwctl_ser_dt_desc_3 = ISNULL(adctl_ser_dt_desc_3,'''')
						,vwctl_ser_dt_desc_4 = ISNULL(adctl_ser_dt_desc_4,'''')
						,vwctl_ser_dt_desc_5 = ISNULL(adctl_ser_dt_desc_5,'''')
						,vwctl_ser_dt_desc_6 = ISNULL(adctl_ser_dt_desc_6,'''')
						,vwctl_ser_dt_desc_7 = ISNULL(adctl_ser_dt_desc_7,'''')
						,intOriginDegreeOption = CAST(A4GLIdentity AS INT)
					FROM adctlmst
				
				')
		END
		-- PT VIEW
		IF  (((SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1)
			AND EXISTS(SELECT TOP 1 1 FROM sys.objects where name = 'pdctlmst')
		)
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vyuTMOriginDegreeOption]  
					AS  
					SELECT  
						vwctl_ser_dt_desc_1 = ISNULL(pdctl_ser_dt_desc_1,'''')
						,vwctl_ser_dt_desc_2 = ISNULL(pdctl_ser_dt_desc_2,'''')
						,vwctl_ser_dt_desc_3 = ISNULL(pdctl_ser_dt_desc_3,'''')
						,vwctl_ser_dt_desc_4 = ISNULL(pdctl_ser_dt_desc_4,'''')
						,vwctl_ser_dt_desc_5 = ''''
						,vwctl_ser_dt_desc_6 = ''''
						,vwctl_ser_dt_desc_7 = ''''
						,intOriginDegreeOption = CAST(A4GLIdentity AS INT)
					FROM pdctlmst
				
				')
		END
	END
	ELSE
	BEGIN
	NOORIGIN:
		EXEC ('
			CREATE VIEW [dbo].[vyuTMOriginDegreeOption]  
			AS  
			SELECT  
				vwctl_ser_dt_desc_1 = ''''
				,vwctl_ser_dt_desc_2 = ''''
				,vwctl_ser_dt_desc_3 = ''''
				,vwctl_ser_dt_desc_4 = ''''
				,vwctl_ser_dt_desc_5 = ''''
				,vwctl_ser_dt_desc_6 = ''''
				,vwctl_ser_dt_desc_7 = ''''
				,intOriginDegreeOption = 0
			WHERE 1 = 0
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateOriginDegreeOptionView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateOriginDegreeOptionView'
GO 
	EXEC ('uspTMRecreateOriginDegreeOptionView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateOriginDegreeOptionView'
GO