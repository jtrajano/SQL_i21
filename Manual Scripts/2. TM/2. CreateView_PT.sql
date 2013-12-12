
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
vwtrm_key_n = CAST(pttrm_code AS INT)
,vwtrm_desc = pttrm_desc
,A4GLIdentity= CAsT(A4GLIdentity AS INT)
FROM
pttrmmst
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
vwcus_key    = ptcus_cus_no    
,vwcus_last_name =			(CASE WHEN (ptcus_co_per_ind_cp = 'P') 
									THEN RTRIM(CAST(ptcus_last_name AS CHAR(25))) 
									ELSE 
											CAST(ptcus_last_name AS CHAR(15))  
											+ CAST(ptcus_first_name AS CHAR(12)) 
											+ CAST(ISNULL(ptcus_mid_init,'') AS CHAR(1)) 
											+ CAST(ISNULL(ptcus_name_suffx,'') AS CHAR(2))
									END)
,vwcus_first_name =			(CASE WHEN (ptcus_co_per_ind_cp = 'P') 
									THEN RTRIM(CAST(ISNULL(ptcus_first_name,'') AS CHAR(25))) 
									ELSE 
										CAST('' AS CHAR(25))
									END)
,vwcus_mid_init = (CASE WHEN (ptcus_co_per_ind_cp = 'P') 
									THEN RTRIM(CAST(ISNULL(ptcus_mid_init,'') AS CHAR(1))) 
									ELSE 
										CAST('' AS CHAR(1))
									END)
,vwcus_name_suffix = (CASE WHEN (ptcus_co_per_ind_cp = 'P') 
									THEN RTRIM(CAST(ISNULL(ptcus_name_suffx,'') AS CHAR(2))) 
									ELSE 
										CAST('' AS CHAR(2))
									END)
,vwcus_addr    = ptcus_addr    
,vwcus_addr2   = ISNULL(CAST(RTRIM(ptcus_addr2) AS CHAR(30)),'')   
,vwcus_city    = ptcus_city    
,vwcus_state   = ptcus_state    
,vwcus_zip    = CAST(ptcus_zip AS CHAR(10))    
,vwcus_phone   = CAST(ptcus_phone AS CHAR(15))
,vwcus_phone_ext  = ptcus_phone_ext    
,vwcus_bill_to   = ptcus_bill_to    
,vwcus_contact   = ptcus_contact    
,vwcus_comments   = CAST(ptcus_comment AS CHAR(30)) 
,vwcus_slsmn_id   = ptcus_slsmn_id    
,vwcus_terms_cd   = CAST(ptcus_terms_code AS INT)
,vwcus_prc_lvl   = CAST(ptcus_prc_level AS TINYINT)
,vwcus_stmt_fmt   = ptcus_stmt_fmt    
,vwcus_ytd_pur   = CAST(ptcus_purchs_ytd AS INT)    
,vwcus_ytd_sls   = ptcus_ytd_sales    
,vwcus_ytd_cgs   = ptcus_ytd_cgs    
,vwcus_budget_amt  = CAST(ptcus_budget_amt AS DECIMAL(9))    
,vwcus_budget_beg_mm = ptcus_budget_beg_mm    
,vwcus_budget_end_mm = ptcus_budget_end_mm    
,vwcus_active_yn  = ptcus_active_yn    
,vwcus_ar_future  = ptcus_ar_curr    
,vwcus_ar_per1   = ptcus_ar_3160    
,vwcus_ar_per2   = ptcus_ar_6190    
,vwcus_ar_per3   = ptcus_ar_91120    
,vwcus_ar_per4   = ptcus_ar_ov120    
,vwcus_ar_per5   = CAST(0 AS DECIMAL(18,6))    
,vwcus_pend_ivc   = (SELECT SUM(
							CASE WHEN vwpye_amt IS NULL THEN 0 ELSE vwpye_amt END
								) FROM vwpyemst WHERE vwpye_cus_no = ptcus_cus_no )    
