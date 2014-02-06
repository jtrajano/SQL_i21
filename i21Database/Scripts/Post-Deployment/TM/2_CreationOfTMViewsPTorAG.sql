
/*****TOP 1 1 Object:  View [dbo].[vwclsmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwclsmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwclsmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwcmtmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwcmtmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwcmtmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwcntmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwcntmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwcntmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwctlmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwctlmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwctlmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwcusmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwcusmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwcusmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwitmmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwitmmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwitmmst]
END	
GO

/*****TOP 1 1 Object:  View [dbo].[vwivcmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwivcmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwivcmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwlclmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwlclmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwlclmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwlocmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwlocmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwlocmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwprcmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwprcmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwprcmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwpxcycmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwpxcycmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwpxcycmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwpyemst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwpyemst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwpyemst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwslsmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwslsmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwslsmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwtaxmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwtaxmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwtaxmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwtrmmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwtrmmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwtrmmst]
END
GO

/*****TOP 1 1 Object:  View [dbo].[vwticmst]    Script Date: 02/06/2014 13:51:25 ******/
IF EXISTS (SELECT TOP 1 1 FROM dbo.sysobjects WHERE ID = OBJECT_ID(N'[dbo].[vwticmst]') AND OBJECTPROPERTY(ID, N'IsView') = 1)
BEGIN
	DROP VIEW [dbo].[vwticmst]
END
GO



