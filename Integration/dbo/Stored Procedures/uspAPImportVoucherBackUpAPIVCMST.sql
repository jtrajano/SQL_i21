CREATE PROCEDURE [dbo].[uspAPImportVoucherBackupAPIVCMST]
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@totalAPIVCMST INT OUTPUT,
	@totalAPHGLMST INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @nextVoucherNumber INT;
DECLARE @nextPrePayNumber INT;
DECLARE @nextDebitNumber INT;

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

SELECT
	@nextVoucherNumber = A.intNumber
FROM tblSMStartingNumber A
WHERE A.intStartingNumberId = 9

SELECT
	@nextPrePayNumber = A.intNumber
FROM tblSMStartingNumber A
WHERE A.intStartingNumberId = 20

SELECT
	@nextDebitNumber = A.intNumber
FROM tblSMStartingNumber A
WHERE A.intStartingNumberId = 18

IF OBJECT_ID('dbo.tmp_apivcmstImport') IS NOT NULL DROP TABLE tmp_apivcmstImport

CREATE TABLE tmp_apivcmstImport(
	[apivc_vnd_no] [char](10) NOT NULL,
	[apivc_ivc_no] [char](18) NOT NULL,
	[apivc_status_ind] [char](1) NOT NULL,
	[apivc_cbk_no] [char](2) NOT NULL,
	[apivc_chk_no] [char](50) NOT NULL,
	[apivc_trans_type] [char](1) NULL,
	[apivc_pay_ind] [char](1) NULL,
	[apivc_ap_audit_no] [smallint] NULL,
	[apivc_pur_ord_no] [char](8) NULL,
	[apivc_po_rcpt_seq] [smallint] NULL,
	[apivc_ivc_rev_dt] [int] NULL,
	[apivc_disc_rev_dt] [int] NULL,
	[apivc_due_rev_dt] [int] NULL,
	[apivc_chk_rev_dt] [int] NULL,
	[apivc_gl_rev_dt] [int] NULL,
	[apivc_orig_amt] [decimal](11, 2) NULL,
	[apivc_disc_avail] [decimal](11, 2) NULL,
	[apivc_disc_taken] [decimal](11, 2) NULL,
	[apivc_wthhld_amt] [decimal](11, 2) NULL,
	[apivc_net_amt] [decimal](11, 2) NULL,
	[apivc_1099_amt] [decimal](11, 2) NULL,
	[apivc_comment] [char](30) NULL,
	[apivc_adv_chk_no] [int] NULL,
	[apivc_recur_yn] [char](1) NULL,
	[apivc_currency] [char](3) NULL,
	[apivc_currency_rt] [decimal](15, 8) NULL,
	[apivc_currency_cnt] [char](8) NULL,
	[apivc_user_id] [char](16) NULL,
	[apivc_user_rev_dt] [int] NULL,
	[A4GLIdentity] [numeric](9, 0) NOT NULL,
	[apchk_A4GLIdentity] INT NULL,
	[intBackupId]			INT NULL, --Use this to update the linking between the back up and created voucher
	[intId]			INT IDENTITY(1,1) NOT NULL,
	 CONSTRAINT [k_tmpapivcmst] PRIMARY KEY NONCLUSTERED 
	(
		[apivc_vnd_no] ASC,
		[apivc_ivc_no] ASC
	)
)

IF @DateFrom IS NULL
BEGIN
	INSERT INTO tmp_apivcmstImport
	(
		[apivc_vnd_no]			,
		[apivc_ivc_no]			,
		[apivc_status_ind]		,
		[apivc_cbk_no]			,
		[apivc_chk_no]			,
		[apivc_trans_type]		,
		[apivc_pay_ind]			,
		[apivc_ap_audit_no]		,
		[apivc_pur_ord_no]		,
		[apivc_po_rcpt_seq]		,
		[apivc_ivc_rev_dt]		,
		[apivc_disc_rev_dt]		,
		[apivc_due_rev_dt]		,
		[apivc_chk_rev_dt]		,
		[apivc_gl_rev_dt]		,
		[apivc_orig_amt]		,
		[apivc_disc_avail]		,
		[apivc_disc_taken]		,
		[apivc_wthhld_amt]		,
		[apivc_net_amt]			,
		[apivc_1099_amt]		,
		[apivc_comment]			,
		[apivc_adv_chk_no]		,
		[apivc_recur_yn]		,
		[apivc_currency]		,
		[apivc_currency_rt]		,
		[apivc_currency_cnt]	,
		[apivc_user_id]			,
		[apivc_user_rev_dt]		,
		[A4GLIdentity]			,
		[apchk_A4GLIdentity]	
	)
	SELECT
		[apivc_vnd_no]			=	A.[apivc_vnd_no]		,
		[apivc_ivc_no]			=	A.[apivc_ivc_no]		,
		[apivc_status_ind]		=	A.[apivc_status_ind]	,
		[apivc_cbk_no]			=	A.[apivc_cbk_no]		,
		[apivc_chk_no]			=	CASE WHEN PaymentInfo.A4GLIdentity IS NULL AND (A.apivc_status_ind = 'P' OR ISNULL(A.apivc_chk_no,'') != '') 
										THEN dbo.fnTrim(A.apivc_vnd_no) + '-' + dbo.fnTrim(A.apivc_ivc_no) + '-' + dbo.fnTrim(A.apivc_cbk_no)
									ELSE A.[apivc_chk_no] END,
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
		SELECT 
			G.A4GLIdentity
		FROM apchkmst G
		WHERE G.apchk_vnd_no = A.apivc_vnd_no
			AND G.apchk_chk_no = A.apivc_chk_no
			AND G.apchk_rev_dt = A.apivc_chk_rev_dt
			AND G.apchk_cbk_no = A.apivc_cbk_no
			AND G.apchk_alt_trx_ind != 'O'
	) PaymentInfo
	WHERE A.apivc_trans_type IN ('I', 'C', 'A')
