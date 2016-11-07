CREATE PROCEDURE [dbo].[uspAPRevertImportVoucher]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

--REINSERT RECORDS DELETED FROM aptrxmst
IF OBJECT_ID(N'dbo.tmp_aptrxmstImport') IS NOT NULL
BEGIN

	INSERT INTO aptrxmst(
		[aptrx_vnd_no]       ,
		[aptrx_ivc_no]       ,
		[aptrx_sys_rev_dt]   ,
		[aptrx_sys_time]     ,
		[aptrx_cbk_no]       ,
		[aptrx_chk_no]       ,
		[aptrx_trans_type]   ,
		[aptrx_batch_no]     ,
		[aptrx_pur_ord_no]   ,
		[aptrx_po_rcpt_seq]  ,
		[aptrx_ivc_rev_dt]   ,
		[aptrx_disc_rev_dt]  ,
		[aptrx_due_rev_dt]   ,
		[aptrx_chk_rev_dt]   ,
		[aptrx_gl_rev_dt]    ,
		[aptrx_disc_pct]     ,
		[aptrx_orig_amt]     ,
		[aptrx_disc_amt]     ,
		[aptrx_wthhld_amt]   ,
		[aptrx_net_amt]      ,
		[aptrx_1099_amt]     ,
		[aptrx_comment]      ,
		[aptrx_orig_type]    ,
		[aptrx_name]         ,
		[aptrx_recur_yn]     ,
		[aptrx_currency]     ,
		[aptrx_currency_rt]  ,
		[aptrx_currency_cnt] ,
		[aptrx_user_id]      ,
		[aptrx_user_rev_dt]	
	)
	SELECT
		A.[aptrx_vnd_no]       ,
		A.[aptrx_ivc_no]       ,
		A.[aptrx_sys_rev_dt]   ,
		A.[aptrx_sys_time]     ,
		A.[aptrx_cbk_no]       ,
		A.[aptrx_chk_no]       ,
		A.[aptrx_trans_type]   ,
		A.[aptrx_batch_no]     ,
		A.[aptrx_pur_ord_no]   ,
		A.[aptrx_po_rcpt_seq]  ,
		A.[aptrx_ivc_rev_dt]   ,
		A.[aptrx_disc_rev_dt]  ,
		A.[aptrx_due_rev_dt]   ,
		A.[aptrx_chk_rev_dt]   ,
		A.[aptrx_gl_rev_dt]    ,
		A.[aptrx_disc_pct]     ,
		A.[aptrx_orig_amt]     ,
		A.[aptrx_disc_amt]     ,
		A.[aptrx_wthhld_amt]   ,
		A.[aptrx_net_amt]      ,
		A.[aptrx_1099_amt]     ,
		A.[aptrx_comment]      ,
		A.[aptrx_orig_type]    ,
		A.[aptrx_name]         ,
		A.[aptrx_recur_yn]     ,
		A.[aptrx_currency]     ,
		A.[aptrx_currency_rt]  ,
		A.[aptrx_currency_cnt] ,
		A.[aptrx_user_id]      ,
		A.[aptrx_user_rev_dt]	
	FROM tmp_aptrxmstImport A
	WHERE NOT EXISTS
	(
		SELECT 1 FROM aptrxmst B WHERE A.aptrx_vnd_no = B.aptrx_vnd_no AND A.aptrx_ivc_no = B.aptrx_ivc_no
	)
	
	--NO NEED AS WE DO NOT CREATE PAYMENT ON IMPORT ON-GOING
	--DELETE A
	--FROM tblAPPayment A
	--INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
	--INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
	--INNER JOIN tblAPaptrxmst D ON C.intBillId = D.intBillId
	--INNER JOIN tmp_aptrxmstImport E ON D.intId = E.intBackupId

	--DELETE FIRST THE INSERTED VOUCHER
	DELETE A
	FROM tblAPBill A
	INNER JOIN tblAPaptrxmst B ON A.intBillId = B.intBillId
	INNER JOIN tmp_aptrxmstImport C ON B.intId = C.intBackupId
	WHERE A.ysnPosted = 0

	--DELETE BACK UP RECORDS FROM tblAPaptrxmst
	DELETE A
	FROM tblAPaptrxmst A
	INNER JOIN tmp_aptrxmstImport B ON A.intId = B.intBackupId

	--REINSERT RECORDS DELETED FROM apeglmst
	INSERT INTO apeglmst(
		[apegl_cbk_no]		
		,[apegl_trx_ind]		
		,[apegl_vnd_no]		
		,[apegl_ivc_no]		
		,[apegl_dist_no]		
		,[apegl_alt_cbk_no]	
		,[apegl_gl_acct]		
		,[apegl_gl_amt]		
		,[apegl_gl_un]		
	)
	SELECT
		[apegl_cbk_no]		=	B.[apegl_cbk_no]		,
		[apegl_trx_ind]		=	B.[apegl_trx_ind]		,
		[apegl_vnd_no]		=	B.[apegl_vnd_no]		,
		[apegl_ivc_no]		=	B.[apegl_ivc_no]		,
		[apegl_dist_no]		=	B.[apegl_dist_no]		,
		[apegl_alt_cbk_no]	=	B.[apegl_alt_cbk_no]	,
		[apegl_gl_acct]		=	B.[apegl_gl_acct]		,
		[apegl_gl_amt]		=	B.[apegl_gl_amt]		,
		[apegl_gl_un]		=	B.[apegl_gl_un]			
	FROM tmp_aptrxmstImport A
	INNER JOIN tmp_apeglmstImport B ON A.intId = B.intHeaderId
	WHERE NOT EXISTS
	(
		SELECT 1 FROM aptrxmst B WHERE A.aptrx_vnd_no = B.aptrx_vnd_no AND A.aptrx_ivc_no = B.aptrx_ivc_no
	)

	--DELETE BACK UP RECORDS FROM tblAPapeglmst
	DELETE A
	FROM tblAPapeglmst A
	INNER JOIN tmp_aptrxmstImport B ON A.intHeaderId= B.intBackupId

	DELETE A
	FROM aphglmst A
	INNER JOIN apivcmst B ON A.aphgl_vnd_no = B.apivc_vnd_no AND A.aphgl_ivc_no = B.apivc_ivc_no
	INNER JOIN tmp_aptrxmstImport C
		ON A.aphgl_vnd_no = C.aptrx_vnd_no AND A.aphgl_ivc_no = C.aptrx_ivc_no
	WHERE B.apivc_status_ind = 'R'

	--DELETE REINSERTED RECORDS TO apivcmst
	DELETE A
	FROM apivcmst A
	INNER JOIN tmp_aptrxmstImport B
		ON A.apivc_vnd_no = B.aptrx_vnd_no AND A.apivc_ivc_no = B.aptrx_ivc_no
	WHERE A.apivc_status_ind = 'R'

	DELETE A
	FROM tblAPapivcmst A
	INNER JOIN tmp_aptrxmstImport B
		ON A.apivc_vnd_no = B.aptrx_vnd_no AND A.apivc_ivc_no = B.aptrx_ivc_no

	DELETE A
	FROM tblAPaphglmst A
	INNER JOIN tmp_aptrxmstImport B
		ON A.aphgl_vnd_no = B.aptrx_vnd_no AND A.aphgl_ivc_no = B.aptrx_ivc_no
	 

END

IF OBJECT_ID(N'dbo.tmp_apivcmstImport') IS NOT NULL
BEGIN

	DELETE A
	FROM tblAPPayment A
	INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
	INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
	INNER JOIN tblAPapivcmst D ON C.intBillId = D.intBillId
	INNER JOIN tmp_apivcmstImport E ON D.intId = E.intBackupId
		
	DELETE A
	FROM tblAPBill A
	INNER JOIN tblAPapivcmst B ON A.intBillId = B.intBillId
	INNER JOIN tmp_apivcmstImport C ON B.intId = C.intBackupId

	DELETE A
	FROM tblAPapivcmst A
	INNER JOIN tmp_apivcmstImport B ON A.intId = B.intBackupId

	DELETE A
	FROM tblAPaphglmst A
	INNER JOIN tmp_apivcmstImport B ON A.intHeaderId = B.intBackupId
	
END

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @errorRevert NVARCHAR(500) = ERROR_MESSAGE();
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR(@errorRevert, 16, 1);
END CATCH

