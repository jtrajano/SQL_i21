
-- Create a integration compliant stored procedure. 
-- There is another stored procedure of the same name in the i21Database project. 
-- If there is an integration with the origin system, this stored procedure will be used. 
-- Otherwise, the stored procedure in the i21Database will be used. 
CREATE PROCEDURE uspCMProcessUndepositedFunds
	@intBankAccountId AS INT 
	,@strTransactionId NVARCHAR(40) = NULL 
	,@intUserId INT = NULL 
	,@isSuccessful BIT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Refresh the data in the undeposited fund table. 
EXEC uspCMRefreshUndepositedFundsFromOrigin @intBankAccountId, @intUserId

-- Validate the records
-- 1. Check any of the undeposited fund is missing 
DECLARE @isValid AS BIT

SELECT	@isValid = 0
FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d
			ON h.intTransactionId = d.intTransactionId
WHERE	h.strTransactionId = @strTransactionId
		AND d.intUndepositedFundId IS NOT NULL
		AND NOT EXISTS (
			SELECT	intUndepositedFundId 
			FROM	tblCMUndepositedFund uf
			WHERE	uf.intUndepositedFundId = d.intUndepositedFundId
		)
IF @@ERROR <> 0	GOTO Exit_WithErrors

IF (ISNULL(@isValid, 1) = 0)
BEGIN 
	RAISERROR(50022,11,1)
	IF @@ERROR <> 0	GOTO Exit_WithErrors	
END

-- 2. Check for outdated amounts. 
SET	@isValid = 1

SELECT	@isValid = 0
FROM	(	SELECT	v.intUndepositedFundId
					,total = SUM(ISNULL(v.dblAmount, 0))
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d
						ON h.intTransactionId = d.intTransactionId
					INNER JOIN vyuCMOriginUndepositedFund v 
						ON d.intUndepositedFundId = v.intUndepositedFundId
			WHERE	h.strTransactionId = @strTransactionId
					AND d.intUndepositedFundId IS NOT NULL 
			GROUP BY v.intUndepositedFundId	
		) AS Q1 INNER JOIN (
			SELECT	d.intUndepositedFundId
					,total = SUM(ISNULL(d.dblCredit,0)) - SUM(ISNULL(d.dblDebit, 0))
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d
						ON h.intTransactionId = d.intTransactionId
			WHERE	h.strTransactionId = @strTransactionId
					AND d.intUndepositedFundId IS NOT NULL 
			GROUP BY d.intUndepositedFundId
		) AS Q2
			ON Q1.intUndepositedFundId = Q1.intUndepositedFundId
WHERE	Q1.intUndepositedFundId = Q2.intUndepositedFundId
		AND Q1.total <> Q2.total
		
IF @@ERROR <> 0	GOTO Exit_WithErrors		
		
IF (ISNULL(@isValid, 1) = 0)
BEGIN 
	RAISERROR(50023,11,1)
	IF @@ERROR <> 0	GOTO Exit_WithErrors	
END

-- Archive the records in aptrxmst
INSERT INTO tblCMAptrxmstArchive (
		aptrx_vnd_no
		,aptrx_ivc_no
		,aptrx_sys_rev_dt
		,aptrx_sys_time
		,aptrx_cbk_no
		,aptrx_chk_no
		,aptrx_trans_type
		,aptrx_batch_no
		,aptrx_pur_ord_no
		,aptrx_po_rcpt_seq
		,aptrx_ivc_rev_dt
		,aptrx_disc_rev_dt
		,aptrx_due_rev_dt
		,aptrx_chk_rev_dt
		,aptrx_gl_rev_dt
		,aptrx_disc_pct
		,aptrx_orig_amt
		,aptrx_disc_amt
		,aptrx_wthhld_amt
		,aptrx_net_amt
		,aptrx_1099_amt
		,aptrx_comment
		,aptrx_orig_type
		,aptrx_name
		,aptrx_recur_yn
		,aptrx_currency
		,aptrx_currency_rt
		,aptrx_currency_cnt
		,aptrx_user_id
		,aptrx_user_rev_dt
		,intCreatedUserId
		,dtmCreated
)
SELECT	v.aptrx_vnd_no
		,v.aptrx_ivc_no
		,v.aptrx_sys_rev_dt
		,v.aptrx_sys_time
		,v.aptrx_cbk_no
		,v.aptrx_chk_no
		,v.aptrx_trans_type
		,v.aptrx_batch_no
		,v.aptrx_pur_ord_no
		,v.aptrx_po_rcpt_seq
		,v.aptrx_ivc_rev_dt
		,v.aptrx_disc_rev_dt
		,v.aptrx_due_rev_dt
		,v.aptrx_chk_rev_dt
		,v.aptrx_gl_rev_dt
		,v.aptrx_disc_pct
		,v.aptrx_orig_amt
		,v.aptrx_disc_amt
		,v.aptrx_wthhld_amt
		,v.aptrx_net_amt
		,v.aptrx_1099_amt
		,v.aptrx_comment
		,v.aptrx_orig_type
		,v.aptrx_name
		,v.aptrx_recur_yn
		,v.aptrx_currency
		,v.aptrx_currency_rt
		,v.aptrx_currency_cnt
		,v.aptrx_user_id
		,v.aptrx_user_rev_dt
		,@intUserId
		,GETDATE()
