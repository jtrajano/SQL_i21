﻿/*
	This stored procedure either inserts or updates a Lot cost bucket. 
	When new stock is coming IN, it will try to determine if there are any negative Lot buckets it needs to update. 
	Otherwise, it inserts a new cost bucket. 
	
	Parameters: 

*/
CREATE PROCEDURE dbo.uspICIncreaseStockInLotInTransit
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME
	,@intLotId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT
	,@dblQty NUMERIC(38,20) 
	,@dblCost AS NUMERIC(38,20)
	,@intEntityUserSecurityId AS INT
	,@FullQty AS NUMERIC(38,20) 
	,@TotalQtyOffset AS NUMERIC(38,20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@intTransactionDetailId AS INT 
	,@RemainingQty AS NUMERIC(38,20) OUTPUT
	,@CostUsed AS NUMERIC(38,20) OUTPUT 
	,@QtyOffset AS NUMERIC(38,20) OUTPUT 
	,@NewLotId AS INT OUTPUT 
	,@UpdatedLotId AS INT OUTPUT 
	,@strRelatedTransactionId AS NVARCHAR(40) OUTPUT
	,@intRelatedTransactionId AS INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty);

-- Initialize the remaining qty to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @QtyOffset = NULL;
SET @NewLotId = NULL;
SET @UpdatedLotId = NULL;
SET @strRelatedTransactionId = NULL;
SET @intRelatedTransactionId = NULL;

-- Upsert (update or insert) a record into the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryLot 
WITH	(HOLDLOCK) 
AS		Lot_bucket
USING (
	SELECT	intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intItemUOMId
			,intLotId = @intLotId
			,intSubLocationId = @intSubLocationId
			,intStorageLocationId = @intStorageLocationId
) AS Source_Query  
	ON Lot_bucket.intItemId = Source_Query.intItemId
	AND Lot_bucket.intItemLocationId = Source_Query.intItemLocationId
	AND Lot_bucket.intItemUOMId = Source_Query.intItemUOMId
	AND Lot_bucket.intLotId = Source_Query.intLotId
	AND ISNULL(Lot_bucket.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(Lot_bucket.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)
	AND Lot_bucket.dblStockIn < Lot_bucket.dblStockOut -- Update an existing negative stock 

-- Update an existing negative stock Lot bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	Lot_bucket.dblStockIn = ISNULL(Lot_bucket.dblStockIn, 0) 
					+ CASE	WHEN (Lot_bucket.dblStockOut - Lot_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (Lot_bucket.dblStockOut - Lot_bucket.dblStockIn) 
					END 

		,Lot_bucket.intConcurrencyId = ISNULL(Lot_bucket.intConcurrencyId, 0) + 1
		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (Lot_bucket.dblStockOut - Lot_bucket.dblStockIn) >= @dblQty THEN 0
							ELSE @dblQty - (Lot_bucket.dblStockOut - Lot_bucket.dblStockIn)
					END
		-- retrieve the cost from the cost bucket. 
		,@CostUsed = Lot_bucket.dblCost

		-- retrieve the negative qty that was offset by the incoming stock 
		,@QtyOffset = 
					CASE	WHEN (Lot_bucket.dblStockOut - Lot_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (Lot_bucket.dblStockOut - Lot_bucket.dblStockIn) 
					END 

		,@UpdatedLotId = Lot_bucket.intInventoryLotId
		,@strRelatedTransactionId = Lot_bucket.strTransactionId
		,@intRelatedTransactionId = Lot_bucket.intTransactionId

-- Insert a new Lot bucket if there is no negative stock to offset. 
WHEN NOT MATCHED AND @FullQty > 0 THEN 
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
		,@FullQty
		,@TotalQtyOffset
		,@dblCost
		,@strTransactionId
		,@intTransactionId
		,@intTransactionDetailId
		,GETDATE()
		,@intEntityUserSecurityId
		,1	
	)
;

-- If the incoming stock was fully consumed by the negative stock, the "WHEN NOT MATCHED AND @PurchasedQty > 0 THEN" is not triggered.
-- Thus if remaining qty is zero (not null*),  then add a new stock bucket. 
--
-- Note: 
-- *	Why null in "remaining qty" is important? A null in "remaining qty" means update was not performed in the above statement. 
--      A follow-up insert statement is needed to complete the Lot buckets. 
IF @RemainingQty = 0 
BEGIN 
	INSERT dbo.tblICInventoryLot (
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
		,@FullQty
		,@FullQty
		,@dblCost
		,@strTransactionId
		,@intTransactionId
		,GETDATE()
		,@intEntityUserSecurityId
		,1	
	)

	-- Do a follow-up retrieval of the new Lot id.
	SELECT @NewLotId = SCOPE_IDENTITY() WHERE @UpdatedLotId IS NOT NULL; 
END 

-- If Update was not performed, assume an insert was done. 
SELECT @NewLotId = SCOPE_IDENTITY() WHERE @UpdatedLotId IS NULL; 
