/*
    Avoid the error of over clause in sql version 2008 (unsupported)
*/
GO
IF SUBSTRING(CONVERT (NVARCHAR(20), SERVERPROPERTY('ProductVersion')),1,2) > 10
BEGIN
    EXEC (
        'ALTER VIEW dbo.vyuCMCashProjection
        AS
        WITH BankBalances AS (
            SELECT SUM([dbo].[fnCMGetBankBalance] (intBankAccountId, getdate())) Balance
            FROM dbo.tblCMBankAccount
        ),
        WeekQuery as(
                SELECT  
                DATEADD(wk, 0, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirsDayOfWeek,
                CAST(DATEPART (YEAR, getdate())AS NVARCHAR(4)) + CAST(DATEPART (WEEK, getdate())as nvarchar(3))   WeekNo
                UNION SELECT 
                DATEADD(wk, -1, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirsDayOfWeek,
                CAST(DATEPART (YEAR, DATEADD( DAY, -7, getdate()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -7, getdate()))as nvarchar(3))  WeekNo
                UNION SELECT 
                DATEADD(wk, -2, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirsDayOfWeek,
                CAST(DATEPART (YEAR, DATEADD( DAY, -14, getdate()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -14, getdate()))as nvarchar(3))  WeekNo
                UNION SELECT 
                DATEADD(wk, -3, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirsDayOfWeek,
                CAST(DATEPART (YEAR, DATEADD( DAY, -21, getdate()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -21, getdate()))as nvarchar(3)) WeekNo
                UNION SELECT 
                DATEADD(wk, -4, DATEADD(DAY, 1-DATEPART(WEEKDAY, GETDATE()), DATEDIFF(dd, 0, GETDATE()))) FirsDayOfWeek,
                CAST(DATEPART (YEAR, DATEADD( DAY, -28, getdate()))AS NVARCHAR(4)) + CAST(DATEPART (WEEK, DATEADD( DAY, -28, getdate()))as nvarchar(3)) WeekNo
        )
        ,QueryAR AS
        (
            SELECT 
                dtmDueDate,
                dblAmountDue
            FROM dbo.tblARInvoice 
            WHERE ysnPosted = 1
            AND ysnPaid = 0
            AND strTransactionType IN (''Invoice'', ''Debit Memo'') 
        ),
        CombineARAP AS (
            SELECT CAST(DATEPART (YEAR, dtmDueDate)AS NVARCHAR(4)) + RIGHT(''0'' + CAST(DATEPART (WEEK, dtmDueDate) as nvarchar(3)),2) WeekNo , dblAmountDue * -1 dblAmountDue 
            FROM dbo.vyuAPPayablesAmountDue 
            UNION ALL
            SELECT CAST(DATEPART (YEAR, dtmDueDate)AS NVARCHAR(4)) + RIGHT(''0'' + CAST(DATEPART (WEEK, dtmDueDate) as nvarchar(3)),2) WeekNo , dblAmountDue dblAmountDue FROM QueryAR 
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
            B.FirsDayOfWeek,
            B.WeekNo, 
            dblAmountDue
            FROM TotalQuery A right join
            WeekQuery B ON B.WeekNo = A.WeekNo
        )
        ,RunningTotal as(
            SELECT 
            FirsDayOfWeek,
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
        BankBalances B')
END
GO