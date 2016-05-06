﻿CREATE PROCEDURE [dbo].[uspAPImportVoucherBackUpAPTRXMST]
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

--BACK UP aptrxmst
IF OBJECT_ID('tempdb..#tmp_aptrxmstImport') IS NOT NULL DROP TABLE #tmp_aptrxmstImport

SELECT
	[aptrx_vnd_no]			=	A.[aptrx_vnd_no]		,
	[aptrx_ivc_no]			=	CASE WHEN DuplicateDataBackup.aptrx_ivc_no IS NOT NULL THEN dbo.fnTrim(A.[aptrx_ivc_no]) + '-DUP' ELSE A.aptrx_ivc_no END,
	[aptrx_sys_rev_dt]  	=	A.[aptrx_sys_rev_dt]	,
	[aptrx_sys_time]    	=	A.[aptrx_sys_time]		,
	[aptrx_cbk_no]      	=	A.[aptrx_cbk_no]		,
	[aptrx_chk_no]      	=	A.[aptrx_chk_no]		,
	[aptrx_trans_type]  	=	A.[aptrx_trans_type]	,
	[aptrx_batch_no]    	=	A.[aptrx_batch_no]		,
	[aptrx_pur_ord_no]  	=	A.[aptrx_pur_ord_no]	,
	[aptrx_po_rcpt_seq] 	=	A.[aptrx_po_rcpt_seq]	,
	[aptrx_ivc_rev_dt]  	=	A.[aptrx_ivc_rev_dt]	,
	[aptrx_disc_rev_dt] 	=	A.[aptrx_disc_rev_dt]	,
	[aptrx_due_rev_dt]  	=	A.[aptrx_due_rev_dt]	,
	[aptrx_chk_rev_dt]  	=	A.[aptrx_chk_rev_dt]	,
	[aptrx_gl_rev_dt]   	=	A.[aptrx_gl_rev_dt]		,
	[aptrx_disc_pct]    	=	A.[aptrx_disc_pct]		,
	[aptrx_orig_amt]    	=	A.[aptrx_orig_amt]		,
	[aptrx_disc_amt]    	=	A.[aptrx_disc_amt]		,
	[aptrx_wthhld_amt]  	=	A.[aptrx_wthhld_amt]	,
	[aptrx_net_amt]     	=	A.[aptrx_net_amt]		,
	[aptrx_1099_amt]    	=	A.[aptrx_1099_amt]		,
	[aptrx_comment]     	=	A.[aptrx_comment]		,
	[aptrx_orig_type]   	=	A.[aptrx_orig_type]		,
	[aptrx_name]        	=	A.[aptrx_name]			,
	[aptrx_recur_yn]    	=	A.[aptrx_recur_yn]		,
	[aptrx_currency]    	=	A.[aptrx_currency]		,
	[aptrx_currency_rt] 	=	A.[aptrx_currency_rt]	,
	[aptrx_currency_cnt]	=	A.[aptrx_currency_cnt]	,
	[aptrx_user_id]     	=	A.[aptrx_user_id]		,
	[aptrx_user_rev_dt]		=	A.[aptrx_user_rev_dt]	,	
	[A4GLIdentity]			=	A.[A4GLIdentity]		
	INTO #tmp_aptrxmstImport
FROM aptrxmst A
OUTER APPLY (
	SELECT E.* FROM aptrxmst E
	WHERE EXISTS(
		SELECT 1 FROM tblAPaptrxmst F
		WHERE A.aptrx_ivc_no = F.aptrx_ivc_no
		AND A.aptrx_vnd_no = F.aptrx_vnd_no
	)
	AND A.aptrx_vnd_no = E.aptrx_vnd_no
	AND A.aptrx_ivc_no = E.aptrx_ivc_no
) DuplicateDataBackup
WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
				THEN
					CASE WHEN CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
				ELSE 1 END)
	AND A.aptrx_trans_type IN ('I','C','A','O')
	AND A.aptrx_orig_amt != 0

