--Re-Insert Bill Detail data as there is an issue on the importing of bills on previous version
--not all bill details were imported
--Make sure this will only run once
--Check if there is no correct bill detail
IF NOT EXISTS(SELECT 1 FROM aphglmst 
	INNER JOIN (tblAPBillDetail A INNER JOIN tblAPBill B ON A.intBillId = B.intBillId)
		ON B.strVendorOrderNumber COLLATE Latin1_General_CI_AS = aphglmst.aphgl_ivc_no COLLATE Latin1_General_CI_AS)
BEGIN
	--Delete first those existing imported bill details
	DELETE 
	FROM tblAPBillDetail
	FROM tblAPBillDetail A
		INNER JOIN tblAPBill B
			ON A.intBillId = B.intBillId
		INNER JOIN tblAPTempBill C
			ON B.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.aptrx_ivc_no COLLATE Latin1_General_CI_AS

	--Re-insert Bill Details
	INSERT INTO tblAPBillDetail(
				[intBillId],
				[strDescription],
				[intAccountId],
				[dblTotal]
			)
	SELECT 
		A.intBillId,
		A.strDescription,
		ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.apegl_gl_acct), 0),
		C.apegl_gl_amt
	FROM tblAPBill A
		INNER JOIN apeglmst C
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.apegl_ivc_no COLLATE Latin1_General_CI_AS
	UNION
	SELECT 
		A.intBillId,
		A.strDescription,
		ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.aphgl_gl_acct), 0),
		C.aphgl_gl_amt
		FROM tblAPBill A
		INNER JOIN aphglmst C
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.aphgl_ivc_no COLLATE Latin1_General_CI_AS
END