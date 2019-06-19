CREATE PROCEDURE [dbo].[uspICValidateICAmountVsGLAmount]
	@strTransactionId AS NVARCHAR(50) = NULL 
	,@strTransactionType AS NVARCHAR(500) = NULL 
	,@dtmDateFrom AS DATETIME = NULL 
	,@dtmDateTo AS DATETIME = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


DECLARE @result TABLE (
	strTransactionType NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
	,dblICAmount NUMERIC(18, 6) NULL 
	,dblGLAmount NUMERIC(18, 6) NULL 
)

-- Get the inventory value from the Inventory Valuation 
BEGIN 
	INSERT INTO @result (
		strTransactionType 
		,dblICAmount
	)
	SELECT	
		[strTransactionType] = ty.strName
		,[dblICAmount] = 
			SUM (
				ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + ISNULL(t.dblValue, 0), 2)
			)
	FROM	
		tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
			ON t.intTransactionTypeId = ty.intTransactionTypeId			
	WHERE	
		(t.strTransactionId = @strTransactionId OR @strTransactionId IS NULL) 
		AND (ty.strName = @strTransactionType OR @strTransactionType IS NULL) 
		AND (dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmDateFrom) = 1 OR @dtmDateFrom IS NULL)
		AND (dbo.fnDateLessThanEquals(t.dtmDate, @dtmDateTo) = 1 OR @dtmDateTo IS NULL)
		AND t.ysnIsUnposted = 0 
		AND t.intInTransitSourceLocationId IS NULL 
	GROUP BY ty.strName 
END 
 
-- Get the inventory value from GL 
BEGIN 
	MERGE INTO @result 
	AS result
	USING (
		SELECT 
			[strTransactionType] = gd.strTransactionType
			,[dblGLAmount] = SUM(ROUND(ISNULL(dblDebit, 0) - ISNULL(dblCredit, 0),2))			
		FROM	
			tblGLDetail gd INNER JOIN tblGLAccount ga
				ON gd.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegmentMapping gs
				ON gs.intAccountId = ga.intAccountId
			INNER JOIN tblGLAccountSegment gm
				ON gm.intAccountSegmentId = gs.intAccountSegmentId
			INNER JOIN tblGLAccountCategory ac 
				ON ac.intAccountCategoryId = gm.intAccountCategoryId 
		WHERE 
			(gd.strTransactionId = @strTransactionId OR @strTransactionId IS NULL) 
			AND (gd.strTransactionType = @strTransactionType OR @strTransactionType IS NULL) 
			AND (dbo.fnDateGreaterThanEquals(gd.dtmDate, @dtmDateFrom) = 1 OR @dtmDateFrom IS NULL)
			AND (dbo.fnDateLessThanEquals(gd.dtmDate, @dtmDateTo) = 1 OR @dtmDateTo IS NULL)
			AND ac.strAccountCategory IN ('Inventory')
			AND gd.ysnIsUnposted = 0 
		GROUP BY 
			gd.strTransactionType
	) AS glResult 
		ON result.strTransactionType = glResult.strTransactionType
	WHEN MATCHED THEN 
		UPDATE 
		SET dblGLAmount = glResult.[dblGLAmount]
	WHEN NOT MATCHED THEN
		INSERT (
			strTransactionType 
			,dblGLAmount
		)	 
		VALUES (
			glResult.[strTransactionType]
			,glResult.[dblGLAmount]
		)
	;
END

-- Return the result of the comparison 
BEGIN 
	SELECT 
		strTransactionType
		,[dblICAmount] = ISNULL(dblICAmount, 0)
		,[dblGLAmount] = ISNULL(dblGLAmount, 0)
		--,[difference] = ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0)
	FROM @result
	WHERE 
		ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0) <> 0 
END 