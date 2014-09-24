GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwitmmst')
	DROP VIEW vwitmmst
GO


-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwitmmst]  
		AS  
		SELECT  
		vwitm_no = agitm_no  
		,vwitm_loc_no = agitm_loc_no  
		,vwitm_class = agitm_class  
		,vwitm_search = agitm_search  
		,vwitm_desc = RTRIM(ISNULL(agitm_desc,'''')) 
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
		FROM agitmmst
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwitmmst]  
		AS  
		SELECT  
		vwitm_no = CAST(ptitm_itm_no AS CHAR(13))    
		,vwitm_loc_no = ptitm_loc_no  
		,vwitm_class = ptitm_class  
		,vwitm_search = CAST(''''  AS CHAR(13))    
		,vwitm_desc = RTRIM(ISNULL(CAST(ptitm_desc AS CHAR(33)),''''))
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
		,vwitm_last_un_cost = CAST(0.00  AS DECIMAL(18,6))    
		,vwitm_avg_un_cost    = ptitm_avg_cost  
		,vwitm_std_un_cost    = ptitm_std_cost  
		FROM ptitmmst
		')
GO