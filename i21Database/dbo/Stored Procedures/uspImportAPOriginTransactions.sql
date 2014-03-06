CREATE PROCEDURE uspImportAPOriginTransactions
	@DateFrom	DATE = NULL,
	@DateTo	DATE = NULL,
	@PeriodFrom	INT = NULL,
	@PeriodTo	INT = NULL,
	@Total INT OUTPUT
AS
BEGIN

DECLARE @InsertedData TABLE (strBillId NVARCHAR(100))

--Create table that holds all the imported transaction
IF(OBJECT_ID('dbo.tblAPTempBill') IS NULL)
	SELECT * INTO tblAPTempBill FROM aptrxmst WHERE aptrxmst.aptrx_ivc_no IS NULL

IF(@DateFrom IS NULL AND @PeriodFrom IS NULL)
BEGIN
	INSERT INTO [dbo].[tblAPBill] (
		[strVendorId], 
		[strBillId],
		[strVendorOrderNumber], 
		[intTermsId], 
		[intTaxCodeId], 
		[dtmDate], 
		[dtmBillDate], 
		[dtmDueDate], 
		[intAccountId], 
		[strDescription], 
		[dblTotal], 
		[ysnPosted], 
		[ysnPaid], 
		[dblAmountDue])
	OUTPUT inserted.strBillId INTO @InsertedData(strBillId)
	--Unposted
	SELECT 
		[strVendorId]			=	A.aptrx_vnd_no,
		[strBillId] 			=	A.aptrx_ivc_no,
		[strVendorOrderNumber] 	=	A.aptrx_ivc_no,
		[intTermsId] 			=	0,
		[intTaxCodeId] 			=	NULL,
		[dtmDate] 				=	CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112),
		[dtmBillDate] 			=	CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112),
		[dtmDueDate] 			=	CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112),
		[intAccountId] 			=	NULL, --(SELECT TOP 1 inti21ID FROM tblGLCOACrossReference WHERE strExternalID = B.apegl_gl_acct),
		[strDescription] 		=	A.aptrx_comment,
		[dblTotal] 				=	A.aptrx_orig_amt,
		[ysnPosted] 			=	0,
		[ysnPaid] 				=	0, --CASE WHEN SUM(ISNULL(B.apegl_gl_amt,0)) = A.aptrx_orig_amt THEN 1 ELSE 0 END,
		[dblAmountDue]			=	A.aptrx_orig_amt--CASE WHEN B.apegl_ivc_no IS NULL THEN A.aptrx_orig_amt ELSE A.aptrx_orig_amt - SUM(ISNULL(B.apegl_gl_amt,0)) END
	FROM aptrxmst A
		LEFT JOIN apeglmst B
			ON A.aptrx_ivc_no = B.apegl_ivc_no
		LEFT JOIN tblAPTempBill C
			ON A.aptrx_ivc_no = C.aptrx_ivc_no

		WHERE C.aptrx_ivc_no IS NULL

		GROUP BY A.aptrx_ivc_no, 
		A.aptrx_vnd_no, 
		A.aptrx_sys_rev_dt,
		A.aptrx_gl_rev_dt,
		A.aptrx_due_rev_dt,
		A.aptrx_comment,
		A.aptrx_orig_amt,
		B.apegl_ivc_no

		----add detail
		--INSERT INTO tblAPBillDetail(
		--	[intBillId],
		--	[strDescription],
		--	[intAccountId],
		--	[dblTotal]
		--)
		--SELECT 
		--	[intBillId],
		--	[strDescription],
		--	(SELECT TOP 1 inti21ID FROM tblGLCOACrossReference WHERE strExternalID = B.apegl_gl_acct)
		--	FROM tblAPBill

		--Add already imported bill
		--SET IDENTITY_INSERT tblAPTempBill ON
		--INSERT INTO tblAPTempBill()
		--SELECT 
		--	* 
		--	INTO tblAPTempBill
		--	FROM aptrxmst A
		--INNER JOIN @InsertedData B
		--	ON A.aptrx_vnd_no = B.strBillId
		--SET IDENTITY_INSERT tblAPTempBill OFF
		SET @Total = @@ROWCOUNT;
