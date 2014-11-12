/*
	This stored procedure either inserts or updates a fifo cost bucket. 
	When new stock is coming IN, it will try to determine if there are any negative fifo buckets it needs to update. 
	Otherwise, it inserts a new cost bucket. 
	
	Parameters: 

*/
CREATE PROCEDURE dbo.uspICIncreaseStockInFIFO
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@intUserId AS INT
	,@FullQty AS NUMERIC(18,6) 
	,@TotalQtyOffset AS NUMERIC(18,6)
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
	,@CostUsed AS NUMERIC(18,6) OUTPUT 
	,@QtyOffset AS NUMERIC(18,6) OUTPUT 
	,@NewFifoId AS INT OUTPUT 
	,@UpdatedFifoId AS INT OUTPUT 
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
SET @NewFifoId = NULL;
SET @UpdatedFifoId = NULL;

-- Upsert (update or insert) a record into the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryFIFO 
WITH	(HOLDLOCK) 
AS		fifo_bucket
USING (
	SELECT	intItemId = @intItemId
			,intItemLocationId = @intItemLocationId	
) AS Source_Query  
	ON fifo_bucket.intItemId = Source_Query.intItemId
	AND fifo_bucket.intItemLocationId = Source_Query.intItemLocationId
	-- Update an existing negative stock 
	AND fifo_bucket.dblStockIn < fifo_bucket.dblStockOut

-- Update an existing negative stock fifo bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	fifo_bucket.dblStockIn = ISNULL(fifo_bucket.dblStockIn, 0) 
					+ CASE	WHEN (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn) 
					END 

		,fifo_bucket.intConcurrencyId = ISNULL(fifo_bucket.intConcurrencyId, 0) + 1
		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn) >= @dblQty THEN 0
							ELSE @dblQty - (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn)
					END
		-- retrieve the cost from the cost bucket. 
		,@CostUsed = fifo_bucket.dblCost

		-- retrieve the negative qty that was offset by the incoming stock 
		,@QtyOffset = 
					CASE	WHEN (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (fifo_bucket.dblStockOut - fifo_bucket.dblStockIn) 
					END 

		,@UpdatedFifoId = fifo_bucket.intInventoryFIFOId

-- Insert a new fifo bucket if there is no negative stock to offset. 
WHEN NOT MATCHED AND @FullQty > 0 THEN 
	INSERT (
		[intItemId]
		,[intItemLocationId]
		,[dtmDate]
		,[dblStockIn]
		,[dblStockOut]
		,[dblCost]
		,[dtmCreated]
		,[intCreatedUserId]
		,[intConcurrencyId]
	)
	VALUES (
		@intItemId
		,@intItemLocationId
		,@dtmDate
		,@FullQty
		,@TotalQtyOffset
		,@dblCost
		,GETDATE()
		,@intUserId
		,1	
	)
;

-- If the incoming stock was fully consumed by the negative stock, the "WHEN NOT MATCHED AND @PurchasedQty > 0 THEN" is not triggered.
-- Thus if remaining qty is zero (not null*),  then add a new stock bucket. 
--
-- Note: 
-- *	Why null in "remaining qty" is important? A null in "remaining qty" means update was not performed in the above statement. 
--      A follow-up insert statement is needed to complete the fifo buckets. 
IF @RemainingQty = 0 
BEGIN 
	INSERT dbo.tblICInventoryFIFO (
		[intItemId]
		,[intItemLocationId]
		,[dtmDate]
		,[dblStockIn]
		,[dblStockOut]
		,[dblCost]
		,[dtmCreated]
		,[intCreatedUserId]
		,[intConcurrencyId]
	)
	VALUES (
		@intItemId
		,@intItemLocationId
		,@dtmDate
		,@FullQty
		,@FullQty
		,@dblCost
		,GETDATE()
		,@intUserId
		,1	
	)

	-- Do a follow-up retrieval of the new fifo id.
	SELECT @NewFifoId = SCOPE_IDENTITY() WHERE @UpdatedFifoId IS NOT NULL; 
END 

-- If Update was not performed, assume an insert was done. 
SELECT @NewFifoId = SCOPE_IDENTITY() WHERE @UpdatedFifoId IS NULL; 
