GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwprcmst')
	DROP VIEW vwprcmst

GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
	IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'ASP' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'spprcmst') = 1
		
		EXEC ('
			CREATE VIEW [dbo].[vwprcmst]  
			AS  
			SELECT  
			vwprc_cus_no   = spprc_cus_no     
			,vwprc_itm_no   = spprc_itm_no     
			,vwprc_class    = spprc_class      
			,vwprc_basis_ind   = spprc_basis_ind     
			,vwprc_begin_rev_dt  = spprc_begin_rev_dt    
			,vwprc_end_rev_dt  = spprc_end_rev_dt    
			,vwprc_factor   = spprc_factor     
			,vwprc_comment   = spprc_comment     
			,vwprc_cost_to_use_las = spprc_cost_to_use_las   
			,vwprc_qty_disc_by_pa = spprc_qty_disc_by_pa   
			,vwprc_units_1   = spprc_units_1     
			,vwprc_units_2   = spprc_units_2     
			,vwprc_units_3   = spprc_units_3     
			,vwprc_disc_per_un_1  = spprc_disc_per_un_1    
			,vwprc_disc_per_un_2  = spprc_disc_per_un_2    
			,vwprc_disc_per_un_3  = spprc_disc_per_un_3    
			,vwprc_fet_yn   = spprc_fet_yn     
			,vwprc_set_yn   = spprc_set_yn     
			,vwprc_sst_ynp   = spprc_sst_ynp     
			,vwprc_lc1_yn   = spprc_lc1_yn     
			,vwprc_lc2_yn   = spprc_lc2_yn     
			,vwprc_lc3_yn   = spprc_lc3_yn     
			,vwprc_lc4_yn   = spprc_lc4_yn     
			,vwprc_lc5_yn   = spprc_lc5_yn     
			,vwprc_lc6_yn   = spprc_lc6_yn     
			,vwprc_user_id   = spprc_user_id     
			,vwprc_user_rev_dt  = spprc_user_rev_dt    
			,A4GLIdentity = CAST(A4GLIdentity   AS INT)
			,vwprc_rack_vnd_no  = '''' 
			,vwprc_rack_itm_no  = ''''
			FROM  
			spprcmst
			')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
	IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PSP' and strDBName = db_name()) = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ptpdvmst') = 1
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vwprcmst]  
			AS  
			SELECT  
			vwprc_cus_no   = ptpdv_cus_no     
			,vwprc_itm_no   = ptpdv_itm_no     
			,vwprc_class    = ptpdv_class      
			,vwprc_basis_ind   = ptpdv_basis_ind     
			,vwprc_begin_rev_dt  = ptpdv_begin_rev_dt    
			,vwprc_end_rev_dt  = ptpdv_end_rev_dt    
			,vwprc_factor   = ptpdv_factor     
			,vwprc_comment   = ptpdv_comment     
			,vwprc_cost_to_use_las = ptpdv_cost_to_use_las   
			,vwprc_qty_disc_by_pa = ''''   
			,vwprc_units_1   = 0     
			,vwprc_units_2   = 0     
			,vwprc_units_3   = 0     
			,vwprc_disc_per_un_1  = 0    
			,vwprc_disc_per_un_2  = 0    
			,vwprc_disc_per_un_3  = 0    
			,vwprc_fet_yn   = ptpdv_fet_yn     
			,vwprc_set_yn   = ptpdv_set_yn     
			,vwprc_sst_ynp   = ptpdv_sst_yn     
			,vwprc_lc1_yn   = ptpdv_lc1_yn     
			,vwprc_lc2_yn   = ptpdv_lc2_yn     
			,vwprc_lc3_yn   = ptpdv_lc3_yn     
			,vwprc_lc4_yn   = ptpdv_lc4_yn     
			,vwprc_lc5_yn   = ptpdv_lc5_yn     
			,vwprc_lc6_yn   = ptpdv_lc6_yn     
			,vwprc_user_id   = NULL     
			,vwprc_user_rev_dt  = NULL    
			,A4GLIdentity = CAST(A4GLIdentity   AS INT)
			,vwprc_rack_vnd_no  = ptpdv_rack_vnd_no 
			,vwprc_rack_itm_no  = ptpdv_rack_itm_no 
			FROM  
			ptpdvmst
			')
	END
END
GO