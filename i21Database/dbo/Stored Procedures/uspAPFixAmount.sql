CREATE PROCEDURE [dbo].[uspAPFixAmount]
AS

--FIX VOUCHER AMOUNT
UPDATE A
	SET A.dblAmountDue = ABS(A.dblAmountDue)
	,A.dblTotal = ABS(A.dblTotal)
	,A.dblPayment = ABS(A.dblPayment)
FROM tblAPBill A

--FIX VOUCHER DETAIL AMOUNT
UPDATE A
	SET A.dblTotal = CASE WHEN A.dblQtyReceived > 0 THEN ABS(A.dblTotal) ELSE A.dblTotal END
	,A.dbl1099 = CASE WHEN A.dblQtyReceived > 0 THEN ABS(A.dbl1099) ELSE A.dbl1099 END
FROM tblAPBillDetail A

--FIX PAYMENT AMOUNT
UPDATE A
	SET A.dblAmountPaid = ABS(A.dblAmountPaid)
	,A.dblWithheld = ABS(A.dblWithheld)
FROM tblAPPayment A
INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
INNER JOIN tblCMBankTransaction C ON A.strPaymentRecordNum = C.strTransactionId
WHERE C.ysnCheckVoid = 0

--FIX PAYMENT DETAIL AMOUNT
UPDATE A
	SET dblAmountDue = ABS(A.dblAmountDue)
	,A.dblDiscount = ABS(A.dblDiscount)
	,A.dblInterest = ABS(A.dblInterest)
	,A.dblPayment = ABS(A.dblPayment)
	,A.dblTotal = ABS(A.dblTotal)
	,A.dblWithheld = ABS(A.dblWithheld)
FROM tblAPPaymentDetail A
INNER JOIN tblAPPayment B ON A.intPaymentId = B.intPaymentId
INNER JOIN tblCMBankTransaction C ON B.strPaymentRecordNum = C.strTransactionId
WHERE C.ysnCheckVoid = 0

RETURN 0
