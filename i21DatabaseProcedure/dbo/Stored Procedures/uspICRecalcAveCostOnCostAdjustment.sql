
/*
	This is the stored procedure that recomputes the average cost after a cost adjustment. 
*/
CREATE PROCEDURE [dbo].[uspICRecalcAveCostOnCostAdjustment]
	@intItemId AS INT
	,@intItemLocationId AS INT 
	,@strTransactionId AS NVARCHAR(50) 
	,@strBatchId AS NVARCHAR(50)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dblAdjustValue AS NUMERIC(38,20)

-- Do not calculate if item location is an In-Transit
IF EXISTS (
	SELECT	TOP 1 1 
	FROM	tblICItemLocation 
	WHERE	intLocationId IS NULL 
			AND strDescription = 'In-Transit' 
			AND intItemLocationId = @intItemLocationId
)
BEGIN
	RETURN 0;
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Update the average cost 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	DECLARE @CurrentStockQty AS NUMERIC(38,20)
			,@CurrentAverageCost AS NUMERIC(38,20)

	SELECT TOP 1 
			@CurrentStockQty = ISNULL(dblUnitOnHand, 0)
	FROM	dbo.tblICItemStock
	WHERE	intItemId = @intItemId
			AND intItemLocationId = @intItemLocationId

	SELECT	TOP 1
			@CurrentAverageCost = ISNULL(dblAverageCost, 0)
	FROM	dbo.tblICItemPricing 
	WHERE	intItemId = @intItemId
			AND intItemLocationId = @intItemLocationId

	SELECT	@dblAdjustValue = SUM(dblValue) 
	FROM	tblICInventoryTransaction t
	WHERE	t.strTransactionId = @strTransactionId
			AND t.strBatchId = @strBatchId
			AND t.ysnIsUnposted = 0 

	MERGE	
	INTO	dbo.tblICItemPricing 
	WITH	(HOLDLOCK) 
	AS		ItemPricing
	USING (
			SELECT	intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
					,dblCurrentStockValue = dbo.fnMultiply(@CurrentStockQty, @CurrentAverageCost) 
					,dblNewAverageCost = 
							dbo.fnDivide(
								dbo.fnMultiply(@CurrentStockQty, @CurrentAverageCost) + ISNULL(@dblAdjustValue, 0)
								,@CurrentStockQty
							)
	) AS StockToUpdate
		ON ItemPricing.intItemId = StockToUpdate.intItemId
		AND ItemPricing.intItemLocationId = StockToUpdate.intItemLocationId

	-- If matched, recalculate the average cost
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblAverageCost = StockToUpdate.dblNewAverageCost --CASE WHEN @CurrentStockQty <=0 THEN @CurrentAverageCost ELSE StockToUpdate.dblNewAverageCost END 
				,ysnIsPendingUpdate = 1

	-- If none found, insert a new item pricing record
	WHEN NOT MATCHED THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,dblAverageCost 
			,dblLastCost 
			,dblStandardCost
			,ysnIsPendingUpdate
			,intConcurrencyId
		)
		VALUES (
			StockToUpdate.intItemId
			,StockToUpdate.intItemLocationId
			,@CurrentAverageCost
			,0
			,0
			,1
			,1
		)
	;

	-- Update the item pricing because of the new average cost. 
	EXEC uspICUpdateItemPricing
		@intItemId
		,@intItemLocationId
END 