END
ELSE
BEGIN
	INSERT INTO tmp_apivcmstImport
	(
		[apivc_vnd_no]			,
		[apivc_ivc_no]			,
		[apivc_status_ind]		,
		[apivc_cbk_no]			,
		[apivc_chk_no]			,
		[apivc_trans_type]		,
		[apivc_pay_ind]			,
		[apivc_ap_audit_no]		,
		[apivc_pur_ord_no]		,
		[apivc_po_rcpt_seq]		,
		[apivc_ivc_rev_dt]		,
		[apivc_disc_rev_dt]		,
		[apivc_due_rev_dt]		,
		[apivc_chk_rev_dt]		,
		[apivc_gl_rev_dt]		,
		[apivc_orig_amt]		,
		[apivc_disc_avail]		,
		[apivc_disc_taken]		,
		[apivc_wthhld_amt]		,
		[apivc_net_amt]			,
		[apivc_1099_amt]		,
		[apivc_comment]			,
		[apivc_adv_chk_no]		,
		[apivc_recur_yn]		,
		[apivc_currency]		,
		[apivc_currency_rt]		,
		[apivc_currency_cnt]	,
		[apivc_user_id]			,
		[apivc_user_rev_dt]		,
		[A4GLIdentity]			,
		[apchk_A4GLIdentity]	
	)
	SELECT
		[apivc_vnd_no]			=	A.[apivc_vnd_no]		,
		[apivc_ivc_no]			=	A.[apivc_ivc_no]		,
		[apivc_status_ind]		=	A.[apivc_status_ind]	,
		[apivc_cbk_no]			=	A.[apivc_cbk_no]		,
		[apivc_chk_no]			=	CASE WHEN PaymentInfo.A4GLIdentity IS NULL AND (A.apivc_status_ind = 'P' OR ISNULL(A.apivc_chk_no,'') != '')
										THEN dbo.fnTrim(A.apivc_vnd_no) + '-' + dbo.fnTrim(A.apivc_ivc_no) + '-' + dbo.fnTrim(A.apivc_cbk_no)
									ELSE A.[apivc_chk_no] END,
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
		SELECT 
			G.A4GLIdentity
		FROM apchkmst G
		WHERE G.apchk_vnd_no = A.apivc_vnd_no
			AND G.apchk_chk_no = A.apivc_chk_no
			AND G.apchk_rev_dt = A.apivc_chk_rev_dt
			AND G.apchk_cbk_no = A.apivc_cbk_no
			--AND G.apchk_chk_amt <> 0
	) PaymentInfo
	WHERE 1 = CASE WHEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
	AND A.apivc_comment IN ('CCD Reconciliation', 'CCD Reconciliation Reversal') AND A.apivc_status_ind = 'U'
	AND A.apivc_trans_type IN ('I', 'C', 'A')
	AND NOT EXISTS(
		SELECT 1 FROM tblAPapivcmst H
		WHERE A.apivc_ivc_no = H.apivc_ivc_no AND A.apivc_vnd_no = H.apivc_vnd_no
	) --MAKE SURE TO IMPORT CCD IF NOT YET IMPORTED
END

IF OBJECT_ID('tempdb..#tmpPostedBackupId') IS NOT NULL DROP TABLE #tmpPostedBackupId
CREATE TABLE #tmpPostedBackupId(intBackupId INT, intId INT)