,vwcus_cred_reg   = ptcus_cred_reg    
,vwcus_pend_pymt  = (SELECT SUM(
								CASE vwtic_type
									WHEN 'I' THEN CASE WHEN vwtic_ship_total IS NULL THEN 0 ELSE vwtic_ship_total END 
									WHEN 'C' THEN CASE WHEN vwtic_ship_total IS NULL THEN -0 ELSE 0-vwtic_ship_total END  
									WHEN 'S' THEN CASE WHEN vwtic_ship_total IS NULL THEN 0 ELSE vwtic_ship_total END  
									WHEN 'R' THEN CASE WHEN vwtic_ship_total IS NULL THEN -0 ELSE 0-vwtic_ship_total END  
									WHEN 'D' THEN CASE WHEN vwtic_ship_total IS NULL THEN 0 ELSE vwtic_ship_total END 
									WHEN 'O' THEN CASE WHEN vwtic_ship_total IS NULL THEN 0 ELSE vwtic_ship_total END 
									WHEN 'B' THEN CASE WHEN vwtic_ship_total IS NULL THEN 0 ELSE vwtic_ship_total END 
									ELSE vwtic_ship_total
								END
									)		
									FROM vwticmst WHERE vwtic_cus_no = ptcus_cus_no )    
,vwcus_cred_ga   = CAST(0 AS DECIMAL(18,6))    
,vwcus_co_per_ind_cp = CAST(ptcus_co_per_ind_cp AS CHAR(4))
,vwcus_bus_loc_no  = ptcus_bus_loc_no   
,vwcus_cred_limit  = CAST(ptcus_credit_limit AS INT)  
,vwcus_last_stmt_bal = ptcus_last_stmnt_bal  
,vwcus_budget_amt_due = CAST(0 AS DECIMAL(18,6))
,vwcus_cred_ppd   = ptcus_cred_ppd  
,vwcus_ytd_srvchr  = CAST(0 AS DECIMAL(18,6))
,vwcus_last_pymt  = ptcus_last_pay_amt  
,vwcus_last_pay_rev_dt = ptcus_last_pay_rev_dt  
,vwcus_last_ivc_rev_dt = ptcus_last_ivc_rev_dt  
,vwcus_high_cred  = CAST(0 AS DECIMAL(18,6))   
,vwcus_high_past_due = CAST(0 AS DECIMAL(18,6)) 
,vwcus_avg_days_pay  = CAST(0 AS SMALLINT)  
,vwcus_avg_days_no_ivcs = CAST(0 AS SMALLINT)
,vwcus_last_stmt_rev_dt = ptcus_last_stmnt_rev_dt  
,vwcus_country   = CAST('' as char(3))
,vwcus_termdescription  = (select top 1 pttrm_desc from pttrmmst where pttrm_code = ptcus_terms_code) 
,vwcus_tax_ynp   = CAST('' as char(1))
,vwcus_tax_state  = CAST('' as char(2))
,A4GLIdentity= CAST(A4GLIdentity as INT)  
,vwcus_phone2   =ptcus_phone2  
,vwcus_balance = ptcus_ar_curr + ptcus_ar_3160 + ptcus_ar_6190 + ptcus_ar_91120 + ptcus_ar_ov120 -ptcus_cred_reg - ptcus_cred_ppd 
,vwcus_ptd_sls = ptcus_ptd_sales   
,vwcus_lyr_sls = CAST(0 AS DECIMAL)
FROM ptcusmst
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
,vwctl_key			=CAST(ptctl_key AS INT)
,vwcar_per1_desc	=CAST(pt4cf_per_desc_1 AS CHAR(20))
,vwcar_per2_desc	=CAST(pt4cf_per_desc_2 AS CHAR(20))
,vwcar_per3_desc	=CAST(pt4cf_per_desc_3 AS CHAR(20))
,vwcar_per4_desc	=CAST(pt4cf_per_desc_4 AS CHAR(20))
,vwcar_per5_desc	=CAST(pt4cf_per_desc_5 AS CHAR(20))
,vwcar_future_desc	=CAST(NULL AS CHAR(12))  
,vwctl_sa_cost_ind	=CAST(pt4cf_per_desc_1 AS CHAR(1))  
,vwctl_stmt_close_rev_dt =(SELECT pt3cf_eom_business_rev_dt FROM ptctlmst WHERE ptctl_key=3)
FROM ptctlmst
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
vwcnt_cus_no= ptcnt_cus_no
,vwcnt_cnt_no= CAST(ptcnt_cnt_no AS CHAR(8))  
,vwcnt_line_no= ptcnt_line_no  
,vwcnt_alt_cus= ptcnt_alt_cus_no 
,vwcnt_itm_or_cls= CAST(ptcnt_itm_or_cls AS CHAR(13)) 
,vwcnt_loc_no= ptcnt_loc_no 
,vwcnt_alt_cnt_no= CAST(ptcnt_alt_cnt_no AS CHAR(8))  
,vwcnt_amt_orig= ptcnt_amt_orig 
,vwcnt_amt_bal= ptcnt_amt_bal
,vwcnt_due_rev_dt= CONVERT(DATETIME, SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),1,4) + '/' 
								+ SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),5,2) + '/' 
								+  SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),7,2), 101) -- yyy/mm/dd
