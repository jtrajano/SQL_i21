GO
	PRINT 'START OF CREATING [uspTMRecreateTermsView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateTermsView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateTermsView
GO

CREATE PROCEDURE uspTMRecreateTermsView 
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

	

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwtrmmst')
	BEGIN
		DROP VIEW vwtrmmst
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
	-- AG VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwtrmmst]
					AS
					SELECT 
						vwtrm_key_n = CAST(agtrm_key_n AS INT)
						,vwtrm_desc = agtrm_desc
						,A4GLIdentity= CAsT(A4GLIdentity AS INT)
					FROM
					agtrmmst
				
				')
		END
		-- PT VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwtrmmst]
					AS
					SELECT 
						vwtrm_key_n = CAST(pttrm_code AS INT)
						,vwtrm_desc = pttrm_desc
						,A4GLIdentity= CAsT(A4GLIdentity AS INT)
					FROM
					pttrmmst
				
				')
		END
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vwtrmmst]
			AS
			SELECT 
				vwtrm_key_n = CAST(strTermCode AS INT)
				,vwtrm_desc = strTerm
				,A4GLIdentity= CAsT(intTermID AS INT)
			FROM
			tblSMTerm
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateTermsView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateTermsView'
GO 
	EXEC ('uspTMRecreateTermsView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateTermsView'
GO