--BACK UP RECORDS TO BE IMPORTED FROM aptrxmst
SET IDENTITY_INSERT tblAPaptrxmst ON
INSERT INTO tblAPaptrxmst(
	[aptrx_vnd_no]				,
	[aptrx_ivc_no]				,
	[aptrx_sys_rev_dt]   		,
	[aptrx_sys_time]     		,
	[aptrx_cbk_no]       		,
	[aptrx_chk_no]       		,
	[aptrx_trans_type]   		,
	[aptrx_batch_no]     		,
	[aptrx_pur_ord_no]   		,
	[aptrx_po_rcpt_seq]  		,
	[aptrx_ivc_rev_dt]   		,
	[aptrx_disc_rev_dt]  		,
	[aptrx_due_rev_dt]   		,
	[aptrx_chk_rev_dt]   		,
	[aptrx_gl_rev_dt]    		,
	[aptrx_disc_pct]     		,
	[aptrx_orig_amt]     		,
	[aptrx_disc_amt]     		,
	[aptrx_wthhld_amt]   		,
	[aptrx_net_amt]      		,
	[aptrx_1099_amt]     		,
	[aptrx_comment]      		,
	[aptrx_orig_type]    		,
	[aptrx_name]         		,
	[aptrx_recur_yn]     		,
	[aptrx_currency]     		,
	[aptrx_currency_rt]  		,
	[aptrx_currency_cnt] 		,
	[aptrx_user_id]      		,
	[aptrx_user_rev_dt]			,
	[A4GLIdentity]				,
	[ysnInsertedToAPIVC]
)
SELECT
	[aptrx_vnd_no]				=	A.[aptrx_vnd_no]			,
	[aptrx_ivc_no]				=	A.[aptrx_ivc_no]			,
	[aptrx_sys_rev_dt]   		=	A.[aptrx_sys_rev_dt]   		,
	[aptrx_sys_time]     		=	A.[aptrx_sys_time]     		,
	[aptrx_cbk_no]       		=	A.[aptrx_cbk_no]       		,
	[aptrx_chk_no]       		=	A.[aptrx_chk_no]       		,
	[aptrx_trans_type]   		=	A.[aptrx_trans_type]   		,
	[aptrx_batch_no]     		=	A.[aptrx_batch_no]     		,
	[aptrx_pur_ord_no]   		=	A.[aptrx_pur_ord_no]   		,
	[aptrx_po_rcpt_seq]  		=	A.[aptrx_po_rcpt_seq]  		,
	[aptrx_ivc_rev_dt]   		=	A.[aptrx_ivc_rev_dt]   		,
	[aptrx_disc_rev_dt]  		=	A.[aptrx_disc_rev_dt]  		,
	[aptrx_due_rev_dt]   		=	A.[aptrx_due_rev_dt]   		,
	[aptrx_chk_rev_dt]   		=	A.[aptrx_chk_rev_dt]   		,
	[aptrx_gl_rev_dt]    		=	A.[aptrx_gl_rev_dt]    		,
	[aptrx_disc_pct]     		=	A.[aptrx_disc_pct]     		,
	[aptrx_orig_amt]     		=	A.[aptrx_orig_amt]     		,
	[aptrx_disc_amt]     		=	A.[aptrx_disc_amt]     		,
	[aptrx_wthhld_amt]   		=	A.[aptrx_wthhld_amt]   		,
	[aptrx_net_amt]      		=	A.[aptrx_net_amt]      		,
	[aptrx_1099_amt]     		=	A.[aptrx_1099_amt]     		,
	[aptrx_comment]      		=	A.[aptrx_comment]      		,
	[aptrx_orig_type]    		=	A.[aptrx_orig_type]    		,
	[aptrx_name]         		=	A.[aptrx_name]         		,
	[aptrx_recur_yn]     		=	A.[aptrx_recur_yn]     		,
	[aptrx_currency]     		=	A.[aptrx_currency]     		,
	[aptrx_currency_rt]  		=	A.[aptrx_currency_rt]  		,
	[aptrx_currency_cnt] 		=	A.[aptrx_currency_cnt] 		,
	[aptrx_user_id]      		=	A.[aptrx_user_id]      		,
	[aptrx_user_rev_dt]			=	A.[aptrx_user_rev_dt]		,
	[A4GLIdentity]				=	A.[A4GLIdentity]			,
	[ysnInsertedToAPIVC]		=	1
