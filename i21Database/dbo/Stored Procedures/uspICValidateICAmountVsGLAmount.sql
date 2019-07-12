CREATE PROCEDURE [dbo].[uspICValidateICAmountVsGLAmount]
	@strTransactionId AS NVARCHAR(50) = NULL 
	,@strTransactionType AS NVARCHAR(500) = NULL 
	,@dtmDateFrom AS DATETIME = NULL 
	,@dtmDateTo AS DATETIME = NULL 
	,@ysnThrowError AS BIT = 0 
	,@GLEntries RecapTableType READONLY
	,@ysnPost AS BIT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @result TABLE (
	strTransactionType NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
	,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,dblICAmount NUMERIC(18, 6) NULL 
	,dblGLAmount NUMERIC(18, 6) NULL 
	,intAccountId INT NULL 
	,strItemDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
	,strAccountDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
)

-- Get the inventory value from the Inventory Valuation 
BEGIN 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		INSERT INTO @result (
			strTransactionType 
			,strTransactionId
			,strBatchId
			,dblICAmount
			,intAccountId  
			--,strItemDescription 
		)
		SELECT	
			[strTransactionType] = ty.strName
			,[strTransactionId] = t.strTransactionId
			,[strBatchId] = t.strBatchId			
			,[dblICAmount] = 
				SUM (
					ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + ISNULL(t.dblValue, 0), 2)
				)
			,[intAccountId] = glAccount.intAccountId
			--,[strItemDescription] = i.strDescription
		FROM	
			tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
				ON t.intTransactionTypeId = ty.intTransactionTypeId			
			INNER JOIN tblICItem i
				ON i.intItemId = t.intItemId 
			INNER JOIN (
				SELECT DISTINCT 
					gl.strTransactionId
					,gl.strBatchId 					
				FROM 
					@GLEntries gl
			) gl
				ON t.strTransactionId = gl.strTransactionId 
				AND t.strBatchId = gl.strBatchId
			OUTER APPLY dbo.fnGetItemGLAccountAsTable(
				t.intItemId
				,t.intItemLocationId
				,'Inventory'
			) glAccount
		WHERE	
			t.intInTransitSourceLocationId IS NULL 
		GROUP BY 
			ty.strName 
			,t.strTransactionId
			,t.strBatchId
			,glAccount.intAccountId
			--,i.strDescription
	END 
	ELSE 
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
			AND t.intInTransitSourceLocationId IS NULL 
		GROUP BY ty.strName 
	END 
END 

-- Get the inventory value from GL 
BEGIN 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		MERGE INTO @result 
		AS result
		USING (
			SELECT 
				[strTransactionType] = gd.strTransactionType
				,[strTransactionId] = gd.strTransactionId
				,[strBatchId] = gd.strBatchId
				,[intAccountId] = gd.intAccountId 
				,[dblGLAmount] = SUM(ROUND(ISNULL(dblDebit, 0) - ISNULL(dblCredit, 0),2))			
				,[strAccountDescription] = ga.strDescription
			FROM	
				@GLEntries gd INNER JOIN tblGLAccount ga
					ON gd.intAccountId = ga.intAccountId
				INNER JOIN tblGLAccountSegmentMapping gs
					ON gs.intAccountId = ga.intAccountId
				INNER JOIN tblGLAccountSegment gm
					ON gm.intAccountSegmentId = gs.intAccountSegmentId
				INNER JOIN tblGLAccountCategory ac 
					ON ac.intAccountCategoryId = gm.intAccountCategoryId 
			WHERE 
				ac.strAccountCategory IN ('Inventory')
			GROUP BY 				
				gd.strTransactionType
				,gd.strTransactionId
				,gd.strBatchId
				,gd.intAccountId 
				,ga.strDescription
		) AS glResult 
			ON 
				result.strTransactionId = glResult.strTransactionId
				AND result.strBatchId = glResult.strBatchId
				AND result.strTransactionType = glResult.strTransactionType
				AND result.intAccountId = glResult.intAccountId
				
		WHEN MATCHED THEN 
			UPDATE 
			SET 
				dblGLAmount = glResult.[dblGLAmount]
				,strAccountDescription = glResult.[strAccountDescription]

		WHEN NOT MATCHED THEN
			INSERT (
				strTransactionType 
				,strTransactionId
				,dblGLAmount
				,strAccountDescription
			)	 
			VALUES (
				glResult.[strTransactionType]
				,glResult.[strTransactionId]
				,glResult.[dblGLAmount]
				,glResult.[strAccountDescription]
			)
		;
	END 
	ELSE 
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
END

IF @ysnThrowError = 1 
	AND EXISTS (SELECT TOP 1 1 FROM @result WHERE ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0) <> 0 )
BEGIN 
	DECLARE @difference AS NUMERIC(18, 6) 
			,@strItemDescription NVARCHAR(500) 
			,@strAccountDescription NVARCHAR(500)

	SELECT TOP 1 
		@strTransactionId = ISNULL(@strTransactionId, strTransactionId) 
		,@strTransactionType = strTransactionType
		,@difference = ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0)
		,@strItemDescription = strItemDescription
		,@strAccountDescription = strAccountDescription
	FROM 
		@result
	WHERE 
		ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0) <> 0

	IF @strTransactionId IS NOT NULL 
		AND @strItemDescription IS NOT NULL 
		AND @strAccountDescription IS NOT NULL 
		AND @ysnPost IS NOT NULL 
	BEGIN 

		-- Inventory and GL mismatch in {Transaction Id}. Discrepancy of {#,##0.00} in {Item Description} does not match with {GL Account Description}. Cannot {Post|Unpost}.
		IF @ysnPost = 1 
		EXEC uspICRaiseError 80232, @strTransactionId, @difference, @strItemDescription, @strAccountDescription, 'Post'; 

		IF @ysnPost = 0 
		EXEC uspICRaiseError 80232, @strTransactionId, @difference, @strItemDescription, @strAccountDescription, 'Unpost'; 
	
		RETURN 80232
	END 

	SET @strTransactionType = ISNULL(@strTransactionType, 'Unknown type')

	-- Inventory and GL mismatch for {Transaction Id}. Discrepancy of {#,##0.00} is found for {Transaction Type}.
	EXEC uspICRaiseError 80233, @strTransactionId, @difference, @strTransactionType; 
	RETURN 80233
END

-- Else, return the result of the comparison 
ELSE 
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