GO
	PRINT 'START OF CREATING [uspTMRecreateItemView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateItemView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateItemView
GO

CREATE PROCEDURE uspTMRecreateItemView 
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

	

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwitmmst')
	BEGIN
		DROP VIEW vwitmmst
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1)
	BEGIN
	-- AG VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwitmmst]  
					AS  
					SELECT  
					vwitm_no = agitm_no  COLLATE Latin1_General_CI_AS
					,vwitm_loc_no = agitm_loc_no  COLLATE Latin1_General_CI_AS
					,vwitm_class = agitm_class  COLLATE Latin1_General_CI_AS
					,vwitm_search = agitm_search  
					,vwitm_desc = RTRIM(ISNULL(agitm_desc,'''')) COLLATE Latin1_General_CI_AS
					,vwitm_un_desc = CAST(agitm_un_desc AS CHAR(10))  
					,vwitm_un_prc1 = agitm_un_prc1  
					,vwitm_un_prc2 = agitm_un_prc2  
					,vwitm_un_prc3 = agitm_un_prc3  
					,vwitm_un_prc4 = agitm_un_prc4  
					,vwitm_un_prc5 = agitm_un_prc5  
					,vwitm_un_prc6 = agitm_un_prc6  
					,vwitm_un_prc7 = agitm_un_prc7  
					,vwitm_un_prc8 = agitm_un_prc8  
					,vwitm_un_prc9 = agitm_un_prc9  
					,vwitm_ytd_ivc_cost = agitm_ytd_ivc_cost  
					,A4GLIdentity  = CAST(A4GLIdentity   AS INT)  
					,vwitm_avail_tm = CAST(agitm_avail_tm AS CHAR(10))  
					,vwitm_phys_inv_ynbo = CAST(agitm_phys_inv_ynbo AS CHAR(10)) 
					,vwitm_deflt_percnt = CAST(ISNULL(agitm_deflt_percnt,0) AS INT)  
					,vwitm_slstax_rpt_ynha = agitm_slstax_rpt_ynha  
					,vwitm_last_un_cost = agitm_last_un_cost  
					,vwitm_avg_un_cost    = agitm_avg_un_cost  
					,vwitm_std_un_cost    = agitm_std_un_cost  
					,intConcurrencyId = 0 
					FROM agitmmst
				
				')
		END
		-- PT VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
		BEGIN
			EXEC ('
					CREATE VIEW [dbo].[vwitmmst]  
					AS  
					SELECT  
					vwitm_no = CAST(ptitm_itm_no AS CHAR(13)) COLLATE Latin1_General_CI_AS   
					,vwitm_loc_no = ptitm_loc_no  COLLATE Latin1_General_CI_AS
					,vwitm_class = ptitm_class  COLLATE Latin1_General_CI_AS
					,vwitm_search = CAST(''''  AS CHAR(13))    
					,vwitm_desc = RTRIM(ISNULL(CAST(ptitm_desc AS CHAR(33)),'''')) COLLATE Latin1_General_CI_AS
					,vwitm_un_desc = CAST(ptitm_unit  AS CHAR(10))  
					,vwitm_un_prc1 = CAST(ptitm_prc1  AS DECIMAL(18,6))    
					,vwitm_un_prc2 = CAST(ptitm_prc2  AS DECIMAL(18,6))   
					,vwitm_un_prc3 = CAST(ptitm_prc3  AS DECIMAL(18,6))    
					,vwitm_un_prc4 = CAST(0.00  AS DECIMAL(18,6))    
					,vwitm_un_prc5 = CAST(0.00  AS DECIMAL(18,6))    
					,vwitm_un_prc6 = CAST(0.00  AS DECIMAL(18,6))    
					,vwitm_un_prc7 = CAST(0.00  AS DECIMAL(18,6))    
					,vwitm_un_prc8 = CAST(0.00  AS DECIMAL(18,6))    
					,vwitm_un_prc9 = CAST(0.00  AS DECIMAL(18,6))    
					,vwitm_ytd_ivc_cost = CAST(0.00  AS DECIMAL(18,6))    
					,A4GLIdentity  = CAST(A4GLIdentity   AS INT)  
					,vwitm_avail_tm = ISNULL(ptitm_avail_tm,''N'')
					,vwitm_phys_inv_ynbo = CAST(ptitm_phys_inv_yno AS CHAR(10)) 
					,vwitm_deflt_percnt = CAST(ptitm_deflt_percnt  AS INT)
					,vwitm_slstax_rpt_ynha = ptitm_sst_yn  
					,vwitm_last_un_cost = ISNULL(ptitm_cost1,0.0)  
					,vwitm_avg_un_cost    = ptitm_avg_cost  
					,vwitm_std_un_cost    = ptitm_std_cost  
					,intConcurrencyId = 0 
					FROM ptitmmst
				
				')
		END
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vwitmmst]
			AS
			SELECT  
				vwitm_no = A.strItemNo COLLATE Latin1_General_CI_AS
				,vwitm_loc_no = C.strLocationName
				,vwitm_class = D.strCategoryCode
				,vwitm_search = CAST(''''  AS CHAR(13))    
				,vwitm_desc = A.strDescription COLLATE Latin1_General_CI_AS
				,vwitm_un_desc = ''''
				,vwitm_un_prc1 = CAST(0.0  AS DECIMAL(18,6))    
				,vwitm_un_prc2 = CAST(0.0  AS DECIMAL(18,6))   
				,vwitm_un_prc3 = CAST(0.0  AS DECIMAL(18,6))    
				,vwitm_un_prc4 = CAST(0.00  AS DECIMAL(18,6))    
				,vwitm_un_prc5 = CAST(0.00  AS DECIMAL(18,6))    
				,vwitm_un_prc6 = CAST(0.00  AS DECIMAL(18,6))    
				,vwitm_un_prc7 = CAST(0.00  AS DECIMAL(18,6))    
				,vwitm_un_prc8 = CAST(0.00  AS DECIMAL(18,6))    
				,vwitm_un_prc9 = CAST(0.00  AS DECIMAL(18,6))    
				,vwitm_ytd_ivc_cost = CAST(0.00  AS DECIMAL(18,6))    
				,A4GLIdentity  = A.intItemId
				,vwitm_avail_tm = (CASE WHEN strType = ''Service'' THEN ''S'' ELSE (CASE WHEN A.ysnAvailableTM = 1 THEN ''Y'' ELSE ''N'' END) END)
				,vwitm_phys_inv_ynbo = ISNULL(B.strCounted,'''') 
				,vwitm_deflt_percnt = CAST(ISNULL(A.dblDefaultFull,0) AS INT)
				,vwitm_slstax_rpt_ynha = ''N''  
				,vwitm_last_un_cost = ISNULL(E.dblLastCost,0.0)  
				,vwitm_avg_un_cost = ISNULL(E.dblAverageCost,0.0)  
				,vwitm_std_un_cost = ISNULL(E.dblStandardCost,0.0)  
				,intConcurrencyId = A.intConcurrencyId 
			FROM tblICItem A
			INNER JOIN tblICItemLocation B
				ON A.intItemId = B.intItemId
			INNER JOIN tblSMCompanyLocation C
				ON B.intLocationId = C.intCompanyLocationId
			LEFT JOIN tblICCategory D
				ON A.intCategoryId = D.intCategoryId
			LEFT JOIN tblICItemPricing E
				ON A.intItemId = E.intItemId 
				AND B.intLocationId = E.intItemLocationId
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateItemView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateItemView'
GO 
	EXEC ('uspTMRecreateItemView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateItemView'
GO