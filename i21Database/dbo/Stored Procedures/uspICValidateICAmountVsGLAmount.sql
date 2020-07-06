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

-- Create the temp table for the specific items/categories to rebuild
IF OBJECT_ID('tempdb..#uspICValidateICAmountVsGLAmount_result') IS NOT NULL  
BEGIN 
	DROP TABLE #uspICValidateICAmountVsGLAmount_result
END 

IF OBJECT_ID('tempdb..#uspICValidateICAmountVsGLAmount_result') IS NULL  
BEGIN 
	CREATE TABLE #uspICValidateICAmountVsGLAmount_result (
		intId INT IDENTITY(1, 1) 
		,strTransactionType NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
		,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dblICAmount NUMERIC(18, 6) NULL 
		,dblGLAmount NUMERIC(18, 6) NULL 
		,intAccountId INT NULL 
		,strItemDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
		,strAccountDescription NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
	)

	--CREATE NONCLUSTERED INDEX [IX_ValidateICAmountVsGLAmount_result]
	--	ON [dbo].[#uspICValidateICAmountVsGLAmount_result](strTransactionType asc, strTransactionId asc, strBatchId asc, intAccountId asc)
END 

DECLARE @glTransactions TABLE (
	strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)

INSERT INTO @glTransactions (
	strTransactionId
	,strBatchId
)
SELECT DISTINCT 
	gl.strTransactionId
	,gl.strBatchId 					
FROM 
	@GLEntries gl

IF @strTransactionId IS NOT NULL AND NOT EXISTS (SELECT TOP 1 1 FROM @glTransactions) 
BEGIN 
	INSERT INTO @glTransactions (
		strTransactionId
		,strBatchId
	)
	SELECT DISTINCT 
		gd.strTransactionId
		,gd.strBatchId 					
	FROM 
		tblGLDetail gd
	WHERE 
		gd.strTransactionId = @strTransactionId
END 

DECLARE @strBatchId AS NVARCHAR(50) = NULL 

-- Get the transaction id if @GLEntries is processing only one transaction 
IF EXISTS (SELECT COUNT(1) FROM (SELECT DISTINCT strTransactionId FROM @GLEntries) N_GLEntries HAVING COUNT(1) = 1)
BEGIN 
	SELECT TOP 1 
		@strTransactionId = strTransactionId 
		,@strBatchId = strBatchId
	FROM @GLEntries
END 

-- Validate the account ids. 
IF EXISTS (
	SELECT TOP 1 1 
	FROM tblICInventoryTransaction t INNER JOIN @glTransactions gl
		ON t.strTransactionId = gl.strTransactionId 
		AND t.strBatchId = gl.strBatchId 
	WHERE	
		t.intInTransitSourceLocationId IS NULL 
)
BEGIN 
	DECLARE @strAccountCategory AS NVARCHAR(50)
	DECLARE @strItemNo AS NVARCHAR(50)

	-- Check the 'Inventory' Account
	SELECT 
		TOP 1 
		@strAccountCategory = ac.strAccountCategory
		,@strItemNo = i.strItemNo
		,@strAccountCategory = ac.strAccountCategory
	FROM	
		tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
			ON t.intTransactionTypeId = ty.intTransactionTypeId			
		INNER JOIN tblICItem i
			ON i.intItemId = t.intItemId 
		INNER JOIN @glTransactions gl
			ON t.strTransactionId = gl.strTransactionId 
			AND t.strBatchId = gl.strBatchId
		INNER JOIN tblGLAccount ga
			ON ga.intAccountId = dbo.fnGetItemGLAccount(t.intItemId, t.intItemLocationId, 'Inventory')
		INNER JOIN tblGLAccountSegmentMapping gs
			ON gs.intAccountId = ga.intAccountId
		INNER JOIN tblGLAccountSegment gm
			ON gm.intAccountSegmentId = gs.intAccountSegmentId
		INNER JOIN tblGLAccountCategory ac 
			ON ac.intAccountCategoryId = gm.intAccountCategoryId 	
		INNER JOIN tblGLAccountStructure gst
			ON gm.intAccountStructureId = gst.intAccountStructureId
	WHERE
		gst.strType = 'Primary'
		AND ac.strAccountCategory NOT IN ('Inventory')
		AND t.intInTransitSourceLocationId IS NULL 

	IF @strAccountCategory IS NOT NULL AND @strItemNo IS NOT NULL AND @ysnThrowError = 1 
	BEGIN 
		-- 'Inventory Account is set to <Category> for item <Item No>.'
		EXEC uspICRaiseError 80250, @strAccountCategory, @strItemNo
		RETURN 80250
	END 
	
	---- Check the 'Work In Progress' Account
	--SELECT 
	--	TOP 1 
	--	@strAccountCategory = ac.strAccountCategory
	--	,@strItemNo = i.strItemNo
	--FROM	
	--	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
	--		ON t.intTransactionTypeId = ty.intTransactionTypeId			
	--	INNER JOIN tblICItem i
	--		ON i.intItemId = t.intItemId 
	--	INNER JOIN @glTransactions gl
	--		ON t.strTransactionId = gl.strTransactionId 
	--		AND t.strBatchId = gl.strBatchId
	--	INNER JOIN tblGLAccount ga
	--		ON ga.intAccountId = dbo.fnGetItemGLAccount(t.intItemId, t.intItemLocationId, 'Work In Progress')
	--	INNER JOIN tblGLAccountSegmentMapping gs
	--		ON gs.intAccountId = ga.intAccountId
	--	INNER JOIN tblGLAccountSegment gm
	--		ON gm.intAccountSegmentId = gs.intAccountSegmentId
	--	INNER JOIN tblGLAccountCategory ac 
	--		ON ac.intAccountCategoryId = gm.intAccountCategoryId 	
	--	INNER JOIN tblGLAccountStructure gst
	--		ON gm.intAccountStructureId = gst.intAccountStructureId
	--WHERE
	--	gst.strType = 'Primary'
	--	AND ac.strAccountCategory NOT IN ('Work In Progress')
	--	AND t.intInTransitSourceLocationId IS NULL 
	--	AND ty.strName IN ('Consume', 'Produce')

	--IF @strAccountCategory IS NOT NULL AND @strItemNo IS NOT NULL AND @ysnThrowError = 1 
	--BEGIN 
	--	-- 'Inventory Account is set to <Account Id> for item <Item No>.'
	--	-- 'Work In Progress Account is set to <Account Id> for item <Item No>.'
	--	EXEC uspICRaiseError 80251, @strAccountCategory, @strItemNo
	--	RETURN 80251
	--END 
END 

-- Get the inventory value from the Inventory Valuation 
BEGIN 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		INSERT INTO #uspICValidateICAmountVsGLAmount_result (
			strTransactionType 
			,strTransactionId
			,strBatchId
			,dblICAmount
			,intAccountId  
		)
		SELECT	
			[strTransactionType] = ty.strName
			,[strTransactionId] = t.strTransactionId
			,[strBatchId] = t.strBatchId			
			,[dblICAmount] = 
				SUM (
					ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + ISNULL(t.dblValue, 0), 2)
				)
			,[intAccountId] = dbo.fnGetItemGLAccount(t.intItemId, t.intItemLocationId, 'Inventory')
		FROM	
			tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
				ON t.intTransactionTypeId = ty.intTransactionTypeId			
			INNER JOIN tblICItem i
				ON i.intItemId = t.intItemId 
			INNER JOIN @glTransactions gl
				ON t.strTransactionId = gl.strTransactionId 
				AND t.strBatchId = gl.strBatchId
		WHERE	
			t.intInTransitSourceLocationId IS NULL 
		GROUP BY 
			ty.strName 
			,t.strTransactionId
			,t.strBatchId
			,dbo.fnGetItemGLAccount(t.intItemId, t.intItemLocationId, 'Inventory')

		---- Get the Consume Inventory Transactions 
		--INSERT INTO #uspICValidateICAmountVsGLAmount_result (
		--	strTransactionType 
		--	,strTransactionId
		--	,strBatchId
		--	,dblICAmount
		--	,intAccountId  
		--)
		--SELECT	
		--	[strTransactionType] = ty.strName
		--	,[strTransactionId] = t.strTransactionId
		--	,[strBatchId] = t.strBatchId			
		--	,[dblICAmount] = 
		--		SUM (
		--			-ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + ISNULL(t.dblValue, 0), 2)
		--		)
		--	,[intAccountId] = icGLAccount.intWIPAccountId
		--FROM	
		--	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
		--		ON t.intTransactionTypeId = ty.intTransactionTypeId			
		--	INNER JOIN tblICItem i
		--		ON i.intItemId = t.intItemId 
		--	INNER JOIN @glTransactions gl
		--		ON t.strTransactionId = gl.strTransactionId 
		--		AND t.strBatchId = gl.strBatchId
		--	INNER JOIN @icGLAccounts icGLAccount
		--		ON icGLAccount.intItemId = t.intItemId
		--		AND icGLAccount.intItemLocationId = t.intItemLocationId
		--WHERE	
		--	t.intInTransitSourceLocationId IS NULL 
		--	AND ty.strName IN ('Consume', 'Produce')
		--GROUP BY 
		--	ty.strName 
		--	,t.strTransactionId
		--	,t.strBatchId
		--	,icGLAccount.intWIPAccountId

		---- Get the Produce Inventory Transactions 
		--INSERT INTO #uspICValidateICAmountVsGLAmount_result (
		--	strTransactionType 
		--	,strTransactionId
		--	,strBatchId
		--	,dblICAmount
		--	,intAccountId  
		--)
		--SELECT	
		--	[strTransactionType] = ty.strName
		--	,[strTransactionId] = t.strTransactionId
		--	,[strBatchId] = t.strBatchId			
		--	,[dblICAmount] = 
		--		SUM (
		--			-ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + ISNULL(t.dblValue, 0), 2)
		--		)
		--	,[intAccountId] = dbo.fnGetItemGLAccount(t.intItemId, t.intItemLocationId, 'Work In Progress')
		--FROM	
		--	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
		--		ON t.intTransactionTypeId = ty.intTransactionTypeId			
		--	INNER JOIN tblICItem i
		--		ON i.intItemId = t.intItemId 
		--	INNER JOIN (
		--		SELECT DISTINCT 
		--			gl.strTransactionId
		--			,gl.strBatchId 					
		--		FROM 
		--			@GLEntries gl
		--	) gl
		--		ON t.strTransactionId = gl.strTransactionId 
		--		AND t.strBatchId = gl.strBatchId
		--WHERE	
		--	t.intInTransitSourceLocationId IS NULL 
		--	AND ty.strName IN ('Produce')
		--GROUP BY 
		--	ty.strName 
		--	,t.strTransactionId
		--	,t.strBatchId
		--	,dbo.fnGetItemGLAccount(t.intItemId, t.intItemLocationId, 'Work In Progress')
		-- Get the Cost Adjustment from MFG. 
		--UNION ALL 
		--SELECT	
		--	[strTransactionType] = ty.strName
		--	,[strTransactionId] = t.strTransactionId
		--	,[strBatchId] = t.strBatchId			
		--	,[dblICAmount] = 
		--		SUM (
		--			-ROUND(dbo.fnMultiply(t.dblQty, t.dblCost) + ISNULL(t.dblValue, 0), 2)
		--		)
		--	,[intAccountId] = glAccount.intAccountId
		--FROM	
		--	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
		--		ON t.intTransactionTypeId = ty.intTransactionTypeId			
		--	INNER JOIN tblICItem i
		--		ON i.intItemId = t.intItemId 
		--	INNER JOIN (
		--		SELECT DISTINCT 
		--			gl.strTransactionId
		--			,gl.strBatchId 					
		--		FROM 
		--			@GLEntries gl
		--	) gl
		--		ON t.strTransactionId = gl.strTransactionId 
		--		AND t.strBatchId = gl.strBatchId
		--	OUTER APPLY dbo.fnGetItemGLAccountAsTable(
		--		t.intItemId
		--		,t.intItemLocationId
		--		,'Work In Progress'
		--	) glAccount
		--WHERE	
		--	t.intInTransitSourceLocationId IS NULL 
		--	AND ty.strName IN ('Cost Adjustment')
		--	AND t.strTransactionForm IN ('Consume', 'Produce')
		--GROUP BY 
		--	ty.strName 
		--	,t.strTransactionId
		--	,t.strBatchId
		--	,glAccount.intAccountId
		--SELECT * FROM @GLEntries
	END 
	ELSE 
	BEGIN 
		INSERT INTO #uspICValidateICAmountVsGLAmount_result (
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
			INNER JOIN @glTransactions gl
				ON t.strTransactionId = gl.strTransactionId 
				AND t.strBatchId = gl.strBatchId					
		WHERE	
			(ty.strName = @strTransactionType OR @strTransactionType IS NULL) 
			AND (dbo.fnDateGreaterThanEquals(t.dtmDate, @dtmDateFrom) = 1 OR @dtmDateFrom IS NULL)
			AND (dbo.fnDateLessThanEquals(t.dtmDate, @dtmDateTo) = 1 OR @dtmDateTo IS NULL)
			AND t.intInTransitSourceLocationId IS NULL 
		GROUP BY ty.strName 
	END 
