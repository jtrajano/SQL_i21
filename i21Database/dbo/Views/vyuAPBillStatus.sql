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
	,CASE WHEN A.intTransactionType !=1 THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END AS dblBillAmountDue
	,Payments.dblPayment AS dblPayment
	,Payments.dblDiscount AS dblDiscount
	,Payments.dblInterest AS dblInterest
	,Payments.dblWithheld AS dblWithheld
	,Prepayments.dblPrepayment
	,OpenPayables.dblAmountDue dblPayablesAmountDue
	,A.ysnPosted
	,A.ysnPaid
	,A.ysnOrigin
	,CASE WHEN (A.dblPayment != Payments.dblPayment OR A.dblPayment != 0 AND Payments.dblPayment IS NULL)
			THEN 'Invalid Payment' --Invalid tblAPBill.dblPayment
		  WHEN (CASE WHEN A.intTransactionType !=1 THEN A.dblDiscount * -1 ELSE A.dblDiscount END) != Payments.dblDiscount 
			THEN 'Invalid Discount'
		  WHEN (CASE WHEN A.intTransactionType !=1 THEN A.dblInterest * -1 ELSE A.dblInterest END) != Payments.dblInterest 
			THEN 'Invalid Interest'
		  WHEN (CASE WHEN A.intTransactionType !=1 THEN A.dblWithheld * -1 ELSE A.dblWithheld END) != Payments.dblWithheld
			THEN 'Invalid Withheld'
		WHEN CAST((CASE WHEN A.intTransactionType !=1 THEN A.dblAmountDue * -1 ELSE A.dblAmountDue END) AS DECIMAL(18,2)) != OpenPayables.dblAmountDue 
			THEN 'Payables amount due do not matched with voucher amount due.'
		WHEN A.ysnPosted = 1 AND A.dblTotal != ISNULL(GLData.dblCredit,0) AND A.ysnOrigin = 0 AND A.intTransactionType != 2 THEN 'Voucher and GL amount do not match.'
		WHEN A.intBillId IS NULL AND GLRecord.intTransactionId IS NOT NULL THEN 'GL Record exists but not in voucher table.'
		WHEN (A.ysnPaid = 1 AND (CASE WHEN A.intTransactionType !=1 THEN A.dblTotal * -1 ELSE A.dblTotal END)
				 != ((CASE WHEN A.intTransactionType !=1 THEN A.dblPayment * -1 ELSE A.dblPayment END)
						 + (CASE WHEN A.intTransactionType !=1 THEN A.dblDiscount * -1 ELSE A.dblDiscount END)
						 - (CASE WHEN A.intTransactionType !=1 THEN A.dblInterest * -1 ELSE A.dblInterest END)))
			THEN 'Invalid Paid Status. Bill was not fully paid. (6 Decimals)'
		WHEN (A.ysnPaid = 1 AND CAST((CASE WHEN A.intTransactionType !=1 THEN A.dblTotal * -1 ELSE A.dblTotal END) AS DECIMAL(18,2))
				 != CAST(((CASE WHEN A.intTransactionType !=1 THEN A.dblPayment * -1 ELSE A.dblPayment END)
						 + (CASE WHEN A.intTransactionType !=1 THEN A.dblDiscount * -1 ELSE A.dblDiscount END)
						 - (CASE WHEN A.intTransactionType !=1 THEN A.dblInterest * -1 ELSE A.dblInterest END)) AS DECIMAL(18,2)))
			THEN 'Invalid Paid Status. Bill was not fully paid. (2 Decimals)'
		 WHEN (A.ysnPaid = 0 AND (CASE WHEN A.intTransactionType !=1 THEN A.dblTotal * -1 ELSE A.dblTotal END)
			 = CAST(((CASE WHEN A.intTransactionType !=1 THEN A.dblPayment * -1 ELSE A.dblPayment END)
						 + (CASE WHEN A.intTransactionType !=1 THEN A.dblDiscount * -1 ELSE A.dblDiscount END)
						 - (CASE WHEN A.intTransactionType !=1 THEN A.dblInterest * -1 ELSE A.dblInterest END)) AS DECIMAL(18,2)))
			THEN 'Invalid Paid Status. Bill was already fully paid.'
		WHEN A.ysnPosted = 1 AND A.intTransactionType = 2 AND A.dblPayment != 0 AND ISNULL(Payments.dblPayment,0) = 0
			THEN 'Prepayment has payment but did no offset transaction'
			ELSE 'OK' END COLLATE Latin1_General_CI_AS AS strStatus
