
GO

/****** Object:  View [dbo].[vwticmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwticmst')
Begin
	drop view vwticmst
end

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwticmst]
AS
SELECT
vwtic_ship_total	= CAST(0 AS DECIMAL(18,6))
,vwtic_cus_no	= CAST('' AS CHAR(10))
,vwtic_type	= CAST('' AS CHAR(1))
GO

/****** Object:  View [dbo].[vwtrmmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwtrmmst')
Begin
	drop view vwtrmmst
end
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwtrmmst]
AS
SELECT 
vwtrm_key_n = CAST(agtrm_key_n AS INT)
,vwtrm_desc = agtrm_desc
,A4GLIdentity= CAsT(A4GLIdentity AS INT)
FROM
agtrmmst
GO
/****** Object:  View [dbo].[vwcusmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwcusmst')
Begin
	drop view vwcusmst
end
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwcusmst]  
AS  
SELECT  
vwcus_key    = agcus_key    
,vwcus_last_name =			(CASE WHEN (agcus_co_per_ind_cp = 'P') 
									THEN RTRIM(CAST(agcus_last_name AS CHAR(25))) 
									ELSE 
										CAST(agcus_last_name AS CHAR(25))  + CAST(agcus_first_name AS CHAR(25))
									END)
,vwcus_first_name =			(CASE WHEN (agcus_co_per_ind_cp = 'P') 
									THEN RTRIM(CAST(ISNULL(agcus_first_name,'') AS CHAR(25))) 
									ELSE 
										CAST('' AS CHAR(25))
									END)   
,vwcus_mid_init = CAST('' AS CHAR(1))
,vwcus_name_suffix = CAST('' AS CHAR(2))
,vwcus_addr    = agcus_addr    
,vwcus_addr2   = agcus_addr2    
,vwcus_city    = agcus_city    
,vwcus_state   = agcus_state    
,vwcus_zip    = agcus_zip    
,vwcus_phone   = agcus_phone    
,vwcus_phone_ext  = agcus_phone_ext    
,vwcus_bill_to   = agcus_bill_to    
,vwcus_contact   = agcus_contact    
,vwcus_comments   = agcus_comments    
,vwcus_slsmn_id   = agcus_slsmn_id    
,vwcus_terms_cd   = CAST(agcus_terms_cd AS INT)    
,vwcus_prc_lvl   = agcus_prc_lvl    
,vwcus_stmt_fmt   = agcus_stmt_fmt    
,vwcus_ytd_pur   = agcus_ytd_pur    
,vwcus_ytd_sls   = agcus_ytd_sls    
,vwcus_ytd_cgs   = agcus_ytd_cgs    
,vwcus_budget_amt  = agcus_budget_amt    
,vwcus_budget_beg_mm = agcus_budget_beg_mm    
,vwcus_budget_end_mm = agcus_budget_end_mm    
,vwcus_active_yn  = agcus_active_yn    
,vwcus_ar_future  = agcus_ar_future    
,vwcus_ar_per1   = agcus_ar_per1    
,vwcus_ar_per2   = agcus_ar_per2    
,vwcus_ar_per3   = agcus_ar_per3    
,vwcus_ar_per4   = agcus_ar_per4    
,vwcus_ar_per5   = agcus_ar_per5    
,vwcus_pend_ivc   = agcus_pend_ivc    
,vwcus_cred_reg   = agcus_cred_reg    
,vwcus_pend_pymt  = agcus_pend_pymt    
,vwcus_cred_ga   = agcus_cred_ga    
,vwcus_co_per_ind_cp = CAST(agcus_co_per_ind_cp AS CHAR(4))  
,vwcus_bus_loc_no  = agcus_bus_loc_no   
,vwcus_cred_limit  = agcus_cred_limit  
,vwcus_last_stmt_bal = agcus_last_stmt_bal  
,vwcus_budget_amt_due = CAST(agcus_budget_amt_due AS DECIMAL(18,6))  
,vwcus_cred_ppd   = agcus_cred_ppd  
,vwcus_ytd_srvchr  = CAST(agcus_ytd_srvchr AS DECIMAL(18,6))  
,vwcus_last_pymt  = agcus_last_pymt  
,vwcus_last_pay_rev_dt = agcus_last_pay_rev_dt  
,vwcus_last_ivc_rev_dt = agcus_last_ivc_rev_dt  
,vwcus_high_cred  = agcus_high_cred   
,vwcus_high_past_due = agcus_high_past_due  
,vwcus_avg_days_pay  = agcus_avg_days_pay  
,vwcus_avg_days_no_ivcs = agcus_avg_days_no_ivcs  
,vwcus_last_stmt_rev_dt = agcus_last_stmt_rev_dt  
,vwcus_country   = agcus_country  
,vwcus_termdescription  = (select top 1 agtrm_desc from agtrmmst where agtrm_key_n = agcus_terms_cd)  
,vwcus_tax_ynp   = agcus_tax_ynp  
,vwcus_tax_state  = agcus_tax_state  
,A4GLIdentity= CAST(A4GLIdentity as INT)  
,vwcus_phone2   =agcus_phone2  
,vwcus_balance = agcus_ar_future + agcus_ar_per1 + agcus_ar_per2 + agcus_ar_per3 + agcus_ar_per4 + agcus_ar_per5 - agcus_cred_reg - agcus_cred_ga  
,vwcus_ptd_sls = agcus_ptd_sls   
,vwcus_lyr_sls = agcus_lyr_sls
FROM agcusmst
GO


/****** Object:  View [dbo].[vwctlmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwctlmst')
Begin
	drop view vwctlmst
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO
/****** Object:  View [dbo].[vwcoctlmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwcoctlmst')
Begin
	drop view vwcoctlmst
end
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwcoctlmst]
AS
SELECT
vwcoctl_le_yn = coctl_le_yn
,vwctl_sp_yn = coctl_sp_yn
,A4GLIdentity = CAST(A4GLIdentity   AS INT)
FROM
coctlmst
GO
/****** Object:  View [dbo].[vwcntmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwcntmst')
Begin
	drop view vwcntmst
end
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwcntmst]
AS
SELECT
vwcnt_cus_no=agcnt_cus_no
,vwcnt_cnt_no= agcnt_cnt_no
,vwcnt_line_no= agcnt_line_no
,vwcnt_alt_cus=agcnt_alt_cus
,vwcnt_itm_or_cls=agcnt_itm_or_cls
,vwcnt_loc_no=agcnt_loc_no
,vwcnt_alt_cnt_no=agcnt_alt_cnt_no
,vwcnt_amt_orig=agcnt_amt_orig
,vwcnt_amt_bal=agcnt_amt_bal
,vwcnt_due_rev_dt= CONVERT(DATETIME, SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),1,4) + '/' 
								+ SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),5,2) + '/' 
								+  SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),7,2), 101) -- yyy/mm/dd
,vwcnt_hdr_comments=agcnt_hdr_comments
,vwcnt_un_orig=agcnt_un_orig
,vwcnt_un_bal=agcnt_un_bal
,vwcnt_lc1_yn=agcnt_lc1_yn
,vwcnt_lc2_yn=agcnt_lc2_yn
,vwcnt_lc3_yn=agcnt_lc3_yn
,vwcnt_lc4_yn =agcnt_lc4_yn
,vwcnt_lc5_yn =agcnt_lc5_yn
,vwcnt_lc6_yn =agcnt_lc6_yn
,vwcnt_ppd_yndm =agcnt_ppd_yndm
,vwcnt_un_prc=agcnt_un_prc
,vwcnt_prc_lvl = agcnt_prc_lvl
,A4GLIdentity = CAST(A4GLIdentity   AS INT)

FROM agcntmst
GO
/****** Object:  View [dbo].[vwcmtmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwcmtmst')
Begin
	drop view vwcmtmst
end
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwcmtmst]
AS
SELECT
vwcmt_cus_no				=agcmt_cus_no
,vwcmt_com_typ				=agcmt_com_typ
,vwcmt_com_cd				=CAST(agcmt_com_cd AS CHAR(4))
,vwcmt_com_seq				=CAST(agcmt_com_seq AS CHAR(4))
,vwcmt_data					=agcmt_data
,vwcmt_payee_1				=agcmt_payee_1
,vwcmt_payee_2				=agcmt_payee_2
,vwcmt_rc_lic_no			=agcmt_rc_lic_no
,vwcmt_rc_exp_rev_dt		=agcmt_rc_exp_rev_dt
,vwcmt_rc_comment			=agcmt_rc_comment
,vwcmt_rc_custom_yn			=CAST(agcmt_rc_custom_yn AS CHAR(4))
,vwcmt_tr_ins_no			=agcmt_tr_ins_no
,vwcmt_tr_exp_rev_dt		=agcmt_tr_exp_rev_dt
,vwcmt_tr_comment			=agcmt_tr_comment
,vwcmt_ord_comment1			=agcmt_ord_comment1
,vwcmt_ord_comment2			=CAST(agcmt_ord_comment2 AS CHAR(60))
,vwcmt_fax_contact			=agcmt_fax_contact
,vwcmt_fax_to_fax_num		=agcmt_fax_to_fax_num
,vwcmt_eml_contact			=agcmt_eml_contact
,vwcmt_eml_address			=agcmt_eml_address
,vwcmt_stl_lic_no			=agcmt_stl_lic_no
,vwcmt_stl_exp_rev_dt		=agcmt_stl_exp_rev_dt
,vwcmt_stl_comment			=agcmt_stl_comment
,vwcmt_user_id				=agcmt_user_id
,vwcmt_user_rev_dt			=agcmt_user_rev_dt
,A4GLIdentity	= CAST(A4GLIdentity   AS INT)
FROM agcmtmst
GO
/****** Object:  View [dbo].[vwclsmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwclsmst')
Begin
	drop view vwclsmst
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwclsmst]
AS
SELECT
vwcls_desc				=CAST(agcls_desc AS CHAR(20))		 		
,vwcls_sls_acct_no		=agcls_sls_acct_no	
,vwcls_pur_acct_no		=agcls_pur_acct_no	
,vwcls_var_acct_no		=agcls_var_acct_no	
,vwcls_inv_acct_no		=agcls_inv_acct_no	
,vwcls_beg_inv_acct_no	=agcls_beg_inv_acct_no	
,vwcls_end_inv_acct_no	=agcls_end_inv_acct_no	
,vwcls_cd =agcls_cd
,A4GLIdentity	= CAST(A4GLIdentity   AS INT)
FROM agclsmst
GO
/****** Object:  View [dbo].[vwapivcmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwapivcmst')
Begin
	drop view vwapivcmst
end
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwapivcmst]  
AS  
SELECT  
 vwivc_vnd_no = apivc_vnd_no  
, vwivc_ivc_no = apivc_ivc_no  
, vwivc_status_ind = apivc_status_ind  
, vwivc_cbk_no = apivc_cbk_no  
, vwivc_chk_no = apivc_chk_no  
, vwivc_trans_type = apivc_trans_type  
, vwivc_pay_ind = apivc_pay_ind  
, vwivc_ap_audit_no = apivc_ap_audit_no  
, vwivc_pur_ord_no = apivc_pur_ord_no  
, vwivc_po_rcpt_seq = apivc_po_rcpt_seq  
, vwivc_ivc_rev_dt = apivc_ivc_rev_dt  
, vwivc_disc_rev_dt = apivc_disc_rev_dt  
, vwivc_due_rev_dt = apivc_due_rev_dt  
, vwivc_chk_rev_dt = apivc_chk_rev_dt  
, vwivc_gl_rev_dt = apivc_gl_rev_dt  
, vwivc_orig_amt = apivc_orig_amt  
, vwivc_disc_avail = apivc_disc_avail  
, vwivc_disc_taken = apivc_disc_taken  
, vwivc_wthhld_amt = apivc_wthhld_amt  
, vwivc_net_amt = apivc_net_amt  
, vwivc_1099_amt = apivc_1099_amt  
, vwivc_comment = apivc_comment  
, vwivc_adv_chk_no = apivc_adv_chk_no  
, vwivc_recur_yn = apivc_recur_yn  
, vwivc_currency = apivc_currency  
, vwivc_currency_rt = apivc_currency_rt  
, vwivc_currency_cnt = apivc_currency_cnt  
, vwivc_user_id = apivc_user_id  
, vwivc_user_rev_dt = apivc_user_rev_dt  
, A4GLIdentity = CAST(A4GLIdentity   AS INT)
FROM apivcmst
GO
/****** Object:  View [dbo].[vwtaxmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwtaxmst')
Begin
	drop view vwtaxmst
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwtaxmst]  
AS  
SELECT  
  
 vwtax_itm_no   = agtax_itm_no  
, vwtax_state    = agtax_state  
, vwtax_auth_id1   = agtax_auth_id1  
, vwtax_auth_id2   = agtax_auth_id2  
, vwtax_if_rt    = agtax_if_rt  
, vwtax_if_gl_acct  = agtax_if_gl_acct  
, vwtax_fet_rt   = CAST(agtax_fet_rt AS DECIMAL(18,6))  
, vwtax_fet_sls_acct  = agtax_fet_sls_acct  
, vwtax_fet_pur_acct  = agtax_fet_pur_acct  
, vwtax_fet_eft_yn  = CAST(agtax_fet_eft_yn AS CHAR(4))  
, vwtax_set_rt   = agtax_set_rt  
, vwtax_set_sls_acct  = agtax_set_sls_acct  
, vwtax_set_pur_acct  = agtax_set_pur_acct  
, vwtax_set_eft_yn  = CAST(agtax_set_eft_yn AS CHAR(4))  
, vwtax_sst_rt   = agtax_sst_rt  
, vwtax_sst_sls_acct  = agtax_sst_sls_acct  
, vwtax_sst_pur_acct  = agtax_sst_pur_acct  
, vwtax_sst_pu   = agtax_sst_pu  
, vwtax_sst_on_fet_yn  = CAST(agtax_sst_on_fet_yn AS CHAR(4))  
, vwtax_sst_on_set_yn  = agtax_sst_on_set_yn  
, vwtax_sst_eft_yn  = CAST(agtax_sst_eft_yn AS CHAR(4))  
, vwtax_pst_rt   = agtax_pst_rt  
, vwtax_pst_sls_acct  = agtax_pst_sls_acct  
, vwtax_pst_pur_acct  = agtax_pst_pur_acct  
, vwtax_pst_pu   = CAST(agtax_pst_pu AS CHAR(4))  
, vwtax_pst_on_fet_yn  = CAST(agtax_pst_on_fet_yn AS CHAR(4))  
, vwtax_pst_on_set_yn  = CAST(agtax_pst_on_set_yn AS CHAR(4))  
, vwtax_lc1_rt   = agtax_lc1_rt  
, vwtax_lc1_sls_acct  = agtax_lc1_sls_acct  
, vwtax_lc1_pur_acct  = agtax_lc1_pur_acct  
, vwtax_lc1_pu   = CAST(agtax_lc1_pu AS CHAR(4))  
, vwtax_sst_on_lc1_yn  = CAST(agtax_sst_on_lc1_yn AS CHAR(4))  
, vwtax_lc1_on_fet_yn  = CAST(agtax_lc1_on_fet_yn AS CHAR(4))  
, vwtax_lc1_eft_yn  = agtax_lc1_eft_yn  
, vwtax_lc1_scrn_desc  = CAST(agtax_lc1_scrn_desc AS CHAR(4))  
, vwtax_lc2_rt   = agtax_lc2_rt  
, vwtax_lc2_sls_acct  = agtax_lc2_sls_acct  
, vwtax_lc2_pur_acct  = agtax_lc2_pur_acct  
, vwtax_lc2_pu   = CAST(agtax_lc2_pu AS CHAR(4))  
, vwtax_sst_on_lc2_yn  = CAST(agtax_sst_on_lc2_yn AS CHAR(4))  
, vwtax_lc2_on_fet_yn  = CAST(agtax_lc2_on_fet_yn AS CHAR(4))  
, vwtax_lc2_eft_yn  = agtax_lc2_eft_yn  
, vwtax_lc2_scrn_desc  = CAST(agtax_lc2_scrn_desc AS CHAR(4))  
, vwtax_lc3_rt   = agtax_lc3_rt  
, vwtax_lc3_sls_acct  = agtax_lc3_sls_acct  
, vwtax_lc3_pur_acct  = agtax_lc3_pur_acct  
, vwtax_lc3_pu   = CAST(agtax_lc3_pu AS CHAR(4))  
, vwtax_sst_on_lc3_yn  = CAST(agtax_sst_on_lc3_yn AS CHAR(4))  
, vwtax_lc3_on_fet_yn  = CAST(agtax_lc3_on_fet_yn AS CHAR(4))  
, vwtax_lc3_eft_yn  = CAST(agtax_lc3_eft_yn AS CHAR(4))  
, vwtax_lc3_scrn_desc  = CAST(agtax_lc3_scrn_desc AS CHAR(4))  
, vwtax_lc4_rt   = agtax_lc4_rt  
, vwtax_lc4_sls_acct  = agtax_lc4_sls_acct  
, vwtax_lc4_pur_acct  = agtax_lc4_pur_acct  
, vwtax_lc4_pu   = CAST(agtax_lc4_pu AS CHAR(4))  
, vwtax_sst_on_lc4_yn  = CAST(agtax_sst_on_lc4_yn AS CHAR(4))  
, vwtax_lc4_on_fet_yn  = CAST(agtax_lc4_on_fet_yn AS CHAR(4))  
, vwtax_lc4_eft_yn  = agtax_lc4_eft_yn  
, vwtax_lc4_scrn_desc  = CAST(agtax_lc4_scrn_desc AS CHAR(4))  
, vwtax_lc5_rt   = agtax_lc5_rt  
, vwtax_lc5_sls_acct  = agtax_lc5_sls_acct  
, vwtax_lc5_pur_acct  = agtax_lc5_pur_acct  
, vwtax_lc5_pu   = CAST(agtax_lc5_pu AS CHAR(4))  
, vwtax_sst_on_lc5_yn  = CAST(agtax_sst_on_lc5_yn AS CHAR(4))  
, vwtax_lc5_on_fet_yn  = CAST(agtax_lc5_on_fet_yn AS CHAR(4))  
, vwtax_lc5_eft_yn  = agtax_lc5_eft_yn  
, vwtax_lc5_scrn_desc  = CAST(agtax_lc5_scrn_desc AS CHAR(4))  
, vwtax_lc6_rt   = agtax_lc6_rt  
, vwtax_lc6_sls_acct  = agtax_lc6_sls_acct  
, vwtax_lc6_pur_acct  = agtax_lc6_pur_acct  
, vwtax_lc6_pu   = CAST(agtax_lc6_pu AS CHAR(4))  
, vwtax_sst_on_lc6_yn  = CAST(agtax_sst_on_lc6_yn AS CHAR(4))  
, vwtax_lc6_on_fet_yn  = CAST(agtax_lc6_on_fet_yn AS CHAR(4))  
, vwtax_lc6_eft_yn  = agtax_lc6_eft_yn  
, vwtax_lc6_scrn_desc  = CAST(agtax_lc6_scrn_desc AS CHAR(4))  
, vwtax_user_id   = agtax_user_id  
, vwtax_user_rev_dt  = agtax_user_rev_dt  
, A4GLIdentity   = CAST(A4GLIdentity   AS INT)
FROM [agtaxmst]
GO

/****** Object:  View [dbo].[vwslsmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwslsmst')
Begin
	drop view vwslsmst
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwslsmst]  
AS  
SELECT  
  
vwsls_slsmn_id   = agsls_slsmn_id  
,vwsls_name    =  ISNULL(agsls_name, '')
,vwsls_addr1   = agsls_addr1  
,vwsls_addr2   = agsls_addr2  
,vwsls_city    = agsls_city  
,vwsls_state   = agsls_state  
,vwsls_zip    = agsls_zip  
,vwsls_country   = CAST(agsls_country AS CHAR(4))  
,vwsls_phone   = agsls_phone  
,vwsls_sales_ty_1  = agsls_sales_ty_1  
,vwsls_sales_ty_2  = agsls_sales_ty_2  
,vwsls_sales_ty_3  = agsls_sales_ty_3  
,vwsls_sales_ty_4  = agsls_sales_ty_4  
,vwsls_sales_ty_5  = agsls_sales_ty_5  
,vwsls_sales_ty_6  = agsls_sales_ty_6  
,vwsls_sales_ty_7  = agsls_sales_ty_7  
,vwsls_sales_ty_8  = agsls_sales_ty_8  
,vwsls_sales_ty_9  = agsls_sales_ty_9  
,vwsls_sales_ty_10  = agsls_sales_ty_10  
,vwsls_sales_ty_11  = agsls_sales_ty_11  
,vwsls_sales_ty_12  = agsls_sales_ty_12  
,vwsls_sales_ly_1  = agsls_sales_ly_1  
,vwsls_sales_ly_2  = agsls_sales_ly_2  
,vwsls_sales_ly_3  = agsls_sales_ly_3  
,vwsls_sales_ly_4  = agsls_sales_ly_4  
,vwsls_sales_ly_5  = agsls_sales_ly_5  
,vwsls_sales_ly_6  = agsls_sales_ly_6  
,vwsls_sales_ly_7  = agsls_sales_ly_7  
,vwsls_sales_ly_8  = agsls_sales_ly_8  
,vwsls_sales_ly_9  = agsls_sales_ly_9  
,vwsls_sales_ly_10  = agsls_sales_ly_10  
,vwsls_sales_ly_11  = agsls_sales_ly_11  
,vwsls_sales_ly_12  = agsls_sales_ly_12  
,vwsls_profit_ty_1  = agsls_profit_ty_1  
,vwsls_profit_ty_2  = agsls_profit_ty_2  
,vwsls_profit_ty_3  = agsls_profit_ty_3  
,vwsls_profit_ty_4  = agsls_profit_ty_4  
,vwsls_profit_ty_5  = agsls_profit_ty_5  
,vwsls_profit_ty_6  = agsls_profit_ty_6  
,vwsls_profit_ty_7  = agsls_profit_ty_7  
,vwsls_profit_ty_8  = agsls_profit_ty_8  
,vwsls_profit_ty_9  = agsls_profit_ty_9  
,vwsls_profit_ty_10  = agsls_profit_ty_10  
,vwsls_profit_ty_11  = agsls_profit_ty_11  
,vwsls_profit_ty_12  = agsls_profit_ty_12  
,vwsls_profit_ly_1  = agsls_profit_ly_1  
,vwsls_profit_ly_2  = agsls_profit_ly_2  
,vwsls_profit_ly_3  = agsls_profit_ly_3  
,vwsls_profit_ly_4  = agsls_profit_ly_4  
,vwsls_profit_ly_5  = agsls_profit_ly_5  
,vwsls_profit_ly_6  = agsls_profit_ly_6  
,vwsls_profit_ly_7  = agsls_profit_ly_7  
,vwsls_profit_ly_8  = agsls_profit_ly_8  
,vwsls_profit_ly_9  = agsls_profit_ly_9  
,vwsls_profit_ly_10  = agsls_profit_ly_10  
,vwsls_profit_ly_11  = agsls_profit_ly_11  
,vwsls_profit_ly_12  = agsls_profit_ly_12  
,vwsls_email   = agsls_email  
,vwsls_textmsg_email = agsls_textmsg_email  
,vwsls_dispatch_email = CAST(agsls_dispatch_email AS CHAR(4))  
,vwsls_user_id   = agsls_user_id  
,vwsls_user_rev_dt  = agsls_user_rev_dt  
,A4GLIdentity  = CAST(A4GLIdentity   AS INT)
FROM agslsmst
GO

/****** Object:  View [dbo].[vwpyemst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwpyemst')
Begin
	drop view vwpyemst
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwpyemst]
AS
SELECT 
vwpye_amt	= agpye_amt
,vwpye_cus_no	=agpye_cus_no
from
agpyemst
GO

/****** Object:  View [dbo].[vwprcmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwprcmst')
Begin
	drop view vwprcmst
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
GO

/****** Object:  View [dbo].[vwlocmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwlocmst')
Begin
	drop view vwlocmst
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwlocmst]
AS

SELECT
	agloc_loc_no	COLLATE Latin1_General_CI_AS as vwloc_loc_no,
	agloc_name		COLLATE Latin1_General_CI_AS as vwloc_name,
	agloc_addr		COLLATE Latin1_General_CI_AS as vwloc_addr,
	CAST(A4GLIdentity AS INT) as A4GLIdentity	
FROM aglocmst
GO

/****** Object:  View [dbo].[vwlclmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwlclmst')
Begin
	drop view vwlclmst
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
FROM aglclmst
GO


/****** Object:  View [dbo].[vwivcmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwivcmst')
Begin
	drop view vwivcmst
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwivcmst]
AS
SELECT
vwivc_bill_to_cus		=	agivc_bill_to_cus
,vwivc_ivc_no			=	agivc_ivc_no
,vwivc_loc_no			=	agivc_loc_no
,vwivc_type				=	CAST(agivc_type AS CHAR(4))
,vwivc_status			=	CAST(agivc_status AS CHAR(3))
,vwivc_rev_dt			=	agivc_rev_dt
,vwivc_comment			=	agivc_comment
,vwivc_po_no			=	agivc_po_no
,vwivc_sold_to_cus		=	agivc_sold_to_cus
,vwivc_slsmn_no			=	CAST(agivc_slsmn_no AS CHAR(4))
,vwivc_slsmn_tot		=	agivc_slsmn_tot
,vwivc_net_amt			=	agivc_net_amt
,vwivc_slstx_amt		=	CAST(agivc_slstx_amt AS DECIMAL(18,6))
,vwivc_srvchr_amt		=	agivc_srvchr_amt
,vwivc_disc_amt			=	CAST(agivc_disc_amt AS DECIMAL(18,6))
,vwivc_amt_paid			=	agivc_amt_paid
,vwivc_bal_due			=	agivc_bal_due
,vwivc_pend_disc		=	CAST(agivc_pend_disc AS DECIMAL(18,6))
,vwivc_no_payments		=	CAST(agivc_no_payments AS INT)
,vwivc_adj_inv_yn		=	agivc_adj_inv_yn
,vwivc_srvchr_cd		=	CAST(agivc_srvchr_cd AS INT)
,vwivc_disc_rev_dt		=	agivc_disc_rev_dt
,vwivc_net_rev_dt		=	agivc_net_rev_dt
,vwivc_src_sys			=	CAST(agivc_src_sys AS CHAR(4))
,vwivc_orig_rev_dt		=	agivc_orig_rev_dt
,vwivc_split_no			=	agivc_split_no
,vwivc_pd_days_old		=	CAST(agivc_pd_days_old AS INT)
,vwivc_currency			=	CAST(agivc_currency AS CHAR(4))
,vwivc_currency_rt		=	agivc_currency_rt
,vwivc_currency_cnt		=	agivc_currency_cnt
,vwivc_eft_ivc_paid_yn	=	agivc_eft_ivc_paid_yn
,vwivc_terms_code		=	CAST(agivc_terms_code AS CHAR(4))
,vwivc_pay_type			=	CAST(agivc_pay_type AS CHAR(4))
,vwivc_user_id			=	agivc_user_id
,vwivc_user_rev_dt		=	agivc_user_rev_dt
,A4GLIdentity			=	CAST(A4GLIdentity   AS INT)
FROM agivcmst
GO

/****** Object:  View [dbo].[vwitmmst]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwitmmst')
Begin
	drop view vwitmmst
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwitmmst]
AS
SELECT
--vwitm_no						=	agitm_no
--,vwitm_loc_no					=	agitm_loc_no
--,vwitm_class					=	agitm_class
--,vwitm_search					=	agitm_search
--,vwitm_bar_code_ind				=	agitm_bar_code_ind
--,vwitm_upc_code					=	agitm_upc_code
--,vwitm_desc						=	agitm_desc
--,vwitm_binloc					=	CAST(agitm_binloc AS CHAR(10))
--,vwitm_vnd_no					=	agitm_vnd_no
--,vwitm_fml_lvl					=	agitm_fml_lvl
--,vwitm_un_desc					=	CAST(agitm_un_desc AS CHAR(10))
--,vwitm_lbs_per_un				=	agitm_lbs_per_un
--,vwitm_un_per_pak				=	agitm_un_per_pak
--,vwitm_pak_desc					=	agitm_pak_desc
--,vwitm_phys_inv_ynbo			=	agitm_phys_inv_ynbo
--,vwitm_sls_acct					=	agitm_sls_acct
--,vwitm_pur_acct					=	agitm_pur_acct
--,vwitm_var_acct					=	agitm_var_acct
--,vwitm_std_un_cost				=	agitm_std_un_cost
--,vwitm_avg_un_cost				=	agitm_avg_un_cost
--,vwitm_eom_un_cost				=	agitm_eom_un_cost
--,vwitm_last_un_cost				=	agitm_last_un_cost
--,vwitm_last_cost_chg_rev_dt		=	agitm_last_cost_chg_rev_dt
--,vwitm_un_prc1					=	agitm_un_prc1
--,vwitm_un_prc2					=	agitm_un_prc2
--,vwitm_un_prc3					=	agitm_un_prc3
--,vwitm_un_prc4					=	agitm_un_prc4
--,vwitm_un_prc5					=	agitm_un_prc5
--,vwitm_un_prc6					=	agitm_un_prc6
--,vwitm_un_prc7					=	agitm_un_prc7
--,vwitm_un_prc8					=	agitm_un_prc8
--,vwitm_un_prc9					=	agitm_un_prc9
--,vwitm_prc_no_dec				=	agitm_prc_no_dec
--,vwitm_prc_calc_ind				=	CAST(agitm_prc_calc_ind AS CHAR(10))
--,vwitm_prc_lst_ind				=	CAST(agitm_prc_lst_ind AS CHAR(10))
--,vwitm_prc_calc1				=	agitm_prc_calc1
--,vwitm_prc_calc2				=	agitm_prc_calc2
--,vwitm_prc_calc3				=	agitm_prc_calc3
--,vwitm_prc_calc4				=	agitm_prc_calc4
--,vwitm_prc_calc5				=	agitm_prc_calc5
--,vwitm_prc_calc6				=	agitm_prc_calc6
--,vwitm_prc_calc7				=	agitm_prc_calc7
--,vwitm_prc_calc8				=	agitm_prc_calc8
--,vwitm_prc_calc9				=	agitm_prc_calc9
--,vwitm_min_un_prc				=	agitm_min_un_prc
--,vwitm_max_un_prc				=	agitm_max_un_prc
--,vwitm_disc_cupn_ind			=	CAST(agitm_disc_cupn_ind AS CHAR(10))
--,vwitm_disc						=	agitm_disc
--,vwitm_un_on_hand				=	agitm_un_on_hand
--,vwitm_un_mfg_in_prs			=	agitm_un_mfg_in_prs
--,vwitm_un_ord_committed			=	agitm_un_ord_committed
--,vwitm_un_cnt_committed			=	agitm_un_cnt_committed
--,vwitm_un_fert_committed		=	agitm_un_fert_committed
--,vwitm_un_on_order				=	agitm_un_on_order
--,vwitm_un_min_bal				=	agitm_un_min_bal
--,vwitm_un_max_bal				=	agitm_un_max_bal
--,vwitm_un_sold_ty_1				=	agitm_un_sold_ty_1
--,vwitm_un_sold_ty_2				=	agitm_un_sold_ty_2
--,vwitm_un_sold_ty_3				=	agitm_un_sold_ty_3
--,vwitm_un_sold_ty_4				=	agitm_un_sold_ty_4
--,vwitm_un_sold_ty_5				=	agitm_un_sold_ty_5
--,vwitm_un_sold_ty_6				=	agitm_un_sold_ty_6
--,vwitm_un_sold_ty_7				=	agitm_un_sold_ty_7
--,vwitm_un_sold_ty_8				=	agitm_un_sold_ty_8
--,vwitm_un_sold_ty_9				=	agitm_un_sold_ty_9
--,vwitm_un_sold_ty_10			=	agitm_un_sold_ty_10
--,vwitm_un_sold_ty_11			=	agitm_un_sold_ty_11
--,vwitm_un_sold_ty_12			=	agitm_un_sold_ty_12
--,vwitm_un_sold_ly_1				=	agitm_un_sold_ly_1
--,vwitm_un_sold_ly_2				=	agitm_un_sold_ly_2
--,vwitm_un_sold_ly_3				=	agitm_un_sold_ly_3
--,vwitm_un_sold_ly_4				=	agitm_un_sold_ly_4
--,vwitm_un_sold_ly_5				=	agitm_un_sold_ly_5
--,vwitm_un_sold_ly_6				=	agitm_un_sold_ly_6
--,vwitm_un_sold_ly_7				=	agitm_un_sold_ly_7
--,vwitm_un_sold_ly_8				=	agitm_un_sold_ly_8
--,vwitm_un_sold_ly_9				=	agitm_un_sold_ly_9
--,vwitm_un_sold_ly_10			=	agitm_un_sold_ly_10
--,vwitm_un_sold_ly_11			=	agitm_un_sold_ly_11
--,vwitm_un_sold_ly_12			=	agitm_un_sold_ly_12
--,vwitm_ytd_ivc_un				=	agitm_ytd_ivc_un
--,vwitm_ytd_ivc_cost				=	agitm_ytd_ivc_cost
--,vwitm_un_pend_ivcs				=	agitm_un_pend_ivcs
--,vwitm_last_purch_rev_dt		=	agitm_last_purch_rev_dt
--,vwitm_last_sale_rev_dt			=	agitm_last_sale_rev_dt
--,vwitm_intax_rpt_yn				=	CAST(agitm_intax_rpt_yn AS CHAR(4))
--,vwitm_outtax_rpt_yn			=	CAST(agitm_outtax_rpt_yn AS CHAR(4))
--,vwitm_slstax_rpt_ynha			=	CAST(agitm_slstax_rpt_ynha AS CHAR(4))
--,vwitm_tontax_rpt_yn			=	CAST(agitm_tontax_rpt_yn AS CHAR(4))
--,vwitm_rest_chem_rpt_yn			=	CAST(agitm_rest_chem_rpt_yn AS CHAR(4))
--,vwitm_insp_fee_ynf				=	CAST(agitm_insp_fee_ynf AS CHAR(4))
--,vwitm_dyed_fuel_yn				=	CAST(agitm_dyed_fuel_yn AS CHAR(4))
--,vwitm_tax_cls					=	CAST(agitm_tax_cls AS CHAR(4))
--,vwitm_pat_cat_code				=	CAST(agitm_pat_cat_code AS CHAR(4))
--,vwitm_last_phys_rev_dt			=	agitm_last_phys_rev_dt
--,vwitm_last_price_rev_dt		=	agitm_last_price_rev_dt
--,vwitm_comments					=	agitm_comments
--,vwitm_msds_yn					=	CAST(agitm_msds_yn AS CHAR(10))
--,vwitm_epa_no					=	agitm_epa_no
--,vwitm_stk_yn					=	CAST(agitm_stk_yn AS CHAR(10))
--,vwitm_lot_yns					=	CAST(agitm_lot_yns AS CHAR(10))
--,vwitm_load_yn					=	CAST(agitm_load_yn AS CHAR(10))
--,vwitm_hand_add_yn				=	CAST(agitm_hand_add_yn AS CHAR(10))
--,vwitm_mix_order				=	agitm_mix_order
--,vwitm_comm_rt					=	CAST(agitm_comm_rt AS DECIMAL(18,6))
--,vwitm_comm_ind_uag				=	CAST(agitm_comm_ind_uag AS CHAR(10))
--,vwitm_rebate_grp				=	CAST(agitm_rebate_grp AS CHAR(10))
--,vwitm_tank_req_yn				=	CAST(agitm_tank_req_yn AS CHAR(10))
--,vwitm_invc_tag					=	CAST(agitm_invc_tag AS CHAR(10))
--,vwitm_med_tag					=	CAST(agitm_med_tag AS CHAR(10))
--,vwitm_ga_com_cd				=	CAST(agitm_ga_com_cd AS CHAR(10))
--,vwitm_ga_shrk_factor			=	CAST(agitm_ga_shrk_factor AS DECIMAL(18,6))
--,vwitm_rin_req_nri				=	CAST(agitm_rin_req_nri AS CHAR(10))
--,vwitm_rin_char_cd				=	CAST(agitm_rin_char_cd AS CHAR(10))
--,vwitm_rin_feed_stock			=	agitm_rin_feed_stock
--,vwitm_rin_pct_denaturant		=	agitm_rin_pct_denaturant
--,vwitm_user_id					=	agitm_user_id
--,vwitm_user_rev_dt				=	agitm_user_rev_dt
--,A4GLIdentity	
--,vwitm_avail_tm					=	CAST(agitm_avail_tm AS CHAR(10))
--,vwitm_deflt_percnt				=	agitm_deflt_percnt
vwitm_no	=	agitm_no
,vwitm_loc_no	=	agitm_loc_no
,vwitm_class	=	agitm_class
,vwitm_search	=	agitm_search
,vwitm_desc	=	agitm_desc
,vwitm_un_desc	=	CAST(agitm_un_desc AS CHAR(10))
,vwitm_un_prc1	=	agitm_un_prc1
,vwitm_un_prc2	=	agitm_un_prc2
,vwitm_un_prc3	=	agitm_un_prc3
,vwitm_un_prc4	=	agitm_un_prc4
,vwitm_un_prc5	=	agitm_un_prc5
,vwitm_un_prc6	=	agitm_un_prc6
,vwitm_un_prc7	=	agitm_un_prc7
,vwitm_un_prc8	=	agitm_un_prc8
,vwitm_un_prc9	=	agitm_un_prc9
,vwitm_ytd_ivc_cost	=	agitm_ytd_ivc_cost
,A4GLIdentity		= CAST(A4GLIdentity   AS INT)
,vwitm_avail_tm	=	CAST(agitm_avail_tm AS CHAR(10))
,vwitm_deflt_percnt	=	agitm_deflt_percnt
,vwitm_slstax_rpt_ynha = agitm_slstax_rpt_ynha
,vwitm_last_un_cost = agitm_last_un_cost
,vwitm_avg_un_cost				=	agitm_avg_un_cost
,vwitm_std_un_cost				=	agitm_std_un_cost
FROM agitmmst
GO

/****** Object:  View [dbo].[vwDispatch]    Script Date: 10/07/2013 18:09:01 ******/
if exists (select top 1 1 from sys.views where name = 'vwDispatch')
Begin
	drop view vwDispatch
