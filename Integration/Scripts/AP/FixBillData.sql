--Fix Bill for the issue of wrong strBillId, new fields and new features (14.2 - 14.3)
IF EXISTS(SELECT 1 FROM tblAPBill WHERE LEFT(strBillId,3) <> 'BL-')
BEGIN

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

	--REPOPULATE tblAPTempBill
	DROP TABLE tblAPTempBill --recreate tblAPTempBill

	SELECT 
		[aptrx_vnd_no], [aptrx_ivc_no]
	INTO tblAPTempBill
	FROM aptrxmst A
	INNER JOIN tblAPBill B
		ON B.strVendorOrderNumber COLLATE Latin1_General_CI_AS = A.aptrx_ivc_no COLLATE Latin1_General_CI_AS
	WHERE A.aptrx_trans_type IN ('I','C')
		
	INSERT INTO tblAPTempBill([aptrx_vnd_no], [aptrx_ivc_no])
	SELECT 
		[apivc_vnd_no],[apivc_ivc_no] 
	FROM apivcmst A
	INNER JOIN tblAPBill B
		ON B.strVendorOrderNumber COLLATE Latin1_General_CI_AS = A.apivc_ivc_no COLLATE Latin1_General_CI_AS
	WHERE A.apivc_trans_type IN ('I','C')

	--Remove transaction type <> I and C
	DELETE FROM tblAPBill
	FROM tblAPBill A
		INNER JOIN apivcmst B
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = B.apivc_ivc_no COLLATE Latin1_General_CI_AS
	WHERE B.apivc_trans_type NOT IN ('I','C')

	DELETE FROM tblAPBill
	FROM tblAPBill A
		INNER JOIN aptrxmst B
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = B.aptrx_ivc_no COLLATE Latin1_General_CI_AS
	WHERE B.aptrx_trans_type NOT IN ('I','C')

	--Update transaction type and withheld amount and ysnPaid, date paid, ysnPaid, amount due
	UPDATE tblAPBill
	SET intTransactionType = CASE WHEN B.aptrx_trans_type = 'I' THEN 1 ELSE 3 END
	,dblWithheld = B.aptrx_wthhld_amt
	FROM tblAPBill A
		INNER JOIN aptrxmst B
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = B.aptrx_ivc_no COLLATE Latin1_General_CI_AS

	UPDATE tblAPBill
	SET intTransactionType = CASE WHEN B.apivc_trans_type = 'I' THEN 1 ELSE 3 END
	,dblWithheld = B.apivc_wthhld_amt
	,ysnPaid = CASE WHEN apivc_status_ind = 'P' THEN 1 ELSE 0 END
	,dblAmountDue = CASE WHEN apivc_status_ind = 'P' THEN 0 ELSE dblAmountDue END
	,dtmDatePaid = CASE WHEN apivc_status_ind = 'P' THEN CONVERT(DATE, CAST(apivc_chk_rev_dt AS CHAR(12)), 112) ELSE NULL END
	FROM tblAPBill A
		INNER JOIN apivcmst B
			ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = B.apivc_ivc_no COLLATE Latin1_General_CI_AS
			
	--Update strBillId
	DECLARE @tmpBillIds TABLE (intBillId INT, intTransactionType INT)

	INSERT INTO @tmpBillIds
	SELECT intBillId, intTransactionType FROM tblAPBill WHERE LEFT(strBillId,3) <> 'BL-' OR intTransactionType = 3

	WHILE EXISTS(SELECT 1 FROM @tmpBillIds)
	BEGIN
		
		DECLARE @id INT
		DECLARE @type INT
		DECLARE @billId NVARCHAR(50)

		SELECT TOP 1 @id = intBillId, @type = intTransactionType FROM @tmpBillIds
		
		IF(@type = 1)
		EXEC uspSMGetStartingNumber 9, @billId OUT
		ELSE
		EXEC uspSMGetStartingNumber 18, @billId OUT

		UPDATE tblAPBill
		SET strBillId = @billId
		WHERE intBillId = @id

		DELETE FROM @tmpBillIds
		WHERE intBillId = @id

	END

	--Update Bill Cost, Landed Cost, Quantity Order and Received, Discount
	UPDATE tblAPBillDetail
	SET dblCost = A.dblTotal
	,dblLandedCost = A.dblTotal
	,dblQtyOrdered = 1
	,dblQtyReceived = 1
	FROM tblAPBillDetail A
		INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
	
END
