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
	SELECT 
		A.aptrx_vnd_no,
		A.aptrx_ivc_no,
		0,
		NULL,
		CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112),
		CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112),
		CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112),
		NULL, --(SELECT TOP 1 inti21ID FROM tblGLCOACrossReference WHERE strExternalID = B.apegl_gl_acct),
		A.aptrx_comment,
		A.aptrx_orig_amt,
		CASE WHEN B.apegl_ivc_no IS NULL THEN 0 ELSE 1 END,
		CASE WHEN SUM(ISNULL(B.apegl_gl_amt,0)) = A.aptrx_orig_amt THEN 1 ELSE 0 END,
		CASE WHEN B.apegl_ivc_no IS NULL THEN A.aptrx_orig_amt ELSE A.aptrx_orig_amt - SUM(ISNULL(B.apegl_gl_amt,0)) END
		
	FROM aptrxmst A
		LEFT JOIN apeglmst B
			ON A.aptrx_ivc_no = B.apegl_ivc_no
		
	WHERE --CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
		 CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
		 AND CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112), 3), 4, 2)) BETWEEN @PeriodFrom AND @PeriodTo

		GROUP BY A.aptrx_ivc_no, 
		A.aptrx_vnd_no, 
		A.aptrx_sys_rev_dt,
		A.aptrx_gl_rev_dt,
		A.aptrx_due_rev_dt,
		A.aptrx_comment,
		A.aptrx_orig_amt,
		B.apegl_ivc_no

	
	
	SET @Total = @@ROWCOUNT;
END