,vwcnt_hdr_comments= ptcnt_hdr_comments  
,vwcnt_un_orig= ptcnt_un_orig
,vwcnt_un_bal=ptcnt_un_bal
,vwcnt_lc1_yn=ptcnt_lc1_yn
,vwcnt_lc2_yn=ptcnt_lc2_yn
,vwcnt_lc3_yn=ptcnt_lc3_yn
,vwcnt_lc4_yn =ptcnt_lc4_yn
,vwcnt_lc5_yn =ptcnt_lc5_yn
,vwcnt_lc6_yn =ptcnt_lc6_yn
,vwcnt_ppd_yndm =ptcnt_prepaid_ynd
,vwcnt_un_prc= CAST(0.00 AS DECIMAL(18,6)) 
,vwcnt_prc_lvl = ptcnt_prc_lvl
,A4GLIdentity = CAST(A4GLIdentity   AS INT)

FROM ptcntmst
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
vwcmt_cus_no				=ptcmt_cus_no  
,vwcmt_com_typ				=ptcmt_type  
,vwcmt_com_cd				=CAST(NULL AS CHAR(4))  
,vwcmt_com_seq				=CAST(ptcmt_seq_no AS CHAR(2))  
,vwcmt_data					=CAST(NULL AS CHAR(69))  
,vwcmt_payee_1				=CAST(NULL AS CHAR(30))  
,vwcmt_payee_2				=CAST(NULL AS CHAR(30))  
,vwcmt_rc_lic_no			=CAST(NULL AS CHAR(12))  
,vwcmt_rc_exp_rev_dt		=NULL  
,vwcmt_rc_comment			=CAST(NULL AS CHAR(30))  
,vwcmt_rc_custom_yn			=CAST(NULL AS CHAR(4))  
,vwcmt_tr_ins_no			=CAST(NULL AS CHAR(12))  
,vwcmt_tr_exp_rev_dt		=NULL  
,vwcmt_tr_comment			=CAST(NULL AS CHAR(30))  
,vwcmt_ord_comment1			=CAST(NULL AS CHAR(30))  
,vwcmt_ord_comment2			=CAST(ptcmt_comment AS CHAR(60))
,vwcmt_fax_contact			=CAST(NULL AS CHAR(30))  
,vwcmt_fax_to_fax_num		=CAST(NULL AS CHAR(24))  
,vwcmt_eml_contact			=CAST(NULL AS CHAR(30))  
,vwcmt_eml_address			=CAST(NULL AS CHAR(39))  
,vwcmt_stl_lic_no			=CAST(NULL AS CHAR(15))  
,vwcmt_stl_exp_rev_dt		=NULL  
,vwcmt_stl_comment			=CAST(NULL AS CHAR(30))  
,vwcmt_user_id				=CAST(NULL AS CHAR(16))  
,vwcmt_user_rev_dt			=NULL  
,A4GLIdentity	= CAST(A4GLIdentity aS INT)
FROM ptcmtmst
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
vwcls_desc				=CAST(ptcls_desc AS CHAR(20))		 		
,vwcls_sls_acct_no		=ptcls_sls_acct_no	
,vwcls_pur_acct_no		=ptcls_pur_acct_no	
,vwcls_var_acct_no		=ptcls_var_acct_no	
,vwcls_inv_acct_no		=ptcls_inv_acct_no	
,vwcls_beg_inv_acct_no	=ptcls_beg_inv_acct_no	
,vwcls_end_inv_acct_no	=ptcls_end_inv_acct_no	
,vwcls_cd = ptcls_class
,A4GLIdentity	= CAST(A4GLIdentity   AS INT)
FROM ptclsmst
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
  
 vwtax_itm_no   = CAST(pttax_itm_no AS CHAR(13))  
