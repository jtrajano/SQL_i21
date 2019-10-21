CREATE VIEW [dbo].[vyuAPPaidOriginPrepaid]
AS 

--Exclude joining on payment detail to handle those prepaid that has been imported without payment transaction but already paid
SELECT 
	A.intBillId
FROM tblAPBill A
-- INNER JOIN tblAPPaymentDetail B ON A.intBillId = B.intBillId
-- INNER JOIN tblAPPayment C ON B.intPaymentId = C.intPaymentId
WHERE A.ysnOrigin = 1 AND A.ysnPaid = 1 AND A.intTransactionType = 2 --AND C.ysnOrigin = 1 AND C.ysnPosted = 1
--MAKE SURE IT HAS NOT BEEN PAID IN i21
AND NOT EXISTS (
	SELECT 1 FROM tblAPPaymentDetail B INNER JOIN tblAPPayment C ON B.intPaymentId = C.intPaymentId
	WHERE B.intBillId = A.intBillId AND C.ysnOrigin = 0 AND C.ysnPrepay = 0
)