CREATE FUNCTION [dbo].[fnAPGetVoucherLatestPayment]
(
	@voucherId INT
)
RETURNS TABLE 
WITH SCHEMABINDING
AS
RETURN
SELECT
	TOP 1 
	A.intPaymentId
	,A.strPaymentInfo
	,B.dblPayment
	,B.dblDiscount
	,B.dblInterest
	,B.dblWithheld
	,CAST(CASE WHEN C.dtmCheckPrinted IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS ysnPrinted
	,dbo.fnAPMaskBankAccountNos(dbo.fnAESDecryptASym(D.strBankAccountNo)) AS strBankAccountNo
	,ISNULL(C.ysnCheckVoid,0) AS ysnVoid
	,ISNULL(C.ysnClr,0) AS ysnCleared
	,C.dtmDateReconciled
FROM dbo.tblAPPayment A
INNER JOIN dbo.tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
LEFT JOIN dbo.tblCMBankAccount D ON A.intBankAccountId = D.intBankAccountId
LEFT JOIN dbo.tblCMBankTransaction C ON A.strPaymentRecordNum = C.strTransactionId 
WHERE ISNULL(B.intBillId,B.intOrigBillId) = @voucherId
ORDER BY A.intPaymentId DESC
