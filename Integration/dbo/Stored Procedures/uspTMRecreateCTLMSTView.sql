GO
	PRINT 'START OF CREATING [uspTMRecreateCTLMSTView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateCTLMSTView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateCTLMSTView
GO

CREATE PROCEDURE uspTMRecreateCTLMSTView 
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

	

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwctlmst')
	BEGIN
		DROP VIEW vwctlmst
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
	-- AG VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwctlmst]
					AS
					SELECT
						A4GLIdentity		=CAST(A4GLIdentity   AS INT)
						,vwctl_key			=CAST (agctl_key AS INT)
						,vwcar_per1_desc	=CAST(agcar_per1_desc AS CHAR(20))
						,vwcar_per2_desc	=CAST(agcar_per2_desc AS CHAR(20))
						,vwcar_per3_desc	=CAST(agcar_per3_desc AS CHAR(20))
						,vwcar_per4_desc	=CAST(agcar_per4_desc AS CHAR(20))
						,vwcar_per5_desc	=CAST(agcar_per5_desc AS CHAR(20))
						,vwcar_future_desc	=agcar_future_desc	
						,vwctl_sa_cost_ind	=agctl_sa_cost_ind
						,vwctl_stmt_close_rev_dt =(SELECT agctl_stmt_close_rev_dt FROM agctlmst WHERE agctl_key=1)
					FROM agctlmst
				
				')
		END
		-- PT VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwctlmst]
					AS
					SELECT
						A4GLIdentity		=CAST(A4GLIdentity   AS INT)
						,vwctl_key			=CAST(ptctl_key AS INT)
						,vwcar_per1_desc	=CAST(pt4cf_per_desc_1 AS CHAR(20))
						,vwcar_per2_desc	=CAST(pt4cf_per_desc_2 AS CHAR(20)) 
						,vwcar_per3_desc	=CAST(pt4cf_per_desc_3 AS CHAR(20))
						,vwcar_per4_desc	=CAST(pt4cf_per_desc_4 AS CHAR(20))
						,vwcar_per5_desc	=CAST(pt4cf_per_desc_5 AS CHAR(20))  
						,vwcar_future_desc	=CAST(NULL AS CHAR(12)) 	
						,vwctl_sa_cost_ind	=CAST(pt4cf_per_desc_1 AS CHAR(1))
						,vwctl_stmt_close_rev_dt =pt3cf_eom_business_rev_dt
					FROM ptctlmst
				
				')
		END
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vwctlmst]
			AS
			SELECT
				A4GLIdentity		= 1
				,vwctl_key			= 1
				,vwcar_per1_desc	= ''Current''
				,vwcar_per2_desc	= ''11-30 Days''
				,vwcar_per3_desc	= ''31-60 Days''
				,vwcar_per4_desc	= ''61-90 Days''
				,vwcar_per5_desc	= ''Over 90 Days''
				,vwcar_future_desc	= ''Future''
				,vwctl_sa_cost_ind	= ''''
				,vwctl_stmt_close_rev_dt = 0
			FROM ptctlmst
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateCTLMSTView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateCTLMSTView'
GO 
	EXEC ('uspTMRecreateCTLMSTView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateCTLMSTView'
GO