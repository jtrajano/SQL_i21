CREATE FUNCTION [dbo].[fnICGetMovingAverageCost] (
	@intItemId AS INT 
	,@intItemLocation AS INT 
	,@intInventoryTransactionId INT
)
RETURNS NUMERIC(38,20)
AS
BEGIN 

	DECLARE 
		@dblQty AS NUMERIC(38, 20)
		,@dblCost AS NUMERIC(38, 20) 
		,@dblRunningQty AS NUMERIC(38, 20) 
		,@dblMovingAverageCost AS NUMERIC(38, 20) 
		,@intStockUOM AS INT 

	SELECT 
		@intStockUOM = iu.intItemUOMId
	FROM tblICItemUOM iu
	WHERE 
		iu.intItemId = @intItemId
		AND iu.ysnStockUnit = 1

	DECLARE loopOriginalAverageCost CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT 
		dblQty = dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, @intStockUOM, t.dblQty)
		,dblCost = 
			COALESCE (
				dbo.fnCalculateCostBetweenUOM(cb.intItemUOMId, @intStockUOM, cb.dblCost) -- Get any adjusted cost from the cost bucket. 
				,dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, @intStockUOM, t.dblCost)
			)
	FROM 
		tblICInventoryTransaction t LEFT JOIN tblICInventoryFIFO cb 
			ON t.intItemId = cb.intItemId
			AND t.intItemLocationId = cb.intItemLocationId
			AND t.strTransactionId = cb.strTransactionId
			AND t.intTransactionId = cb.intTransactionId
			AND t.intTransactionDetailId = cb.intTransactionDetailId
			AND cb.ysnIsUnposted = 0 
	WHERE 
		t.intItemId = @intItemId
		AND t.intItemLocationId = @intItemLocation
		AND (t.intInventoryTransactionId < @intInventoryTransactionId OR @intInventoryTransactionId IS NULL)
		AND t.ysnIsUnposted = 0 
	ORDER BY 
		t.intInventoryTransactionId ASC 

	OPEN loopOriginalAverageCost
	FETCH NEXT FROM loopOriginalAverageCost INTO 
		@dblQty 
		,@dblCost 

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @dblRunningQty = ISNULL(@dblRunningQty, 0) + @dblQty

		SET @dblMovingAverageCost = dbo.fnCalculateAverageCost(
			@dblQty
			,@dblCost
			,@dblRunningQty
			,ISNULL(@dblMovingAverageCost, 0) 
		)

		FETCH NEXT FROM loopOriginalAverageCost INTO 
			@dblQty 
			,@dblCost 
	END 

	CLOSE loopOriginalAverageCost;
	DEALLOCATE loopOriginalAverageCost;

	RETURN @dblMovingAverageCost
END 
