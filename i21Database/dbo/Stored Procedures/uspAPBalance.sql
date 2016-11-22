CREATE PROCEDURE [dbo].[uspAPBalance]
	@UserId INT,
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
DECLARE @intPayablesCategory INT
DECLARE @accountId NVARCHAR(40);

SET @logKey = @key;

DECLARE @log TABLE
(
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)

SELECT @intPayablesCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'AP Account'

SELECT TOP 1 @accountId = strAccountId FROM vyuGLAccountDetail WHERE intAccountCategoryId = @intPayablesCategory

--GET THE BALANCE
IF OBJECT_ID(N'tempdb..#tmpAPAccountBalance') IS NOT NULL DROP TABLE #tmpAPAccountBalance
CREATE TABLE #tmpAPAccountBalance(strAccountId NVARCHAR(40), dblBalance DECIMAL(18,6))

INSERT INTO #tmpAPAccountBalance
SELECT @accountId, SUM(dblAmountDue) FROM(
	SELECT 
	CAST((SUM(tmpAPPayables.dblTotal) + SUM(tmpAPPayables.dblInterest) - SUM(tmpAPPayables.dblAmountPaid) - SUM(tmpAPPayables.dblDiscount)) AS DECIMAL(18,2)) AS dblAmountDue
	FROM (
		SELECT 
				intBillId
				,dblTotal
				,dblAmountDue
				,dblAmountPaid
				,dblDiscount
				,dblInterest
				,dtmDate
				FROM dbo.vyuAPPayables A
			) tmpAPPayables 
	GROUP BY intBillId
) AS tmpAgingSummaryTotal

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