FROM #tmp_aptrxmstImport A
SET IDENTITY_INSERT tblAPaptrxmst OFF
--BACK UP RECORDS FROM aptrxmst TO apivcmst to make sure origin will not abel to create duplicate vendor order number
INSERT INTO apivcmst(
	[apivc_vnd_no]				,
	[apivc_ivc_no]				,
	[apivc_cbk_no]       		,
	[apivc_chk_no]       		,
	[apivc_status_ind]			,
	[apivc_trans_type]   		,
	[apivc_pur_ord_no]   		,
	[apivc_po_rcpt_seq]  		,
	[apivc_ivc_rev_dt]   		,
	[apivc_disc_rev_dt]  		,
	[apivc_due_rev_dt]   		,
	[apivc_chk_rev_dt]   		,
	[apivc_gl_rev_dt]    		,
	[apivc_orig_amt]     		,
	[apivc_wthhld_amt]   		,
	[apivc_net_amt]      		,
	[apivc_1099_amt]     		,
	[apivc_comment]      		,
	[apivc_recur_yn]     		,
	[apivc_currency]     		,
	[apivc_currency_rt]  		,
	[apivc_currency_cnt] 		,
	[apivc_user_id]      		,
	[apivc_user_rev_dt]			
)
SELECT
	[apivc_vnd_no]			=	A.[aptrx_vnd_no]		,
	[apivc_ivc_no]			=	A.[aptrx_ivc_no]		,
	[apivc_cbk_no]      	=	A.[aptrx_cbk_no]		,
	[apivc_chk_no]      	=	A.[aptrx_chk_no]		,
	[apivc_status_ind]		=	'R'					,
	[apivc_trans_type]  	=	A.[aptrx_trans_type]	,
	[apivc_pur_ord_no]  	=	A.[aptrx_pur_ord_no]	,
	[apivc_po_rcpt_seq] 	=	A.[aptrx_po_rcpt_seq]	,
	[apivc_ivc_rev_dt]  	=	A.[aptrx_ivc_rev_dt]	,
	[apivc_disc_rev_dt] 	=	A.[aptrx_disc_rev_dt]	,
	[apivc_due_rev_dt]  	=	A.[aptrx_due_rev_dt]	,
	[apivc_chk_rev_dt]  	=	A.[aptrx_chk_rev_dt]	,
	[apivc_gl_rev_dt]   	=	A.[aptrx_gl_rev_dt]		,
	[apivc_orig_amt]    	=	A.[aptrx_orig_amt]		,
	[apivc_wthhld_amt]  	=	A.[aptrx_wthhld_amt]	,
	[apivc_net_amt]     	=	A.[aptrx_net_amt]		,
	[apivc_1099_amt]    	=	A.[aptrx_1099_amt]		,
	[apivc_comment]     	=	'Imported Origin Bill - i21 Record'		,
	[apivc_recur_yn]    	=	A.[aptrx_recur_yn]		,
	[apivc_currency]    	=	A.[aptrx_currency]		,
	[apivc_currency_rt] 	=	A.[aptrx_currency_rt]	,
	[apivc_currency_cnt]	=	A.[aptrx_currency_cnt]	,
	[apivc_user_id]     	=	A.[aptrx_user_id]		,
	[apivc_user_rev_dt]		=	A.[aptrx_user_rev_dt]	
FROM #tmp_aptrxmstImport A

