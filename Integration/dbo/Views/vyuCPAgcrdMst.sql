-- DELETE OLD VIEW
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCPAgcrdMst')
	DROP VIEW vwCPAgcrdMst
GO

-- DELETE EXISTING VIEW
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCPAgcrdMst')
	DROP VIEW vyuCPAgcrdMst
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPAgcrdMst] AS
		SELECT
			agcrd_cus_no
			,agcrd_rev_dt
			,agcrd_seq_no
			,agcrd_type
			,agcrd_ref_no
			,agcrd_amt
			,agcrd_amt_used
			,agcrd_cred_ind
			,agcrd_acct_no
			,agcrd_loc_no
			,agcrd_note
			,agcrd_batch_no
			,agcrd_audit_no
			,agcrd_eft_in_progress_yn
			,agcrd_currency
			,agcrd_currency_rt
			,agcrd_currency_cnt
			,agcrd_pay_type
			,agcrd_user_id
			,agcrd_user_rev_dt
			,A4GLIdentity
		  FROM
			agcrdmst
		')
GO
IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()	) = 1 and (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'EC' and strDBName = db_name()) = 1
	EXEC ('
		CREATE VIEW [dbo].[vyuCPAgcrdMst] AS
		SELECT
			agcrd_cus_no = ptcrd_cus_no
			,agcrd_rev_dt = ptcrd_rev_dt
			,agcrd_seq_no = ptcrd_seq_no
			,agcrd_type = ptcrd_type
			,agcrd_ref_no = ptcrd_invc_no
			,agcrd_amt = ptcrd_amt
			,agcrd_amt_used = ptcrd_amt_used
			,agcrd_cred_ind = ptcrd_cred_ind
			,agcrd_acct_no = ptcrd_acct_no
			,agcrd_loc_no = ptcrd_loc_no
			,agcrd_note = ptcrd_note
			,agcrd_batch_no = null
			,agcrd_audit_no = null
			,agcrd_eft_in_progress_yn = ptcrd_eft_in_progress_yn
			,agcrd_currency = null
			,agcrd_currency_rt = null
			,agcrd_currency_cnt = null
			,agcrd_pay_type = ptcrd_pay_type
			,agcrd_user_id = ptcrd_user_id
			,agcrd_user_rev_dt = ptcrd_user_rev_dt
			,A4GLIdentity = A4GLIdentity
		  FROM
			ptcrdmst
		')
GO
