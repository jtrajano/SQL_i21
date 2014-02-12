IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcusmst')
	DROP VIEW vwcusmst
GO

-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
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
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
	EXEC ('
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
		,vwcus_ar_future  = CAST(0 AS DECIMAL(18,6))
		,vwcus_ar_per1   = ptcus_ar_curr    
		,vwcus_ar_per2   = ptcus_ar_3160    
		,vwcus_ar_per3   = ptcus_ar_6190    
		,vwcus_ar_per4   = ptcus_ar_91120    
		,vwcus_ar_per5   = ptcus_ar_ov120    
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
		,vwcus_high_past_due = CAST(ptcus_high_past_due AS DECIMAL(18,6))  
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
GO
