
/*
	This is the stored procedure that recomputes the average cost after a cost adjustment. 
*/
CREATE PROCEDURE [dbo].[uspICRecalcAveCostOnCostAdjustment]
	@intItemId AS INT
	,@intItemLocationId AS INT 
	,@RevaluedQty AS NUMERIC(38,20)
	,@CostBucketUOMQty AS NUMERIC(38,20)
	,@dblNewCost AS NUMERIC(38,20)
	,@CostBucketCost AS NUMERIC(38,20)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
			@CurrentStockQty = dblUnitOnHand
	FROM	dbo.tblICItemStock
	WHERE	intItemId = @intItemId
			AND intItemLocationId = @intItemLocationId

	SELECT	TOP 1
			@CurrentAverageCost = dblAverageCost
	FROM	dbo.tblICItemPricing 
	WHERE	intItemId = @intItemId
			AND intItemLocationId = @intItemLocationId

	MERGE	
	INTO	dbo.tblICItemPricing 
	WITH	(HOLDLOCK) 
	AS		ItemPricing
	USING (
			SELECT	intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
					,[UnsoldQty] = dbo.fnCalculateStockUnitQty(@RevaluedQty, @CostBucketUOMQty)
					,[CostDifference] = dbo.fnCalculateUnitCost(@dblNewCost, @CostBucketUOMQty) - dbo.fnCalculateUnitCost(@CostBucketCost, @CostBucketUOMQty)
					,[CurrentStock] = @CurrentStockQty
	) AS StockToUpdate
		ON ItemPricing.intItemId = StockToUpdate.intItemId
		AND ItemPricing.intItemLocationId = StockToUpdate.intItemLocationId

	-- If matched, update the average cost, last cost, and standard cost
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblAverageCost = dbo.fnCalculateAverageCostAfterCostAdj(
					StockToUpdate.[UnsoldQty]
					,StockToUpdate.[CostDifference]
					,StockToUpdate.[CurrentStock]
					,@CurrentAverageCost
				)

	-- If none found, insert a new item pricing record
	WHEN NOT MATCHED THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,dblAverageCost 
			,dblLastCost 
			,dblStandardCost
			,intConcurrencyId
		)
		VALUES (
			StockToUpdate.intItemId
			,StockToUpdate.intItemLocationId
			,@CurrentAverageCost
			,0
			,0
			,1
		)
	;
END 