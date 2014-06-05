
-- The view is used in CM -> Undeposited Funds. 
-- It is used to retrieve the latest deposit entry records from origin. 
-- The undeposited funds table is updated with the records from this view. 

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	EXEC ('
		IF OBJECT_ID(''vyuCMOriginDepositEntry'', ''V'') IS NOT NULL 
			DROP VIEW vyuCMOriginDepositEntry
	')

	EXEC ('
		CREATE VIEW [dbo].[vyuCMOriginDepositEntry]
		AS

		SELECT  o.aptrx_vnd_no
				,o.aptrx_ivc_no
				,o.aptrx_sys_rev_dt
				,o.aptrx_sys_time
				,o.aptrx_cbk_no
				,o.aptrx_chk_no
				,o.aptrx_trans_type
				,o.aptrx_batch_no
				,o.aptrx_pur_ord_no
				,o.aptrx_po_rcpt_seq
				,o.aptrx_ivc_rev_dt
				,o.aptrx_disc_rev_dt
				,o.aptrx_due_rev_dt
				,o.aptrx_chk_rev_dt
				,o.aptrx_gl_rev_dt
				,o.aptrx_disc_pct
				,o.aptrx_orig_amt
				,o.aptrx_disc_amt
				,o.aptrx_wthhld_amt
				,o.aptrx_net_amt
				,o.aptrx_1099_amt
				,o.aptrx_comment
				,o.aptrx_orig_type
				,o.aptrx_name
				,o.aptrx_recur_yn
				,o.aptrx_currency
				,o.aptrx_currency_rt
				,o.aptrx_currency_cnt
				,o.aptrx_user_id
				,o.aptrx_user_rev_dt
		FROM	dbo.aptrxmst o
		WHERE	aptrx_trans_type = ''O''    
	')
END

GO