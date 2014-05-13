GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwtaxmst')
	DROP VIEW vwtaxmst
GO
-- AG VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()	) = 1
	EXEC ('
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
GO
-- PT VIEW
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1
	EXEC ('
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
GO
