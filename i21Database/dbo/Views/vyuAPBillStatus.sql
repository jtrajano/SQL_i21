CREATE VIEW [dbo].[vyuAPBillStatus]
AS
SELECT
	A.intBillId
	,A.strBillId
	,CASE WHEN A.intTransactionType !=1 THEN A.dblTotal * -1 ELSE A.dblTotal END AS dblBillTotal
	,CASE WHEN A.intTransactionType !=1 THEN A.dblPayment * -1 ELSE A.dblPayment END AS dblBillPayment
	,CASE WHEN A.intTransactionType !=1 THEN A.dblDiscount * -1 ELSE A.dblDiscount END AS dblBillDiscount
	,CASE WHEN A.intTransactionType !=1 THEN A.dblInterest * -1 ELSE A.dblInterest END AS dblBillInterest
	,CASE WHEN A.intTransactionType !=1 THEN A.dblWithheld * -1 ELSE A.dblWithheld END AS dblBillWithheld
	,Payments.dblPayment AS dblPayment
	,Payments.dblDiscount AS dblDiscount
	,Payments.dblInterest AS dblInterest
	,Payments.dblWithheld AS dblWithheld
	,Prepayments.dblPrepayment
	,A.ysnPosted
	,A.ysnPaid
	,A.ysnOrigin
	,CASE WHEN (CASE WHEN A.intTransactionType !=1 THEN A.dblPayment * -1 ELSE A.dblPayment END) != Payments.dblPayment
			THEN 'Invalid Payment'
		  WHEN (CASE WHEN A.intTransactionType !=1 THEN A.dblDiscount * -1 ELSE A.dblDiscount END) != Payments.dblDiscount 
			THEN 'Invalid Discount'
		  WHEN (CASE WHEN A.intTransactionType !=1 THEN A.dblInterest * -1 ELSE A.dblInterest END) != Payments.dblInterest 
			THEN 'Invalid Interest'
		  WHEN (CASE WHEN A.intTransactionType !=1 THEN A.dblWithheld * -1 ELSE A.dblWithheld END) != Payments.dblWithheld
			THEN 'Invalid Withheld'
		WHEN (A.ysnPaid = 1 AND (CASE WHEN A.intTransactionType !=1 THEN A.dblTotal * -1 ELSE A.dblTotal END)
				 != CAST(((CASE WHEN A.intTransactionType !=1 THEN A.dblPayment * -1 ELSE A.dblPayment END)
						 + (CASE WHEN A.intTransactionType !=1 THEN A.dblDiscount * -1 ELSE A.dblDiscount END)
						 - (CASE WHEN A.intTransactionType !=1 THEN A.dblInterest * -1 ELSE A.dblInterest END)) AS DECIMAL(18,2)))
			THEN 'Invalid Paid Status. Bill was not fully paid.'
		 WHEN (A.ysnPaid = 0 AND (CASE WHEN A.intTransactionType !=1 THEN A.dblTotal * -1 ELSE A.dblTotal END)
			 = CAST(((CASE WHEN A.intTransactionType !=1 THEN A.dblPayment * -1 ELSE A.dblPayment END)
						 + (CASE WHEN A.intTransactionType !=1 THEN A.dblDiscount * -1 ELSE A.dblDiscount END)
						 - (CASE WHEN A.intTransactionType !=1 THEN A.dblInterest * -1 ELSE A.dblInterest END)) AS DECIMAL(18,2)))
			THEN 'Invalid Paid Status. Bill was already fully paid.'
		WHEN A.ysnPosted = 1 AND A.intTransactionType = 2 AND ISNULL(Prepayments.dblPrepayment,0) = 0
			THEN 'Prepayment was posted but not payment transaction created.'
		WHEN A.ysnPosted = 1 AND A.intTransactionType = 2 AND A.dblPayment != 0 AND ISNULL(Payments.dblPayment,0) = 0
			THEN 'Prepayment has payment but did no offset transaction'
			ELSE 'OK' END AS strStatus
FROM tblAPBill A
OUTER APPLY (
	SELECT
		SUM(B.dblTotal) dblTotal
	FROM tblAPBillDetail B
	WHERE A.intBillId = B.intBillId
) Details
OUTER APPLY (
	SELECT
		CASE WHEN A.intTransactionType != 1 THEN SUM(D.dblPayment * -1) ELSE SUM(D.dblPayment) END dblPayment
		,CASE WHEN A.intTransactionType != 1 THEN SUM(D.dblDiscount * -1) ELSE SUM(D.dblDiscount) END dblDiscount
		,CASE WHEN A.intTransactionType != 1 THEN SUM(D.dblInterest * -1) ELSE SUM(D.dblInterest) END dblInterest
		,CASE WHEN A.intTransactionType != 1 THEN SUM(D.dblWithheld * -1) ELSE SUM(D.dblWithheld) END dblWithheld
	FROM tblAPPayment C
	INNER JOIN tblAPPaymentDetail D ON C.intPaymentId = D.intPaymentId
	WHERE D.intBillId = A.intBillId
	AND C.ysnPrepay = 0
) Payments
OUTER APPLY (
	SELECT
		SUM(F.dblPayment * -1) AS dblPrepayment
	FROM tblAPPayment E
	INNER JOIN tblAPPaymentDetail F ON E.intPaymentId = F.intPaymentId
	WHERE F.intBillId = A.intBillId
	AND E.ysnPrepay = 1 AND E.ysnPosted = 1
) Prepayments

