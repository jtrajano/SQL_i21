CREATE PROCEDURE [dbo].[uspAPShowBalanceDifference]
(
	@startDate DATETIME = NULL,
	@endDate DATETIME = NULL
)
AS
DECLARE @intPayablesCategory INT, @prepaymentCategory INT;
DECLARE @start DATETIME = CASE WHEN @startDate IS NULL THEN '1/1/1900' ELSE @startDate END;
DECLARE @end DATETIME = CASE WHEN @endDate IS NULL THEN '12/31/2100' ELSE @endDate END;

--DELETE FROM tblAPBalanceDifference

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
		FROM 
		(
			SELECT * FROM dbo.vyuAPPayables
			WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @start AND @end
		) tmpAPPayables 
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
		FROM 
		(
			SELECT * FROM dbo.vyuAPPrepaidPayables
			WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @start AND @end
		) tmpAPPayables2 
		GROUP BY intBillId
	) AS tmpAgingSummaryTotal
	LEFT JOIN dbo.tblAPBill A
	ON A.intBillId = tmpAgingSummaryTotal.intBillId
	LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId
	WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
	UNION ALL
	SELECT
	A.strInvoiceNumber
	,CAST((SUM(tmpAPPayables3.dblTotal) + SUM(tmpAPPayables3.dblInterest) - SUM(tmpAPPayables3.dblAmountPaid) - SUM(tmpAPPayables3.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
	FROM 
	(
		SELECT * FROM dbo.vyuAPSalesForPayables
		WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @start AND @end
	) tmpAPPayables3 
	INNER JOIN tblARInvoice A ON tmpAPPayables3.intInvoiceId = A.intInvoiceId
	GROUP BY A.strInvoiceNumber
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
				,SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit,0)) AS dblTotal --DISCOUNT IS ALREADY PART OF THIS
				,0 AS dblPayment
			FROM tblGLDetail A
			INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			WHERE D.intAccountCategoryId IN (@intPayablesCategory)
			AND A.ysnIsUnposted = 0
			AND A.strTransactionForm = 'Bill' AND intJournalLineNo = 1
			AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
			GROUP BY A.strTransactionId
			UNION ALL
			--POSTED INVOICE
			SELECT
				A.strTransactionId AS strBillId
				,SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit,0)) AS dblTotal --DISCOUNT IS ALREADY PART OF THIS
				,0 AS dblPayment
			FROM tblGLDetail A
			INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			WHERE D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
			AND A.ysnIsUnposted = 0
			AND A.strTransactionForm = 'Invoice' AND A.strTransactionType = 'Cash Refund'
			AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
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
			AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
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
			AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
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
			--APPLIED PAYMENT FOR THE TRANSACTION OWNS THE tblAPAppliedPrepaidAndDebit
			SELECT
				A.strTransactionId AS strBillId
				,0 as dblAmountDue
				,SUM(A.dblDebit - A.dblCredit)  AS dblPayment
			FROM tblGLDetail A
			--INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			INNER JOIN tblAPBill C ON A.strTransactionId = C.strBillId
			INNER JOIN tblAPAppliedPrepaidAndDebit C2 ON C.intBillId = C2.intBillId AND C2.intTransactionId = A.intJournalLineNo
			INNER JOIN tblAPBill C3 ON C2.intTransactionId = C3.intBillId
			WHERE D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
			AND A.strJournalLineDescription = 'Applied Debit Memo'
			AND A.dblDebit != 0 --GET THE PAYMENT FOR THE TRANSACTION ONLY
			AND A.ysnIsUnposted = 0
			AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
			GROUP BY A.strTransactionId
			UNION
			--APPLIED PAYMENT FOR THE TRANSACTION ON THE TAB (DM-VPRE)
			SELECT
				C3.strBillId AS strBillId
				,0 as dblAmountDue
				,SUM(A.dblCredit - A.dblDebit) * -1 AS dblPayment
			FROM tblGLDetail A
			--INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			INNER JOIN tblAPBill C ON A.strTransactionId = C.strBillId
			INNER JOIN tblAPAppliedPrepaidAndDebit C2 ON C.intBillId = C2.intBillId AND C2.intTransactionId = A.intJournalLineNo
			INNER JOIN tblAPBill C3 ON C2.intTransactionId = C3.intBillId
			WHERE D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
			AND A.strJournalLineDescription = 'Applied Debit Memo'
			AND A.dblCredit != 0 --GET THE PAYMENT FOR THE TRANSACTION ONLY
			AND A.ysnIsUnposted = 0
			AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
			GROUP BY C3.strBillId
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
			AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
			AND EXISTS(
				SELECT TOP 1 1 FROM tblGLDetail E WHERE E.strTransactionId = A.strTransactionId AND E.strJournalLineDescription = 'Interest'
			)
			GROUP BY A.strJournalLineDescription
			UNION ALL
			--POSTED PAYMENT
			SELECT
				A.strJournalLineDescription AS strBillId
				,0 as dblAmountDue
				,SUM(ISNULL(A.dblDebit,0)) - SUM(ISNULL(A.dblCredit,0)) AS dblPayment 
			FROM tblGLDetail A
			INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			WHERE D.intAccountCategoryId IN (@intPayablesCategory, @prepaymentCategory)
			AND A.ysnIsUnposted = 0
			AND A.strTransactionForm = 'Payable' AND A.strJournalLineDescription != 'Posted Payment'
			AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
			GROUP BY A.strJournalLineDescription
			--UNION ALL
			----POSTED PAYMENT
			--SELECT
			--	A.strJournalLineDescription AS strBillId
			--	,0 as dblAmountDue
			--	,SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit,0)) AS dblPayment 
			--FROM tblGLDetail A
			--INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			--INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			--WHERE D.intAccountCategoryId IN (@prepaymentCategory)
			--AND A.ysnIsUnposted = 0
			--AND A.strTransactionForm = 'Payable' AND A.strJournalLineDescription != 'Posted Payment'
			--AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
			--GROUP BY A.strJournalLineDescription
			 --UNION ALL
			 ----POSTED DISCOUNT
			 --SELECT
			 --	C.strBillId AS strBillIds
			 --	,0 as dblAmountDue
			 --	,SUM(CASE WHEN CHARINDEX(A.strTransactionId,'V') > 0 THEN (A.dblDebit - A.dblCredit) ELSE (A.dblCredit - A.dblDebit) END)  AS dblPayment --handle void
			 --FROM tblGLDetail A
			 --INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			 --INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			 --INNER JOIN tblAPPayment E ON A.strTransactionId = E.strPaymentRecordNum
			 --INNER JOIN tblAPPaymentDetail F ON E.intPaymentId = F.intPaymentId AND ABS(A.dblDebit - A.dblCredit) = F.dblDiscount
			 --INNER JOIN tblAPBill C ON C.intBillId = F.intBillId
			 --WHERE D.intAccountCategoryId NOT IN (1, 53)
			 --AND A.ysnIsUnposted = 0
			 --AND A.strTransactionForm = 'Payable' AND A.strJournalLineDescription = 'Discount'
			 ----AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
			 --GROUP BY C.strBillId
			UNION ALL --PAYMENT MADE TO AR
			SELECT
				C.strBillId AS strBillId
				,0 as dblAmountDue
				,SUM(A.dblDebit - dblCredit) AS dblPayment
			FROM tblGLDetail A
			INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
			INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
			INNER JOIN tblARPayment E ON A.strTransactionId = E.strRecordNumber
			INNER JOIN tblARPaymentDetail F ON E.intPaymentId = F.intPaymentId AND A.intJournalLineNo = F.intPaymentDetailId
			INNER JOIN tblAPBill C ON C.intBillId = F.intBillId
			WHERE D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
			AND A.ysnIsUnposted = 0
			AND A.strTransactionForm = 'Receive Payments'
			AND DATEADD(dd, DATEDIFF(dd, 0,A.dtmDate), 0) BETWEEN @start AND @end
			GROUP BY C.strBillId

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
--INSERT INTO tblAPBalanceDifference(strTransactionId, ysnOrigin, dblAPBalance, dblAPGLBalance, dblDifference)
SELECT 
	*
FROM (
	SELECT
		ISNULL(payables.strBillId, glPayables.strGLBillId) AS strBillId
		,ISNULL(voucher.ysnOrigin,0) ysnOrigin
		,ISNULL(payables.dblAmountDue,0) AS dblAmountDue
		-- ,strGLBillId
		,ISNULL(glPayables.dblGLAmountDue,0) AS dblGLAmountDue
		,ISNULL(payables.dblAmountDue,0) - ISNULL(glPayables.dblGLAmountDue,0) dblDifference
	FROM payables
	FULL OUTER JOIN glPayables ON payables.strBillId = glPayables.strGLBillId
	LEFT JOIN tblAPBill voucher ON voucher.strBillId = payables.strBillId
	WHERE (payables.strBillId IS NOT NULL OR glPayables.strGLBillId IS NOT NULL)
) payables
WHERE dblAmountDue != dblGLAmountDue

--SELECT * FROM tblAPBalanceDifference