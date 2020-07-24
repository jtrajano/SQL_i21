CREATE VIEW dbo.vyuCMCashProjection
AS
WITH BankBalances AS (
	SELECT SUM([dbo].[fnCMGetBankBalance] (intBankAccountId, GETDATE())) Balance
	FROM dbo.tblCMBankAccount
),
WeekQuery AS(
		SELECT  
		DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirsDayOfWeek,
		CAST(DATEPART (YEAR, GETDATE())AS NVARCHAR(4)) + CAST(DATEPART (WEEK, GETDATE())AS NVARCHAR(3))   WeekNo
		UNION SELECT 
		DATEADD(wk, -1, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirsDayOfWeek,
		CAST(DATEPART (YEAR, DATEADD( DAY, -7, GETDATE()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -7, GETDATE()))AS NVARCHAR(3))  WeekNo
		UNION SELECT 
		DATEADD(wk, -2, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirsDayOfWeek,
		CAST(DATEPART (YEAR, DATEADD( DAY, -14, GETDATE()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -14, GETDATE()))AS NVARCHAR(3))  WeekNo
		UNION SELECT 
		DATEADD(wk, -3, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirsDayOfWeek,
		CAST(DATEPART (YEAR, DATEADD( DAY, -21, GETDATE()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -21, GETDATE()))AS NVARCHAR(3)) WeekNo
		UNION SELECT 
		DATEADD(wk, -4, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirsDayOfWeek,
		CAST(DATEPART (YEAR, DATEADD( DAY, -28, GETDATE()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -28, GETDATE()))AS NVARCHAR(3)) WeekNo
)
,QueryAR AS
(
	SELECT 
		dtmDueDate,
		dblAmountDue
	FROM dbo.tblARInvoice 
	WHERE ysnPosted = 1
	AND ysnPaid = 0
	AND strTransactionType IN ('Invoice', 'Debit Memo') 
),
CombineARAP AS (
	SELECT CAST(DATEPART (YEAR, dtmDueDate)AS NVARCHAR(4)) + RIGHT('0' + CAST(DATEPART (WEEK, dtmDueDate) AS NVARCHAR(3)),2) WeekNo , dblAmountDue * -1 dblAmountDue 
	FROM dbo.vyuAPPayablesAmountDue 
	UNION ALL
	SELECT CAST(DATEPART (YEAR, dtmDueDate)AS NVARCHAR(4)) + RIGHT('0' + CAST(DATEPART (WEEK, dtmDueDate) AS NVARCHAR(3)),2) WeekNo , dblAmountDue dblAmountDue FROM QueryAR 
)
,TotalQuery AS(
	SELECT  
	SUM(dblAmountDue)dblAmountDue
	, WeekNo
	FROM CombineARAP A
	group by WeekNo
)
,JoinInWeeks AS(
	SELECT 
	B.FirsDayOfWeek,
	B.WeekNo, 
	dblAmountDue
	FROM TotalQuery A right join
	WeekQuery B ON B.WeekNo = A.WeekNo
)
,RunningTotal AS(
	SELECT 
	FirsDayOfWeek,
	WeekNo,
	ISNULL(dblAmountDue,0) dblAmountDue,
	RunningTotal.Val RunningTotal
FROM
JoinInWeeks T1
OUTER APPLY (
	SELECT SUM(dblAmountDue) Val from JoinInWeeks T2
	WHERE T2.WeekNo<=T1.WeekNo
)RunningTotal

)
SELECT 
	A.*
	,B.Balance + RunningTotal NetAmount
FROM RunningTotal A,
BankBalances B