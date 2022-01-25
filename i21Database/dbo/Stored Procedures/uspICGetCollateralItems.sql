CREATE PROCEDURE uspICGetCollateralItems
	@dtmStartDate AS DATETIME 
	,@intItemId AS INT 
	,@isPeriodic AS BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT OFF
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

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
		c.intItemId, intCategoryId = NULL 
	FROM 
		#tmpCollateralItemsOverride c INNER JOIN tblICItem i 
			ON c.intItemId = i.intItemId

	RETURN 0; 
END 

-- Create the temp table
IF OBJECT_ID('tempdb..#tmpCollateralItems') IS NULL  
BEGIN 
	CREATE TABLE #tmpCollateralItems (
		intItemId INT
		,lvl INT 
	)
END 

IF OBJECT_ID('tempdb..#tmpCollateralItems') IS NOT NULL  
BEGIN 
	TRUNCATE TABLE #tmpCollateralItems
END 

-- Anchor Query:
INSERT INTO #tmpCollateralItems (
	intItemId
	,lvl
)
SELECT 
	DISTINCT 
	collateralItem.intItemId
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
			i2.strItemNo
			,i2.intItemId 
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
	i.intItemId = @intItemId
	AND t.ysnIsUnposted = 0 
	AND t.dblQty < 0 
	AND ty.strName IN (
		'Inventory Adjustment - Item Change'
		,'Consume'
	)
SET @continueLoop = @@ROWCOUNT

-- Do Loop and Query the collateral items: 
WHILE (ISNULL(@continueLoop, 0) > 0 )
BEGIN 
	INSERT INTO #tmpCollateralItems (
		intItemId
		,lvl
	)
	SELECT  DISTINCT
		collateralItem.intItemId
		,[level] = [lvl] + 1
	FROM 
		tblICInventoryTransaction t INNER JOIN tblICItem i 
			ON t.intItemId = i.intItemId
		INNER JOIN #tmpCollateralItems c
			ON t.intItemId = c.intItemId
		INNER JOIN tblICInventoryTransactionType ty
			ON ty.intTransactionTypeId = t.intTransactionTypeId
		CROSS APPLY [dbo].[udfDateGreaterThanEquals] (
			CASE WHEN @isPeriodic = 0 THEN t.dtmCreated ELSE t.dtmDate END
			, @dtmStartDate						
		) d
		CROSS APPLY (
			SELECT 
				i2.strItemNo
				,i2.intItemId 
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
				AND i2.intItemId <> @intItemId				
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
				AND NOT EXISTS (SELECT TOP  1 1 FROM #tmpCollateralItems c WHERE c.intItemId = i2.intItemId)
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
-- Only collateral items that is out of sequence will be returned. 
SELECT DISTINCT 
	i.intItemId, intCategoryId = NULL 
FROM 
	#tmpCollateralItems c INNER JOIN tblICItem i 
		ON c.intItemId = i.intItemId
	OUTER APPLY (
		SELECT 
			dtmDate = MIN(tblSequenced.dtmDate) 
		FROM (
				SELECT 
					t.dtmDate
					,correctSeq = ROW_NUMBER() OVER (ORDER BY t.intItemId, t.dtmDate, t.intInventoryTransactionId)
					,actualSeq = ROW_NUMBER() OVER (ORDER BY t.intItemId, t.intInventoryTransactionId)
				FROM 
					tblICInventoryTransaction t 
				WHERE
					t.intItemId = i.intItemId
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