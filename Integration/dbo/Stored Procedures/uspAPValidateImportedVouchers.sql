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
			FROM tmp_apivcmstImport C2
				INNER JOIN tblAPapivcmst C3 ON C2.intBackupId = C3.intId
				INNER JOIN tblAPBill C ON C3.intBillId = C.intBillId
				INNER JOIN tblAPBillDetail B ON C.intBillId = B.intBillId
				INNER JOIN tblGLDetail D ON C.strBillId = D.strTransactionId AND C.intBillId = D.intTransactionId
			WHERE C.ysnOrigin = 1 AND D.intGLDetailId IS NULL
			UNION ALL
			SELECT 
			E.intBillId
			,E.strBillId
			,E.dblTotal i21Total
			,ISNULL(F.dblTotal,0) i21DetailTotal
			FROM tmp_aptrxmstImport E2
				INNER JOIN tblAPaptrxmst E3 ON E2.intBackupId = E3.intId
				INNER JOIN tblAPBill E ON E3.intBillId = E.intBillId
				INNER JOIN tblAPBillDetail F ON E.intBillId = F.intBillId
				INNER JOIN tblGLDetail G ON E.strBillId = G.strTransactionId AND E.intBillId = G.intTransactionId
			WHERE E.ysnOrigin = 1 AND G.intGLDetailId IS NULL
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
FROM tmp_apivcmstImport C2
INNER JOIN tblAPapivcmst C3 ON C2.intBackupId = C3.intId
INNER JOIN tblAPBill C ON C3.intBillId = C.intBillId
LEFT JOIN tblAPPaymentDetail D ON C.intBillId = D.intBillId
LEFT JOIN tblGLDetail E ON E.intTransactionId = C.intBillId AND E.strTransactionId = C.strBillId
WHERE C.ysnPaid = 1 AND D.intPaymentDetailId IS NULL AND C.ysnOrigin = 1 AND C.ysnPosted = 1 AND E.intGLDetailId IS NULL

--GET THOSE INVALID PAYMENT TRANSACTION
INSERT INTO @log
SELECT
	strPaymentRecordNum + CASE WHEN i21Total <> i21DetailTotal 
							THEN ' total do not match. Header: ' + CAST(i21Total AS NVARCHAR) + ' Detail:' +  CAST(i21DetailTotal AS NVARCHAR)
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
			,(CASE WHEN LOWER(PM.strPaymentMethod) = 'deposit' THEN A.dblAmountPaid * -1 ELSE A.dblAmountPaid END) i21Total
			,ISNULL((CASE WHEN C.intTransactionType != 1 AND (A.ysnPrepay = 0 OR LOWER(PM.strPaymentMethod) = 'deposit')
						THEN B.dblPayment * -1 
						ELSE B.dblPayment END),0) i21DetailTotal
			FROM tblAPPayment A
			INNER JOIN tblSMPaymentMethod PM ON A.intPaymentMethodId = PM.intPaymentMethodID
			LEFT JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
			LEFT JOIN tblAPBill C ON B.intBillId = C.intBillId
			LEFT JOIN tblGLDetail D ON D.intTransactionId = A.intPaymentId AND D.strTransactionId = A.strPaymentRecordNum
			WHERE A.ysnOrigin = 1 AND D.intGLDetailId IS NULL
			AND B.intBillId  IN (
				SELECT 
					V2.intBillId
				FROM tmp_apivcmstImport V
				INNER JOIN tblAPapivcmst  V2 ON V.intBackupId = V2.intId
			)
			) ImportedBills
	GROUP BY 
	intPaymentId
	,strPaymentRecordNum
	,i21Total
	) Summary
WHERE i21Total <> i21DetailTotal

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