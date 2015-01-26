GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcusmst')
	DROP VIEW vwcusmst
GO

-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwcusmst]  
		AS  
		SELECT  
		vwcus_key    = A.agcus_key    
		,vwcus_last_name =			(CASE WHEN (A.agcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(A.agcus_last_name AS CHAR(25))) 
											ELSE 
												CAST(A.agcus_last_name AS CHAR(25))  + CAST(A.agcus_first_name AS CHAR(25))
											END)
		,vwcus_first_name =			(CASE WHEN (A.agcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(ISNULL(A.agcus_first_name,'''') AS CHAR(25))) 
											ELSE 
												CAST('''' AS CHAR(25))
											END)   
		,vwcus_mid_init = CAST('''' AS CHAR(1))
		,vwcus_name_suffix = CAST('''' AS CHAR(2))
		,vwcus_addr    = A.agcus_addr    
		,vwcus_addr2   = A.agcus_addr2    
		,vwcus_city    = A.agcus_city    
		,vwcus_state   = A.agcus_state    
		,vwcus_zip    = A.agcus_zip    
		,vwcus_phone   = A.agcus_phone    
		,vwcus_phone_ext  = A.agcus_phone_ext    
		,vwcus_bill_to   = A.agcus_bill_to    
		,vwcus_contact   = A.agcus_contact    
		,vwcus_comments   = A.agcus_comments    
		,vwcus_slsmn_id   = A.agcus_slsmn_id    
		,vwcus_terms_cd   = CAST(A.agcus_terms_cd AS INT)    
		,vwcus_prc_lvl   = A.agcus_prc_lvl    
		,vwcus_stmt_fmt   = A.agcus_stmt_fmt    
		,vwcus_ytd_pur   = A.agcus_ytd_pur    
		,vwcus_ytd_sls   = A.agcus_ytd_sls    
		,vwcus_ytd_cgs   = A.agcus_ytd_cgs    
		,vwcus_budget_amt  = A.agcus_budget_amt    
		,vwcus_budget_beg_mm = A.agcus_budget_beg_mm    
		,vwcus_budget_end_mm = A.agcus_budget_end_mm    
		,vwcus_active_yn  = A.agcus_active_yn    
		,vwcus_ar_future  = A.agcus_ar_future    
		,vwcus_ar_per1   = A.agcus_ar_per1    
		,vwcus_ar_per2   = A.agcus_ar_per2    
		,vwcus_ar_per3   = A.agcus_ar_per3    
		,vwcus_ar_per4   = A.agcus_ar_per4    
		,vwcus_ar_per5   = A.agcus_ar_per5    
		,vwcus_pend_ivc   = A.agcus_pend_ivc    
		,vwcus_cred_reg   = A.agcus_cred_reg    
		,vwcus_pend_pymt  = A.agcus_pend_pymt    
		,vwcus_cred_ga   = A.agcus_cred_ga    
		,vwcus_co_per_ind_cp = CAST(A.agcus_co_per_ind_cp AS CHAR(4))  
		,vwcus_bus_loc_no  = A.agcus_bus_loc_no   
		,vwcus_cred_limit  = A.agcus_cred_limit  
		,vwcus_last_stmt_bal = A.agcus_last_stmt_bal  
		,vwcus_budget_amt_due = CAST(A.agcus_budget_amt_due AS DECIMAL(18,6))  
		,vwcus_cred_ppd   = A.agcus_cred_ppd  
		,vwcus_ytd_srvchr  = CAST(A.agcus_ytd_srvchr AS DECIMAL(18,6))  
		,vwcus_last_pymt  = A.agcus_last_pymt  
		,vwcus_last_pay_rev_dt = A.agcus_last_pay_rev_dt  
		,vwcus_last_ivc_rev_dt = A.agcus_last_ivc_rev_dt  
		,vwcus_high_cred  = A.agcus_high_cred   
		,vwcus_high_past_due = ISNULL(A.agcus_ar_per2,0.0) +  ISNULL(A.agcus_ar_per3,0.0) + ISNULL(A.agcus_ar_per4,0.0)+ ISNULL(A.agcus_ar_per5,0.0)
		,vwcus_avg_days_pay  = A.agcus_avg_days_pay  
		,vwcus_avg_days_no_ivcs = A.agcus_avg_days_no_ivcs  
		,vwcus_last_stmt_rev_dt = A.agcus_last_stmt_rev_dt  
		,vwcus_country   = A.agcus_country  
		,vwcus_termdescription  = (select top 1 agtrm_desc from agtrmmst where agtrm_key_n = A.agcus_terms_cd)  
		,vwcus_tax_ynp   = A.agcus_tax_ynp  
		,vwcus_tax_state  = A.agcus_tax_state  
		,A4GLIdentity= CAST(A.A4GLIdentity as INT)  
		,vwcus_phone2   =A.agcus_phone2  
		,vwcus_balance = A.agcus_ar_future + A.agcus_ar_per1 + A.agcus_ar_per2 + A.agcus_ar_per3 + A.agcus_ar_per4 + A.agcus_ar_per5 - A.agcus_cred_reg - A.agcus_cred_ga  
		,vwcus_ptd_sls = A.agcus_ptd_sls   
		,vwcus_lyr_sls = A.agcus_lyr_sls
		,vwcus_acct_stat_x_1 = A.agcus_acct_stat_x_1
		,dblFutureCurrent = ISNULL(A.agcus_ar_future,0.0) + ISNULL(A.agcus_ar_per1,0.0)
		,intConcurrencyId = 0
		,strFullLocation =  ISNULL(B.agloc_loc_no ,'''') + '' '' + ISNULL(agloc_name,'''')
		FROM agcusmst A
		LEFT JOIN aglocmst B
			ON A.agcus_bus_loc_no = B.agloc_loc_no
		')
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vwcusmst]  
		AS  
		SELECT  
		vwcus_key    = A.ptcus_cus_no    
		,vwcus_last_name =			(CASE WHEN (A.ptcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(A.ptcus_last_name AS CHAR(25))) 
											ELSE 
													CAST(A.ptcus_last_name AS CHAR(25))  
													+ CAST(A.ptcus_first_name AS CHAR(22)) 
													+ CAST(ISNULL(A.ptcus_mid_init,'''') AS CHAR(1)) 
													+ CAST(ISNULL(A.ptcus_name_suffx,'''') AS CHAR(2))
											END)
		,vwcus_first_name =			(CASE WHEN (A.ptcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(ISNULL(A.ptcus_first_name,'''') AS CHAR(25))) 
											ELSE 
												CAST('''' AS CHAR(25))
											END)   
		,vwcus_mid_init = (CASE WHEN (A.ptcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(ISNULL(A.ptcus_mid_init,'''') AS CHAR(1))) 
											ELSE 
												CAST('''' AS CHAR(1))
											END)
		,vwcus_name_suffix = (CASE WHEN (A.ptcus_co_per_ind_cp = ''P'') 
											THEN RTRIM(CAST(ISNULL(A.ptcus_name_suffx,'''') AS CHAR(2))) 
											ELSE 
												CAST('''' AS CHAR(2))
											END)
		,vwcus_addr    = A.ptcus_addr    
		,vwcus_addr2   = ISNULL(CAST(RTRIM(A.ptcus_addr2) AS CHAR(30)),'''')    
		,vwcus_city    = A.ptcus_city    
		,vwcus_state   = A.ptcus_state   
		,vwcus_zip    = CAST(A.ptcus_zip AS CHAR(10))    
		,vwcus_phone   = CAST(A.ptcus_phone AS CHAR(15))    
		,vwcus_phone_ext  = A.ptcus_phone_ext    
		,vwcus_bill_to   = A.ptcus_bill_to    
		,vwcus_contact   = A.ptcus_contact    
		,vwcus_comments   = CAST(A.ptcus_comment AS CHAR(30))    
		,vwcus_slsmn_id   = A.ptcus_slsmn_id    
		,vwcus_terms_cd   = CAST(A.ptcus_terms_code AS INT)
		,vwcus_prc_lvl   = CAST(A.ptcus_prc_level AS TINYINT)    
		,vwcus_stmt_fmt   = A.ptcus_stmt_fmt    
		,vwcus_ytd_pur   = CAST(A.ptcus_purchs_ytd AS INT)    
		,vwcus_ytd_sls   = A.ptcus_ytd_sales    
		,vwcus_ytd_cgs   = A.ptcus_ytd_cgs    
		,vwcus_budget_amt  = CAST(A.ptcus_budget_amt AS DECIMAL(18,6))    
		,vwcus_budget_beg_mm = A.ptcus_budget_beg_mm    
		,vwcus_budget_end_mm = A.ptcus_budget_end_mm    
		,vwcus_active_yn  = A.ptcus_active_yn    
		,vwcus_ar_future  = CAST(0 AS DECIMAL(18,6))
		,vwcus_ar_per1   = A.ptcus_ar_curr    
		,vwcus_ar_per2   = A.ptcus_ar_3160    
		,vwcus_ar_per3   = A.ptcus_ar_6190    
		,vwcus_ar_per4   = A.ptcus_ar_91120    
		,vwcus_ar_per5   = A.ptcus_ar_ov120    
		,vwcus_pend_pymt   = ISNULL((SELECT SUM(
									CASE WHEN vwpye_amt IS NULL THEN 0.00 ELSE vwpye_amt END
										) FROM vwpyemst WHERE vwpye_cus_no = A.ptcus_cus_no ),0.00)    
		,vwcus_cred_reg   = A.ptcus_cred_reg    
		,vwcus_pend_ivc  = ISNULL((SELECT SUM(
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
							FROM vwticmst WHERE vwtic_cus_no = A.ptcus_cus_no AND vwtic_line = 1),0.00)    
		,vwcus_cred_ga   = CAST(0 AS DECIMAL(18,6))    
		,vwcus_co_per_ind_cp = CAST(A.ptcus_co_per_ind_cp AS CHAR(4))  
		,vwcus_bus_loc_no  = A.ptcus_bus_loc_no   
		,vwcus_cred_limit  = CAST(A.ptcus_credit_limit AS INT)  
		,vwcus_last_stmt_bal = A.ptcus_last_stmnt_bal  
		,vwcus_budget_amt_due = CAST(A.ptcus_budget_amt AS DECIMAL(18,6)) 
		,vwcus_cred_ppd   = A.ptcus_cred_ppd  
		,vwcus_ytd_srvchr  = CAST(A.ptcus_ytd_srvchr AS DECIMAL(18,6))
		,vwcus_last_pymt  = A.ptcus_last_pay_amt  
		,vwcus_last_pay_rev_dt = A.ptcus_last_pay_rev_dt  
		,vwcus_last_ivc_rev_dt = A.ptcus_last_ivc_rev_dt  
		,vwcus_high_cred  = CAST(A.ptcus_high_cred AS DECIMAL(18,6))   
		,vwcus_high_past_due = ISNULL(A.ptcus_ar_3160,0.0) + ISNULL(A.ptcus_ar_6190,0.0) + ISNULL(A.ptcus_ar_91120,0.0) + ISNULL(A.ptcus_ar_ov120,0.0)
		,vwcus_avg_days_pay  = CAST(A.ptcus_avg_days_pay AS SMALLINT) 
		,vwcus_avg_days_no_ivcs = CAST(A.ptcus_avg_days_no_ivcs AS SMALLINT)  
		,vwcus_last_stmt_rev_dt = A.ptcus_last_stmnt_rev_dt  
		,vwcus_country   = CAST('''' as char(3))  
		,vwcus_termdescription  = (select top 1 pttrm_desc from pttrmmst where pttrm_code = A.ptcus_terms_code)
		,vwcus_tax_ynp   = CAST('''' as char(1))  
		,vwcus_tax_state  = CAST('''' as char(2))  
		,A4GLIdentity= CAST(A.A4GLIdentity as INT)  
		,vwcus_phone2   =A.ptcus_phone2  
		,vwcus_balance = A.ptcus_ar_curr + A.ptcus_ar_3160 + A.ptcus_ar_6190 + A.ptcus_ar_91120 + A.ptcus_ar_ov120 -A.ptcus_cred_reg - A.ptcus_cred_ppd 
		,vwcus_ptd_sls = A.ptcus_ptd_sales   
		,vwcus_lyr_sls = CAST(0 AS DECIMAL)
		,vwcus_acct_stat_x_1 = A.ptcus_acct_stat_x_1
		,dblFutureCurrent = A.ptcus_ar_curr
		,intConcurrencyId = 0
		,strFullLocation =  ISNULL(B.ptloc_loc_no ,'''') + '' '' + ISNULL(ptloc_name,'''')
		FROM ptcusmst A
		LEFT JOIN ptlocmst B
			ON A.ptcus_bus_loc_no = B.ptloc_loc_no
		')
GO
