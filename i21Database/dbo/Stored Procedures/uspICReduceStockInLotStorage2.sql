/*
	This stored procedure either inserts or updates a Lot cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInLotStorage]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME	
	,@intLotId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT
	,@dblQty NUMERIC(38,20) 
	,@dblCost AS NUMERIC(38,20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@intTransactionDetailId AS INT 
	,@intEntityUserSecurityId AS INT
	,@RemainingQty AS NUMERIC(38,20) OUTPUT
	,@CostUsed AS NUMERIC(38,20) OUTPUT 
	,@QtyOffset AS NUMERIC(38,20) OUTPUT 
	,@InventoryLotStorageId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty)

-- Initialize the remaining qty, cost used, Lot id to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @QtyOffset = NULL;
SET @InventoryLotStorageId = NULL;

-- Upsert (update or insert) a record in the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryLotStorage 
WITH	(HOLDLOCK) 
AS		Lot_Storage_bucket	
USING (
	SELECT	intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intItemUOMId							
			,intLotId = @intLotId
			,intSubLocationId = @intSubLocationId
			,intStorageLocationId = @intStorageLocationId
) AS Source_Query 
	ON Lot_Storage_bucket.intItemId = Source_Query.intItemId
	AND Lot_Storage_bucket.intItemLocationId = Source_Query.intItemLocationId
	AND Lot_Storage_bucket.intItemUOMId = Source_Query.intItemUOMId
	AND Lot_Storage_bucket.intLotId = Source_Query.intLotId	
	AND ISNULL(Lot_Storage_bucket.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(Lot_Storage_bucket.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)
	AND (Lot_Storage_bucket.dblStockIn - Lot_Storage_bucket.dblStockOut) > 0 
	AND dbo.fnDateGreaterThanEquals(@dtmDate, Lot_Storage_bucket.dtmDate) = 1

-- Update an existing cost bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	Lot_Storage_bucket.dblStockOut = ISNULL(Lot_Storage_bucket.dblStockOut, 0) 
					+ CASE	WHEN (Lot_Storage_bucket.dblStockIn - Lot_Storage_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (Lot_Storage_bucket.dblStockIn - Lot_Storage_bucket.dblStockOut) 
					END 

		,Lot_Storage_bucket.intConcurrencyId = ISNULL(Lot_Storage_bucket.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (Lot_Storage_bucket.dblStockIn - Lot_Storage_bucket.dblStockOut) >= @dblQty THEN 0
							ELSE (Lot_Storage_bucket.dblStockIn - Lot_Storage_bucket.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the Lot bucket. 
		,@CostUsed = Lot_Storage_bucket.dblCost

		-- retrieve the	qty reduced from a Lot bucket 
		,@QtyOffset = 
					CASE	WHEN (Lot_Storage_bucket.dblStockIn - Lot_Storage_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (Lot_Storage_bucket.dblStockIn - Lot_Storage_bucket.dblStockOut) 
					END

		-- retrieve the id of the matching Lot bucket 
		,@InventoryLotStorageId = Lot_Storage_bucket.intInventoryLotStorageId

-- Insert a new Lot bucket
WHEN NOT MATCHED THEN 
	INSERT (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[dblStockIn]
		,[dblStockOut]
		,[dblCost]
		,[strTransactionId]
		,[intTransactionId]
		,[intTransactionDetailId]
		,[dtmCreated]
		,[intCreatedEntityId]
		,[intConcurrencyId]
	)
	VALUES (
		@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@dtmDate
		,@intLotId
		,@intSubLocationId
		,@intStorageLocationId
		,0
		,@dblQty
		,@dblCost
		,@strTransactionId
		,@intTransactionId
		,@intTransactionDetailId
		,GETDATE()
		,@intEntityUserSecurityId
		,1	
	)
;