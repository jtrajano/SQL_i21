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
FROM  
spprcmst
