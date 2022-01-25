CREATE PROCEDURE uspICGetCollateralCategories
	@dtmStartDate AS DATETIME 
	,@intCategoryId AS INT 
	,@isPeriodic AS BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT OFF
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE 
	@continueLoop AS INT = 1
	,@maxLoop AS INT = 20
	,@loop AS INT = 1

IF OBJECT_ID('tempdb..#tmpCollateralItemsOverride') IS NULL  
BEGIN 
	CREATE TABLE #tmpCollateralItemsOverride (
		intItemId INT NULL 
		,intCategoryId INT NULL 
	)
END 

IF EXISTS (SELECT TOP 1 1 FROM #tmpCollateralItemsOverride)
BEGIN 
	SELECT DISTINCT 
		intItemId = NULL, c.intCategoryId
	FROM 
		#tmpCollateralItemsOverride o INNER JOIN tblICCategory c
			ON c.intCategoryId = o.intCategoryId

	RETURN 0; 
END

-- Create the temp table
IF OBJECT_ID('tempdb..#tmpCollateralCategories') IS NULL  
BEGIN 
	CREATE TABLE #tmpCollateralCategories (
		intCategoryId INT
		,lvl INT 
	)
END 

IF OBJECT_ID('tempdb..#tmpCollateralCategories') IS NOT NULL  
BEGIN 
	TRUNCATE TABLE #tmpCollateralCategories
END 

-- Anchor Query:
INSERT INTO #tmpCollateralCategories (
	intCategoryId
	,lvl
)
SELECT 
	DISTINCT 
	collateralItem.intCategoryId
	,[level] = 1
FROM 
	tblICInventoryTransaction t INNER JOIN tblICItem i 
		ON t.intItemId = i.intItemId
	INNER JOIN tblICInventoryTransactionType ty
		ON ty.intTransactionTypeId = t.intTransactionTypeId
	CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
		CASE WHEN @isPeriodic = 0 THEN t.dtmCreated ELSE t.dtmDate END
		, @dtmStartDate						
	) d
	CROSS APPLY (
		SELECT 
			i2.intCategoryId 
			,t2.strTransactionId
		FROM 
			tblICInventoryTransaction t2 INNER JOIN tblICItem i2
				ON t2.intItemId = i2.intItemId
			INNER JOIN tblICInventoryTransactionType ty2
				ON ty2.intTransactionTypeId = t2.intTransactionTypeId
		WHERE
			t2.strTransactionId = t.strTransactionId
			AND t2.ysnIsUnposted = 0 
			AND i2.intItemId <> t.intItemId
			AND t2.dblQty > 0 
			AND 1 = 
				CASE 
					WHEN 
						ty2.strName = 'Inventory Adjustment - Item Change' 
						AND t2.intTransactionDetailId = t.intTransactionDetailId 
						AND t2.strBatchId = t.strBatchId 
					THEN 
						1 
					WHEN 
						ty2.strName = 'Produce' 
					THEN 
						1 
					ELSE 
						0 
				END 
	) collateralItem
WHERE
	i.intCategoryId = @intCategoryId
	AND t.ysnIsUnposted = 0 
	AND t.dblQty < 0 
	AND ty.strName IN (
		'Inventory Adjustment - Item Change'
		,'Consume'
	)
SET @continueLoop = @@ROWCOUNT

-- Do Loop and Query the collateral categories: 
WHILE (ISNULL(@continueLoop, 0) > 0 )
BEGIN 
	INSERT INTO #tmpCollateralCategories (
		intCategoryId
		,lvl
	)
	SELECT  DISTINCT
		collateralItem.intCategoryId
		,[level] = [lvl] + 1
	FROM 
		tblICInventoryTransaction t INNER JOIN tblICItem i 
			ON t.intItemId = i.intItemId
		INNER JOIN #tmpCollateralCategories c
			ON t.intCategoryId = c.intCategoryId
		INNER JOIN tblICInventoryTransactionType ty
			ON ty.intTransactionTypeId = t.intTransactionTypeId
		CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
			CASE WHEN @isPeriodic = 0 THEN t.dtmCreated ELSE t.dtmDate END
			, @dtmStartDate						
		) d
		CROSS APPLY (
			SELECT 
				i2.intCategoryId 
				,t2.strTransactionId
			FROM 
				tblICInventoryTransaction t2 INNER JOIN tblICItem i2
					ON t2.intItemId = i2.intItemId
				INNER JOIN tblICInventoryTransactionType ty2
					ON ty2.intTransactionTypeId = t2.intTransactionTypeId				
			WHERE
				t2.strTransactionId = t.strTransactionId
				AND t2.ysnIsUnposted = 0 
				AND i2.intCategoryId <> i.intCategoryId
				AND i2.intCategoryId <> @intCategoryId
				AND t2.dblQty > 0 
				AND 1 = 
					CASE 
						WHEN 
							ty2.strName = 'Inventory Adjustment - Item Change' 
							AND t2.intTransactionDetailId = t.intTransactionDetailId 
							AND t2.strBatchId = t.strBatchId 
						THEN 
							1 
						WHEN 
							ty2.strName = 'Produce' 
						THEN 
							1 
						ELSE 
							0 
					END 
				AND NOT EXISTS (SELECT TOP  1 1 FROM #tmpCollateralCategories c WHERE c.intCategoryId = i2.intCategoryId)
		) collateralItem
	WHERE
		t.ysnIsUnposted = 0
		AND t.dblQty < 0 
		AND ty.strName IN (
			'Inventory Adjustment - Item Change'
			,'Consume'
		)		
		AND c.lvl = @loop

	SET @continueLoop = @@ROWCOUNT
	SET @loop += 1

	-- Avoid infinite loop by checking the maximum loop threshold. 
	IF @loop >= @maxLoop 
		BREAK; 
END

-- Return the collateral items 
SELECT DISTINCT 
	intItemId = NULL, c.intCategoryId
FROM 
	#tmpCollateralCategories c INNER JOIN tblICCategory cat
		ON cat.intCategoryId = c.intCategoryId
	OUTER APPLY (
		SELECT 
			dtmDate = MIN(tblSequenced.dtmDate) 
		FROM (
				SELECT 
					t.dtmDate
					,correctSeq = ROW_NUMBER() OVER (ORDER BY t.intItemId, t.dtmDate, t.intInventoryTransactionId)
					,actualSeq = ROW_NUMBER() OVER (ORDER BY t.intItemId, t.intInventoryTransactionId)
				FROM 
					tblICInventoryTransaction t INNER JOIN tblICItem i 
						ON t.intItemId = i.intItemId
				WHERE
					i.intCategoryId = cat.intCategoryId
					AND t.dblQty <> 0 
					AND t.dblValue = 0  
					AND FLOOR(CAST(t.dtmDate AS FLOAT)) >= FLOOR(CAST(@dtmStartDate AS FLOAT))
			)
			AS tblSequenced
		WHERE
			tblSequenced.correctSeq <> tblSequenced.actualSeq
	) outOfSequence
WHERE
	outOfSequence.dtmDate IS NOT NULL 