FROM	tblCMUndepositedFund uf INNER JOIN vyuCMOriginDepositEntry v
			ON uf.strSourceTransactionId = ( 
						CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
						+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
						+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
						+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
					) COLLATE Latin1_General_CI_AS		
WHERE	uf.intUndepositedFundId IN (
			SELECT	d.intUndepositedFundId
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d
						ON h.intTransactionId = d.intTransactionId
			WHERE	h.strTransactionId = @strTransactionId
		)
IF @@ERROR <> 0	GOTO Exit_WithErrors	

-- Archive the records in apchkmst
INSERT INTO tblCMApchkmstArchive (
		apchk_cbk_no
		,apchk_rev_dt
		,apchk_trx_ind
		,apchk_chk_no
		,apchk_alt_cbk_no
		,apchk_alt_trx_ind
		,apchk_alt_chk_no
		,apchk_vnd_no
		,apchk_alt2_cbk_no
		,apchk_name
		,apchk_addr_1
		,apchk_addr_2
		,apchk_city
		,apchk_st
		,apchk_zip
		,apchk_chk_amt
		,apchk_disc_amt
		,apchk_wthhld_amt
		,apchk_1099_amt
		,apchk_gl_rev_dt
		,apchk_adv_chk_yn
		,apchk_man_auto_ind
		,apchk_void_ind
		,apchk_void_rev_dt
		,apchk_cleared_ind
		,apchk_clear_rev_dt
		,apchk_src_sys
		,apchk_comment_1
		,apchk_comment_2
		,apchk_comment_3
		,apchk_currency_rt
		,apchk_currency_cnt
		,apchk_payee_1
		,apchk_payee_2
		,apchk_payee_3
		,apchk_payee_4
		,apchk_user_id
		,apchk_user_rev_dt
		,apchk_chk_exp_yn
		,intCreatedUserId
		,dtmCreated
)
SELECT	chk.apchk_cbk_no
		,chk.apchk_rev_dt
		,chk.apchk_trx_ind
		,chk.apchk_chk_no
		,chk.apchk_alt_cbk_no
		,chk.apchk_alt_trx_ind
		,chk.apchk_alt_chk_no
		,chk.apchk_vnd_no
		,chk.apchk_alt2_cbk_no
		,chk.apchk_name
		,chk.apchk_addr_1
		,chk.apchk_addr_2
		,chk.apchk_city
		,chk.apchk_st
		,chk.apchk_zip
		,chk.apchk_chk_amt
		,chk.apchk_disc_amt
		,chk.apchk_wthhld_amt
		,chk.apchk_1099_amt
		,chk.apchk_gl_rev_dt
		,chk.apchk_adv_chk_yn
		,chk.apchk_man_auto_ind
		,chk.apchk_void_ind
		,chk.apchk_void_rev_dt
		,chk.apchk_cleared_ind
		,chk.apchk_clear_rev_dt
		,chk.apchk_src_sys
		,chk.apchk_comment_1
		,chk.apchk_comment_2
		,chk.apchk_comment_3
		,chk.apchk_currency_rt
		,chk.apchk_currency_cnt
		,chk.apchk_payee_1
		,chk.apchk_payee_2
		,chk.apchk_payee_3
		,chk.apchk_payee_4
		,chk.apchk_user_id
		,chk.apchk_user_rev_dt
		,chk.apchk_chk_exp_yn
		,@intUserId
		,GETDATE()
FROM	apchkmst chk INNER JOIN vyuCMOriginDepositEntry v
			ON chk.apchk_cbk_no = v.aptrx_cbk_no
			AND chk.apchk_chk_no = v.aptrx_chk_no
			AND chk.apchk_vnd_no = v.aptrx_vnd_no
			AND chk.apchk_rev_dt = v.aptrx_chk_rev_dt
		INNER JOIN tblCMUndepositedFund uf 
			ON uf.strSourceTransactionId = ( 
						CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
						+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
						+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
						+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
					) COLLATE Latin1_General_CI_AS		
WHERE	uf.intUndepositedFundId IN (
			SELECT	d.intUndepositedFundId
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d
						ON h.intTransactionId = d.intTransactionId
			WHERE	h.strTransactionId = @strTransactionId
		)
