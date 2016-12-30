
-- Retrieves the cost of the item from the cost bucket 
CREATE FUNCTION [dbo].[fnGetCostFromCostBucket](
	@intItemId INT
	,@intItemLocationId INT
	,@intItemUOMId AS INT 
	,@intLotId INT 	-- If @intLotId is null, it will get the cost from the first lot record received for the line item. 
	,@strTransactionId AS NVARCHAR(50)
	,@intTransactionId AS INT 
	,@intTransactionDetailId AS INT 
	,@strActualCostId AS NVARCHAR(50) 
)
RETURNS NUMERIC(38, 20)
AS 
BEGIN 
	DECLARE @AVERAGECOST AS INT = 1
			,@FIFO AS INT = 2
			,@LIFO AS INT = 3
			,@LOTCOST AS INT = 4 	
			,@ACTUALCOST AS INT = 5	

	DECLARE	@intCostingMethod AS INT 
			,@dblCost AS NUMERIC(38, 20)

	SELECT @intCostingMethod = dbo.fnGetCostingMethod(@intItemId, @intItemLocationId) 

	SELECT	@dblCost = COALESCE(lot.dblCost, actualCost.dblCost, fifo.dblCost, lifo.dblCost) 
	FROM	tblICItem i 
			OUTER APPLY (
				SELECT	TOP 1 
						dblCost = dbo.fnCalculateCostBetweenUOM(cb.intItemUOMId, @intItemUOMId, cb.dblCost) 
				FROM	tblICInventoryLot cb
				WHERE	@intCostingMethod = @LOTCOST
						AND cb.intItemId = i.intItemId 
						AND cb.intItemLocationId = @intItemLocationId
						AND cb.intLotId = ISNULL(@intLotId, cb.intLotId) 
						AND cb.strTransactionId = @strTransactionId			
						AND cb.intTransactionId = @intTransactionId
						AND cb.intTransactionDetailId = @intTransactionDetailId
			) lot
			OUTER APPLY (
				SELECT	TOP 1 
						dblCost = dbo.fnCalculateCostBetweenUOM(cb.intItemUOMId, @intItemUOMId, cb.dblCost) 
				FROM	tblICInventoryActualCost cb
				WHERE	@strActualCostId IS NOT NULL 
						AND cb.intItemId = i.intItemId 
						AND cb.intItemLocationId = @intItemLocationId
						AND cb.strTransactionId = @strTransactionId			
						AND cb.intTransactionId = @intTransactionId
						AND cb.intTransactionDetailId = @intTransactionDetailId
						AND cb.strActualCostId = @strActualCostId
			) actualCost
			OUTER APPLY (
				SELECT	TOP 1 
						dblCost = dbo.fnCalculateCostBetweenUOM(cb.intItemUOMId, @intItemUOMId, cb.dblCost) 
				FROM	tblICInventoryFIFO cb
				WHERE	@intCostingMethod IN (@AVERAGECOST, @FIFO)
						AND cb.intItemId = i.intItemId 
						AND cb.intItemLocationId = @intItemLocationId
						AND cb.strTransactionId = @strTransactionId			
						AND cb.intTransactionId = @intTransactionId
						AND cb.intTransactionDetailId = @intTransactionDetailId
			) fifo
			OUTER APPLY (
				SELECT	TOP 1 
						dblCost = dbo.fnCalculateCostBetweenUOM(cb.intItemUOMId, @intItemUOMId, cb.dblCost) 
				FROM	tblICInventoryLIFO cb
				WHERE	@intCostingMethod = @LIFO
						AND cb.intItemId = i.intItemId 
						AND cb.intItemLocationId = @intItemLocationId
						AND cb.strTransactionId = @strTransactionId			
						AND cb.intTransactionId = @intTransactionId
						AND cb.intTransactionDetailId = @intTransactionDetailId
			) lifo
	WHERE	i.intItemId = @intItemId

	RETURN @dblCost;	
END
GO