, vwtax_state    = pttax_state  
, vwtax_auth_id1   = pttax_local1  
, vwtax_auth_id2   = pttax_local2  
, vwtax_if_rt    = pttax_fet_rt  
, vwtax_if_gl_acct  = pttax_fet_acct  
, vwtax_fet_rt   = CAST(0.00 AS DECIMAL(18,6)) 
, vwtax_fet_sls_acct  = CAST(0.00 AS DECIMAL(18,6))
, vwtax_fet_pur_acct  = CAST(0.00 AS DECIMAL(18,6))
, vwtax_fet_eft_yn  = CAST(NULL AS CHAR(4))
, vwtax_set_rt   = pttax_set_rt
, vwtax_set_sls_acct  = pttax_set_acct  
, vwtax_set_pur_acct  = CAST(0.00 AS DECIMAL(18,6)) 
, vwtax_set_eft_yn  = CAST(NULL AS CHAR(4))
, vwtax_sst_rt   = pttax_sst_rt  
, vwtax_sst_sls_acct  = CAST(pttax_sst_on_fet_yn AS DECIMAL(18,6))
, vwtax_sst_pur_acct  = CAST(pttax_sst_on_set_yn AS DECIMAL(18,6))
, vwtax_sst_pu   = pttax_sst_pu  
, vwtax_sst_on_fet_yn  = CAST(NULL AS CHAR(4))
, vwtax_sst_on_set_yn  = pttax_pst_pu  
, vwtax_sst_eft_yn  = CAST(NULL AS CHAR(4))
, vwtax_pst_rt   = pttax_pst_rt  
, vwtax_pst_sls_acct  = CAST(0.00 AS DECIMAL(18,6))  
, vwtax_pst_pur_acct  = CAST(0.00 AS DECIMAL(18,6))  
, vwtax_pst_pu   = CAST(NULL AS CHAR(4))
, vwtax_pst_on_fet_yn  = CAST(NULL AS CHAR(4))  
, vwtax_pst_on_set_yn  = CAST(NULL AS CHAR(4)) 
, vwtax_lc1_rt   = pttax_lc1_rt  
, vwtax_lc1_sls_acct  = CAST(0.00 AS DECIMAL(18,6))  
, vwtax_lc1_pur_acct  = CAST(0.00 AS DECIMAL(18,6))  
, vwtax_lc1_pu   = CAST(NULL AS CHAR(4))  
, vwtax_sst_on_lc1_yn  = CAST(NULL AS CHAR(4)) 
, vwtax_lc1_on_fet_yn  = CAST(NULL AS CHAR(4))  
, vwtax_lc1_eft_yn  = pttax_lc1_eft_yn  
, vwtax_lc1_scrn_desc  = CAST(NULL AS CHAR(4))
, vwtax_lc2_rt   = pttax_lc2_rt  
, vwtax_lc2_sls_acct  = CAST(0.00 AS DECIMAL(18,6))  
, vwtax_lc2_pur_acct  = CAST(0.00 AS DECIMAL(18,6))  
, vwtax_lc2_pu   = CAST(NULL AS CHAR(4))  
, vwtax_sst_on_lc2_yn  = CAST(NULL AS CHAR(4)) 
, vwtax_lc2_on_fet_yn  = CAST(NULL AS CHAR(4)) 
, vwtax_lc2_eft_yn  = pttax_lc2_eft_yn  
, vwtax_lc2_scrn_desc  = CAST(NULL AS CHAR(4))
, vwtax_lc3_rt   = pttax_lc3_rt  
, vwtax_lc3_sls_acct  = CAST(0.00 AS DECIMAL(18,6))  
, vwtax_lc3_pur_acct  = CAST(0.00 AS DECIMAL(18,6))  
, vwtax_lc3_pu   = CAST(NULL AS CHAR(4))  
, vwtax_sst_on_lc3_yn  = CAST(NULL AS CHAR(4)) 
, vwtax_lc3_on_fet_yn  = CAST(NULL AS CHAR(4)) 
, vwtax_lc3_eft_yn  = CAST(pttax_lc3_eft_yn AS CHAR(4)) 
, vwtax_lc3_scrn_desc  = CAST(NULL AS CHAR(4))
, vwtax_lc4_rt   = pttax_lc4_rt  
, vwtax_lc4_sls_acct  = CAST(0.00 AS DECIMAL(18,6))  
, vwtax_lc4_pur_acct  = CAST(0.00 AS DECIMAL(18,6))  
, vwtax_lc4_pu   = CAST(NULL AS CHAR(4))  
, vwtax_sst_on_lc4_yn  = CAST(NULL AS CHAR(4)) 
, vwtax_lc4_on_fet_yn  = CAST(NULL AS CHAR(4))
, vwtax_lc4_eft_yn  = pttax_lc4_eft_yn  
, vwtax_lc4_scrn_desc  = CAST(NULL AS CHAR(4))
, vwtax_lc5_rt   = pttax_lc5_rt  
, vwtax_lc5_sls_acct  = CAST(0.00 AS DECIMAL(18,6)) 
, vwtax_lc5_pur_acct  = CAST(0.00 AS DECIMAL(18,6))
, vwtax_lc5_pu   = CAST(NULL AS CHAR(4))  
, vwtax_sst_on_lc5_yn  = CAST(NULL AS CHAR(4)) 
, vwtax_lc5_on_fet_yn  = CAST(NULL AS CHAR(4))
, vwtax_lc5_eft_yn  = pttax_lc5_eft_yn  
, vwtax_lc5_scrn_desc  = CAST(NULL AS CHAR(4))
, vwtax_lc6_rt   = pttax_lc6_rt  
, vwtax_lc6_sls_acct  = CAST(0.00 AS DECIMAL(18,6))
, vwtax_lc6_pur_acct  = CAST(0.00 AS DECIMAL(18,6))
, vwtax_lc6_pu   = CAST(NULL AS CHAR(4))
, vwtax_sst_on_lc6_yn  = CAST(NULL AS CHAR(4)) 
, vwtax_lc6_on_fet_yn  = CAST(NULL AS CHAR(4))
, vwtax_lc6_eft_yn  = pttax_lc6_eft_yn  
, vwtax_lc6_scrn_desc  = CAST(NULL AS CHAR(4))
, vwtax_user_id   = CAST(NULL AS CHAR(16))  
, vwtax_user_rev_dt  = NULL  
, A4GLIdentity   = CAST(A4GLIdentity   AS INT)
FROM [pttaxmst]
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
  