END 


-- Get the inventory value from GL 
BEGIN 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	AND EXISTS (
			SELECT TOP 1 1 
			FROM 
				tblGLDetail gd INNER JOIN @glTransactions list
					ON gd.strTransactionId = list.strTransactionId
					AND gd.strBatchId = list.strBatchId
			WHERE 
				(gd.ysnIsUnposted = 0 AND ISNULL(@ysnPost, 0) = 1)				
		) 
	BEGIN 		
		MERGE INTO #uspICValidateICAmountVsGLAmount_result 
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
				1 = 
					CASE 
						WHEN gd.strTransactionType = 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory') THEN 1 
						--WHEN gd.strTransactionType <> 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory', 'Work In Progress') THEN 1 
						WHEN gd.strTransactionType <> 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory') THEN 1 
						WHEN gd.strTransactionType = 'Storage Settlement' AND ac.strAccountCategory IN ('Inventory') THEN 1 

						ELSE 0 
					END 
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
				dblGLAmount = ISNULL(result.dblGLAmount, 0) + ISNULL(glResult.[dblGLAmount], 0)

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

		MERGE INTO #uspICValidateICAmountVsGLAmount_result 
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
				tblGLDetail gd INNER JOIN tblGLAccount ga
					ON gd.intAccountId = ga.intAccountId
				INNER JOIN tblGLAccountSegmentMapping gs
					ON gs.intAccountId = ga.intAccountId
				INNER JOIN tblGLAccountSegment gm
					ON gm.intAccountSegmentId = gs.intAccountSegmentId
				INNER JOIN tblGLAccountCategory ac 
					ON ac.intAccountCategoryId = gm.intAccountCategoryId 
				INNER JOIN @glTransactions list
					ON gd.strTransactionId = list.strTransactionId
					AND gd.strBatchId = list.strBatchId
			WHERE 
				(gd.strTransactionType = @strTransactionType OR @strTransactionType IS NULL) 
				AND (dbo.fnDateGreaterThanEquals(gd.dtmDate, @dtmDateFrom) = 1 OR @dtmDateFrom IS NULL)
				AND (dbo.fnDateLessThanEquals(gd.dtmDate, @dtmDateTo) = 1 OR @dtmDateTo IS NULL)
				AND gd.ysnIsUnposted = 0 
				AND 1 = 
					CASE 
						WHEN gd.strTransactionType = 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory') THEN 1 
						--WHEN gd.strTransactionType <> 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory', 'Work In Progress') THEN 1 
						WHEN gd.strTransactionType <> 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory') THEN 1 
						WHEN gd.strTransactionType = 'Storage Settlement' AND ac.strAccountCategory IN ('Inventory') THEN 1 
						ELSE 0 
					END 
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
				dblGLAmount = ISNULL(result.dblGLAmount, 0) + ISNULL(glResult.[dblGLAmount], 0)

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
	ELSE IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		MERGE INTO #uspICValidateICAmountVsGLAmount_result 
		AS result
		USING (
			SELECT 
				[strTransactionType] = 
						CASE 
							WHEN gd.strTransactionType = 'Inventory Adjustment' THEN 'Inventory Auto Variance'
							ELSE gd.strTransactionType
						END COLLATE Latin1_General_CI_AS
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
				1 = 
					CASE 
						WHEN gd.strTransactionType = 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory') THEN 1 
						--WHEN gd.strTransactionType <> 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory', 'Work In Progress') THEN 1 
						WHEN gd.strTransactionType <> 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory') THEN 1 
						WHEN gd.strTransactionType = 'Storage Settlement' AND ac.strAccountCategory IN ('Inventory') THEN 1 
						ELSE 0 
					END 

			GROUP BY 				
				CASE 
					WHEN gd.strTransactionType = 'Inventory Adjustment' THEN 'Inventory Auto Variance'
					ELSE gd.strTransactionType
				END COLLATE Latin1_General_CI_AS
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
				dblGLAmount = ROUND(ISNULL(result.dblGLAmount, 0) + ISNULL(glResult.[dblGLAmount], 0), 2) 

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
		MERGE INTO #uspICValidateICAmountVsGLAmount_result 
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
				INNER JOIN @glTransactions list
					ON gd.strTransactionId = list.strTransactionId
					AND gd.strBatchId = list.strBatchId
			WHERE 
				(gd.strTransactionType = @strTransactionType OR @strTransactionType IS NULL) 
				AND (dbo.fnDateGreaterThanEquals(gd.dtmDate, @dtmDateFrom) = 1 OR @dtmDateFrom IS NULL)
				AND (dbo.fnDateLessThanEquals(gd.dtmDate, @dtmDateTo) = 1 OR @dtmDateTo IS NULL)
				AND 1 = 
					CASE 
						WHEN gd.strTransactionType = 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory') THEN 1 
						--WHEN gd.strTransactionType <> 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory', 'Work In Progress') THEN 1 
						WHEN gd.strTransactionType <> 'Cost Adjustment' AND ac.strAccountCategory IN ('Inventory') THEN 1 
						WHEN gd.strTransactionType = 'Storage Settlement' AND ac.strAccountCategory IN ('Inventory') THEN 1 
						ELSE 0 
					END 

			GROUP BY 
				gd.strTransactionType
		) AS glResult 
			ON result.strTransactionType = glResult.strTransactionType
		WHEN MATCHED THEN 
			UPDATE 
			SET 
				dblGLAmount = ROUND(ISNULL(result.dblGLAmount, 0) + ISNULL(glResult.[dblGLAmount], 0), 2) 
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
	AND EXISTS (
		SELECT TOP 1 
			SUM(ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0))
		FROM 
			#uspICValidateICAmountVsGLAmount_result 
		GROUP BY
			intAccountId
		HAVING 
			SUM(ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0)) <> 0 
	)
