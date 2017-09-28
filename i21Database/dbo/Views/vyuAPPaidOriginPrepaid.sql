CREATE VIEW [dbo].[vyuAPPaidOriginPrepaid]
AS 
SELECT 
	A.intBillId
FROM tblAPBill A
INNER JOIN tblAPPaymentDetail B ON A.intBillId = B.intBillId
INNER JOIN tblAPPayment C ON B.intPaymentId = C.intPaymentId
WHERE A.ysnOrigin = 1 AND A.ysnPaid = 1 AND A.intTransactionType = 2 AND C.ysnOrigin = 1 AND C.ysnPosted = 1
