--CHANGING strVendorId to intVendorId
--BACK UP Bill Data
IF COL_LENGTH('tblAPBill','strVendorId') IS NOT NULL
BEGIN
	PRINT('Backing up Vendor Bill Data')
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblAPTempBillData]'))
	BEGIN
		DROP TABLE tblAPTempBillData
	END

	CREATE TABLE tblAPTempBillData
	(
		intBillId INT,
		strVendorId NVARCHAR(50) COLLATE Latin1_General_CI_AS
	)

	INSERT INTO tblAPTempBillData
	SELECT intBillId, strVendorId FROM tblAPBill
	PRINT('END Backing up Vendor Bill Data')
END

--BACK UP Payment Data
IF COL_LENGTH('tblAPPayment','strVendorId') IS NOT NULL
BEGIN
	PRINT('Backing up Vendor Payment Data')
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblAPTempPaymentData]'))
	BEGIN
		DROP TABLE tblAPTempPaymentData
	END

	CREATE TABLE tblAPTempPaymentData
	(
		intPaymentId INT,
		strVendorId NVARCHAR(50) COLLATE Latin1_General_CI_AS
	)

	INSERT INTO tblAPTempPaymentData
	SELECT intPaymentId, strVendorId FROM tblAPPayment
	PRINT('End Backing up Vendor Payment Data')
END