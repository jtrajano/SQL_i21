CREATE PROCEDURE [dbo].[uspAPBalance]
	@balance DECIMAL(18,6) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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

IF EXISTS(SELECT 1 FROM #tmpAPAccountBalance)
SELECT @balance = SUM(ISNULL(dblBalance, 0)) FROM #tmpAPAccountBalance
ELSE
SET @balance = 0

SELECT * FROM #tmpAPAccountBalance

RETURN
