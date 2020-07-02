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
CombineARAP AS (
	SELECT CAST(DATEPART (YEAR, dtmDueDate)AS NVARCHAR(4)) + RIGHT('0' + CAST(DATEPART (WEEK, dtmDueDate) as nvarchar(3)),2) WeekNo , dblAmountDue * -1 dblAmountDue 
	FROM vyuAPOpenPayables 
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





