GO
	PRINT 'START OF CREATING [uspTMRecreateCustomerView] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspTMRecreateCustomerView]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspTMRecreateCustomerView
GO

CREATE PROCEDURE uspTMRecreateCustomerView 
AS
BEGIN
	IF OBJECT_ID('tempdb..#tblTMOriginMod') IS NOT NULL DROP TABLE #tblTMOriginMod

	CREATE TABLE #tblTMOriginMod
	(
		 intModId INT IDENTITY(1,1)
		, strDBName nvarchar(50) NOT NULL 
		, strPrefix NVARCHAR(5) NOT NULL UNIQUE
		, strName NVARCHAR(30) NOT NULL UNIQUE
		, ysnUsed BIT NOT NULL 
	)

	-- AG ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_ag')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''AG'', N''AG ACCOUNTING'', CASE ISNULL(coctl_ag, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	-- PETRO ACCOUNTING
	IF EXISTS (SELECT TOP 1 1 from INFORMATION_SCHEMA.COLUMNS where COLUMN_NAME = 'coctl_pt')
	BEGIN
		EXEC ('INSERT INTO #tblTMOriginMod (strDBName, strPrefix, strName, ysnUsed) SELECT TOP 1 db_name(), N''PT'', N''PETRO ACCOUNTING'', CASE ISNULL(coctl_pt, ''N'') WHEN ''Y'' THEN 1 else 0 END FROM coctlmst')
	END

	IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcusmst')
	BEGIN
		DROP VIEW vwcusmst
	END

	IF ((SELECT TOP 1 ysnUseOriginIntegration FROM tblTMPreferenceCompany) = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'agcusmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'aglocmst') = 1 
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwpyemst') = 1
		AND (SELECT TOP 1 1 TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwticmst') = 1
	)
	BEGIN
	-- AG VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
		BEGIN
			EXEC ('
				CREATE VIEW [dbo].[vwcusmst]  
				AS  
				SELECT  
				vwcus_key    = A.agcus_key    
				,vwcus_last_name =			(CASE WHEN (ISNULL(A.agcus_co_per_ind_cp,'''') = ''P'') 
													THEN RTRIM(CAST(ISNULL(A.agcus_last_name,'''') AS CHAR(25))) 
													ELSE 
														CAST(ISNULL(A.agcus_last_name,'''') AS CHAR(25))  + CAST(ISNULL(A.agcus_first_name,'''') AS CHAR(25))
													END)
				,vwcus_first_name =			(CASE WHEN (ISNULL(A.agcus_co_per_ind_cp,'''') = ''P'') 
													THEN RTRIM(CAST(ISNULL(A.agcus_first_name,'''') AS CHAR(25))) 
													ELSE 
														CAST('''' AS CHAR(25))
													END)   
				,vwcus_mid_init = CAST('''' AS CHAR(1))
				,vwcus_name_suffix = CAST('''' AS CHAR(2))
				,vwcus_addr    = ISNULL(A.agcus_addr,'''')
				,vwcus_addr2   = ISNULL(A.agcus_addr2,'''')    
				,vwcus_city    = ISNULL(A.agcus_city,'''')    
				,vwcus_state   = ISNULL(A.agcus_state,'''')    
				,vwcus_zip    = ISNULL(A.agcus_zip,'''')    
				,vwcus_phone   = ISNULL(A.agcus_phone,'''')    
				,vwcus_phone_ext  = ISNULL(A.agcus_phone_ext,'''')    
				,vwcus_bill_to   = ISNULL(A.agcus_bill_to,'''')    
				,vwcus_contact   = ISNULL(A.agcus_contact,'''')    
				,vwcus_comments   = ISNULL(A.agcus_comments,'''')    
				,vwcus_slsmn_id   = ISNULL(A.agcus_slsmn_id,'''')    
				,vwcus_terms_cd   = CAST(ISNULL(A.agcus_terms_cd,'''') AS INT)    
				,vwcus_prc_lvl   = CAST(ISNULL(A.agcus_prc_lvl,0) AS INT)   
				,vwcus_stmt_fmt   = ISNULL(A.agcus_stmt_fmt,'''')    
				,vwcus_ytd_pur   = ISNULL(A.agcus_ytd_pur,0.0)    
				,vwcus_ytd_sls   = ISNULL(A.agcus_ytd_sls,0.0)    
				,vwcus_ytd_cgs   = ISNULL(A.agcus_ytd_cgs,0.0)    
				,vwcus_budget_amt  = ISNULL(A.agcus_budget_amt,0.0)    
				,vwcus_budget_beg_mm = CAST(ISNULL(A.agcus_budget_beg_mm,0) AS INT)   
				,vwcus_budget_end_mm = CAST(ISNULL(A.agcus_budget_end_mm,0) AS INT)   
				,vwcus_active_yn  = ISNULL(A.agcus_active_yn,'''')    
				,vwcus_ar_future  = ISNULL(A.agcus_ar_future,0.0)    
				,vwcus_ar_per1   = ISNULL(A.agcus_ar_per1,0.0)    
				,vwcus_ar_per2   = ISNULL(A.agcus_ar_per2,0.0)    
				,vwcus_ar_per3   = ISNULL(A.agcus_ar_per3,0.0)    
				,vwcus_ar_per4   = ISNULL(A.agcus_ar_per4,0.0)    
				,vwcus_ar_per5   = ISNULL(A.agcus_ar_per5,0.0)    
				,vwcus_pend_ivc   = ISNULL(A.agcus_pend_ivc,0.0)    
				,vwcus_cred_reg   = ISNULL(A.agcus_cred_reg,0.0)    
				,vwcus_pend_pymt  = ISNULL(A.agcus_pend_pymt,0.0)    
				,vwcus_cred_ga   = ISNULL(A.agcus_cred_ga,0.0)    
				,vwcus_co_per_ind_cp = CAST(ISNULL(A.agcus_co_per_ind_cp,'''') AS CHAR(4))  
				,vwcus_bus_loc_no  = ISNULL(A.agcus_bus_loc_no,'''')   
				,vwcus_cred_limit  = CAST(ISNULL(A.agcus_cred_limit,0.0) AS DECIMAL(18,6)) 
				,vwcus_last_stmt_bal = ISNULL(A.agcus_last_stmt_bal,0.0)  
				,vwcus_budget_amt_due = CAST(ISNULL(A.agcus_budget_amt_due,0.0) AS DECIMAL(18,6))  
				,vwcus_cred_ppd   = CAST(ISNULL(A.agcus_cred_ppd,0.0) AS NUMERIC(18,6))  
				,vwcus_ytd_srvchr  = CAST(ISNULL(A.agcus_ytd_srvchr,0.0) AS DECIMAL(18,6))  
				,vwcus_last_pymt  = ISNULL(A.agcus_last_pymt,0.0)  
				,vwcus_last_pay_rev_dt = ISNULL(A.agcus_last_pay_rev_dt,0)  
				,vwcus_last_ivc_rev_dt = ISNULL(A.agcus_last_ivc_rev_dt,0)  
				,vwcus_high_cred  = ISNULL(A.agcus_high_cred,0.0)
				,vwcus_high_past_due = ISNULL(A.agcus_ar_per2,0.0) +  ISNULL(A.agcus_ar_per3,0.0) + ISNULL(A.agcus_ar_per4,0.0)+ ISNULL(A.agcus_ar_per5,0.0)
				,vwcus_avg_days_pay  = CAST(ISNULL(A.agcus_avg_days_pay,0) AS INT) 
				,vwcus_avg_days_no_ivcs = CAST(ISNULL(A.agcus_avg_days_no_ivcs,0) AS INT)
				,vwcus_last_stmt_rev_dt = ISNULL(A.agcus_last_stmt_rev_dt,0)  
				,vwcus_country   = ISNULL(A.agcus_country,'''')  
				,vwcus_termdescription  = ISNULL(C.agtrm_desc,'''')
				,vwcus_tax_ynp   = ISNULL(A.agcus_tax_ynp,'''')  
				,vwcus_tax_state  = ISNULL(A.agcus_tax_state,'''')  
				,A4GLIdentity= CAST(A.A4GLIdentity as INT)  
				,vwcus_phone2   =ISNULL(A.agcus_phone2,'''')  
				,vwcus_balance = ISNULL(A.agcus_ar_future,0.0) + ISNULL(A.agcus_ar_per1,0.0) + ISNULL(A.agcus_ar_per2,0.0) + ISNULL(A.agcus_ar_per3,0.0) + ISNULL(A.agcus_ar_per4,0.0) + ISNULL(A.agcus_ar_per5,0.0) - ISNULL(A.agcus_cred_reg,0.0) - ISNULL(A.agcus_cred_ga,0.0)  
				,vwcus_ptd_sls = ISNULL(A.agcus_ptd_sls,0.0) 
				,vwcus_lyr_sls = ISNULL(A.agcus_lyr_sls,0.0)
				,vwcus_acct_stat_x_1 = ISNULL(A.agcus_acct_stat_x_1,'''')
				,dblFutureCurrent = ISNULL(A.agcus_ar_future,0.0) + ISNULL(A.agcus_ar_per1,0.0)
				,intConcurrencyId = 0
				,strFullLocation =  ISNULL(B.agloc_loc_no ,'''') + '' '' + ISNULL(agloc_name,'''')
				,intTaxId = CAST((SELECT TOP 1 A4GLIdentity 
								FROM aglclmst 
								WHERE ISNULL(aglcl_tax_state,'''') COLLATE Latin1_General_CI_AS = ISNULL(agcus_tax_state,'''') COLLATE Latin1_General_CI_AS
									AND ISNULL(aglcl_tax_auth_id1,'''') COLLATE Latin1_General_CI_AS = ISNULL(agcus_tax_auth_id1,'''') COLLATE Latin1_General_CI_AS
									AND ISNULL(aglcl_tax_auth_id2,'''') COLLATE Latin1_General_CI_AS = ISNULL(agcus_tax_auth_id2,'''') COLLATE Latin1_General_CI_AS) AS INT)
				,ysnOriginIntegration = CAST(1 AS BIT)
				,strFullCustomerName = (CASE WHEN A.agcus_co_per_ind_cp = ''C''   
										 THEN    RTRIM(A.agcus_last_name) + RTRIM(A.agcus_first_name)
										 ELSE    
													CASE WHEN A.agcus_first_name IS NULL OR RTRIM(A.agcus_first_name) = ''''  
														THEN     RTRIM(A.agcus_last_name) 
													ELSE     RTRIM(A.agcus_last_name) + '', '' + RTRIM(A.agcus_first_name)   
													END   
										 END)COLLATE Latin1_General_CI_AS
				,intCustomerPricingLevel = CAST(NULL AS INT)
				,strCustomerContactEmail = ''''
				,dtmLastInvoiceRevisedDate = CASE WHEN ISDATE(A.agcus_last_ivc_rev_dt) = 1 THEN CONVERT(DATETIME, CAST(A.agcus_last_ivc_rev_dt AS CHAR(12)), 112) ELSE CONVERT(DATETIME, CAST(''19000101'' AS CHAR(12)), 112) END
				,dtmLastPaymentRevisedDate = CASE WHEN ISDATE(A.agcus_last_pay_rev_dt) = 1 THEN CONVERT(DATETIME, CAST(A.agcus_last_pay_rev_dt AS CHAR(12)), 112) ELSE CONVERT(DATETIME, CAST(''19000101'' AS CHAR(12)), 112) END 
				,dtmLastStatementRevDate = CASE WHEN ISDATE(A.agcus_last_stmt_rev_dt) = 1 THEN CONVERT(DATETIME, CAST(A.agcus_last_stmt_rev_dt AS CHAR(12)), 112) ELSE CONVERT(DATETIME, CAST(''19000101'' AS CHAR(12)), 112) END 
				,strCompleteAddress = dbo.[fnConvertToFullAddress]((CASE WHEN RTRIM(ISNULL(A.agcus_addr2,'''')) <> '''' THEN (CASE WHEN RTRIM(ISNULL(A.agcus_addr,'''')) <> '''' THEN (RTRIM(ISNULL(A.agcus_addr,'''')) + CHAR(13) + CHAR(10) + RTRIM(A.agcus_addr2)) ELSE RTRIM(A.agcus_addr2) END) ELSE ISNULL(A.agcus_addr,'''') END)
																	,ISNULL(A.agcus_city,'''')
																	,ISNULL(A.agcus_state,'''')
																	,ISNULL(A.agcus_zip,'''')) COLLATE Latin1_General_CI_AS
				,strFormattedAddress = (CASE WHEN RTRIM(ISNULL(A.agcus_addr2,'''')) <> '''' THEN (CASE WHEN RTRIM(ISNULL(A.agcus_addr,'''')) <> '''' THEN (RTRIM(ISNULL(A.agcus_addr,'''')) + CHAR(13) + CHAR(10) + RTRIM(A.agcus_addr2)) ELSE RTRIM(A.agcus_addr2) END) ELSE ISNULL(A.agcus_addr,'''') END) COLLATE Latin1_General_CI_AS
				,strFullName = (CASE WHEN A.agcus_co_per_ind_cp = ''C'' 
									THEN RTRIM(A.agcus_last_name) + RTRIM(A.agcus_first_name) 
								WHEN A.agcus_first_name IS NULL OR RTRIM(A.agcus_first_name) = ''''  
									THEN RTRIM(A.agcus_last_name)
								ELSE RTRIM(A.agcus_last_name) + '', '' + RTRIM(A.agcus_first_name) 
								END)  COLLATE Latin1_General_CI_AS
				,strFullTermName = (CAST(ISNULL(A.agcus_terms_cd,'''') AS NVARCHAR(10)) + '' - '' + ISNULL(C.agtrm_desc,'''')) COLLATE Latin1_General_CI_AS
				,strCreditNote =''''
				FROM agcusmst A
				LEFT JOIN aglocmst B
					ON A.agcus_bus_loc_no = B.agloc_loc_no
				LEFT JOIN (
					SELECT 
						agtrm_desc
						,agtrm_key_n
						,intRecCountId = ROW_NUMBER() OVER(PARTITION BY agtrm_key_n ORDER BY A4GLIdentity)
					FROM agtrmmst
				) C 
				ON  C.agtrm_key_n = A.agcus_terms_cd  
					AND C.intRecCountId = 1
				')
		END
		-- PT VIEW
		IF  (SELECT TOP 1 ysnUsed FROM #tblTMOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
		BEGIN
			EXEC ('
				CREATE VIEW [dbo].[vwcusmst]  
				AS  
				SELECT  
				vwcus_key    = ISNULL(A.ptcus_cus_no,'''')    
				,vwcus_last_name =			(CASE WHEN (ISNULL(A.ptcus_co_per_ind_cp,'''') = ''P'') 
													THEN RTRIM(CAST(ISNULL(A.ptcus_last_name,'''') AS CHAR(25))) 
													ELSE 
															CAST(ISNULL(A.ptcus_last_name,'''') AS CHAR(25))  
															+ CAST(ISNULL(A.ptcus_first_name,'''') AS CHAR(22)) 
															+ CAST(ISNULL(A.ptcus_mid_init,'''') AS CHAR(1)) 
															+ CAST(ISNULL(A.ptcus_name_suffx,'''') AS CHAR(2))
													END)
				,vwcus_first_name =			(CASE WHEN (ISNULL(A.ptcus_co_per_ind_cp,'''') = ''P'') 
													THEN RTRIM(CAST(ISNULL(A.ptcus_first_name,'''') AS CHAR(25))) 
													ELSE 
														CAST('''' AS CHAR(25))
													END)   
				,vwcus_mid_init = (CASE WHEN (ISNULL(A.ptcus_co_per_ind_cp,'''') = ''P'') 
													THEN RTRIM(CAST(ISNULL(A.ptcus_mid_init,'''') AS CHAR(1))) 
													ELSE 
														CAST('''' AS CHAR(1))
													END)
				,vwcus_name_suffix = (CASE WHEN (A.ptcus_co_per_ind_cp = ''P'') 
													THEN RTRIM(CAST(ISNULL(A.ptcus_name_suffx,'''') AS CHAR(2))) 
													ELSE 
														CAST('''' AS CHAR(2))
													END)
				,vwcus_addr    = ISNULL(A.ptcus_addr,'''')    
				,vwcus_addr2   = ISNULL(CAST(RTRIM(A.ptcus_addr2) AS CHAR(30)),'''')    
				,vwcus_city    = ISNULL(A.ptcus_city,'''')    
				,vwcus_state   = ISNULL(A.ptcus_state,'''')   
				,vwcus_zip    = CAST(ISNULL(A.ptcus_zip,'''') AS CHAR(10))    
				,vwcus_phone   = CAST(ISNULL(A.ptcus_phone,'''') AS CHAR(15))    
				,vwcus_phone_ext  = ISNULL(A.ptcus_phone_ext,'''')
				,vwcus_bill_to   = ISNULL(A.ptcus_bill_to,'''')    
				,vwcus_contact   = ISNULL(A.ptcus_contact,'''')    
				,vwcus_comments   = CAST(ISNULL(A.ptcus_comment,'''') AS CHAR(30))    
				,vwcus_slsmn_id   = ISNULL(A.ptcus_slsmn_id,'''')    
				,vwcus_terms_cd   = CAST(ISNULL(A.ptcus_terms_code,0) AS INT)
				,vwcus_prc_lvl   = CAST(ISNULL(A.ptcus_prc_level,0) AS INT)    
				,vwcus_stmt_fmt   = ISNULL(A.ptcus_stmt_fmt,'''')    
				,vwcus_ytd_pur   = CAST(ISNULL(A.ptcus_purchs_ytd,0.0) AS INT)    
				,vwcus_ytd_sls   = ISNULL(A.ptcus_ytd_sales,0.0)    
				,vwcus_ytd_cgs   = ISNULL(A.ptcus_ytd_cgs,0.0)    
				,vwcus_budget_amt  = CAST(ISNULL(A.ptcus_budget_amt,0.0) AS DECIMAL(18,6))    
				,vwcus_budget_beg_mm = CAST(ISNULL(A.ptcus_budget_beg_mm,0) AS INT)   
				,vwcus_budget_end_mm = CAST(ISNULL(A.ptcus_budget_end_mm,0) AS INT)   
				,vwcus_active_yn  = ISNULL(A.ptcus_active_yn,'''')    
				,vwcus_ar_future  = CAST(0 AS DECIMAL(18,6))
				,vwcus_ar_per1   = ISNULL(A.ptcus_ar_curr,0.0)    
				,vwcus_ar_per2   = ISNULL(A.ptcus_ar_3160,0.0)    
				,vwcus_ar_per3   = ISNULL(A.ptcus_ar_6190,0.0)    
				,vwcus_ar_per4   = ISNULL(A.ptcus_ar_91120,0.0)    
				,vwcus_ar_per5   = ISNULL(A.ptcus_ar_ov120,0.0)    
				,vwcus_pend_pymt   = ISNULL((SELECT SUM(
											CASE WHEN vwpye_amt IS NULL THEN 0.00 ELSE vwpye_amt END
												) FROM vwpyemst WHERE vwpye_cus_no = A.ptcus_cus_no ),0.00)    
				,vwcus_cred_reg   = ISNULL(A.ptcus_cred_reg,0.0)    
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
				,vwcus_co_per_ind_cp = CAST(ISNULL(A.ptcus_co_per_ind_cp,'''') AS CHAR(4))  
				,vwcus_bus_loc_no  = ISNULL(A.ptcus_bus_loc_no,'''')   
				,vwcus_cred_limit  = CAST(ISNULL(A.ptcus_credit_limit,0.0) AS DECIMAL(18,6))
				,vwcus_last_stmt_bal = ISNULL(A.ptcus_last_stmnt_bal,0.0)  
				,vwcus_budget_amt_due = CAST(ISNULL(A.ptcus_budget_amt,0.0) AS DECIMAL(18,6)) 
				,vwcus_cred_ppd   = ISNULL(A.ptcus_cred_ppd,0.0)  
				,vwcus_ytd_srvchr  = CAST(ISNULL(A.ptcus_ytd_srvchr,0.0) AS DECIMAL(18,6))
				,vwcus_last_pymt  = ISNULL(A.ptcus_last_pay_amt,0.0)  
				,vwcus_last_pay_rev_dt = ISNULL(A.ptcus_last_pay_rev_dt,0)  
				,vwcus_last_ivc_rev_dt = ISNULL(A.ptcus_last_ivc_rev_dt,0)  
				,vwcus_high_cred  = CAST(ISNULL(A.ptcus_high_cred,0.0) AS DECIMAL(18,6))   
				,vwcus_high_past_due = ISNULL(A.ptcus_ar_3160,0.0) + ISNULL(A.ptcus_ar_6190,0.0) + ISNULL(A.ptcus_ar_91120,0.0) + ISNULL(A.ptcus_ar_ov120,0.0)
				,vwcus_avg_days_pay  = CAST(ISNULL(A.ptcus_avg_days_pay,0) AS INT) 
				,vwcus_avg_days_no_ivcs = CAST(ISNULL(A.ptcus_avg_days_no_ivcs,0) AS INT)  
				,vwcus_last_stmt_rev_dt = ISNULL(A.ptcus_last_stmnt_rev_dt,0)  
				,vwcus_country   = CAST('''' as char(3))  
				,vwcus_termdescription  = ISNULL((select top 1 pttrm_desc from pttrmmst where pttrm_code = A.ptcus_terms_code),'''')
				,vwcus_tax_ynp   = CAST('''' as char(1))  
				,vwcus_tax_state  = CAST('''' as char(2))  
				,A4GLIdentity= CAST(A.A4GLIdentity as INT)  
				,vwcus_phone2   =ISNULL(A.ptcus_phone2,'''')  
				,vwcus_balance = ISNULL(A.ptcus_ar_curr,0.0) + ISNULL(A.ptcus_ar_3160,0.0) + ISNULL(A.ptcus_ar_6190,0.0) + ISNULL(A.ptcus_ar_91120,0.0) + ISNULL(A.ptcus_ar_ov120,0.0) - ISNULL(A.ptcus_cred_reg,0.0) - ISNULL(A.ptcus_cred_ppd,0.0) 
				,vwcus_ptd_sls = ISNULL(A.ptcus_ptd_sales,0.0)   
				,vwcus_lyr_sls = CAST(0 AS DECIMAL)
				,vwcus_acct_stat_x_1 = ISNULL(A.ptcus_acct_stat_x_1,'''')
				,dblFutureCurrent = ISNULL(A.ptcus_ar_curr,0.0)
				,intConcurrencyId = 0
				,strFullLocation =  ISNULL(B.ptloc_loc_no ,'''') + '' '' + ISNULL(ptloc_name,'''')
				,intTaxId = CAST((SELECT TOP 1 A4GLIdentity 
								FROM ptlclmst 
								WHERE ISNULL(ptlcl_state,'''') COLLATE Latin1_General_CI_AS = ISNULL(ptcus_state,'''') COLLATE Latin1_General_CI_AS
									AND ISNULL(ptlcl_local1_id,'''') COLLATE Latin1_General_CI_AS = ISNULL(ptcus_local1,'''') COLLATE Latin1_General_CI_AS
									AND ISNULL(ptlcl_local2_id,'''') COLLATE Latin1_General_CI_AS = ISNULL(ptcus_local2,'''') COLLATE Latin1_General_CI_AS) AS INT)
				,ysnOriginIntegration = CAST(1 AS BIT)
				,strFullCustomerName = (CASE WHEN A.ptcus_co_per_ind_cp = ''C''   
										 THEN    RTRIM(A.ptcus_last_name) + RTRIM(A.ptcus_first_name) + RTRIM(A.ptcus_mid_init) + RTRIM(A.ptcus_name_suffx)   
										 ELSE    
													CASE WHEN A.ptcus_first_name IS NULL OR RTRIM(A.ptcus_first_name) = ''''  
														THEN     RTRIM(A.ptcus_last_name) + RTRIM(A.ptcus_name_suffx)    
													ELSE     RTRIM(A.ptcus_last_name) + RTRIM(A.ptcus_name_suffx) + '', '' + RTRIM(A.ptcus_first_name) + RTRIM(A.ptcus_mid_init)    
													END   
										 END)COLLATE Latin1_General_CI_AS
				,intCustomerPricingLevel = CAST(NULL AS INT)
				,strCustomerContactEmail = ''''
				,dtmLastInvoiceRevisedDate = CASE WHEN ISDATE(A.ptcus_last_ivc_rev_dt) = 1 THEN CONVERT(DATETIME, CAST(A.ptcus_last_ivc_rev_dt AS CHAR(12)), 112) ELSE CONVERT(DATETIME, CAST(''19000101'' AS CHAR(12)), 112) END
				,dtmLastPaymentRevisedDate = CASE WHEN ISDATE(A.ptcus_last_pay_rev_dt) = 1 THEN CONVERT(DATETIME, CAST(A.ptcus_last_pay_rev_dt AS CHAR(12)), 112) ELSE CONVERT(DATETIME, CAST(''19000101'' AS CHAR(12)), 112) END
				,dtmLastStatementRevDate =  CASE WHEN ISDATE(A.ptcus_last_stmnt_rev_dt) = 1 THEN CONVERT(DATETIME, CAST(A.ptcus_last_stmnt_rev_dt AS CHAR(12)), 112) ELSE CONVERT(DATETIME, CAST(''19000101'' AS CHAR(12)), 112) END
				,strCompleteAddress = dbo.[fnConvertToFullAddress](LTRIM((CASE WHEN RTRIM(ISNULL(A.ptcus_addr2,'''')) <> '''' THEN (CASE WHEN RTRIM(ISNULL(A.ptcus_addr,'''')) <> '''' THEN (RTRIM(ISNULL(A.ptcus_addr,'''')) + CHAR(13) + CHAR(10) + RTRIM(A.ptcus_addr2)) ELSE RTRIM(A.ptcus_addr2) END) ELSE RTRIM(ISNULL(A.ptcus_addr,'''')) END))
																	,ISNULL(A.ptcus_city,'''')
																	,ISNULL(A.ptcus_state,'''')
																	,ISNULL(A.ptcus_zip,'''')) COLLATE Latin1_General_CI_AS
				,strFormattedAddress = LTRIM((CASE WHEN RTRIM(ISNULL(A.ptcus_addr2,'''')) <> '''' THEN (CASE WHEN RTRIM(ISNULL(A.ptcus_addr,'''')) <> '''' THEN (RTRIM(ISNULL(A.ptcus_addr,'''')) + CHAR(13) + CHAR(10) + RTRIM(A.ptcus_addr2)) ELSE RTRIM(A.ptcus_addr2) END) ELSE RTRIM(ISNULL(A.ptcus_addr,'''')) END)) COLLATE Latin1_General_CI_AS
				,strFullName = (CASE WHEN A.ptcus_co_per_ind_cp = ''C'' 
									THEN RTRIM(A.ptcus_last_name) + RTRIM(A.ptcus_first_name) + RTRIM(A.ptcus_mid_init) + RTRIM(A.ptcus_name_suffx)   
								WHEN A.ptcus_first_name IS NULL OR RTRIM(A.ptcus_first_name) = ''''  
									THEN     RTRIM(A.ptcus_last_name) + RTRIM(A.ptcus_name_suffx)    
								ELSE     RTRIM(A.ptcus_last_name) + RTRIM(A.ptcus_name_suffx) + '', '' + RTRIM(A.ptcus_first_name) + RTRIM(A.ptcus_mid_init)
								END)  COLLATE Latin1_General_CI_AS
				,strFullTermName = (CAST(ISNULL(A.ptcus_terms_code,'''') AS NVARCHAR(10)) + '' - '' + ISNULL(C.pttrm_desc,'''')) COLLATE Latin1_General_CI_AS
				,strCreditNote =''''
				FROM ptcusmst A
				LEFT JOIN ptlocmst B
					ON A.ptcus_bus_loc_no = B.ptloc_loc_no
				LEFT JOIN (
					SELECT 
						pttrm_desc
						,pttrm_code
						,intRecCountId = ROW_NUMBER() OVER(PARTITION BY pttrm_code ORDER BY A4GLIdentity)
					FROM pttrmmst
				) C 
				ON  C.pttrm_code = A.ptcus_terms_code  
					AND C.intRecCountId = 1
				')
		END
	END
	ELSE
	BEGIN
		EXEC ('
			CREATE VIEW [dbo].[vwcusmst]  
			AS  
			SELECT
				vwcus_key = ISNULL(Ent.strEntityNo,'''')
				,vwcus_last_name = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,1,25) ELSE SUBSTRING(Ent.strName, 1, (CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  -1 ELSE 25 END)) END),'''')
				,vwcus_first_name = ISNULL((CASE WHEN Cus.strType = ''Company'' THEN SUBSTRING(Ent.strName,26,50) ELSE SUBSTRING(Ent.strName,(CASE WHEN CHARINDEX( '', '', Ent.strName) != 0 THEN CHARINDEX( '', '', Ent.strName)  + 2 ELSE 50 END),50) END),'''')
				,vwcus_mid_init = ''''
				,vwcus_name_suffix = ''''
				,vwcus_addr = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress,1,30), 0, CHARINDEX(CHAR(10),Loc.strAddress)) ELSE SUBSTRING(Loc.strAddress,1,30) END
				,vwcus_addr2 = CASE WHEN CHARINDEX(CHAR(10), Loc.strAddress) > 0 THEN SUBSTRING(SUBSTRING(Loc.strAddress, CHARINDEX(CHAR(10),Loc.strAddress) + 1, LEN(Loc.strAddress)),1,30) ELSE NULL END
				,vwcus_city = SUBSTRING(Loc.strCity,1,20)
				,vwcus_state = SUBSTRING(Loc.strState,1,2)
				,vwcus_zip = SUBSTRING(Loc.strZipCode,1,10)  
				,vwcus_phone = E.strPhone
				,vwcus_phone_ext = E.strPhoneExtension
				,vwcus_bill_to = ''''  
				,vwcus_contact = SUBSTRING((Con.strName),1,20) 
				,vwcus_comments = SUBSTRING(Con.strInternalNotes,1,30) 
				,vwcus_slsmn_id = (SELECT strSalespersonId FROM tblARSalesperson WHERE intEntityId = Cus.intSalespersonId)
				,vwcus_terms_cd = Loc.intTermsId
				,vwcus_prc_lvl = CAST(0 AS INT)
				,vwcus_stmt_fmt =	CASE WHEN Cus.strStatementFormat = ''Open Item'' THEN ''O''
									 WHEN Cus.strStatementFormat = ''Balance Forward'' THEN ''B'' 
									 WHEN Cus.strStatementFormat = ''Budget Reminder'' THEN ''R'' 
									 WHEN Cus.strStatementFormat = ''None'' THEN ''N'' 
									 WHEN Cus.strStatementFormat IS NULL THEN Null ELSE '''' END
				,vwcus_ytd_pur = 0  
				,vwcus_ytd_sls = ISNULL(CI.dblYTDSales, 0.0)
				,vwcus_ytd_cgs = 0.0  
				,vwcus_budget_amt = Cus.dblMonthlyBudget
				,vwcus_budget_beg_mm = CAST(ISNULL(SUBSTRING(Cus.strBudgetBillingBeginMonth,1,2),0) AS INT)
				,vwcus_budget_end_mm = CAST(ISNULL(SUBSTRING(Cus.strBudgetBillingEndMonth,1,2),0) AS INT)
				,vwcus_active_yn = CASE WHEN Cus.ysnActive = 1 THEN ''Y'' ELSE ''N'' END
				,vwcus_ar_future = CAST(ISNULL(CI.dblFuture,0.0) AS NUMERIC(18,6))
				,vwcus_ar_per1 = ISNULL(CI.dbl10Days,0.0) +  ISNULL(CI.dbl0Days,0.0)
				,vwcus_ar_per2 = ISNULL(CI.dbl30Days,0.0)
				,vwcus_ar_per3 = ISNULL(CI.dbl60Days,0.0)
				,vwcus_ar_per4 = ISNULL(CI.dbl90Days,0.0)
				,vwcus_ar_per5 = ISNULL(CI.dbl91Days,0.0)
				,vwcus_pend_ivc = ISNULL(CI.dblPendingInvoice,0.0)
				,vwcus_cred_reg = ISNULL(CI.dblUnappliedCredits,0.0)
				,vwcus_pend_pymt = ISNULL(CI.dblPendingPayment,0.0)
				,vwcus_cred_ga = 0.0
				,vwcus_co_per_ind_cp = CASE WHEN Cus.strType = ''Company'' THEN ''C'' ELSE ''P'' END
				,vwcus_bus_loc_no = ''''
				,vwcus_cred_limit = Cus.dblCreditLimit
				,vwcus_last_stmt_bal = ISNULL(CI.dblLastStatement,0.0)
				,vwcus_budget_amt_due  = ISNULL(CI.dblBudgetAmount,0.0)
				,vwcus_cred_ppd  = CAST(ISNULL(CI.dblPrepaids,0.0) AS NUMERIC(18,6))
				,vwcus_ytd_srvchr = 0.0 
				,vwcus_last_pymt = ISNULL(CI.dblLastPayment,0.0)
				,vwcus_last_pay_rev_dt = ISNULL(CAST((SELECT CAST(YEAR(CI.dtmLastPaymentDate) AS NVARCHAR(4)) + RIGHT(''00'' + CAST(MONTH(CI.dtmLastPaymentDate) AS NVARCHAR(2)),2)  + RIGHT(''00'' + CAST(DAY(CI.dtmLastPaymentDate) AS NVARCHAR(2)),2))  AS INT),0)  
				,vwcus_last_ivc_rev_dt = 0
				,vwcus_high_cred = 0.0  
				,vwcus_high_past_due = ISNULL(CI.dbl30Days,0.0) + ISNULL(CI.dbl60Days,0.0) + ISNULL(CI.dbl90Days,0.0) + ISNULL(CI.dbl91Days,0.0)
				,vwcus_avg_days_pay = 0
				,vwcus_avg_days_no_ivcs = 0
				,vwcus_last_stmt_rev_dt = ISNULL(CAST((SELECT CAST(YEAR(CI.dtmLastStatementDate) AS NVARCHAR(4)) + RIGHT(''00'' + CAST(MONTH(CI.dtmLastStatementDate) AS NVARCHAR(2)),2)  + RIGHT(''00'' + CAST(DAY(CI.dtmLastStatementDate) AS NVARCHAR(2)),2)) AS INT),0) 
				,vwcus_country = (CASE WHEN LEN(Loc.strCountry) = 3 THEN Loc.strCountry ELSE '''' END)  
				,vwcus_termdescription = (SELECT strTerm FROM tblSMTerm WHERE intTermID = Loc.intTermsId)
				,vwcus_tax_ynp = CASE WHEN Cus.ysnApplyPrepaidTax = 1 THEN ''Y'' ELSE ''N'' END   
				,vwcus_tax_state = ''''  
				,A4GLIdentity = Ent.intEntityId
				,vwcus_phone2 =  F.strPhone
				,vwcus_balance = ISNULL(CI.dblTotalDue,0.0)
				,vwcus_ptd_sls = ISNULL(CI.dblYTDSales,0.0)
				,vwcus_lyr_sls = ISNULL(CI.dblLastYearSales,0.0)
				,vwcus_acct_stat_x_1 = (SELECT strAccountStatusCode FROM tblARAccountStatus WHERE intAccountStatusId = Cus.intAccountStatusId)
				,dblFutureCurrent = ISNULL(CI.dblFuture,0.0) + ISNULL(CI.dbl10Days,0.0) + ISNULL(CI.dbl0Days,0.0)
				,intConcurrencyId = 0
				,strFullLocation =  ISNULL(Loc.strLocationName ,'''')
				,intTaxId = CAST(NULL AS INT)
				,ysnOriginIntegration = CAST(0 AS BIT)
				,strFullCustomerName = Ent.strName
				,intCustomerPricingLevel = Cus.intCompanyLocationPricingLevelId
				,strCustomerContactEmail = Con.strEmail
				,dtmLastInvoiceRevisedDate = (SELECT TOP 1 dtmDate FROM tblARInvoice WHERE intEntityId = Ent.intEntityId AND strTransactionType = ''Invoice'' ORDER BY dtmDate DESC)
				,dtmLastPaymentRevisedDate = CI.dtmLastPaymentDate
				,dtmLastStatementRevDate = CI.dtmLastStatementDate
				,strCompleteAddress = dbo.[fnConvertToFullAddress](ISNULL(Loc.strAddress,'''')
																	,ISNULL(Loc.strCity,'''')
																	,ISNULL(Loc.strState,'''')
																	,ISNULL(Loc.strZipCode,'''')) COLLATE Latin1_General_CI_AS
				,strFormattedAddress =  ISNULL(Loc.strAddress,'''') COLLATE Latin1_General_CI_AS
				,strFullName = Ent.strName
				,strFullTermName = (CAST(ISNULL(T.intTermID,'''') AS NVARCHAR(10)) + '' - '' + ISNULL(T.strTerm,'''')) COLLATE Latin1_General_CI_AS
				,strCreditNote =''''
			FROM tblEMEntity Ent
			INNER JOIN tblARCustomer Cus 
				ON Ent.intEntityId = Cus.intEntityId
			INNER JOIN tblEMEntityToContact CustToCon 
				ON Cus.intEntityId = CustToCon.intEntityId 
					and CustToCon.ysnDefaultContact = 1
			INNER JOIN tblEMEntity Con 
				ON CustToCon.intEntityContactId = Con.intEntityId
			INNER JOIN tblEMEntityLocation Loc 
				ON Ent.intEntityId = Loc.intEntityId 
					and Loc.ysnDefaultLocation = 1
			LEFT JOIN [vyuARCustomerInquiryReport] CI
				ON Ent.intEntityId = CI.intEntityCustomerId
			LEFT JOIN tblEMEntityPhoneNumber E
				ON Con.intEntityId = E.intEntityId
			LEFT JOIN tblEMEntityMobileNumber F
				ON Con.intEntityId = F.intEntityId  
			LEFT JOIN tblSMTerm T
				ON Loc.intTermsId = T.intTermID
		
		')
	END
END


GO
	PRINT 'END OF CREATING [uspTMRecreateCustomerView] SP'
GO
	
GO
	PRINT 'BEGIN OF EXECUTE uspTMRecreateCustomerView'
GO 
	EXEC ('uspTMRecreateCustomerView')
GO 
	PRINT 'END OF EXECUTE uspTMRecreateCustomerView'
GO
