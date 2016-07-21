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
	strBillId + ' total do not matched.' AS strBillId
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
			FROM tblAPBill C 
				INNER JOIN tblAPBillDetail B ON C.intBillId = B.intBillId
				INNER JOIN tblGLDetail D ON C.strBillId = D.strTransactionId AND C.intBillId = D.intTransactionId
			WHERE C.ysnOrigin = 1 AND D.intGLDetailId IS NULL
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
	C.strBillId + ' has been paid but do not have payment created.' AS strBillId
FROM tblAPBill C
LEFT JOIN tblAPPaymentDetail D ON C.intBillId = D.intBillId
LEFT JOIN tblGLDetail E ON E.intTransactionId = C.intBillId AND E.strTransactionId = C.strBillId
WHERE C.ysnPaid = 1 AND D.intPaymentDetailId IS NULL AND C.ysnOrigin = 1 AND C.ysnPosted = 1 AND E.intGLDetailId IS NULL

--GET THOSE INVALID PAYMENT TRANSACTION
INSERT INTO @log
SELECT
	strPaymentRecordNum + CASE WHEN i21Total <> i21DetailTotal 
							THEN ' total do not match. Header: ' + CAST(i21Total AS NVARCHAR) + ' Detail:' +  CAST(i21DetailTotal AS NVARCHAR)
							WHEN i21Total < 0
							THEN ' total amount is negative.'
							END AS strPaymentRecordNum
FROM (
	SELECT DISTINCT
	intPaymentId
	,strPaymentRecordNum
	,i21Total
	,SUM(i21DetailTotal) i21DetailTotal
	FROM (
			SELECT 
			A.intPaymentId
			,A.strPaymentRecordNum
			,A.dblAmountPaid i21Total
			,ISNULL((CASE WHEN C.intTransactionType != 1 AND A.ysnPrepay = 0 THEN B.dblPayment * -1 ELSE B.dblPayment END),0) i21DetailTotal
			FROM tblAPPayment A
			LEFT JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
			LEFT JOIN tblAPBill C ON B.intBillId = C.intBillId
			LEFT JOIN tblGLDetail D ON D.intTransactionId = A.intPaymentId AND D.strTransactionId = A.strPaymentRecordNum
			WHERE A.ysnOrigin = 1 AND D.intGLDetailId IS NULL
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