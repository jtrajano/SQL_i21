CREATE VIEW [dbo].[vyuAPPaidBillsHistory]
AS
SELECT
	intPaymentId
	,B.intEntityVendorId
	,C.intBankAccountId
	,B.strVendorId
	,B1.strName as strVendorName
	,C1.strCbkNo
	,A.strPaymentRecordNum
	,A.strPaymentInfo
	,A.dblAmountPaid
	,C.dtmDateReconciled
	,C.ysnClr as ysnCleared
FROM tblAPPayment A
	INNER JOIN (tblAPVendor B INNER JOIN tblEntity B1 ON B.intEntityVendorId = B1.intEntityId) ON A.intVendorId = B.intEntityVendorId
	INNER JOIN (tblCMBankTransaction C INNER JOIN tblCMBankAccount C1 ON C.intBankAccountId = C1.intBankAccountId) ON A.strPaymentRecordNum = C.strTransactionId
WHERE A.ysnPosted = 1 AND C.ysnCheckVoid = 0