vwsls_slsmn_id   = ptsls_slsmn_id  
,vwsls_name    =  ISNULL(ptsls_name, '')
,vwsls_addr1   = ptsls_addr1  
,vwsls_addr2   = ptsls_addr2  
,vwsls_city    = ptsls_city  
,vwsls_state   = ptsls_state  
,vwsls_zip    = ptsls_zip  
,vwsls_country   = CAST(NULL AS CHAR(4))
,vwsls_phone   = CAST(ptsls_phone AS CHAR(15))  
,vwsls_sales_ty_1  = ptsls_sales_ty_1  
,vwsls_sales_ty_2  = ptsls_sales_ty_2  
,vwsls_sales_ty_3  = ptsls_sales_ty_3  
,vwsls_sales_ty_4  = ptsls_sales_ty_4  
,vwsls_sales_ty_5  = ptsls_sales_ty_5  
,vwsls_sales_ty_6  = ptsls_sales_ty_6  
,vwsls_sales_ty_7  = ptsls_sales_ty_7  
,vwsls_sales_ty_8  = ptsls_sales_ty_8  
,vwsls_sales_ty_9  = ptsls_sales_ty_9  
,vwsls_sales_ty_10  = ptsls_sales_ty_10  
,vwsls_sales_ty_11  = ptsls_sales_ty_11  
,vwsls_sales_ty_12  = ptsls_sales_ty_12  
,vwsls_sales_ly_1  = ptsls_sales_ly_1  
,vwsls_sales_ly_2  = ptsls_sales_ly_2  
,vwsls_sales_ly_3  = ptsls_sales_ly_3  
,vwsls_sales_ly_4  = ptsls_sales_ly_4  
,vwsls_sales_ly_5  = ptsls_sales_ly_5  
,vwsls_sales_ly_6  = ptsls_sales_ly_6  
,vwsls_sales_ly_7  = ptsls_sales_ly_7  
,vwsls_sales_ly_8  = ptsls_sales_ly_8  
,vwsls_sales_ly_9  = ptsls_sales_ly_9  
,vwsls_sales_ly_10  = ptsls_sales_ly_10  
,vwsls_sales_ly_11  = ptsls_sales_ly_11  
,vwsls_sales_ly_12  = ptsls_sales_ly_12  
,vwsls_profit_ty_1  = ptsls_profit_ty_1  
,vwsls_profit_ty_2  = ptsls_profit_ty_2  
,vwsls_profit_ty_3  = ptsls_profit_ty_3  
,vwsls_profit_ty_4  = ptsls_profit_ty_4  
,vwsls_profit_ty_5  = ptsls_profit_ty_5  
,vwsls_profit_ty_6  = ptsls_profit_ty_6  
,vwsls_profit_ty_7  = ptsls_profit_ty_7  
,vwsls_profit_ty_8  = ptsls_profit_ty_8  
,vwsls_profit_ty_9  = ptsls_profit_ty_9  
,vwsls_profit_ty_10  = ptsls_profit_ty_10  
,vwsls_profit_ty_11  = ptsls_profit_ty_11  
,vwsls_profit_ty_12  = ptsls_profit_ty_12  
,vwsls_profit_ly_1  = ptsls_profit_ly_1  
,vwsls_profit_ly_2  = ptsls_profit_ly_2  
,vwsls_profit_ly_3  = ptsls_profit_ly_3  
,vwsls_profit_ly_4  = ptsls_profit_ly_4  
,vwsls_profit_ly_5  = ptsls_profit_ly_5  
,vwsls_profit_ly_6  = ptsls_profit_ly_6  
,vwsls_profit_ly_7  = ptsls_profit_ly_7  
,vwsls_profit_ly_8  = ptsls_profit_ly_8  
,vwsls_profit_ly_9  = ptsls_profit_ly_9  
,vwsls_profit_ly_10  = ptsls_profit_ly_10  
,vwsls_profit_ly_11  = ptsls_profit_ly_11  
,vwsls_profit_ly_12  = ptsls_profit_ly_12  
,vwsls_email   = CAST(ptsls_email AS CHAR(50))
,vwsls_textmsg_email = CAST(ptsls_textmsg_email AS CHAR(50))
,vwsls_dispatch_email = CAST(ptsls_dispatch_email AS CHAR(4))
,vwsls_user_id   = CAST(NULL AS CHAR(16)) 
,vwsls_user_rev_dt  = NULL
,A4GLIdentity  = CAST(A4GLIdentity   AS INT)
FROM ptslsmst
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
vwpye_amt	= ptpye_amt
,vwpye_cus_no	=ptpye_cus_no
from
ptpyemst
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
vwprc_cus_no   = CAST('' AS CHAR(10))
,vwprc_itm_no   = CAST('' AS CHAR(13))   
,vwprc_class    =  CAST('' AS CHAR(3))     
,vwprc_basis_ind   = CAST('' AS CHAR(1))    
,vwprc_begin_rev_dt  = CAST(NULL AS INT)   
,vwprc_end_rev_dt  = CAST(NULL AS INT)     
,vwprc_factor   = CAST(NULL AS DECIMAL(18,6))      
,vwprc_comment   = CAST('' AS CHAR(15))       
,vwprc_cost_to_use_las = CAST('' AS CHAR(1))      
,vwprc_qty_disc_by_pa = CAST('' AS CHAR(1))     
,vwprc_units_1   = CAST(NULL AS DECIMAL(18,6))      
,vwprc_units_2   = CAST(NULL AS DECIMAL(18,6))      
,vwprc_units_3   = CAST(NULL AS DECIMAL(18,6))      
,vwprc_disc_per_un_1  = CAST(NULL AS DECIMAL(18,6))     
,vwprc_disc_per_un_2  = CAST(NULL AS DECIMAL(18,6))     
,vwprc_disc_per_un_3  = CAST(NULL AS DECIMAL(18,6))     
,vwprc_fet_yn   = CAST('' AS CHAR(1))     
,vwprc_set_yn   = CAST('' AS CHAR(1))     
,vwprc_sst_ynp   = CAST('' AS CHAR(1))     
,vwprc_lc1_yn   = CAST('' AS CHAR(1))     
,vwprc_lc2_yn   = CAST('' AS CHAR(1))     
,vwprc_lc3_yn   = CAST('' AS CHAR(1))     
,vwprc_lc4_yn   = CAST('' AS CHAR(1))     
,vwprc_lc5_yn   = CAST('' AS CHAR(1))     
,vwprc_lc6_yn   = CAST('' AS CHAR(1))     
,vwprc_user_id   = CAST('' AS CHAR(16))     
,vwprc_user_rev_dt  = CAST('' AS CHAR(8))    
,A4GLIdentity = CAST(0 AS INT)
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
	ptloc_loc_no	COLLATE Latin1_General_CI_AS as vwloc_loc_no,
	ptloc_name		COLLATE Latin1_General_CI_AS as vwloc_name,
	ptloc_addr		COLLATE Latin1_General_CI_AS as vwloc_addr,
	CAST(A4GLIdentity AS INT) as A4GLIdentity	
