--Re-Insert Bill for the issue of wrong strBillId
IF EXISTS(SELECT 1 FROM tblAPBill WHERE LEFT(strBillId,3) <> 'BL-')
BEGIN

	--Re-insert data imported from UNPOSTED bill
	SELECT 
			[intBillBatchId],
			[intVendorId],
			[strVendorOrderNumber],
			[intTermsId],
			[intTaxId],
			[dtmDate],
			[dtmBillDate],
			[dtmDueDate],
			[intAccountId],
			[strDescription],
			[dblTotal],
			[dblAmountDue],
			[intEntityId],
			[ysnPosted],
			[ysnPaid],
			[intTransactionType],
			[dblDiscount],
			[dblWithheld]
	INTO #tmpBillData
	FROM tblAPBill A
		INNER JOIN aptrxmst B
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = B.aptrx_ivc_no COLLATE Latin1_General_CI_AS

	DELETE FROM tblAPBill
	FROM tblAPBill A
	INNER JOIN #tmpBillData B
		ON A.strVendorOrderNumber = B.strVendorOrderNumber

	--SET IDENTITY_INSERT tblAPBill ON
	INSERT INTO tblAPBill(
			[intBillBatchId],
			[intVendorId],
			[strVendorOrderNumber],
			[intTermsId],
			[intTaxId],
			[dtmDate],
			[dtmBillDate],
			[dtmDueDate],
			[intAccountId],
			[strDescription],
			[dblTotal],
			[dblAmountDue],
			[intEntityId],
			[ysnPosted],
			[ysnPaid],
			[intTransactionType],
			[dblDiscount],
			[dblWithheld]
	)
	SELECT * FROM #tmpBillData
	--SET IDENTITY_INSERT tblAPBill OFF

	--Re-insert data imported from POSTED bill
	SELECT 
			[intBillBatchId],
			[intVendorId],
			[strVendorOrderNumber],
			[intTermsId],
			[intTaxId],
			[dtmDate],
			[dtmBillDate],
			[dtmDueDate],
			[intAccountId],
			[strDescription],
			[dblTotal],
			[dblAmountDue],
			[intEntityId],
			[ysnPosted],
			[ysnPaid],
			[intTransactionType],
			[dblDiscount],
			[dblWithheld]
	INTO #tmpBillData2
	FROM tblAPBill A
		INNER JOIN apivcmst B
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = B.apivc_ivc_no COLLATE Latin1_General_CI_AS

	DELETE FROM tblAPBill
	FROM tblAPBill A
	INNER JOIN #tmpBillData2 B
		ON A.strVendorOrderNumber = B.strVendorOrderNumber

	--SET IDENTITY_INSERT tblAPBill ON
	INSERT INTO tblAPBill(
			[intBillBatchId],
			[intVendorId],
			[strVendorOrderNumber],
			[intTermsId],
			[intTaxId],
			[dtmDate],
			[dtmBillDate],
			[dtmDueDate],
			[intAccountId],
			[strDescription],
			[dblTotal],
			[dblAmountDue],
			[intEntityId],
			[ysnPosted],
			[ysnPaid],
			[intTransactionType],
			[dblDiscount],
			[dblWithheld]
	)
	SELECT * FROM #tmpBillData2
	--SET IDENTITY_INSERT tblAPBill OFF

	--Re-Insert Bill Detail data as there is an issue on the importing of bills on previous version
	--not all bill details were imported
	--Make sure this will only run once
	--Check if there is no correct bill detail
	
	--Delete first existing imported bill
	DELETE FROM tblAPBillDetail
	FROM tblAPBillDetail A
		INNER JOIN tblAPBill B
			ON A.intBillId = B.intBillId
		INNER JOIN aptrxmst C
			ON B.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.aptrx_ivc_no COLLATE Latin1_General_CI_AS

	--SET IDENTITY_INSERT tblAPBillDetail ON

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

	--SET IDENTITY_INSERT tblAPBillDetail OFF

	--REPOPULATE tblAPTempBill
	--SET IDENTITY_INSERT tblAPTempBill ON
	DROP TABLE tblAPTempBill --recreate tblAPTempBill

		--INSERT INTO tblAPTempBill([aptrx_vnd_no], [aptrx_ivc_no])
		SELECT 
			[aptrx_vnd_no], [aptrx_ivc_no]
		INTO tblAPTempBill
		FROM aptrxmst A
		INNER JOIN tblAPBill B
			ON B.strVendorOrderNumber COLLATE Latin1_General_CI_AS = A.aptrx_ivc_no COLLATE Latin1_General_CI_AS
		
		INSERT INTO tblAPTempBill([aptrx_vnd_no], [aptrx_ivc_no])
		SELECT 
			[apivc_vnd_no],[apivc_ivc_no] 
		FROM apivcmst A
		INNER JOIN tblAPBill B
			ON B.strVendorOrderNumber COLLATE Latin1_General_CI_AS = A.apivc_ivc_no COLLATE Latin1_General_CI_AS

	--SET IDENTITY_INSERT tblAPTempBill OFF

	
END
----Re-Insert Bill Detail data as there is an issue on the importing of bills on previous version
----not all bill details were imported
----Make sure this will only run once
----Check if there is no correct bill detail
--IF NOT EXISTS(SELECT 1 FROM aphglmst 
--	INNER JOIN (tblAPBillDetail A INNER JOIN tblAPBill B ON A.intBillId = B.intBillId)
--		ON B.strVendorOrderNumber COLLATE Latin1_General_CI_AS = aphglmst.aphgl_ivc_no COLLATE Latin1_General_CI_AS)
--BEGIN
--	--Delete first those existing imported bill details
--	DELETE 
--	FROM tblAPBillDetail
--	FROM tblAPBillDetail A
--		INNER JOIN tblAPBill B
--			ON A.intBillId = B.intBillId
--		INNER JOIN tblAPTempBill C
--			ON B.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.aptrx_ivc_no COLLATE Latin1_General_CI_AS

--	--Re-insert Bill Details
--	INSERT INTO tblAPBillDetail(
--				[intBillId],
--				[strDescription],
--				[intAccountId],
--				[dblTotal]
--			)
--	SELECT 
--		A.intBillId,
--		A.strDescription,
--		ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.apegl_gl_acct), 0),
--		C.apegl_gl_amt
--	FROM tblAPBill A
--		INNER JOIN apeglmst C
--			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.apegl_ivc_no COLLATE Latin1_General_CI_AS
--	UNION
--	SELECT 
--		A.intBillId,
--		A.strDescription,
--		ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.aphgl_gl_acct), 0),
--		C.aphgl_gl_amt
--		FROM tblAPBill A
--		INNER JOIN aphglmst C
--			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.aphgl_ivc_no COLLATE Latin1_General_CI_AS
--END