IF EXISTS(SELECT 1 FROM tblAPPaymentDetail A INNER JOIN tblAPBill B ON A.intBillId = A.intBillId WHERE B.ysnOrigin = 1 AND B.intTransactionType = 3
AND (B.dblPayment > 0 OR B.dblDiscount > 0))
BEGIN

UPDATE A
SET 
	A.dblPayment = CASE WHEN A.dblPayment > 0 THEN A.dblPayment * -1 ELSE A.dblPayment END ,
	A.dblDiscount = CASE WHEN A.dblDiscount > 0 THEN A.dblDiscount * -1 ELSE A.dblDiscount END
FROM tblAPPaymentDetail A
INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
WHERE B.intTransactionType = 3 AND B.ysnOrigin = 1

END