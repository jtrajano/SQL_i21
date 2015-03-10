--BEGIN RESTORING VENDOR ID ON tblAPBill
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblAPTempBillData]'))
BEGIN
	PRINT('RESTORING VENDOR ID OF tblAPBill')
	UPDATE tblAPBill
	SET intVendorId = C.[intEntityVendorId]
	FROM tblAPBill A
		INNER JOIN tblAPTempBillData B
			ON A.intBillId = B.intBillId
		INNER JOIN tblAPVendor C
			ON B.strVendorId = C.strVendorId

	DROP TABLE tblAPTempBillData
	PRINT('END RESTORING VENDOR ID OF tblAPBill')
END

--BEGIN RESTORING VENDOR ID ON tblAPBill
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblAPTempPaymentData]'))
BEGIN
	PRINT('RESTORING VENDOR ID OF tblAPPayment')
	UPDATE tblAPPayment
	SET intVendorId = C.[intEntityVendorId]
	FROM tblAPPayment A
		INNER JOIN tblAPTempPaymentData B
			ON A.intPaymentId = B.intPaymentId
		INNER JOIN tblAPVendor C
			ON B.strVendorId = C.strVendorId

	DROP TABLE tblAPTempPaymentData
	PRINT('END RESTORING VENDOR ID OF tblAPPayment')
END