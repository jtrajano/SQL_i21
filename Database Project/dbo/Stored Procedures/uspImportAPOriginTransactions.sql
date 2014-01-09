CREATE PROCEDURE uspImportAPOriginTransactions
	@DateFrom	DATE,
	@DateTo	DATE,
	@PeriodFrom	INT,
	@PeriodTo	INT,
	@Total INT OUTPUT
AS
BEGIN
	
	INSERT [dbo].[tblAPBill] (
		[strVendorId], 
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
	--Unposted
	SELECT 
		[strVendorId]			=	A.aptrx_vnd_no,
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
		
	WHERE --CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
		 CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
		 AND CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112), 3), 4, 2)) BETWEEN @PeriodFrom AND @PeriodTo
		 AND aptrx_trans_type IN ('I','C')

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
