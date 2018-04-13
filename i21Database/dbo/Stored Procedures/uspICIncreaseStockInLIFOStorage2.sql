/*
	This stored procedure either inserts or updates a LIFO Storage cost bucket. 
	When new stock is coming IN, it will try to determine if there are any negative LIFO buckets it needs to update. 
	Otherwise, it inserts a new cost bucket. 
	
	Parameters: 

*/
CREATE PROCEDURE dbo.uspICIncreaseStockInLIFOStorage
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
	,@dtmDate AS DATETIME
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
	,@NewLIFOStorageId AS INT OUTPUT 
	,@UpdatedLIFOStorageId AS INT OUTPUT 
	,@strRelatedTransactionId AS NVARCHAR(40) OUTPUT
	,@intRelatedTransactionId AS INT OUTPUT
	,@dblUnitRetail AS NUMERIC(38,20)
	,@UnitRetailUsed AS NUMERIC(38,20) OUTPUT 
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
SET @NewLIFOStorageId = NULL;
SET @UpdatedLIFOStorageId = NULL;
SET @strRelatedTransactionId = NULL;
SET @intRelatedTransactionId = NULL;
SET @UnitRetailUsed = NULL;

-- Upsert (update or insert) a record into the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryLIFOStorage 
WITH	(HOLDLOCK) 
AS		lifo_storage_bucket
USING (
	SELECT	intItemId = @intItemId
			,intItemLocationId = @intItemLocationId	
			,intItemUOMId = @intItemUOMId
) AS Source_Query  
	ON lifo_storage_bucket.intItemId = Source_Query.intItemId
	AND lifo_storage_bucket.intItemLocationId = Source_Query.intItemLocationId
	AND lifo_storage_bucket.intItemUOMId = Source_Query.intItemUOMId
	-- Update an existing negative stock 
	AND lifo_storage_bucket.dblStockIn < lifo_storage_bucket.dblStockOut

-- Update an existing negative stock LIFO bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	lifo_storage_bucket.dblStockIn = ISNULL(lifo_storage_bucket.dblStockIn, 0) 
					+ CASE	WHEN (lifo_storage_bucket.dblStockOut - lifo_storage_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (lifo_storage_bucket.dblStockOut - lifo_storage_bucket.dblStockIn) 
					END 

		,lifo_storage_bucket.intConcurrencyId = ISNULL(lifo_storage_bucket.intConcurrencyId, 0) + 1
		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (lifo_storage_bucket.dblStockOut - lifo_storage_bucket.dblStockIn) >= @dblQty THEN 0
							ELSE @dblQty - (lifo_storage_bucket.dblStockOut - lifo_storage_bucket.dblStockIn)
					END
		-- retrieve the cost from the cost bucket. 
		,@CostUsed = lifo_storage_bucket.dblCost

		-- retrieve the negative qty that was offset by the incoming stock 
		,@QtyOffset = 
					CASE	WHEN (lifo_storage_bucket.dblStockOut - lifo_storage_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (lifo_storage_bucket.dblStockOut - lifo_storage_bucket.dblStockIn) 
					END 

		,@UpdatedLIFOStorageId = lifo_storage_bucket.intInventoryLIFOStorageId
		,@strRelatedTransactionId = lifo_storage_bucket.strTransactionId
		,@intRelatedTransactionId = lifo_storage_bucket.intTransactionId
		,@UnitRetailUsed = lifo_storage_bucket.dblUnitRetail 

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
		,[intTransactionDetailId]
		,[dtmCreated]
		,[intCreatedEntityId]
		,[intConcurrencyId]
		,[dblUnitRetail]
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
		,@intTransactionDetailId
		,GETDATE()
		,@intEntityUserSecurityId
		,1
		,@dblUnitRetail
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
	INSERT dbo.tblICInventoryLIFOStorage (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
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
		,@FullQty
		,@FullQty
		,@dblCost
		,@strTransactionId
		,@intTransactionId
		,@intTransactionDetailId
		,GETDATE()
		,@intEntityUserSecurityId
		,1	
	)

	-- Do a follow-up retrieval of the new LIFO id.
	SELECT @NewLIFOStorageId = SCOPE_IDENTITY() WHERE @UpdatedLIFOStorageId IS NOT NULL; 
END 

-- If Update was not performed, assume an insert was done. 
SELECT @NewLIFOStorageId = SCOPE_IDENTITY() WHERE @UpdatedLIFOStorageId IS NULL; 