/*Petro Views*/
IF (SELECT TOP 1 coctl_pt FROM coctlmst) = 'Y'
BEGIN
	EXEC ('	CREATE VIEW [dbo].[vwclsmst]
			AS
			SELECT
			vwcls_desc				=CAST(ptcls_desc AS CHAR(20))		 		
			,vwcls_sls_acct_no		=ptcls_sls_acct_no	
			,vwcls_pur_acct_no		=ptcls_pur_acct_no	
			,vwcls_var_acct_no		=ptcls_var_acct_no	
			,vwcls_inv_acct_no		=ptcls_inv_acct_no	
			,vwcls_beg_inv_acct_no	=ptcls_beg_inv_acct_no	
			,vwcls_end_inv_acct_no	=ptcls_end_inv_acct_no	
			,vwcls_cd				=ptcls_class
			,A4GLIdentity			=CAST(A4GLIdentity   AS INT)
			FROM ptclsmst
		
		')


	EXEC('CREATE VIEW [dbo].[vwcmtmst]
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
			,A4GLIdentity	= CAST(A4GLIdentity   AS INT)
			FROM ptcmtmst
		
		')

	EXEC('CREATE VIEW [dbo].[vwcntmst]
			AS
			SELECT
			vwcnt_cus_no=ptcnt_cus_no
			,vwcnt_cnt_no= CAST(ptcnt_cnt_no AS CHAR(8))  
			,vwcnt_line_no= ptcnt_line_no
			,vwcnt_alt_cus=ptcnt_alt_cus_no
			,vwcnt_itm_or_cls=CAST(ptcnt_itm_or_cls AS CHAR(13))  
			,vwcnt_loc_no=ptcnt_loc_no
			,vwcnt_alt_cnt_no=CAST(ptcnt_alt_cnt_no AS CHAR(8)) 
			,vwcnt_amt_orig=ptcnt_amt_orig
			,vwcnt_amt_bal=ptcnt_amt_bal
			,vwcnt_due_rev_dt= CONVERT(DATETIME, SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),1,4) + ''/'' 
											+ SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),5,2) + ''/'' 
											+  SUBSTRING(CAST(ptcnt_due_rev_dt AS NVARCHAR(8)),7,2), 101) -- yyy/mm/dd
			,vwcnt_hdr_comments=ptcnt_hdr_comments
			,vwcnt_un_orig=ptcnt_un_orig
			,vwcnt_un_bal=ptcnt_un_bal
			,vwcnt_lc1_yn=ptcnt_lc1_yn
			,vwcnt_lc2_yn=ptcnt_lc2_yn
			,vwcnt_lc3_yn=ptcnt_lc3_yn
			,vwcnt_lc4_yn =ptcnt_lc4_yn
			,vwcnt_lc5_yn =ptcnt_lc5_yn
			,vwcnt_lc6_yn =ptcnt_lc6_yn
			,vwcnt_ppd_yndm =ptcnt_prepaid_ynd
			,vwcnt_un_prc=CAST(0.00 AS DECIMAL(18,6))  
			,vwcnt_prc_lvl = ptcnt_prc_lvl
			,A4GLIdentity = CAST(A4GLIdentity   AS INT)

			FROM ptcntmst
			')



	EXEC ('	CREATE VIEW [dbo].[vwctlmst]
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

	EXEC ('
			CREATE VIEW [dbo].[vwpyemst]
			AS
			SELECT 
			vwpye_amt	= ptpye_amt
			,vwpye_cus_no	=ptpye_cus_no
			from
			ptpyemst')
		

	EXEC('
		CREATE VIEW [dbo].[vwticmst]
		AS
		SELECT
		vwtic_ship_total	= pttic_ship_total
		,vwtic_cus_no	= pttic_cus_no
		,vwtic_type	= pttic_type
		FROM
		ptticmst
	')


	EXEC('
		CREATE VIEW [dbo].[vwcusmst]  
		AS  
		SELECT  
		vwcus_key    = ptcus_cus_no    
		,vwcus_last_name =			(CASE WHEN (ptcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(ptcus_last_name AS CHAR(25))) 
											ELSE 
													CAST(ptcus_last_name AS CHAR(15))  
													+ CAST(ptcus_first_name AS CHAR(12)) 
													+ CAST(ISNULL(ptcus_mid_init,'''') AS CHAR(1)) 
													+ CAST(ISNULL(ptcus_name_suffx,'''') AS CHAR(2))
											END)
		,vwcus_first_name =			(CASE WHEN (ptcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(ISNULL(ptcus_first_name,'''') AS CHAR(25))) 
											ELSE 
												CAST('''' AS CHAR(25))
											END)   
		,vwcus_mid_init = (CASE WHEN (ptcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(ISNULL(ptcus_mid_init,'''') AS CHAR(1))) 
											ELSE 
												CAST('''' AS CHAR(1))
											END)
		,vwcus_name_suffix = (CASE WHEN (ptcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(ISNULL(ptcus_name_suffx,'''') AS CHAR(2))) 
											ELSE 
												CAST('''' AS CHAR(2))
											END)
		,vwcus_addr    = ptcus_addr    
		,vwcus_addr2   = ISNULL(CAST(RTRIM(ptcus_addr2) AS CHAR(30)),'''')    
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
		,vwcus_pend_ivc   = ISNULL((SELECT SUM(
									CASE WHEN vwpye_amt IS NULL THEN 0.00 ELSE vwpye_amt END
										) FROM vwpyemst WHERE vwpye_cus_no = ptcus_cus_no ),0.00)    
		,vwcus_cred_reg   = ptcus_cred_reg    
		,vwcus_pend_pymt  = ISNULL((SELECT SUM(
									CASE vwtic_type
										WHEN ''I'' THEN CASE WHEN vwtic_ship_total IS NULL THEN 0 ELSE vwtic_ship_total END 
										WHEN ''C'' THEN CASE WHEN vwtic_ship_total IS NULL THEN -0 ELSE 0-vwtic_ship_total END  
										WHEN ''S'' THEN CASE WHEN vwtic_ship_total IS NULL THEN 0 ELSE vwtic_ship_total END  
										WHEN ''R'' THEN CASE WHEN vwtic_ship_total IS NULL THEN -0 ELSE 0-vwtic_ship_total END  
										WHEN ''D'' THEN CASE WHEN vwtic_ship_total IS NULL THEN 0 ELSE vwtic_ship_total END 
										WHEN ''O'' THEN CASE WHEN vwtic_ship_total IS NULL THEN 0 ELSE vwtic_ship_total END 
										WHEN ''B'' THEN CASE WHEN vwtic_ship_total IS NULL THEN 0 ELSE vwtic_ship_total END 
										ELSE vwtic_ship_total
									END
								)		
							FROM vwticmst WHERE vwtic_cus_no = ptcus_cus_no ),0.00)    
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
		,vwcus_country   = CAST('''' as char(3))  
		,vwcus_termdescription  = (select top 1 pttrm_desc from pttrmmst where pttrm_code = ptcus_terms_code)
		,vwcus_tax_ynp   = CAST('''' as char(1))  
		,vwcus_tax_state  = CAST('''' as char(2))  
		,A4GLIdentity= CAST(A4GLIdentity as INT)  
		,vwcus_phone2   =ptcus_phone2  
		,vwcus_balance = ptcus_ar_curr + ptcus_ar_3160 + ptcus_ar_6190 + ptcus_ar_91120 + ptcus_ar_ov120 -ptcus_cred_reg - ptcus_cred_ppd 
		,vwcus_ptd_sls = ptcus_ptd_sales   
		,vwcus_lyr_sls = CAST(0 AS DECIMAL)
		FROM ptcusmst
	')


	EXEC('
		CREATE VIEW [dbo].[vwitmmst]  
		AS  
		SELECT  
		vwitm_no = CAST(ptitm_itm_no AS CHAR(13))    
		,vwitm_loc_no = ptitm_loc_no  
		,vwitm_class = ptitm_class  
		,vwitm_search = CAST(''''  AS CHAR(13))    
		,vwitm_desc = CAST(ptitm_desc AS CHAR(33))   
		,vwitm_un_desc = CAST(''''  AS CHAR(10))  
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
		,vwitm_avail_tm = CAST(''Y''  AS CHAR(10)) 
		,vwitm_phys_inv_ynbo = CAST(ptitm_phys_inv_yno AS CHAR(10)) 
		,vwitm_deflt_percnt = CAST(ptitm_deflt_percnt  AS INT)
		,vwitm_slstax_rpt_ynha = ptitm_sst_yn  
		,vwitm_last_un_cost = CAST(0.00  AS DECIMAL(18,6))    
		,vwitm_avg_un_cost    = ptitm_avg_cost  
		,vwitm_std_un_cost    = ptitm_std_cost  
		FROM ptitmmst
	')


	EXEC('
		CREATE VIEW [dbo].[vwivcmst]
		AS
		SELECT
		vwivc_bill_to_cus		=	ptivc_cus_no
		,vwivc_ivc_no			=	CAST(ptivc_invc_no AS CHAR(8))  
		,vwivc_loc_no			=	ptivc_loc_no
		,vwivc_type				=	CAST(NULL AS CHAR(4))  
		,vwivc_status			=	CAST(ptivc_sold_by AS CHAR(3))  
		,vwivc_rev_dt			=	NULL
		,vwivc_comment			=	ptivc_comment  
		,vwivc_po_no			=	ptivc_po_no
		,vwivc_sold_to_cus		=	ptivc_sold_to
		,vwivc_slsmn_no			=	CAST(NULL AS CHAR(4))  
		,vwivc_slsmn_tot		=	ptivc_sold_by_tot
		,vwivc_net_amt			=	ptivc_net
		,vwivc_slstx_amt		=	CAST(ptivc_sales_tax AS DECIMAL(18,6)) 
		,vwivc_srvchr_amt		=	CAST(0.00 AS DECIMAL(18,6))  
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
	')

	EXEC('
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
	')


	EXEC('
		CREATE VIEW [dbo].[vwlocmst]
		AS

		SELECT
			ptloc_loc_no	COLLATE Latin1_General_CI_AS as vwloc_loc_no,
			ptloc_name		COLLATE Latin1_General_CI_AS as vwloc_name,
			ptloc_addr		COLLATE Latin1_General_CI_AS as vwloc_addr,
			CAST(A4GLIdentity AS INT) as A4GLIdentity	
		FROM ptlocmst
	')

	EXEC('
		CREATE VIEW [dbo].[vwslsmst]  
		AS  
		SELECT  
	  
		vwsls_slsmn_id   = ptsls_slsmn_id  
		,vwsls_name    =  ISNULL(ptsls_name, '''')
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
	')

	EXEC('
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
	')

	EXEC('
		CREATE VIEW [dbo].[vwtrmmst]
		AS
		SELECT 
		vwtrm_key_n = CAST(pttrm_code AS INT)
		,vwtrm_desc = pttrm_desc
		,A4GLIdentity= CAsT(A4GLIdentity AS INT)
		FROM
		pttrmmst
	')

	
END
/*AG Views*/
ELSE
BEGIN
	EXEC('
		CREATE VIEW [dbo].[vwticmst]
		AS
		SELECT
		vwtic_ship_total	= CAST(0 AS DECIMAL(18,6))
		,vwtic_cus_no	= CAST('' AS CHAR(10))
		,vwtic_type	= CAST('' AS CHAR(1))
	')

	EXEC('
		CREATE VIEW [dbo].[vwtrmmst]
		AS
		SELECT 
		vwtrm_key_n = CAST(agtrm_key_n AS INT)
		,vwtrm_desc = agtrm_desc
		,A4GLIdentity= CAsT(A4GLIdentity AS INT)
		FROM
		agtrmmst
	')

	EXEC('
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
	')	

	EXEC('
		CREATE VIEW [dbo].[vwslsmst]  
		AS  
		SELECT  
	  
		vwsls_slsmn_id   = agsls_slsmn_id  
		,vwsls_name    =  ISNULL(agsls_name, '''')
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
	')

	EXEC('
		CREATE VIEW [dbo].[vwpyemst]
		AS
		SELECT 
		vwpye_amt	= agpye_amt
		,vwpye_cus_no	=agpye_cus_no
		from
		agpyemst
	')

	EXEC('
		CREATE VIEW [dbo].[vwpxcycmst]
		AS
		SELECT  pxcyc_cycle_id AS vwpxcyc_cycle_id
				, CAST(pxcyc_seq_no as INT) AS vwpxcyc_seq_no
				, pxcyc_rpt_state AS vwpxcyc_rpt_state
				, pxcyc_rpt_form AS vwpxcyc_rpt_form
				, pxcyc_rpt_sched AS vwpxcyc_rpt_sched
				, CAST(pxcyc_number_copies as INT)AS vwpxcyc_number_copies
				, pxcyc_user_id AS vwpxcyc_user_id
				, pxcyc_user_rev_dt AS vwpxcyc_user_rev_dt
				, pxsel_rpt_sched_name as vwpxsel_rpt_sched_name
				, CAST(A.A4GLIdentity as INT) AS vwA4GLIdentity
		FROM dbo.pxcycmst A 
		INNER JOIN pxselmst B ON A.pxcyc_rpt_state = B.pxsel_rpt_state 
		AND A.pxcyc_rpt_sched = B.pxsel_rpt_sched 
		AND A.pxcyc_rpt_form = B.pxsel_rpt_form where pxcyc_number_copies <> 0
	')

	EXEC('
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
	')

	EXEC('
		CREATE VIEW [dbo].[vwlocmst]
		AS

		SELECT
			agloc_loc_no	COLLATE Latin1_General_CI_AS as vwloc_loc_no,
			agloc_name		COLLATE Latin1_General_CI_AS as vwloc_name,
			agloc_addr		COLLATE Latin1_General_CI_AS as vwloc_addr,
			CAST(A4GLIdentity AS INT) as A4GLIdentity	
		FROM aglocmst
		')
	
	EXEC('
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
	')

	EXEC('
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
	')

	EXEC('
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
	')

	EXEC('
		CREATE VIEW [dbo].[vwcusmst]  
		AS  
		SELECT  
		vwcus_key    = agcus_key    
		,vwcus_last_name =			(CASE WHEN (agcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(agcus_last_name AS CHAR(25))) 
											ELSE 
												CAST(agcus_last_name AS CHAR(25))  + CAST(agcus_first_name AS CHAR(25))
											END)
		,vwcus_first_name =			(CASE WHEN (agcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(ISNULL(agcus_first_name,'''') AS CHAR(25))) 
											ELSE 
												CAST('''' AS CHAR(25))
											END)   
		,vwcus_mid_init = CAST('''' AS CHAR(1))
		,vwcus_name_suffix = CAST('''' AS CHAR(2))
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
	')

	EXEC('
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

	EXEC('
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
		,vwcnt_due_rev_dt= CONVERT(DATETIME, SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),1,4) + ''/'' 
										+ SUBSTRING(CAST(agcnt_due_rev_dt AS NVARCHAR(8)),5,2) + ''/'' 
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
	')

	EXEC('
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
	')

	EXEC('
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
	')

END