--BACK UP apivcmst
MERGE INTO tblAPapivcmst AS destination
USING
(
	SELECT
		[apivc_vnd_no]			=	A.[apivc_vnd_no]		,
		[apivc_ivc_no]			=	A.[apivc_ivc_no]		,
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
		[apchk_A4GLIdentity]	=	A.[apchk_A4GLIdentity]	,
		[intId]					=	A.intId
	FROM tmp_apivcmstImport A
) AS SourceData
ON (1 = 0)
WHEN NOT MATCHED THEN
INSERT
(
	[apivc_vnd_no]				,	
	[apivc_ivc_no]				,
	[apivc_status_ind]			,
	[apivc_cbk_no]				,
	[apivc_chk_no]				,
	[apivc_trans_type]			,
	[apivc_pay_ind]				,
	[apivc_ap_audit_no]			,
	[apivc_pur_ord_no]			,
	[apivc_po_rcpt_seq]			,
	[apivc_ivc_rev_dt]			,
	[apivc_disc_rev_dt]			,
	[apivc_due_rev_dt]			,
	[apivc_chk_rev_dt]			,
	[apivc_gl_rev_dt]			,
	[apivc_orig_amt]			,
	[apivc_disc_avail]			,
	[apivc_disc_taken]			,
	[apivc_wthhld_amt]			,
	[apivc_net_amt]				,
	[apivc_1099_amt]			,
	[apivc_comment]				,
	[apivc_adv_chk_no]			,
	[apivc_recur_yn]			,
	[apivc_currency]			,
	[apivc_currency_rt]			,
	[apivc_currency_cnt]		,
	[apivc_user_id]				,
	[apivc_user_rev_dt]			,
	[A4GLIdentity]				,
	[apchk_A4GLIdentity]	
)
VALUES
(
	[apivc_vnd_no]				,
	[apivc_ivc_no]				,
	[apivc_status_ind]			,
	[apivc_cbk_no]				,
	[apivc_chk_no]				,
	[apivc_trans_type]			,
	[apivc_pay_ind]				,
	[apivc_ap_audit_no]			,
	[apivc_pur_ord_no]			,
	[apivc_po_rcpt_seq]			,
	[apivc_ivc_rev_dt]			,
	[apivc_disc_rev_dt]			,
	[apivc_due_rev_dt]			,
	[apivc_chk_rev_dt]			,
	[apivc_gl_rev_dt]			,
	[apivc_orig_amt]			,
	[apivc_disc_avail]			,
	[apivc_disc_taken]			,
	[apivc_wthhld_amt]			,
	[apivc_net_amt]				,
	[apivc_1099_amt]			,
	[apivc_comment]				,
	[apivc_adv_chk_no]			,
	[apivc_recur_yn]			,
	[apivc_currency]			,
	[apivc_currency_rt]			,
	[apivc_currency_cnt]		,
	[apivc_user_id]				,
	[apivc_user_rev_dt]			,
	[A4GLIdentity]				,
	[apchk_A4GLIdentity]	
)
OUTPUT inserted.intId intBackupId, SourceData.intId intId INTO #tmpPostedBackupId;

SET @totalAPIVCMST = @@ROWCOUNT;

--UPDATE temp data for the back up link
UPDATE A
	SET A.intBackupId = B.intBackupId
FROM tmp_apivcmstImport A
INNER JOIN #tmpPostedBackupId B ON A.intId = B.intId

IF OBJECT_ID('tmp_aphglmstImport') IS NOT NULL DROP TABLE tmp_aphglmstImport

CREATE TABLE tmp_aphglmstImport
(
	[aphgl_cbk_no] [char](2) NOT NULL,
	[aphgl_trx_ind] [char](1) NOT NULL,
	[aphgl_vnd_no] [char](10) NOT NULL,
	[aphgl_ivc_no] [char](50) NOT NULL,
	[aphgl_dist_no] [smallint] NOT NULL,
	[aphgl_alt_cbk_no] [char](2) NOT NULL,
	[aphgl_gl_acct] [decimal](16, 8) NOT NULL,
	[aphgl_gl_amt] [decimal](11, 2) NULL,
	[aphgl_gl_un] [decimal](13, 4) NULL,
	[A4GLIdentity] [numeric](9, 0) NOT NULL,
	[intHeaderId]	INT NULL
)

--BACK UP aphglmst
INSERT INTO tmp_aphglmstImport(
	[aphgl_cbk_no]		,
	[aphgl_trx_ind]		,
	[aphgl_vnd_no]		,
	[aphgl_ivc_no]		,
	[aphgl_dist_no]		,
	[aphgl_alt_cbk_no]	,
	[aphgl_gl_acct]		,
	[aphgl_gl_amt]		,
	[aphgl_gl_un]		,
	[A4GLIdentity]		,
	[intHeaderId]
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
	[A4GLIdentity]		=	A.[A4GLIdentity]		,
	[intHeaderId]		=	B.intBackupId
FROM aphglmst A 
INNER JOIN tmp_apivcmstImport B 
	ON B.apivc_ivc_no = A.aphgl_ivc_no 
	AND B.apivc_vnd_no = A.aphgl_vnd_no

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
	[A4GLIdentity]		,
	[intHeaderId]
)
SELECT * FROM tmp_aphglmstImport

SET @totalAPHGLMST = @@ROWCOUNT

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @errorValidating NVARCHAR(500) = ERROR_MESSAGE();
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR(@errorValidating, 16, 1);
END CATCH
