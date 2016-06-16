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
SET @logKey = @key;

DECLARE @log TABLE
(
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)

--GET THE BALANCE
IF OBJECT_ID(N'tempdb..#tmpAPAccountBalance') IS NOT NULL DROP TABLE #tmpAPAccountBalance
CREATE TABLE #tmpAPAccountBalance(strAccountId NVARCHAR(40), dblBalance DECIMAL(18,6))

INSERT INTO #tmpAPAccountBalance
SELECT
	B.strAccountId,
	SUM(A.dblTotal) + SUM(A.dblInterest) - SUM(A.dblAmountPaid) - SUM(A.dblDiscount) AS dblBalance
FROM vyuAPPayables A
INNER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
GROUP BY B.strAccountId

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
