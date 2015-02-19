/*
	This stored procedure either inserts or updates a LIFO cost bucket. 
	When new stock is coming IN, it will try to determine if there are any negative LIFO buckets it needs to update. 
	Otherwise, it inserts a new cost bucket. 
	
	Parameters: 

*/
CREATE PROCEDURE dbo.uspICIncreaseStockInLIFO
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@intUserId AS INT
	,@FullQty AS NUMERIC(18,6) 
	,@TotalQtyOffset AS NUMERIC(18,6)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
	,@CostUsed AS NUMERIC(18,6) OUTPUT 
	,@QtyOffset AS NUMERIC(18,6) OUTPUT 
	,@NewLIFOId AS INT OUTPUT 
	,@UpdatedLIFOId AS INT OUTPUT 
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
SET @NewLIFOId = NULL;
SET @UpdatedLIFOId = NULL;
SET @strRelatedTransactionId = NULL;
SET @intRelatedTransactionId = NULL;

-- Upsert (update or insert) a record into the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryLIFO 
WITH	(HOLDLOCK) 
AS		LIFO_bucket
USING (
	SELECT	intItemId = @intItemId
			,intItemLocationId = @intItemLocationId	
			,intItemUOMId = @intItemUOMId
) AS Source_Query  
	ON LIFO_bucket.intItemId = Source_Query.intItemId
	AND LIFO_bucket.intItemLocationId = Source_Query.intItemLocationId
	AND LIFO_bucket.intItemUOMId = Source_Query.intItemUOMId
	-- Update an existing negative stock 
	AND LIFO_bucket.dblStockIn < LIFO_bucket.dblStockOut

-- Update an existing negative stock LIFO bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	LIFO_bucket.dblStockIn = ISNULL(LIFO_bucket.dblStockIn, 0) 
					+ CASE	WHEN (LIFO_bucket.dblStockOut - LIFO_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (LIFO_bucket.dblStockOut - LIFO_bucket.dblStockIn) 
					END 

		,LIFO_bucket.intConcurrencyId = ISNULL(LIFO_bucket.intConcurrencyId, 0) + 1
		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (LIFO_bucket.dblStockOut - LIFO_bucket.dblStockIn) >= @dblQty THEN 0
							ELSE @dblQty - (LIFO_bucket.dblStockOut - LIFO_bucket.dblStockIn)
					END
		-- retrieve the cost from the cost bucket. 
		,@CostUsed = LIFO_bucket.dblCost

		-- retrieve the negative qty that was offset by the incoming stock 
		,@QtyOffset = 
					CASE	WHEN (LIFO_bucket.dblStockOut - LIFO_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (LIFO_bucket.dblStockOut - LIFO_bucket.dblStockIn) 
					END 

		,@UpdatedLIFOId = LIFO_bucket.intInventoryLIFOId
		,@strRelatedTransactionId = LIFO_bucket.strTransactionId
		,@intRelatedTransactionId = LIFO_bucket.intTransactionId

-- Insert a new LIFO bucket if there is no negative stock to offset. 
WHEN NOT MATCHED AND @FullQty > 0 THEN 
	INSERT (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblStockIn]
		,[dblStockOut]
		,[dblCost]
		,[strTransactionId]
		,[intTransactionId]
		,[dtmCreated]
		,[intCreatedUserId]
		,[intConcurrencyId]
	)
	VALUES (
		@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@dtmDate
		,@FullQty
		,@TotalQtyOffset
		,@dblCost
		,@strTransactionId
		,@intTransactionId
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
--      A follow-up insert statement is needed to complete the LIFO buckets. 
IF @RemainingQty = 0 
BEGIN 
	INSERT dbo.tblICInventoryLIFO (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[dblStockIn]
		,[dblStockOut]
		,[dblCost]
		,[strTransactionId]
		,[intTransactionId]
		,[dtmCreated]
		,[intCreatedUserId]
		,[intConcurrencyId]
	)
	VALUES (
		@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@dtmDate
		,@FullQty
		,@FullQty
		,@dblCost
		,@strTransactionId
		,@intTransactionId
		,GETDATE()
		,@intUserId
		,1	
	)

	-- Do a follow-up retrieval of the new LIFO id.
	SELECT @NewLIFOId = SCOPE_IDENTITY() WHERE @UpdatedLIFOId IS NOT NULL; 
END 

-- If Update was not performed, assume an insert was done. 
SELECT @NewLIFOId = SCOPE_IDENTITY() WHERE @UpdatedLIFOId IS NULL; 