END
ELSE
BEGIN
	INSERT [dbo].[tblAPBill] (
		[strVendorId], 
		[strBillId],
		[strVendorOrderNumber], 
		[intTermsId], 
		[intTaxCodeId], 
		[dtmDate], 
		[dtmBillDate], 
		[dtmDueDate], 
		[intAccountId], 
		[strDescription], 
		[dblTotal], 
		[ysnPosted], 
		[ysnPaid], 
		[dblAmountDue])
	OUTPUT inserted.strBillId INTO @InsertedData(strBillId)
	--Unposted
	SELECT 
		[strVendorId]			=	A.aptrx_vnd_no,
		[strBillId] 			=	A.aptrx_ivc_no,
		[strVendorOrderNumber] 	=	A.aptrx_ivc_no,
		[intTermsId] 			=	0,
		[intTaxCodeId] 			=	NULL,
		[dtmDate] 				=	CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112),
		[dtmBillDate] 			=	CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112),
		[dtmDueDate] 			=	CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112),
		[intAccountId] 			=	NULL, --(SELECT TOP 1 inti21ID FROM tblGLCOACrossReference WHERE strExternalID = B.apegl_gl_acct),
		[strDescription] 		=	A.aptrx_comment,
		[dblTotal] 				=	A.aptrx_orig_amt,
		[ysnPosted] 			=	0,
		[ysnPaid] 				=	0, --CASE WHEN SUM(ISNULL(B.apegl_gl_amt,0)) = A.aptrx_orig_amt THEN 1 ELSE 0 END,
		[dblAmountDue]			=	A.aptrx_orig_amt--CASE WHEN B.apegl_ivc_no IS NULL THEN A.aptrx_orig_amt ELSE A.aptrx_orig_amt - SUM(ISNULL(B.apegl_gl_amt,0)) END
		
	FROM aptrxmst A
		LEFT JOIN apeglmst B
			ON A.aptrx_ivc_no = B.apegl_ivc_no
		LEFT JOIN tblAPTempBill C
			ON A.aptrx_ivc_no = C.aptrx_ivc_no
		
	WHERE --CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
		 CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
		 AND CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112), 3), 4, 2)) BETWEEN @PeriodFrom AND @PeriodTo
		 AND A.aptrx_trans_type IN ('I','C')
		 AND C.aptrx_ivc_no IS NULL

		GROUP BY A.aptrx_ivc_no, 
		A.aptrx_vnd_no, 
		A.aptrx_sys_rev_dt,
		A.aptrx_gl_rev_dt,
		A.aptrx_due_rev_dt,
		A.aptrx_comment,
		A.aptrx_orig_amt,
		B.apegl_ivc_no

		--UNION

		----Posted
		--SELECT 
		--[strVendorId]			=	A.apivc_vnd_no,
		--[strVendorOrderNumber] 	=	A.apivc_vnd_no,
		--[intTermsId] 			=	0,
		--[intTaxCodeId] 			=	NULL,
		--[dtmDate] 				=	CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112),
		--[dtmBillDate] 			=	CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112),
		--[dtmDueDate] 			=	CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112),
		--[intAccountId] 			=	NULL, --(SELECT TOP 1 inti21ID FROM tblGLCOACrossReference WHERE strExternalID = B.apegl_gl_acct),
		--[strDescription] 		=	A.aptrx_comment,
		--[dblTotal] 				=	A.aptrx_orig_amt,
		--[ysnPosted] 			=	0,
		--[ysnPaid] 				=	CASE WHEN SUM(ISNULL(B.apegl_gl_amt,0)) = A.aptrx_orig_amt THEN 1 ELSE 0 END,
		--[dblAmountDue]			=	CASE WHEN B.apegl_ivc_no IS NULL THEN A.aptrx_orig_amt ELSE A.aptrx_orig_amt - SUM(ISNULL(B.apegl_gl_amt,0)) END
		
		--FROM apivcmst A

	
	
	SET @Total = @@ROWCOUNT;
END

--Add already imported bill
SET IDENTITY_INSERT tblAPTempBill ON
INSERT INTO tblAPTempBill([aptrx_vnd_no], [aptrx_ivc_no], [aptrx_sys_rev_dt], [aptrx_sys_time], [aptrx_cbk_no], [aptrx_chk_no], [aptrx_trans_type], [aptrx_batch_no],
[aptrx_pur_ord_no], [aptrx_po_rcpt_seq], [aptrx_ivc_rev_dt], [aptrx_disc_rev_dt], [aptrx_due_rev_dt], [aptrx_chk_rev_dt], [aptrx_gl_rev_dt], [aptrx_disc_pct], [aptrx_orig_amt],
[aptrx_disc_amt], [aptrx_wthhld_amt], [aptrx_net_amt], [aptrx_1099_amt], [aptrx_comment], [aptrx_orig_type], [aptrx_name], [aptrx_recur_yn], [aptrx_currency], [aptrx_currency_rt],
[aptrx_currency_cnt], [aptrx_user_id], [aptrx_user_rev_dt], [A4GLIdentity])
SELECT 
	A.* 
FROM aptrxmst A
INNER JOIN @InsertedData B
	ON A.aptrx_ivc_no = B.strBillId
SET IDENTITY_INSERT tblAPTempBill OFF

END