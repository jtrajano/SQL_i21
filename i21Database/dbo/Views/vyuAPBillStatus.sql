CREATE VIEW [dbo].[vyuAPBillStatus]
AS
SELECT
	A.intBillId
	,A.strBillId
	,A.dblTotal AS dblBillTotal
	,A.dblPayment AS dblBillPayment
	,A.dblDiscount AS dblBillDiscount
	,A.dblInterest AS dblBillInterest
	,A.dblWithheld AS dblBillWithheld
	,B.dblPayment AS dblPayment
	,B.dblDiscount AS dblDiscount
	,B.dblInterest AS dblInterest
	,B.dblWithheld AS dblWithheld
	,A.ysnPosted
	,A.ysnPaid
	,CASE WHEN A.dblPayment != B.dblPayment
			THEN 'Invalid Payment'
		  WHEN A.dblDiscount != B.dblDiscount 
			THEN 'Invalid Discount'
		  WHEN A.dblInterest != B.dblInterest 
			THEN 'Invalid Interest'
		  WHEN A.dblWithheld != B.dblWithheld
			THEN 'Invalid Withheld'
		 WHEN (A.ysnPaid = 1 AND A.dblTotal != (A.dblPayment + A.dblDiscount - A.dblInterest))
			THEN 'Invalid Paid Status. Bill was not fully paid.'
		 WHEN (A.ysnPaid = 0 AND A.dblTotal = (A.dblPayment + A.dblDiscount - A.dblInterest))
			THEN 'Invalid Paid Status. Bill was already fully paid.'
			ELSE 'OK' END AS strStatus
FROM tblAPBill A
	INNER JOIN vyuAPBillPayment B ON A.intBillId = B.intBillId
WHERE A.intTransactionType = 1