FROM tblAPBill A
OUTER APPLY (
	SELECT
		SUM(B.dblTotal) dblTotal
	FROM tblAPBillDetail B
	WHERE A.intBillId = B.intBillId
) Details
OUTER APPLY (
	SELECT 
		SUM(dblPayment) dblPayment
		,SUM(dblDiscount) dblDiscount
		,SUM(dblInterest) dblInterest
		,SUM(dblWithheld) dblWithheld
	FROM (
		SELECT
			SUM(D.dblPayment) dblPayment
			,SUM(D.dblDiscount) dblDiscount
			,SUM(D.dblInterest) dblInterest
			,SUM(D.dblWithheld) dblWithheld
		FROM tblAPPayment C
		INNER JOIN tblAPPaymentDetail D ON C.intPaymentId = D.intPaymentId
		WHERE D.intBillId = A.intBillId
		AND C.ysnPrepay = 0 AND C.ysnPosted = 1
		UNION ALL
		SELECT
			SUM(D.dblPayment) dblPayment
			,SUM(D.dblDiscount) dblDiscount
			,SUM(D.dblInterest) dblInterest
			,0 dblWithheld
		FROM tblARPayment C
		INNER JOIN tblARPaymentDetail D ON C.intPaymentId = D.intPaymentId
		WHERE D.intBillId = A.intBillId
		AND C.ysnPosted = 1
	) allPayment
) Payments
OUTER APPLY (
	SELECT
		SUM(F.dblPayment * -1) AS dblPrepayment
	FROM tblAPPayment E
	INNER JOIN tblAPPaymentDetail F ON E.intPaymentId = F.intPaymentId
	WHERE F.intBillId = A.intBillId
	AND (E.ysnPrepay = 1) AND E.ysnPosted = 1
) Prepayments
OUTER APPLY 
(
	SELECT 
		intBillId
		,SUM(tmpAPPayables.dblTotal) AS dblTotal
		,SUM(tmpAPPayables.dblAmountPaid) AS dblAmountPaid
		,SUM(tmpAPPayables.dblDiscount)AS dblDiscount
		,SUM(tmpAPPayables.dblInterest) AS dblInterest
		,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
	FROM (
		SELECT 
			intBillId
			,dblTotal
			,dblAmountDue
			,dblAmountPaid
			,dblDiscount
			,dblInterest
			,dtmDate
		FROM dbo.vyuAPPayables
		WHERE intBillId = A.intBillId
	) tmpAPPayables 
	GROUP BY intBillId
) OpenPayables
OUTER APPLY (
	SELECT
		ABS(SUM(dblCredit - dblDebit)) dblCredit
	FROM tblGLDetail G
	INNER JOIN vyuGLAccountDetail H ON G.intAccountId = H.intAccountId
	WHERE G.strTransactionForm = 'Bill'
	AND A.strBillId = G.strTransactionId AND A.intBillId = G.intTransactionId
	AND G.ysnIsUnposted = 0
	AND H.intAccountCategoryId IN (
		SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Account'
		UNION ALL
		SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Vendor Prepayments'
	)
	GROUP BY G.intAccountId
) GLData
OUTER APPLY (
	SELECT TOP 1 F.intTransactionId, F.strTransactionId
	FROM tblGLDetail F
	WHERE F.strTransactionForm = 'Bill'
	AND A.intBillId = F.intTransactionId AND A.strBillId = F.strTransactionId
	AND F.ysnIsUnposted = 0
) GLRecord 