BEGIN

	/** for debugging purposes
	select 
		't'
		,t.intInventoryTransactionId
		,t.strTransactionId
		,t.strBatchId
		,t.dtmDate
		,v = round(dbo.fnMultiply(t.dblQty, t.dblCost) + t.dblValue, 2) 
		,t.dblQty
		,t.dblCost
		,t.dblValue
		,t.strDescription
		,t.ysnIsUnposted
		,t.intTransactionTypeId
	from 
		tblICInventoryTransaction t 
	where 
		t.strTransactionId = @strTransactionId
	order by
		t.intInventoryTransactionId
	
	select 
		'gd'
		,gd.intJournalLineNo
		,gd.strTransactionId
		,gd.strBatchId
		,gd.dtmDate
		,gd.dblDebit
		,gd.dblCredit	
	from tblGLDetail gd 
	where gd.strTransactionId = @strTransactionId
	order by gd.intJournalLineNo

	select 
		'@GLEntries'
		,gd.intJournalLineNo
		,gd.strTransactionId
		,gd.strBatchId
		,gd.dtmDate
		,gd.dblDebit
		,gd.dblCredit	
	from @GLEntries gd 
	where gd.strTransactionId = @strTransactionId
	order by gd.intJournalLineNo
	**/
 
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
		#uspICValidateICAmountVsGLAmount_result
	WHERE 
		ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0) <> 0
	SELECT * FROM #uspICValidateICAmountVsGLAmount_result
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
ELSE IF @ysnThrowError = 0 
BEGIN 
	SELECT 
		strTransactionType
		,[dblICAmount] = ISNULL(dblICAmount, 0)
		,[dblGLAmount] = ISNULL(dblGLAmount, 0)
		--,[difference] = ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0)
	FROM #uspICValidateICAmountVsGLAmount_result
	WHERE 
		ISNULL(dblICAmount, 0) - ISNULL(dblGLAmount, 0) <> 0 
END
