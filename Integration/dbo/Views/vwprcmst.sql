GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwprcmst')
	DROP VIEW vwprcmst

GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'AG') = 1
BEGIN
	IF ((SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'ASP') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'spprcmst') = 1)
	BEGIN
		
		EXEC ('
			CREATE VIEW [dbo].[vwprcmst]  
			AS  
			SELECT  
			vwprc_cus_no   = spprc_cus_no  COLLATE Latin1_General_CI_AS               
			,vwprc_itm_no   = spprc_itm_no  COLLATE Latin1_General_CI_AS                
			,vwprc_class    = spprc_class  COLLATE Latin1_General_CI_AS          
			,vwprc_basis_ind   = spprc_basis_ind  COLLATE Latin1_General_CI_AS    
			,vwprc_begin_rev_dt  = spprc_begin_rev_dt    
			,vwprc_end_rev_dt  = spprc_end_rev_dt    
			,vwprc_factor   = spprc_factor     
			,vwprc_comment   = spprc_comment  COLLATE Latin1_General_CI_AS        
			,vwprc_cost_to_use_las = spprc_cost_to_use_las  COLLATE Latin1_General_CI_AS          
			,vwprc_qty_disc_by_pa = spprc_qty_disc_by_pa  COLLATE Latin1_General_CI_AS             
			,vwprc_units_1   = spprc_units_1     
			,vwprc_units_2   = spprc_units_2     
			,vwprc_units_3   = spprc_units_3     
			,vwprc_disc_per_un_1  = spprc_disc_per_un_1    
			,vwprc_disc_per_un_2  = spprc_disc_per_un_2    
			,vwprc_disc_per_un_3  = spprc_disc_per_un_3    
			,vwprc_fet_yn   = spprc_fet_yn  COLLATE Latin1_General_CI_AS              
			,vwprc_set_yn   = spprc_set_yn      COLLATE Latin1_General_CI_AS              
			,vwprc_sst_ynp   = spprc_sst_ynp      COLLATE Latin1_General_CI_AS                  
			,vwprc_lc1_yn   = spprc_lc1_yn  COLLATE Latin1_General_CI_AS   
			,vwprc_lc2_yn   = spprc_lc2_yn COLLATE Latin1_General_CI_AS    
			,vwprc_lc3_yn   = spprc_lc3_yn COLLATE Latin1_General_CI_AS     
			,vwprc_lc4_yn   = spprc_lc4_yn COLLATE Latin1_General_CI_AS    
			,vwprc_lc5_yn   = spprc_lc5_yn COLLATE Latin1_General_CI_AS         
			,vwprc_lc6_yn   = spprc_lc6_yn COLLATE Latin1_General_CI_AS         
			,vwprc_user_id   = spprc_user_id   COLLATE Latin1_General_CI_AS           
			,vwprc_user_rev_dt  = spprc_user_rev_dt  COLLATE Latin1_General_CI_AS           
			,A4GLIdentity = CAST(A4GLIdentity   AS INT)
			,vwprc_rack_vnd_no  = '''' COLLATE Latin1_General_CI_AS         
			,vwprc_rack_itm_no  = '''' COLLATE Latin1_General_CI_AS        
			FROM  
			spprcmst
			')
	END
END
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'PT') = 1
BEGIN
	IF ((SELECT TOP 1 ysnUsed FROM #tblOriginMod WHERE strPrefix = 'PSP') = 1 and
	(SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ptpdvmst') = 1)
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vwprcmst]  
			AS  
			SELECT  
			vwprc_cus_no   = ptpdv_cus_no COLLATE Latin1_General_CI_AS                
			,vwprc_itm_no   = ptpdv_itm_no COLLATE Latin1_General_CI_AS                
			,vwprc_class    = ptpdv_class COLLATE Latin1_General_CI_AS           
			,vwprc_basis_ind   = ptpdv_basis_ind  COLLATE Latin1_General_CI_AS     
			,vwprc_begin_rev_dt  = ptpdv_begin_rev_dt    
			,vwprc_end_rev_dt  = ptpdv_end_rev_dt    
			,vwprc_factor   = ptpdv_factor     
			,vwprc_comment   = ptpdv_comment  COLLATE Latin1_General_CI_AS        
			,vwprc_cost_to_use_las = ptpdv_cost_to_use_las  COLLATE Latin1_General_CI_AS          
			,vwprc_qty_disc_by_pa = ''''  COLLATE Latin1_General_CI_AS            
			,vwprc_units_1   = 0     
			,vwprc_units_2   = 0     
			,vwprc_units_3   = 0     
			,vwprc_disc_per_un_1  = 0    
			,vwprc_disc_per_un_2  = 0    
			,vwprc_disc_per_un_3  = 0    
			,vwprc_fet_yn   = ptpdv_fet_yn COLLATE Latin1_General_CI_AS
			,vwprc_set_yn   = ptpdv_set_yn  COLLATE Latin1_General_CI_AS                  
			,vwprc_sst_ynp   = ptpdv_sst_yn  COLLATE Latin1_General_CI_AS                      
			,vwprc_lc1_yn   = ptpdv_lc1_yn  COLLATE Latin1_General_CI_AS        
			,vwprc_lc2_yn   = ptpdv_lc2_yn  COLLATE Latin1_General_CI_AS        
			,vwprc_lc3_yn   = ptpdv_lc3_yn  COLLATE Latin1_General_CI_AS        
			,vwprc_lc4_yn   = ptpdv_lc4_yn  COLLATE Latin1_General_CI_AS        
			,vwprc_lc5_yn   = ptpdv_lc5_yn  COLLATE Latin1_General_CI_AS        
			,vwprc_lc6_yn   = ptpdv_lc6_yn  COLLATE Latin1_General_CI_AS        
			,vwprc_user_id   = ''''  COLLATE Latin1_General_CI_AS            
			,vwprc_user_rev_dt  = ''''  COLLATE Latin1_General_CI_AS           
			,A4GLIdentity = CAST(A4GLIdentity   AS INT)
			,vwprc_rack_vnd_no  = ptpdv_rack_vnd_no COLLATE Latin1_General_CI_AS         
			,vwprc_rack_itm_no  = ptpdv_rack_itm_no  COLLATE Latin1_General_CI_AS        
			FROM  
			ptpdvmst
			')
	END
END
GO