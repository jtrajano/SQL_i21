GO
	PRINT 'START OF CREATING [uspTMRecreateLocaleTaxView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateLocaleTaxView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateLocaleTaxView
GO

CREATE PROCEDURE uspTMRecreateLocaleTaxView 
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

	

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwlclmst')
	BEGIN
		DROP VIEW vwlclmst
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
	-- AG VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwlclmst]
					AS
					SELECT
						vwlcl_tax_state	=	aglcl_tax_state,
						vwlcl_tax_auth_id1	=	aglcl_tax_auth_id1,
						vwlcl_tax_auth_id2	=	aglcl_tax_auth_id2,
						vwlcl_auth_id1_desc	=	aglcl_auth_id1_desc,
						vwlcl_auth_id2_desc	=	aglcl_auth_id2_desc,
						vwlcl_fet_ivc_desc	=	aglcl_fet_ivc_desc,
						vwlcl_set_ivc_desc	=	aglcl_set_ivc_desc,
						vwlcl_lc1_ivc_desc	=	aglcl_lc1_ivc_desc,
						vwlcl_lc2_ivc_desc	=	aglcl_lc2_ivc_desc,
						vwlcl_lc3_ivc_desc	=	aglcl_lc3_ivc_desc,
						vwlcl_lc4_ivc_desc	=	aglcl_lc4_ivc_desc,
						vwlcl_lc5_ivc_desc	=	aglcl_lc5_ivc_desc
						,vwlcl_lc6_ivc_desc	=	aglcl_lc6_ivc_desc
						,vwlcl_user_id	=	aglcl_user_id
						,vwlcl_user_rev_dt	=	aglcl_user_rev_dt
						,A4GLIdentity	=	CAST(A4GLIdentity   AS INT)
						,strTaxStateLocale = ISNULL(aglcl_tax_state,'''') + ''-'' + ISNULL(aglcl_tax_auth_id1,'''') + ''-'' + ISNULL(aglcl_tax_auth_id2,'''')
						,strDescription = ''''
						,intConcurrencyId = 0 
					FROM aglclmst
				
				')
		END
		-- PT VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwlclmst]
					AS
					SELECT
						vwlcl_tax_state	=	ptlcl_state,
						vwlcl_tax_auth_id1	=	ptlcl_local1_id,
						vwlcl_tax_auth_id2	=	ptlcl_local2_id,
						vwlcl_auth_id1_desc	=	ptlcl_desc,
						vwlcl_auth_id2_desc	=	CAST(NULL AS CHAR(30)),
						vwlcl_fet_ivc_desc	=	CAST(NULL AS CHAR(20)),  
						vwlcl_set_ivc_desc	=	CAST(NULL AS CHAR(20)),
						vwlcl_lc1_ivc_desc	=	ptlcl_local1_desc,
						vwlcl_lc2_ivc_desc	=	ptlcl_local2_desc,
						vwlcl_lc3_ivc_desc	=	ptlcl_local3_desc,
						vwlcl_lc4_ivc_desc	=	ptlcl_local4_desc,
						vwlcl_lc5_ivc_desc	=	ptlcl_local5_desc
						,vwlcl_lc6_ivc_desc	=	ptlcl_local6_desc
						,vwlcl_user_id	=	CAST(NULL AS CHAR(16))
						,vwlcl_user_rev_dt	=	NULL
						,A4GLIdentity	=	CAST(A4GLIdentity   AS INT)
						,strTaxStateLocale = ISNULL(ptlcl_state,'''') + ''-'' + ISNULL(ptlcl_local1_id,'''') + ''-'' + ISNULL(ptlcl_local2_id,'''')
						,strDescription = ''''
						,intConcurrencyId = 0 
						
					FROM ptlclmst
				
				')
		END
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vwlclmst]
			AS
			SELECT
				vwlcl_tax_state	=	strTaxGroupMaster,
				vwlcl_tax_auth_id1	=	'''',
				vwlcl_tax_auth_id2	=	'''',
				vwlcl_auth_id1_desc	=	'''',
				vwlcl_auth_id2_desc	=	'''',
				vwlcl_fet_ivc_desc	=	'''',  
				vwlcl_set_ivc_desc	=	'''',
				vwlcl_lc1_ivc_desc	=	'''',
				vwlcl_lc2_ivc_desc	=	'''',
				vwlcl_lc3_ivc_desc	=	'''',
				vwlcl_lc4_ivc_desc	=	'''',
				vwlcl_lc5_ivc_desc	=	''''
				,vwlcl_lc6_ivc_desc	=	''''
				,vwlcl_user_id	=	''''
				,vwlcl_user_rev_dt	=	NULL
				,A4GLIdentity	=	CAST(intTaxGroupMasterId AS INT)
				,intConcurrencyId = 0 
				,strTaxStateLocale = strTaxGroupMaster
				,strDescription = strDescription
			FROM tblSMTaxGroupMaster
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateLocaleTaxView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateLocaleTaxView'
GO 
	EXEC ('uspTMRecreateLocaleTaxView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateLocaleTaxView'
GO