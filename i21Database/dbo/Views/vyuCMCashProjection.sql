--alter VIEW vyuAPGetPayablesPerWeek
--AS
CREATE VIEW vyuCMCashProjection
AS

WITH BankBalances AS (
    SELECT SUM([dbo].[fnCMGetBankBalance] (intBankAccountId, getdate())) Balance
    FROM tblCMBankAccount
),
WeekQuery as(
		SELECT  CAST(DATEPART (YEAR, getdate())AS NVARCHAR(4)) + CAST(DATEPART (WEEK, getdate())as nvarchar(3))   WeekNo
		UNION SELECT 
		CAST(DATEPART (YEAR, DATEADD( DAY, -7, getdate()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -7, getdate()))as nvarchar(3))  WeekNo
		UNION SELECT 
		CAST(DATEPART (YEAR, DATEADD( DAY, -14, getdate()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -14, getdate()))as nvarchar(3))  WeekNo
		UNION SELECT 
		CAST(DATEPART (YEAR, DATEADD( DAY, -21, getdate()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -21, getdate()))as nvarchar(3)) WeekNo
		UNION SELECT 
		CAST(DATEPART (YEAR, DATEADD( DAY, -28, getdate()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -28, getdate()))as nvarchar(3)) WeekNo
)
,QueryAR AS
(
	SELECT 
		dtmDueDate,
		dblAmountDue
	FROM tblARInvoice 
	WHERE ysnPosted = 1
	AND ysnPaid = 0
	AND strTransactionType IN ('Invoice', 'Debit Memo') 
),
QueryAP AS(
	SELECT
		A.dtmDueDate		
		,tmpAgingSummaryTotal.dblAmountDue 
		FROM  
		(
			SELECT 
			intBillId
			,dtmDueDate
			,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (
				SELECT dblTotal, dblInterest,dblAmountPaid,dblDiscount, intBillId,dtmDueDate FROM dbo.vyuAPPayables
			) tmpAPPayables 
			GROUP BY intBillId,dtmDueDate
			UNION ALL
			SELECT 
			intBillId
			,dtmDueDate	
			,CAST((SUM(tmpAPPayables2.dblTotal) + SUM(tmpAPPayables2.dblInterest) - SUM(tmpAPPayables2.dblAmountPaid) - SUM(tmpAPPayables2.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (
				SELECT dblTotal, dblInterest,dblAmountPaid,dblDiscount, intBillId, dtmDueDate FROM dbo.vyuAPPrepaidPayables
			) tmpAPPayables2 
			GROUP BY intBillId,dtmDueDate
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblAPBill A
		ON A.intBillId = tmpAgingSummaryTotal.intBillId
		LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId
		WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
		UNION ALL
		SELECT
			A.dtmDueDate
			,CAST((SUM(A.dblTotal) + SUM(A.dblInterest) - SUM(A.dblAmountPaid) - SUM(A.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM vyuAPSalesForPayables A
		LEFT JOIN dbo.vyuGLAccountDetail D ON  A.intAccountId = D.intAccountId
		WHERE D.strAccountCategory = 'AP Account' --there are old data where cash refund have been posted to non AP account
		GROUP BY A.dtmDueDate
		UNION ALL
		SELECT
			tmpAgingSummaryTotal.dtmDueDate
			,tmpAgingSummaryTotal.dblAmountDue 
		FROM  
		(
			SELECT 
				intBillId
				,dtmDueDate
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
					,intCount
					,dtmDueDate
				  FROM dbo.vyuAPPayablesAgingDeleted
			) tmpAPPayables 
			GROUP BY intBillId,dtmDueDate
			HAVING SUM(DISTINCT intCount) > 1 --DO NOT INCLUDE DELETED REPORT IF THAT IS ONLY THE PART OF DELETED DATA
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblAPBillArchive A ON tmpAgingSummaryTotal.intBillId = A.intBillId
		LEFT JOIN dbo.vyuGLAccountDetail D ON  A.intAccountId = D.intAccountId
),
CombineARAP AS (
	SELECT CAST(DATEPART (YEAR, dtmDueDate)AS NVARCHAR(4)) + RIGHT('0' + CAST(DATEPART (WEEK, dtmDueDate) as nvarchar(3)),2) WeekNo , dblAmountDue * -1 dblAmountDue FROM QueryAP 
	UNION ALL
	SELECT CAST(DATEPART (YEAR, dtmDueDate)AS NVARCHAR(4)) + RIGHT('0' + CAST(DATEPART (WEEK, dtmDueDate) as nvarchar(3)),2) WeekNo , dblAmountDue dblAmountDue FROM QueryAR 
)
,TotalQuery as(
	SELECT  
	SUM(dblAmountDue)dblAmountDue
	, WeekNo
	FROM CombineARAP A
	group by WeekNo
)
,JoinInWeeks as(
	SELECT 
	B.WeekNo, 
	dblAmountDue
	FROM TotalQuery A right join
	WeekQuery B ON B.WeekNo = A.WeekNo
)
,RunningTotal as(
	SELECT 
	WeekNo,
	ISNULL(dblAmountDue,0) dblAmountDue,
	SUM(dblAmountDue) over(order by WeekNo) RunningTotal
FROM
JoinInWeeks
)
SELECT 
	A.*
	,B.Balance + RunningTotal NetAmount
FROM RunningTotal A,
BankBalances B





