CREATE PROCEDURE [dbo].[uspAPGLBalance]
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

DECLARE @key NVARCHAR(100) = NEWID()
DECLARE @logDate DATETIME = GETDATE()
DECLARE @from DATETIME = CASE WHEN @dateFrom IS NULL THEN '1/1/1900' ELSE @dateFrom END;
DECLARE @to DATETIME = CASE WHEN @dateTo IS NULL THEN GETDATE() ELSE @dateTo END;

SET @logKey = @key;

DECLARE @log TABLE
(
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)
DECLARE @intPayablesCategory INT, @prepaymentCategory INT;

SELECT @intPayablesCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Account'
SELECT @prepaymentCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Vendor Prepayments'

--GET THE BALANCE
IF OBJECT_ID(N'tempdb..#tmpAPGLAccountBalance') IS NOT NULL DROP TABLE #tmpAPGLAccountBalance
CREATE TABLE #tmpAPGLAccountBalance(strAccountId NVARCHAR(40), dblBalance DECIMAL(18,6))

INSERT INTO #tmpAPGLAccountBalance
SELECT
	B.strAccountId,
	--CASE WHEN A.strJournalLineDescription LIKE '%Posted%' THEN A.strTransactionId ELSE A.strJournalLineDescription END strBillId,
	SUM(ISNULL(A.dblCredit,0)) - SUM(ISNULL(A.dblDebit, 0))
	
FROM tblGLDetail A
INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
INNER JOIN vyuGLAccountDetail D ON A.intAccountId = D.intAccountId
WHERE D.intAccountCategoryId IN (@prepaymentCategory, @intPayablesCategory)
AND A.ysnIsUnposted = 0
AND DATEADD(dd, DATEDIFF(dd, 0,dtmDate), 0) BETWEEN @from AND @to
GROUP BY B.strAccountId
--,A.strJournalLineDescription,A.strTransactionId

SELECT @balance = SUM(dblBalance) FROM #tmpAPGLAccountBalance

INSERT INTO @log
SELECT
	'Account ' + A.strAccountId + ': ' + CAST(A.dblBalance AS NVARCHAR)
FROM #tmpAPGLAccountBalance A

IF @balance IS NULL SET @balance = 0

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
