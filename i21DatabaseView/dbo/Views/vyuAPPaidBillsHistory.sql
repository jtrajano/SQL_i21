CREATE VIEW [dbo].[vyuAPPaidBillsHistory]
AS
SELECT
	intPaymentId
	,B.[intEntityId]
	,C.intBankAccountId
	,B.strVendorId
	,B1.strName as strVendorName
	,C1.strCbkNo
	,A.strPaymentRecordNum
	,A.strPaymentInfo
	,A.dblAmountPaid
	,C.dtmDateReconciled
	,C.ysnClr as ysnCleared
	,CAST(CASE WHEN C.dtmCheckPrinted IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS ysnPrinted
FROM tblAPPayment A
	INNER JOIN (tblAPVendor B INNER JOIN tblEMEntity B1 ON B.[intEntityId] = B1.intEntityId) ON A.[intEntityVendorId] = B.[intEntityId]
	LEFT JOIN (tblCMBankTransaction C INNER JOIN tblCMBankAccount C1 ON C.intBankAccountId = C1.intBankAccountId) ON A.strPaymentRecordNum = C.strTransactionId
WHERE A.ysnPosted = 1 AND C.ysnCheckVoid = 0