--BACK UP apeglmst
IF OBJECT_ID('tempdb..#tmp_apeglmstImport') IS NOT NULL DROP TABLE tmp_apeglmstImport
SELECT
	[apegl_cbk_no]			=	A.[apegl_cbk_no]		,
	[apegl_trx_ind]			=	A.[apegl_trx_ind]		,
	[apegl_vnd_no]			=	A.[apegl_vnd_no]		,
	[apegl_ivc_no]			=	B.aptrx_ivc_no			,
	[apegl_dist_no]			=	A.[apegl_dist_no]		,
	[apegl_alt_cbk_no]		=	A.[apegl_alt_cbk_no]	,
	[apegl_gl_acct]			=	A.[apegl_gl_acct]		,
	[apegl_gl_amt]			=	A.[apegl_gl_amt]		,
	[apegl_gl_un]			=	A.[apegl_gl_un]			,
	[A4GLIdentity]			=	A.[A4GLIdentity]		,
	[aptrx_ivc_no_header]	=	B.aptrx_ivc_no
	INTO #tmp_apeglmstImport
FROM apeglmst A
INNER JOIN #tmp_aptrxmstImport  B
ON B.aptrx_ivc_no = A.apegl_ivc_no 
	AND B.aptrx_vnd_no = A.apegl_vnd_no

SET IDENTITY_INSERT tblAPapeglmst ON
INSERT INTO tblAPapeglmst(
	[apegl_cbk_no]		,
	[apegl_trx_ind]		,
	[apegl_vnd_no]		,
	[apegl_ivc_no]		,
	[apegl_dist_no]		,
	[apegl_alt_cbk_no]	,
	[apegl_gl_acct]		,
	[apegl_gl_amt]		,
	[apegl_gl_un]		,
	[A4GLIdentity]		,
	[intBillDetailId]
)
SELECT
	[apegl_cbk_no]		=	A.[apegl_cbk_no]		,
	[apegl_trx_ind]		=	A.[apegl_trx_ind]		,
	[apegl_vnd_no]		=	A.[apegl_vnd_no]		,
	[apegl_ivc_no]		=	A.[apegl_ivc_no]		,
	[apegl_dist_no]		=	A.[apegl_dist_no]		,
	[apegl_alt_cbk_no]	=	A.[apegl_alt_cbk_no]	,
	[apegl_gl_acct]		=	A.[apegl_gl_acct]		,
	[apegl_gl_amt]		=	A.[apegl_gl_amt]		,
	[apegl_gl_un]		=	A.[apegl_gl_un]			,
	[A4GLIdentity]		=	A.[A4GLIdentity]		,
	[intBillDetailId]	=	A.A4GLIdentity
FROM #tmp_apeglmstImport A
SET IDENTITY_INSERT tblAPapeglmst OFF

INSERT INTO aphglmst(
	[aphgl_cbk_no]		,
	[aphgl_trx_ind]		,
	[aphgl_vnd_no]		,
	[aphgl_ivc_no]		,
	[aphgl_dist_no]		,
	[aphgl_alt_cbk_no]	,
	[aphgl_gl_acct]		,
	[aphgl_gl_amt]		,
	[aphgl_gl_un]		
)
SELECT 
	[aphgl_cbk_no]			=	A.[apegl_cbk_no]		,
	[aphgl_trx_ind]			=	A.[apegl_trx_ind]		,
	[aphgl_vnd_no]			=	A.[apegl_vnd_no]		,
	[aphgl_ivc_no]			=	A.[apegl_ivc_no]		,
	[aphgl_dist_no]			=	A.[apegl_dist_no]		,
	[aphgl_alt_cbk_no]		=	A.[apegl_alt_cbk_no]	,
	[aphgl_gl_acct]			=	A.[apegl_gl_acct]		,
	[aphgl_gl_amt]			=	A.[apegl_gl_amt]		,
	[aphgl_gl_un]			=	A.[apegl_gl_un]		
FROM #tmp_apeglmstImport A

END TRY
BEGIN CATCH
	DECLARE @errorBackingUp NVARCHAR(500) = ERROR_MESSAGE();
	RAISERROR(@errorBackingUp, 16, 1);
END CATCH

