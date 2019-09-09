UPDATE A
	SET 
		A.dblTotal = A.dblTotal * (CASE WHEN A.dblTotal > 0 THEN -1 ELSE 1 END),
		A.dblPayment = A.dblPayment * (CASE WHEN A.dblPayment > 0 THEN -1 ELSE 1 END),
		A.dblAmountDue = A.dblAmountDue * (CASE WHEN A.dblAmountDue > 0 THEN -1 ELSE 1 END)
FROM tblAPPaymentDetail A
INNER JOIN tblAPPayment A2
	ON A.intPaymentId = A2.intPaymentId
INNER JOIN tblAPBill B
	ON A.intBillId = B.intBillId
WHERE B.ysnPrepayHasPayment = 1 AND A.ysnOffset = 1
