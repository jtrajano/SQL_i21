--UPDATE ALL EXISTING tblAPPaymentDetail RECORDS FOR NEW ysnOffset field.
--all DM, VPRE, BA
UPDATE A
	SET A.ysnOffset = 1
FROM tblAPPaymentDetail A
INNER JOIN tblAPPayment A2
	ON A.intPaymentId = A2.intPaymentId
INNER JOIN tblAPBill B
	ON ISNULL(A.intBillId,A.intOrigBillId) = B.intBillId
CROSS APPLY 
(
	SELECT COUNT(*) intCount FROM tblAPPaymentDetail A3
	WHERE A3.intPaymentId = A2.intPaymentId
) payDetails
WHERE 
	B.intTransactionType IN (2, 13)
AND payDetails.intCount > 1
AND EXISTS 
(
	--make sure there is ysnPrepay for it to determine it was an offset
	SELECT 1 FROM tblAPPayment pay INNER JOIN tblAPPaymentDetail pay2 ON pay.intPaymentId = pay2.intPaymentId
	WHERE pay.ysnPrepay = 1 AND pay.intPaymentId != A2.intPaymentId AND pay2.intBillId = A.intBillId
)

UPDATE A
	SET A.ysnOffset = 1
FROM tblAPPaymentDetail A
INNER JOIN tblAPPayment A2
	ON A.intPaymentId = A2.intPaymentId
INNER JOIN tblAPBill B
	ON ISNULL(A.intBillId,A.intOrigBillId) = B.intBillId
CROSS APPLY 
(
	SELECT COUNT(*) intCount FROM tblAPPaymentDetail A3
	WHERE A3.intPaymentId = A2.intPaymentId
) payDetails
WHERE 
	B.intTransactionType IN (3)
AND payDetails.intCount >= 1