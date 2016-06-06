CREATE PROCEDURE [dbo].[uspAPValidateImportedVouchers]
	@UserId INT,
	@logKey NVARCHAR(100) OUTPUT,
	@isValid INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @key NVARCHAR(100) = NEWID()
DECLARE @logDate DATETIME = GETDATE()

DECLARE @log TABLE
(
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)

SET @logKey = @key;

--GET THOSE VOUCHERS WHERE TOTAL DETAIL IS NOT EQUAL TO TOTAL HEADER
INSERT INTO @log
SELECT 
	strBillId + ' total do not matched.'
FROM (
	SELECT DISTINCT
	intBillId
	,strBillId
	,i21Total
	,SUM(i21DetailTotal) i21DetailTotal
	FROM (
			SELECT 
			C.intBillId
			,C.strBillId
			,C.dblTotal i21Total
			,ISNULL(B.dblTotal,0) i21DetailTotal
			FROM tmp_apivcmstImport A
			INNER JOIN tblAPapivcmst A2 ON A.intBackupId = A2.intId
			INNER JOIN tblAPBill C ON A2.intBillId = C.intBillId
				LEFT JOIN tblAPBillDetail B ON C.intBillId = B.intBillId
			) ImportedBills
	GROUP BY 
	intBillId
	,strBillId
	,i21Total
	) Summary
WHERE i21Total <> i21DetailTotal --Verify if total and detail total are equal

--GET THOSE PAID VOUCHERS THAT DO NOT HAVE PAYMENT
INSERT INTO @log
SELECT
	C.strBillId + ' has been paid but do not have payment created.'
FROM tmp_apivcmstImport A
INNER JOIN tblAPapivcmst B ON A.intBackupId = B.intId
INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
LEFT JOIN tblAPPaymentDetail D ON C.intBillId = D.intBillId
WHERE C.ysnPaid = 1 AND D.intPaymentDetailId IS NULL

--GET THOSE INVALID PAYMENT TRANSACTION
INSERT INTO @log
SELECT
	strPaymentRecordNum + CASE WHEN i21Total <> i21DetailTotal 
							THEN ' total do not match.'
							WHEN i21Total < 0
							THEN ' total amount is negative.'
							END
FROM (
	SELECT DISTINCT
	intPaymentId
	,strPaymentRecordNum
	,i21Total
	,SUM(i21DetailTotal) i21DetailTotal
	FROM (
			SELECT 
			E.intPaymentId
			,E.strPaymentRecordNum
			,E.dblAmountPaid i21Total
			,ISNULL(D.dblPayment,0) i21DetailTotal
			FROM tmp_apivcmstImport A
			INNER JOIN tblAPapivcmst B ON A.intBackupId = B.intId
			INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
			INNER JOIN tblAPPaymentDetail D ON C.intBillId = D.intBillId
			INNER JOIN tblAPPayment E ON D.intPaymentId = E.intPaymentId
			WHERE C.ysnPaid = 1
			) ImportedBills
	GROUP BY 
	intPaymentId
	,strPaymentRecordNum
	,i21Total
	) Summary
WHERE i21Total <> i21DetailTotal OR i21Total < 0

INSERT INTO tblAPImportVoucherLog
(
	[strDescription], 
    [intEntityId], 
	[strLogKey],
    [dtmDate]
)
SELECT 
	strDescription,
	@UserId,
	@key,
	GETDATE()
FROM @log

IF EXISTS(SELECT 1 FROM @log) SET @isValid = 0;
ELSE SET @isValid = 1