end
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwDispatch]
AS
SELECT
DispatchID = A.intDispatchID,
CustomerNumber = H.vwcus_key + ' ' + CASE H.vwcus_co_per_ind_cp
		WHEN 'C' THEN RTRIM(H.vwcus_last_name) + H.vwcus_first_name
		ELSE RTRIM(H.vwcus_last_name) + ',' + H.vwcus_first_name
		END,
CustomerName = 
		CASE H.vwcus_co_per_ind_cp
		WHEN 'C' THEN RTRIM(H.vwcus_last_name) + H.vwcus_first_name
		ELSE RTRIM(H.vwcus_last_name) + ',' + H.vwcus_first_name
		END,
SiteNumber = RIGHT(CAST('0000' + CAST(B.intSiteNumber as varchar) as varchar), 4)+' '+LTRIM(B.strSiteAddress),--B.intSiteNumber,
SiteAddress = B.strSiteAddress,
SiteDescription = B.strDescription,
SiteLocation = B.strLocation,
SiteID = B.intSiteID,
RunOutDate = B.dtmRunOutDate,
ProductNo = F.vwitm_no,
ProductDesc = RTRIM(F.vwitm_desc),
ProductID = F.A4GLIdentity,
ClockNo = D.strClockNumber,
DispatchRequestedDate = A.dtmRequestedDate,
DispatchDate = A.dtmCallInDate,
MinimumQuantity = A.dblMinimumQuantity,
Price = A.dblPrice,
Total = A.dblTotal,
DriverName = RTRIM(G.vwsls_name),
DriverID = G.vwsls_slsmn_id,
NextDeliveryDegreeDay = B.intNextDeliveryDegreeDay,
isDispatched = A.ysnDispatched,
RouteName = E.strRouteID,
RouteID = E.intRouteID
FROM tblTMDispatch A
INNER JOIN tblTMSite B ON A.intDispatchID = B.intSiteID
INNER JOIN tblTMCustomer C ON B.intCustomerID = C.intCustomerID
INNER JOIN tblTMClock D ON D.intClockID = B.intClockID
INNER JOIN tblTMRoute E ON B.intRouteID = E.intRouteID
INNER JOIN vwitmmst F ON CAST(F.A4GLIdentity AS INT) = B.intProduct 
INNER JOIN vwslsmst G ON CAST(G.A4GLIdentity AS INT) = A.intDriverID
INNER JOIN vwcusmst H ON H.A4GLIdentity = C.intCustomerNumber
WHERE B.ysnActive  = 1
	AND H.vwcus_active_yn = 'Y'
GO


