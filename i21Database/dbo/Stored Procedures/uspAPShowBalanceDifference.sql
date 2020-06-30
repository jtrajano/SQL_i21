CREATE PROCEDURE [dbo].[uspAPShowBalanceDifference]
AS
DECLARE @intPayablesCategory INT, @prepaymentCategory INT;

SELECT @intPayablesCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Account'
SELECT @prepaymentCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Vendor Prepayments';

WITH payables (
	strBillId
	,dblAmountDue
) AS (
	SELECT
	A.strBillId
	,tmpAgingSummaryTotal.dblAmountDue
	FROM  
	(
		SELECT 
		intBillId
		,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM (SELECT * FROM dbo.vyuAPPayables) tmpAPPayables 
		GROUP BY intBillId
		UNION ALL
		SELECT   
		intBillId  
		,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue  
		FROM   
		(  
		SELECT * FROM dbo.vyuAPPayablesForeign
		WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @start AND @end  
		) tmpAPPayables   
		GROUP BY intBillId  
		UNION ALL
		SELECT 
		intBillId
		,CAST((SUM(tmpAPPayables2.dblTotal) + SUM(tmpAPPayables2.dblInterest) - SUM(tmpAPPayables2.dblAmountPaid) - SUM(tmpAPPayables2.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM (SELECT * FROM dbo.vyuAPPrepaidPayables) tmpAPPayables2 
		GROUP BY intBillId
	) AS tmpAgingSummaryTotal
	LEFT JOIN dbo.tblAPBill A
	ON A.intBillId = tmpAgingSummaryTotal.intBillId
	LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId
	WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
	--AND A.intBillId = 53660
),
glPayables (
	strGLBillId
	,dblGLAmountDue
) AS (
	SELECT * FROM (
		SELECT
			glData.strBillId
			,SUM(glData.dblTotal) - SUM(glData.dblPayment) AS dblAmountDue
		FROM (
			--POSTED VOUCHER
			SELECT
				A.strTransactionId AS strBillId
				,SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit,0)) AS dblTotal
				,0 AS dblPayment
			FROM tblGLDetail A
			INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			WHERE D.intAccountCategoryId IN (@intPayablesCategory)
			AND A.ysnIsUnposted = 0
			AND A.strTransactionForm = 'Bill' AND intJournalLineNo = 1
			GROUP BY A.strTransactionId
			UNION ALL --PREPAYMENT POSITIVE
			SELECT
				A.strTransactionId AS strBillId
				,SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit,0)) AS dblTotal
				,0 AS dblPayment
			FROM tblGLDetail A
			INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			WHERE D.intAccountCategoryId IN (@prepaymentCategory)
			AND A.ysnIsUnposted = 0
			AND A.strTransactionForm = 'Bill' AND intJournalLineNo = 1
			GROUP BY A.strTransactionId
			UNION ALL --PREPAYMENT NEGATIVE
			SELECT
				A.strTransactionId AS strBillId
				,SUM(ISNULL(A.dblDebit,0)) - SUM(ISNULL(A.dblCredit,0)) AS dblTotal
				,0 AS dblPayment
			FROM tblGLDetail A
			INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			WHERE D.intAccountCategoryId IN (@prepaymentCategory)
			AND A.ysnIsUnposted = 0
			AND A.strTransactionForm = 'Bill' AND intJournalLineNo = 1
			GROUP BY A.strTransactionId
			--UNION ALL
			----POSTED TAX
			--SELECT
			--	A.strTransactionId AS strBillId
			--	,SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit,0)) AS dblTotal
			--	,0 AS dblPayment
			--FROM tblGLDetail A
			--INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			--INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			--WHERE --D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory) AND 
			--A.ysnIsUnposted = 0
			--AND A.strTransactionForm = 'Bill' AND strJournalLineDescription = 'Purchase Tax'
			--GROUP BY A.strTransactionId
			UNION ALL
			--POSTED INTEREST
			SELECT
				A.strJournalLineDescription AS strBillId
				,0 as dblAmountDue
				,SUM(CASE WHEN CHARINDEX(A.strTransactionId,'V') > 0 THEN C.dblInterest * -1 ELSE C.dblInterest END)  AS dblPayment --handle void
			FROM tblGLDetail A
			INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			INNER JOIN tblAPBill C ON A.strJournalLineDescription = C.strBillId
			WHERE D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
			AND A.ysnIsUnposted = 0
			AND A.strTransactionForm = 'Payable' AND A.strJournalLineDescription != 'Posted Payment'
			AND EXISTS(
				SELECT TOP 1 1 FROM tblGLDetail E WHERE E.strTransactionId = A.strTransactionId AND E.strJournalLineDescription = 'Interest'
			)
			GROUP BY A.strJournalLineDescription
			UNION ALL
			--POSTED PAYMENT
			SELECT
				A.strJournalLineDescription AS strBillId
				,0 as dblAmountDue
				,SUM(ISNULL(A.dblDebit,0)) - SUM(ISNULL(A.dblCredit,0))  AS dblPayment --include voided
			FROM tblGLDetail A
			INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			WHERE D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
			AND A.ysnIsUnposted = 0
			AND A.strTransactionForm = 'Payable' AND A.strJournalLineDescription != 'Posted Payment'
			GROUP BY A.strJournalLineDescription
			UNION ALL
			--POSTED DISCOUNT
			SELECT
				A.strJournalLineDescription AS strBillId
				,0 as dblAmountDue
				,SUM(CASE WHEN CHARINDEX(A.strTransactionId,'V') > 0 THEN C.dblDiscount * -1 ELSE C.dblDiscount END)  AS dblPayment --handle void
			FROM tblGLDetail A
			INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			INNER JOIN tblAPBill C ON A.strJournalLineDescription = C.strBillId
			WHERE D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
			AND A.ysnIsUnposted = 0
			AND A.strTransactionForm = 'Payable' AND A.strJournalLineDescription != 'Posted Payment'
			AND EXISTS(
				SELECT TOP 1 1 FROM tblGLDetail E WHERE E.strTransactionId = A.strTransactionId AND E.strJournalLineDescription = 'Discount'
			)
			GROUP BY A.strJournalLineDescription

		) glData
		--WHERE strBillId = 'BL-21123'
		GROUP BY strBillId
	) gl WHERE dblAmountDue != 0
)

--SELECT 
--* 
--FROM payables
--FULL OUTER JOIN glPayables ON payables.strBillId = glPayables.strBillId
--WHERE (payables.strBillId = 'BL-750' OR glPayables.strBillId = 'BL-750') 

SELECT 
	*
FROM (
	SELECT
		strBillId
		,ISNULL(dblAmountDue,0) AS dblAmountDue
		,strGLBillId
		,ISNULL(dblGLAmountDue,0) AS dblGLAmountDue
	FROM payables
	FULL OUTER JOIN glPayables ON payables.strBillId = glPayables.strGLBillId
	WHERE (payables.strBillId IS NOT NULL OR glPayables.strGLBillId IS NOT NULL)
) payables
WHERE dblAmountDue != dblGLAmountDue