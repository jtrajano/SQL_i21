GO
	PRINT 'START OF CREATING [uspTMRecreateLocationView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateLocationView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateLocationView
GO

CREATE PROCEDURE uspTMRecreateLocationView 
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

	

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwlocmst')
	BEGIN
		DROP VIEW vwlocmst
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
	-- AG VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwlocmst]
					AS
					SELECT
						agloc_loc_no	COLLATE Latin1_General_CI_AS as vwloc_loc_no,
						agloc_name		COLLATE Latin1_General_CI_AS as vwloc_name,
						agloc_addr		COLLATE Latin1_General_CI_AS as vwloc_addr,
						CAST(A4GLIdentity AS INT) as A4GLIdentity	
					FROM aglocmst
				
				')
		END
		-- PT VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwlocmst]
					AS
					SELECT
						ptloc_loc_no	COLLATE Latin1_General_CI_AS as vwloc_loc_no,
						ptloc_name		COLLATE Latin1_General_CI_AS as vwloc_name,
						ptloc_addr		COLLATE Latin1_General_CI_AS as vwloc_addr,
						CAST(A4GLIdentity AS INT) as A4GLIdentity	
					FROM ptlocmst
				
				')
		END
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vwlocmst]
			AS
			SELECT
				ptloc_loc_no = strLocationNumber
				,ptloc_name = strLocationName
				,ptloc_addr	= strAddress
				,CAST(intCompanyLocationId AS INT) as A4GLIdentity	
			FROM tblSMCompanyLocation
			
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateLocationView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateLocationView'
GO 
	EXEC ('uspTMRecreateLocationView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateLocationView'
GO