FROM ptlocmst
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
FROM ptlclmst
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
vwivc_bill_to_cus		=	ptivc_cus_no
,vwivc_ivc_no			=	CAST(ptivc_invc_no AS CHAR(8))
,vwivc_loc_no			=	ptivc_loc_no 
,vwivc_type				=	CAST(ptivc_type AS CHAR(4))
,vwivc_status			=	CAST(ptivc_status AS CHAR(3))
,vwivc_rev_dt			=	ptivc_last_pay_rev_dt
,vwivc_comment			=	ptivc_comment
,vwivc_po_no			=	ptivc_po_no
,vwivc_sold_to_cus		=	ptivc_sold_to
,vwivc_slsmn_no			=	CAST(ptivc_sold_by AS CHAR(4))
,vwivc_slsmn_tot		=	ptivc_sold_by_tot
,vwivc_net_amt			=	ptivc_net
,vwivc_slstx_amt		=	CAST(ptivc_sales_tax AS DECIMAL(18,6))  
,vwivc_srvchr_amt		=	CAST(ptivc_serv_chg AS DECIMAL(18,6)) 
,vwivc_disc_amt			=	CAST(ptivc_disc_amt AS DECIMAL(18,6))
,vwivc_amt_paid			=	ptivc_amt_applied
,vwivc_bal_due			=	ptivc_bal_due
,vwivc_pend_disc		=	CAST(ptivc_pend_disc AS DECIMAL(18,6))
,vwivc_no_payments		=	CAST(ptivc_no_payments AS INT)
,vwivc_adj_inv_yn		=	ptivc_adj_inv_yn
,vwivc_srvchr_cd		=	CAST(0 AS INT)
,vwivc_disc_rev_dt		=	NULL
,vwivc_net_rev_dt		=	NULL
,vwivc_src_sys			=	CAST(NULL AS CHAR(4)) 
,vwivc_orig_rev_dt		=	NULL
,vwivc_split_no			=	CAST(NULL AS CHAR(4))
,vwivc_pd_days_old		=	CAST(0 AS INT) 
,vwivc_currency			=	CAST(NULL AS CHAR(4)) 
,vwivc_currency_rt		=	CAST(0.00 AS DECIMAL(18,6)) 
,vwivc_currency_cnt		=	CAST(NULL AS CHAR(8)) 
,vwivc_eft_ivc_paid_yn	=	ptivc_eft_ivc_paid_yn 
,vwivc_terms_code		=	CAST(NULL AS CHAR(4))
,vwivc_pay_type			=	CAST(NULL AS CHAR(4))
,vwivc_user_id			=	CAST(NULL AS CHAR(16))
,vwivc_user_rev_dt		=	NULL
,A4GLIdentity			=	CAST(A4GLIdentity   AS INT)
FROM ptivcmst
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
vwitm_no = ptitm_itm_no  
,vwitm_loc_no = ptitm_loc_no  
,vwitm_class = ptitm_class  
,vwitm_search = ptitm_search  
,vwitm_desc = ptitm_desc  
,vwitm_un_desc = CAST(ptitm_unit AS CHAR(10))  
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
,vwitm_avail_tm = CAST(ptitm_avail_tm AS CHAR(10))  
,vwitm_phys_inv_ynbo = CAST('' AS CHAR(10)) 
,vwitm_deflt_percnt = CAST(ISNULL(ptitm_deflt_percnt,0)  AS INT) 
,vwitm_slstax_rpt_ynha = ptitm_sst_yn  
,vwitm_last_un_cost = CAST(0.00  AS DECIMAL(18,6))    
,vwitm_avg_un_cost    = ptitm_avg_cost  
,vwitm_std_un_cost    = ptitm_std_cost  
FROM ptitmmst  
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
INNER JOIN tblTMSite B ON A.intSiteID = B.intSiteID
INNER JOIN tblTMCustomer C ON B.intCustomerID = C.intCustomerID
INNER JOIN tblTMClock D ON D.intClockID = B.intClockID
INNER JOIN tblTMRoute E ON B.intRouteID = E.intRouteID
INNER JOIN vwitmmst F ON CAST(F.A4GLIdentity AS INT) = B.intProduct 
INNER JOIN vwslsmst G ON CAST(G.A4GLIdentity AS INT) = A.intDriverID
INNER JOIN vwcusmst H ON H.A4GLIdentity = C.intCustomerNumber
WHERE B.ysnActive  = 1
	AND H.vwcus_active_yn = 'Y'
GO


