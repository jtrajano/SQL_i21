CREATE VIEW [dbo].[vyuAPPaidOriginPrepaid]
AS 

--Exclude joining on payment detail to handle those prepaid that has been imported without payment transaction but already paid
SELECT 
	A.intBillId
FROM tblAPBill A
--MAKE SURE TO CHECK IF ORIGIN HAS NO GL RECORDS, UNPOSTED PREPAYMENT ARE VALID IMPORTS
--THOSE IMPORTED UNPOSTED PREPAID SHOULD NOT BE PART OF THIS SQL VIEW BECAUSE IT WILL BE POSTED IN i21
LEFT JOIN tblGLDetail B ON A.strBillId = B.strTransactionId AND B.ysnIsUnposted = 0
-- INNER JOIN tblAPPaymentDetail B ON A.intBillId = B.intBillId
-- INNER JOIN tblAPPayment C ON B.intPaymentId = C.intPaymentId
WHERE A.ysnOrigin = 1 AND A.ysnPaid = 1 AND A.intTransactionType = 2 --AND C.ysnOrigin = 1 AND C.ysnPosted = 1
AND B.intGLDetailId IS NULL --MAKE SURE IT IS NOT POSTED IN i21
--MAKE SURE IT HAS NOT BEEN PAID IN i21
AND NOT EXISTS (
	SELECT 1 FROM tblAPPaymentDetail B INNER JOIN tblAPPayment C ON B.intPaymentId = C.intPaymentId
	WHERE B.intBillId = A.intBillId AND C.ysnOrigin = 0 AND C.ysnPrepay = 0
)