IF @@ERROR <> 0	GOTO Exit_WithErrors	

-- Archive the records in apeglmst 
INSERT INTO tblCMApeglmstArchive (
		apegl_cbk_no
		,apegl_trx_ind
		,apegl_vnd_no
		,apegl_ivc_no
		,apegl_dist_no
		,apegl_alt_cbk_no
		,apegl_gl_acct
		,apegl_gl_amt
		,apegl_gl_un
		,intCreatedUserId
		,dtmCreated
)
SELECT	gl.apegl_cbk_no
		,gl.apegl_trx_ind
		,gl.apegl_vnd_no
		,gl.apegl_ivc_no
		,gl.apegl_dist_no
		,gl.apegl_alt_cbk_no
		,gl.apegl_gl_acct
		,gl.apegl_gl_amt
		,gl.apegl_gl_un
		,@intUserId
		,GETDATE()		
FROM	apeglmst gl INNER JOIN vyuCMOriginDepositEntry v
			ON v.aptrx_cbk_no = gl.apegl_cbk_no
			AND v.aptrx_ivc_no = gl.apegl_ivc_no
			AND v.aptrx_vnd_no = gl.apegl_vnd_no
		INNER JOIN tblCMUndepositedFund uf 
			ON uf.strSourceTransactionId = ( 
						CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
						+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
						+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
						+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
					) COLLATE Latin1_General_CI_AS					
WHERE	gl.apegl_trx_ind = 'O'
		AND uf.intUndepositedFundId IN (
			SELECT	d.intUndepositedFundId
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d
						ON h.intTransactionId = d.intTransactionId
			WHERE	h.strTransactionId = @strTransactionId
		)
IF @@ERROR <> 0	GOTO Exit_WithErrors

-- Delete the records
DELETE	aptrxmst
FROM	tblCMUndepositedFund uf INNER JOIN aptrxmst trx
			ON uf.strSourceTransactionId = ( 
						CAST(trx.aptrx_vnd_no AS NVARCHAR(10)) 
						+ CAST(trx.aptrx_ivc_no AS NVARCHAR(18)) 
						+ CAST(trx.aptrx_cbk_no AS NVARCHAR(2)) 
						+ CAST(trx.aptrx_chk_no AS NVARCHAR(8))
					) COLLATE Latin1_General_CI_AS		
WHERE	uf.intUndepositedFundId IN (
			SELECT	d.intUndepositedFundId
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d
						ON h.intTransactionId = d.intTransactionId
			WHERE	h.strTransactionId = @strTransactionId
		)		
IF @@ERROR <> 0	GOTO Exit_WithErrors

DELETE	apchkmst_origin 
FROM	apchkmst_origin chk INNER JOIN vyuCMOriginDepositEntry v
			ON chk.apchk_cbk_no = v.aptrx_cbk_no
			AND chk.apchk_chk_no = v.aptrx_chk_no
			AND chk.apchk_vnd_no = v.aptrx_vnd_no
			AND chk.apchk_rev_dt = v.aptrx_chk_rev_dt
		INNER JOIN tblCMUndepositedFund uf 
			ON uf.strSourceTransactionId = ( 
						CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
						+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
						+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
						+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
					) COLLATE Latin1_General_CI_AS		
WHERE	uf.intUndepositedFundId IN (
			SELECT	d.intUndepositedFundId
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d
						ON h.intTransactionId = d.intTransactionId
			WHERE	h.strTransactionId = @strTransactionId
		)
IF @@ERROR <> 0	GOTO Exit_WithErrors

DELETE	apeglmst
FROM	apeglmst gl INNER JOIN vyuCMOriginDepositEntry v
			ON v.aptrx_cbk_no = gl.apegl_cbk_no
			AND v.aptrx_ivc_no = gl.apegl_ivc_no
			AND v.aptrx_vnd_no = gl.apegl_vnd_no
		INNER JOIN tblCMUndepositedFund uf 
			ON uf.strSourceTransactionId = ( 
						CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
						+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
						+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
						+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
					) COLLATE Latin1_General_CI_AS					
WHERE	gl.apegl_trx_ind = 'O'
		AND uf.intUndepositedFundId IN (
			SELECT	d.intUndepositedFundId
			FROM	tblCMBankTransaction h INNER JOIN tblCMBankTransactionDetail d
						ON h.intTransactionId = d.intTransactionId
			WHERE	h.strTransactionId = @strTransactionId
		)
IF @@ERROR <> 0	GOTO Exit_WithErrors

--=====================================================================================================================================
-- 	EXIT ROUTINES 
---------------------------------------------------------------------------------------------------------------------------------------

Exit_Successfully:
	SET @isSuccessful = 1
	GOTO Exit_Routine

Exit_WithErrors:
	SET @isSuccessful = 0
	
Exit_Routine:
