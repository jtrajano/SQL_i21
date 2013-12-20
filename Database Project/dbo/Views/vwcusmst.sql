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
