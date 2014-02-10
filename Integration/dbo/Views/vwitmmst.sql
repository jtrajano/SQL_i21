CREATE VIEW [dbo].[vwitmmst]  
AS  
SELECT  
vwitm_no = agitm_no  
,vwitm_loc_no = agitm_loc_no  
,vwitm_class = agitm_class  
,vwitm_search = agitm_search  
,vwitm_desc = agitm_desc  
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