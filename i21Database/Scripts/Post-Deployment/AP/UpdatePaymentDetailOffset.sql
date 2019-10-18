UPDATE A
	SET 
		A.dblTotal = A.dblTotal * (CASE WHEN A.dblTotal > 0 THEN -1 ELSE 1 END),
		A.dblPayment = A.dblPayment * (CASE WHEN A.dblPayment > 0 THEN -1 ELSE 1 END),
		A.dblAmountDue = A.dblAmountDue * (CASE WHEN A.dblAmountDue > 0 THEN -1 ELSE 1 END),
		A.dblDiscount = A.dblDiscount * (CASE WHEN A.dblDiscount > 0 THEN -1 ELSE 1 END),
		A.dblInterest = A.dblInterest * (CASE WHEN A.dblInterest > 0 THEN -1 ELSE 1 END)
FROM tblAPPaymentDetail A
INNER JOIN tblAPPayment A2
	ON A.intPaymentId = A2.intPaymentId
INNER JOIN tblAPBill B
	ON A.intBillId = B.intBillId
WHERE B.ysnPrepayHasPayment = 1 AND A.ysnOffset = 1

UPDATE A
	SET A.dblPayment = A.dblPayment * -1
FROM tblAPPaymentDetail A
WHERE A.ysnOffset = 1 AND A.dblPayment > 0

UPDATE A
	SET A.dblTotal = A.dblTotal * -1
FROM tblAPPaymentDetail A
WHERE A.ysnOffset = 1 AND A.dblTotal > 0

UPDATE A
	SET A.dblAmountDue = A.dblAmountDue * -1
FROM tblAPPaymentDetail A
WHERE A.ysnOffset = 1 AND A.dblAmountDue > 0

UPDATE A
	SET A.dblDiscount = A.dblDiscount * -1
FROM tblAPPaymentDetail A
WHERE A.ysnOffset = 1 AND A.dblDiscount > 0

UPDATE A
	SET A.dblInterest = A.dblInterest * -1
FROM tblAPPaymentDetail A
WHERE A.ysnOffset = 1 AND A.dblInterest > 0

--UPDATE ALL VOID TO POSITIVE, SINCE ORIGINAL IS ALREADY NEGATIVE
UPDATE A
SET
	A.dblTotal = A.dblTotal * (CASE WHEN A.dblTotal > 0 THEN -1 ELSE 1 END),
	A.dblPayment = A.dblPayment * (CASE WHEN A.dblPayment > 0 THEN -1 ELSE 1 END),
	A.dblAmountDue = A.dblAmountDue * (CASE WHEN A.dblAmountDue > 0 THEN -1 ELSE 1 END),
	A.dblDiscount = A.dblDiscount * (CASE WHEN A.dblDiscount > 0 THEN -1 ELSE 1 END),
	A.dblInterest = A.dblInterest * (CASE WHEN A.dblInterest > 0 THEN -1 ELSE 1 END)
FROM tblAPPaymentDetail A
INNER JOIN tblAPPayment A2
	ON A.intPaymentId = A2.intPaymentId
INNER JOIN tblAPBill B
	ON A.intBillId = B.intBillId
INNER JOIN tblCMBankTransaction C
	ON C.strTransactionId = A2.strPaymentRecordNum
WHERE C.intBankTransactionTypeId IN (116, 19, 122)