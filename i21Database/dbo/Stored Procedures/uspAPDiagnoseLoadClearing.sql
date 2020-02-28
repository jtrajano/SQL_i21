CREATE PROCEDURE [dbo].[uspAPDiagnoseLoadClearing]
	@account INT = NULL,
	@dateStart DATETIME = NULL,
	@dateEnd DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @start DATETIME = CASE WHEN @dateStart IS NOT NULL THEN @dateStart ELSE '1/1/1900' END
DECLARE @end DATETIME = CASE WHEN @dateEnd IS NOT NULL THEN @dateEnd ELSE GETDATE() END

DECLARE @loadGLTotal TABLE(strLoadNumber NVARCHAR(50), dblTotal DECIMAL(18,2));
;WITH loadGLTotal (
	strLoadNumber,
	dblTotal
)
AS (
	SELECT
		strTransactionId,
		SUM(dblCredit - dblDebit) AS dblTotal
	FROM tblGLDetail A
	INNER JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
	WHERE 
		A.ysnIsUnposted = 0
	AND B.intAccountCategoryId = 45
	AND A.strModuleName = 'Logistics'
	GROUP BY A.strTransactionId
	-- AND A.strTransactionId = 'LS-1828'
)

INSERT INTO @loadGLTotal
SELECT * FROM loadGLTotal

DECLARE @loadTotal TABLE(strLoadNumber NVARCHAR(50), dblTotal DECIMAL(18,2));
;WITH loadTotal (
	strLoadNumber,
	dblTotal
)
AS (
	SELECT
		strLoadNumber,
		SUM(dblTotal) AS dblTotal
	FROM
	(
		SELECT
			A.strLoadNumber
			,ISNULL(B.dblAmount,0) AS dblTotal
		FROM tblLGLoad A
		INNER JOIN tblLGLoadDetail B
			ON A.intLoadId = B.intLoadId
		WHERE 
			A.ysnPosted = 1 
		AND A.intPurchaseSale IN (1,3) --Inbound/Drop Ship load shipment type only have AP Clearing GL Entries.
		AND A.intSourceType != 1 --Source Type should not be 'None'
		UNION ALL --COST
		SELECT
			A.strLoadNumber
			,C.dblAmount AS dblTotal
		FROM tblLGLoad A
		INNER JOIN tblLGLoadDetail B
			ON A.intLoadId = B.intLoadId
		INNER JOIN tblLGLoadCost C
			ON A.intLoadId = C.intLoadId
		WHERE 
			A.ysnPosted = 1 
		AND A.intPurchaseSale = 2 --Outbound type is the only type that have AP Clearing for cost, this is also driven by company config
		AND C.ysnAccrue = 1
	) tmpLoad
	GROUP BY strLoadNumber
)

INSERT INTO @loadTotal
SELECT * FROM loadTotal

SELECT
	A.strLoadNumber,
	A.dblTotal AS dblGLLoadTotal,
	B.dblTotal AS dblLoadTotal
FROM @loadGLTotal A
INNER JOIN @loadTotal B ON A.strLoadNumber = B.strLoadNumber
