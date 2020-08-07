CREATE VIEW dbo.vyuCMCashProjection
AS
WITH  WeekQuery AS(
		SELECT  
		DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirstDayOfWeek,
		CAST(DATEPART (YEAR, GETDATE())AS NVARCHAR(4)) + RIGHT('0' + CAST(DATEPART (WEEK, GETDATE())AS NVARCHAR(3)),2)   WeekNo
		UNION SELECT 
		DATEADD(wk, -1, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirstDayOfWeek,
		CAST(DATEPART (YEAR, DATEADD( DAY, -7, GETDATE()))AS NVARCHAR(4)) + RIGHT('0'+ CAST(DATEPART (WEEK, DATEADD( DAY, -7, GETDATE()))AS NVARCHAR(3)),2)  WeekNo
		UNION SELECT 
		DATEADD(wk, -2, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirstDayOfWeek,
		CAST(DATEPART (YEAR, DATEADD( DAY, -14, GETDATE()))AS NVARCHAR(4)) + RIGHT('0' + CAST(DATEPART (WEEK, DATEADD( DAY, -14, GETDATE()))AS NVARCHAR(3)),2)  WeekNo
		UNION SELECT 
		DATEADD(wk, -3, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirstDayOfWeek,
		CAST(DATEPART (YEAR, DATEADD( DAY, -21, GETDATE()))AS NVARCHAR(4)) + RIGHT('0' + CAST(DATEPART (WEEK, DATEADD( DAY, -21, GETDATE()))AS NVARCHAR(3)),2) WeekNo
		UNION SELECT 
		DATEADD(wk, -4, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirstDayOfWeek,
		CAST(DATEPART (YEAR, DATEADD( DAY, -28, GETDATE()))AS NVARCHAR(4)) + RIGHT('0' + CAST(DATEPART (WEEK, DATEADD( DAY, -28, GETDATE()))AS NVARCHAR(3)),2) WeekNo
),
BoundaryDate as(

	SELECT min (FirstDayOfWeek) MinDay,  DATEADD(SECOND, -1, DATEADD(day, 35, min (FirstDayOfWeek))) MaxDay   FROM WeekQuery
)
,QueryAR AS
(
	SELECT 
		dtmDueDate,
		isnull(dblAmountDue,0) dblAmountDue
	FROM dbo.tblARInvoice 
	WHERE ysnPosted = 1
	AND ysnPaid = 0
	AND strTransactionType IN ('Invoice', 'Debit Memo') 
),
DueAmounts AS (
	SELECT A.* FROM (
		SELECT dtmDueDate, 'AP' strType, CAST(DATEPART (YEAR, dtmDueDate)AS NVARCHAR(4)) + RIGHT('0' + CAST(DATEPART (WEEK, dtmDueDate) AS NVARCHAR(3)),2) WeekNo , 
		isnull(dblAmountDue ,0) dblAmountDue
		FROM dbo.vyuAPPayablesAmountDue 
		UNION ALL
		SELECT dtmDueDate, 'AR' strType, CAST(DATEPART (YEAR, dtmDueDate)AS NVARCHAR(4)) + RIGHT('0' + CAST(DATEPART (WEEK, dtmDueDate) AS NVARCHAR(3)),2) WeekNo , 
		isnull(dblAmountDue,0) dblAmountDue FROM QueryAR 
	) A
		WHERE dtmDueDate  
		BETWEEN (SELECT MinDay FROM BoundaryDate) 
		AND	(SELECT MaxDay FROM BoundaryDate) 

)
,WeeklyOpenAP as(
	SELECT W.WeekNo, W.FirstDayOfWeek  --, AP.Val APAging, AR.Val ARAging
	, SUM(D.dblAmountDue)dblAmountDue, D.strType
	FROM WeekQuery W
	LEFT JOIN DueAmounts D on D.WeekNo = W.WeekNo
	GROUP BY D.strType, W.WeekNo,W.FirstDayOfWeek
) 
SELECT T1.*, 
RunningTotalAR.ARAged,
RunningTotalAP.APAged,
(Bank.Balance + RunningTotalAR.ARAged - RunningTotalAP.APAged) Cash
FROM WeekQuery T1
OUTER APPLY(
	SELECT SUM(dblAmountDue) ARAged FROM WeeklyOpenAP T2
	WHERE T2.WeekNo<=T1.WeekNo and strType = 'AR'
) RunningTotalAR
OUTER APPLY (
	SELECT SUM(dblAmountDue) APAged FROM WeeklyOpenAP T2
	WHERE T2.WeekNo<=T1.WeekNo and strType = 'AP'
)RunningTotalAP
OUTER APPLY(
	SELECT SUM([dbo].[fnCMGetBankBalance] (intBankAccountId, GETDATE())) Balance
	FROM dbo.tblCMBankAccount
)Bank
GO


