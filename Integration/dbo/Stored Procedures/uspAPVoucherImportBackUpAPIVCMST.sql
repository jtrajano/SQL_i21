CREATE PROCEDURE [dbo].[uspAPVoucherImportBackUpAPIVCMST]
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

--BACK UP apivcmst
SET IDENTITY_INSERT tblAPapivcmst ON
INSERT INTO tblAPapivcmst(
	[apivc_vnd_no],
	[apivc_ivc_no],
	[apivc_status_ind],
	[apivc_cbk_no],
	[apivc_chk_no],
	[apivc_trans_type],
	[apivc_pay_ind],
	[apivc_ap_audit_no],
	[apivc_pur_ord_no],
	[apivc_po_rcpt_seq],
	[apivc_ivc_rev_dt],
	[apivc_disc_rev_dt],
	[apivc_due_rev_dt],
	[apivc_chk_rev_dt],
	[apivc_gl_rev_dt],
	[apivc_orig_amt],
	[apivc_disc_avail],
	[apivc_disc_taken],
	[apivc_wthhld_amt],
	[apivc_net_amt],
	[apivc_1099_amt],
	[apivc_comment],
	[apivc_adv_chk_no],
	[apivc_recur_yn],
	[apivc_currency],
	[apivc_currency_rt],
	[apivc_currency_cnt],
	[apivc_user_id],
	[apivc_user_rev_dt],
	[A4GLIdentity],
	[apchk_A4GLIdentity]
)
SELECT
	[apivc_vnd_no]			=	A.[apivc_vnd_no]		,
	[apivc_ivc_no]			=	CASE WHEN DuplicateDataBackup.apivc_ivc_no IS NOT NULL THEN dbo.fnTrim(A.[apivc_ivc_no]) + '-DUP' ELSE A.apivc_ivc_no END,
	[apivc_status_ind]		=	A.[apivc_status_ind]	,
	[apivc_cbk_no]			=	A.[apivc_cbk_no]		,
	[apivc_chk_no]			=	A.[apivc_chk_no]		,
	[apivc_trans_type]		=	A.[apivc_trans_type]	,
	[apivc_pay_ind]			=	A.[apivc_pay_ind]		,
	[apivc_ap_audit_no]		=	A.[apivc_ap_audit_no]	,
	[apivc_pur_ord_no]		=	A.[apivc_pur_ord_no]	,
	[apivc_po_rcpt_seq]		=	A.[apivc_po_rcpt_seq]	,
	[apivc_ivc_rev_dt]		=	A.[apivc_ivc_rev_dt]	,
	[apivc_disc_rev_dt]		=	A.[apivc_disc_rev_dt]	,
	[apivc_due_rev_dt]		=	A.[apivc_due_rev_dt]	,
	[apivc_chk_rev_dt]		=	A.[apivc_chk_rev_dt]	,
	[apivc_gl_rev_dt]		=	A.[apivc_gl_rev_dt]		,
	[apivc_orig_amt]		=	A.[apivc_orig_amt]		,
	[apivc_disc_avail]		=	A.[apivc_disc_avail]	,
	[apivc_disc_taken]		=	A.[apivc_disc_taken]	,
	[apivc_wthhld_amt]		=	A.[apivc_wthhld_amt]	,
	[apivc_net_amt]			=	A.[apivc_net_amt]		,
	[apivc_1099_amt]		=	A.[apivc_1099_amt]		,
	[apivc_comment]			=	A.[apivc_comment]		,
	[apivc_adv_chk_no]		=	A.[apivc_adv_chk_no]	,
	[apivc_recur_yn]		=	A.[apivc_recur_yn]		,
	[apivc_currency]		=	A.[apivc_currency]		,
	[apivc_currency_rt]		=	A.[apivc_currency_rt]	,
	[apivc_currency_cnt]	=	A.[apivc_currency_cnt]	,
	[apivc_user_id]			=	A.[apivc_user_id]		,
	[apivc_user_rev_dt]		=	A.[apivc_user_rev_dt]	,
	[A4GLIdentity]			=	A.[A4GLIdentity]		,
	[apchk_A4GLIdentity]	=	PaymentInfo.A4GLIdentity
FROM apivcmst A
OUTER APPLY (
	SELECT E.* FROM apivcmst E
	WHERE EXISTS(
		SELECT 1 FROM tblAPapivcmst F
		WHERE A.apivc_ivc_no = F.apivc_ivc_no
		AND A.apivc_vnd_no = F.apivc_vnd_no
	)
	AND A.apivc_vnd_no = E.apivc_vnd_no
	AND A.apivc_ivc_no = E.apivc_ivc_no
) DuplicateDataBackup
OUTER APPLY (
	SELECT 
		G.A4GLIdentity
	FROM apchkmst G
	WHERE G.apchk_vnd_no = A.apivc_vnd_no
		AND G.apchk_chk_no = A.apivc_chk_no
		AND G.apchk_rev_dt = A.apivc_chk_rev_dt
		AND G.apchk_cbk_no = A.apivc_cbk_no
		AND A.apchk_chk_amt <> 0
) PaymentInfo
WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
				THEN
					CASE WHEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
				ELSE 1 END)
	AND A.apivc_trans_type IN ('I','C','A','O')
	AND A.apivc_orig_amt != 0

--BACK UP aphglmst
INSERT INTO tblAPaphglmst(
	[aphgl_cbk_no]		,
	[aphgl_trx_ind]		,
	[aphgl_vnd_no]		,
	[aphgl_ivc_no]		,
	[aphgl_dist_no]		,
	[aphgl_alt_cbk_no]	,
	[aphgl_gl_acct]		,
	[aphgl_gl_amt]		,
	[aphgl_gl_un]		,
	[A4GLIdentity]		
)		
SELECT
	[aphgl_cbk_no]		=	A.[aphgl_cbk_no]		,
	[aphgl_trx_ind]		=	A.[aphgl_trx_ind]		,
	[aphgl_vnd_no]		=	A.[aphgl_vnd_no]		,
	[aphgl_ivc_no]		=	B.[apivc_ivc_no]		,
	[aphgl_dist_no]		=	A.[aphgl_dist_no]		,
	[aphgl_alt_cbk_no]	=	A.[aphgl_alt_cbk_no]	,
	[aphgl_gl_acct]		=	A.[aphgl_gl_acct]		,
	[aphgl_gl_amt]		=	A.[aphgl_gl_amt]		,
	[aphgl_gl_un]		=	A.[aphgl_gl_un]			,
	[A4GLIdentity]		=	A.[A4GLIdentity]		
FROM aphglmst A 
INNER JOIN apivcmst B 
			ON B.apivc_ivc_no = A.aphgl_ivc_no 
			AND B.apivc_vnd_no = A.aphgl_vnd_no
WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
			THEN
				CASE WHEN CONVERT(DATE, CAST(B.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
			ELSE 1 END)
AND B.apivc_trans_type IN ('I','C','A','O')
AND B.apivc_orig_amt != 0

END TRY
BEGIN CATCH
	DECLARE @errorValidating NVARCHAR(500) = ERROR_MESSAGE();
	RAISERROR(@errorValidating, 16, 1);
END CATCH
