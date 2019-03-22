CREATE PROCEDURE [dbo].[uspAPFixAmount]
AS

--FIX VOUCHER AMOUNT
UPDATE A
	SET A.dblAmountDue = ABS(A.dblAmountDue)
	,A.dblTotal = ABS(A.dblTotal)
	,A.dblPayment = ABS(A.dblPayment)
	,A.dblDiscount = ABS(A.dblDiscount)
	,A.dblInterest = ABS(A.dblInterest)
FROM tblAPBill A
--WHERE A.ysnOrigin = 0

--FIX VOUCHER DETAIL AMOUNT
UPDATE A
	SET A.dblTotal = CASE WHEN A.dblQtyReceived > 0 THEN ABS(A.dblTotal) ELSE A.dblTotal END
	,A.dbl1099 = CASE WHEN A.dblQtyReceived > 0 THEN ABS(A.dbl1099) ELSE A.dbl1099 END
FROM tblAPBillDetail A
INNER JOIN tblAPBill B
	ON A.intBillId = B.intBillId
--WHERE B.ysnOrigin = 0

--FIX PAYMENT AMOUNT
--ONLY THOSE RECORDS THAT WERE NOT VOID
UPDATE A
	SET A.dblAmountPaid = ABS(A.dblAmountPaid)
	,A.dblWithheld = ABS(A.dblWithheld)
FROM tblAPPayment A
INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
INNER JOIN tblCMBankTransaction C ON A.strPaymentRecordNum = C.strTransactionId
WHERE C.ysnCheckVoid = 0
--AND A.ysnOrigin = 0
-- AND C.ysnClr = 0

--FIX PAYMENT DETAIL AMOUNT
--ONLY THOSE RECORDS THAT WERE NOT VOID
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
--AND B.ysnOrigin = 0
-- AND C.ysnClr = 0

--PAYMENT TRANSACTION THAT IS NEED TO BECOME NEGATIVE
--VOIDED TRANSACTION
UPDATE A
SET dblDiscount		= CASE WHEN A.dblDiscount < 0 THEN A.dblDiscount ELSE A.dblDiscount * -1 END,
	dblAmountDue	= CASE WHEN A.dblAmountDue < 0 THEN A.dblAmountDue ELSE A.dblAmountDue * -1 END,
	dblPayment		= CASE WHEN A.dblPayment < 0 THEN A.dblPayment ELSE A.dblPayment * -1 END,
	dblInterest		= CASE WHEN A.dblInterest < 0 THEN A.dblInterest ELSE A.dblInterest * -1 END,
	dblTotal		= CASE WHEN A.dblTotal < 0 THEN A.dblTotal ELSE A.dblTotal * -1 END
FROM dbo.tblAPPaymentDetail A
INNER JOIN dbo.tblAPPayment B ON A.intPaymentId = B.intPaymentId
INNER JOIN tblCMBankTransaction C ON B.strPaymentRecordNum = C.strTransactionId
WHERE strNotes  LIKE '%Void transaction for%' and C.ysnCheckVoid = 1

--PAYMENT TRANSACTION THAT IS NEED TO BECOME POSITIVE
UPDATE B
	SET B.dblPayment = CASE WHEN dblPayment < 0 THEN dblPayment * -1 ELSE dblPayment END,
		B.dblAmountDue = CASE WHEN dblAmountDue < 0 THEN dblAmountDue * -1 ELSE dblAmountDue END,
		B.dblDiscount = CASE WHEN dblDiscount < 0 THEN dblDiscount * -1 ELSE dblDiscount END,
		B.dblInterest = CASE WHEN dblInterest < 0 THEN dblInterest * -1 ELSE dblInterest END,
		B.dblTotal = CASE WHEN dblTotal < 0 THEN dblTotal * -1 ELSE dblTotal END
FROM tblAPPayment A
INNER JOIN tblAPPaymentDetail B ON A.intPaymentId = B.intPaymentId
WHERE strNotes LIKE 'Transaction Voided on%' 

RETURN 0
