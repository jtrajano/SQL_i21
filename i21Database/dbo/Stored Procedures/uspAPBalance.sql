CREATE PROCEDURE [dbo].[uspAPBalance]
	@UserId INT,
	@dateFrom DATETIME = NULL,
	@dateTo DATETIME = NULL,
	@balance DECIMAL(18,6) OUTPUT,
	@logKey NVARCHAR(100) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @key NVARCHAR(100) = NEWID();
DECLARE @logDate DATETIME = GETDATE();
DECLARE @from DATETIME = CASE WHEN @dateFrom IS NULL THEN '1/1/1900' ELSE @dateFrom END;
DECLARE @to DATETIME = CASE WHEN @dateTo IS NULL THEN GETDATE() ELSE @dateTo END;
SET @logKey = @key;

DECLARE @log TABLE
(
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)

--GET THE BALANCE
IF OBJECT_ID(N'tempdb..#tmpAPAccountBalance') IS NOT NULL DROP TABLE #tmpAPAccountBalance
CREATE TABLE #tmpAPAccountBalance(strAccountId NVARCHAR(40), dblBalance DECIMAL(18,6))

INSERT INTO #tmpAPAccountBalance
/*SELECT
	B.strAccountId,
	--CAST(SUM(A.dblTotal) + SUM(A.dblInterest) - SUM(A.dblAmountPaid) - SUM(A.dblDiscount)AS DECIMAL(18,2)) AS dblBalance
	CAST(SUM(A.dblAmountDue)AS DECIMAL(18,2)) as dblBalance
FROM vyuAPPayables A
INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
GROUP BY B.strAccountId*/

SELECT * FROM (
	SELECT 
		 strAccountId
		,SUM(dblAmountDue) dblBalance
	FROM (
		SELECT
		A.intBillId
		,A.intAccountId
		,D.strAccountId
		,tmpAgingSummaryTotal.dblAmountDue
		FROM  
		(
			SELECT 
			intBillId
			,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (
				SELECT * FROM dbo.vyuAPPayables
				WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @from AND @to
			) tmpAPPayables 
			GROUP BY intBillId
			UNION ALL
			SELECT 
			intBillId
			,CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (
				SELECT * FROM dbo.vyuAPPayablesForeign
				WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @from AND @to
			) tmpAPPayables 
			GROUP BY intBillId
			UNION ALL
			SELECT 
			intBillId
			,CAST((SUM(tmpAPPayables2.dblTotal) + SUM(tmpAPPayables2.dblInterest) - SUM(tmpAPPayables2.dblAmountPaid) - SUM(tmpAPPayables2.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
			FROM (
				SELECT * FROM dbo.vyuAPPrepaidPayables
				WHERE DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @from AND @to
			) tmpAPPayables2 
			GROUP BY intBillId
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblAPBill A
		ON A.intBillId = tmpAgingSummaryTotal.intBillId
		LEFT JOIN dbo.tblGLAccount D ON  A.intAccountId = D.intAccountId
		WHERE tmpAgingSummaryTotal.dblAmountDue <> 0
		UNION ALL
		SELECT
			A.intInvoiceId
			,A.intAccountId
			,D.strAccountId
			,CAST((SUM(A.dblTotal) + SUM(A.dblInterest) - SUM(A.dblAmountPaid) - SUM(A.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
		FROM vyuAPSalesForPayables A
		LEFT JOIN dbo.vyuGLAccountDetail D ON  A.intAccountId = D.intAccountId
		WHERE D.strAccountCategory = 'AP Account' --there are old data where cash refund have been posted to non AP account
		AND DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @from AND @to
		GROUP BY A.intInvoiceId, A.intAccountId, D.strAccountId
		UNION ALL
		SELECT
			A.intBillId,
			A.intAccountId,
			D.strAccountId,
			tmpAgingSummaryTotal.dblAmountDue
		FROM  
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
					,intCount
				  FROM dbo.vyuAPPayablesAgingDeleted
			) tmpAPPayables 
			GROUP BY intBillId
			HAVING SUM(DISTINCT intCount) > 1 --DO NOT INCLUDE DELETED REPORT IF THAT IS ONLY THE PART OF DELETED DATA
		) AS tmpAgingSummaryTotal
		LEFT JOIN dbo.tblAPBillArchive A ON tmpAgingSummaryTotal.intBillId = A.intBillId
		LEFT JOIN dbo.vyuGLAccountDetail D ON  A.intAccountId = D.intAccountId
	) SubQuery
	GROUP BY 
	strAccountId
) MainQuery	

SELECT @balance = SUM(ISNULL(dblBalance, 0)) FROM #tmpAPAccountBalance

IF @balance IS NULL SET @balance = 0

INSERT INTO @log
SELECT
	'Account ' + A.strAccountId + ': ' + CAST(A.dblBalance AS NVARCHAR)
FROM #tmpAPAccountBalance A

INSERT INTO tblAPImportVoucherLog
(
	[strDescription], 
    [intEntityId], 
    [dtmDate], 
	[strLogKey]
)
SELECT 
	[strDescription], 
    @UserId, 
    @logDate, 
	@key
FROM @log

RETURN

GO

