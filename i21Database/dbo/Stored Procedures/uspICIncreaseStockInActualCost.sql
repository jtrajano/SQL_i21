/*
	This stored procedure either inserts or updates an Actual-Cost cost bucket. 
	When new stock is coming IN, it will try to determine if there are any negative ActualCost buckets it needs to update. 
	Otherwise, it inserts a new cost bucket. 
	
	Parameters: 

*/
CREATE PROCEDURE dbo.uspICIncreaseStockInActualCost
	@strActualCostId AS NVARCHAR(50)
	,@intItemId AS INT
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
	,@NewActualCostId AS INT OUTPUT 
	,@UpdatedActualCostId AS INT OUTPUT 
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
SET @NewActualCostId = NULL;
SET @UpdatedActualCostId = NULL;
SET @strRelatedTransactionId = NULL;
SET @intRelatedTransactionId = NULL;

-- Upsert (update or insert) a record into the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryActualCost 
WITH	(HOLDLOCK) 
AS		ActualCost_bucket
USING (
	SELECT	strActualCostId = @strActualCostId
			,intItemId = @intItemId
			,intItemLocationId = @intItemLocationId	
			,intItemUOMId = @intItemUOMId
) AS Source_Query  
	ON ActualCost_bucket.strActualCostId = Source_Query.strActualCostId
	AND ActualCost_bucket.intItemId = Source_Query.intItemId
	AND ActualCost_bucket.intItemLocationId = Source_Query.intItemLocationId
	AND ActualCost_bucket.intItemUOMId = Source_Query.intItemUOMId

	-- Update an existing negative stock 
	AND ActualCost_bucket.dblStockIn < ActualCost_bucket.dblStockOut

-- Update an existing negative stock ActualCost bucket with the same UOM 
WHEN MATCHED THEN 
	UPDATE 
	SET	ActualCost_bucket.dblStockIn = ISNULL(ActualCost_bucket.dblStockIn, 0) 
					+ CASE	WHEN (ActualCost_bucket.dblStockOut - ActualCost_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (ActualCost_bucket.dblStockOut - ActualCost_bucket.dblStockIn) 
					END
		,ActualCost_bucket.intConcurrencyId = ISNULL(ActualCost_bucket.intConcurrencyId, 0) + 1
		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (ActualCost_bucket.dblStockOut - ActualCost_bucket.dblStockIn) >= @dblQty THEN 0
							ELSE @dblQty - (ActualCost_bucket.dblStockOut - ActualCost_bucket.dblStockIn)
					END
		-- retrieve the cost from the cost bucket. 
		,@CostUsed = ActualCost_bucket.dblCost

		-- retrieve the negative qty that was offset by the incoming stock 
		,@QtyOffset = 
					CASE	WHEN (ActualCost_bucket.dblStockOut - ActualCost_bucket.dblStockIn) >= @dblQty THEN @dblQty
							ELSE (ActualCost_bucket.dblStockOut - ActualCost_bucket.dblStockIn) 
					END 

		,@UpdatedActualCostId = ActualCost_bucket.intInventoryActualCostId
		,@strRelatedTransactionId = ActualCost_bucket.strTransactionId
		,@intRelatedTransactionId = ActualCost_bucket.intTransactionId

-- Insert a new ActualCost bucket if there is no negative stock to offset. 
WHEN NOT MATCHED AND @FullQty > 0 THEN 
	INSERT (
		[strActualCostId]
		,[intItemId]
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
		@strActualCostId
		,@intItemId
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
--      A follow-up insert statement is needed to complete the ActualCost buckets. 
IF @RemainingQty = 0 
BEGIN 
	INSERT dbo.tblICInventoryActualCost (
		[strActualCostId]
		,[intItemId]
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
		@strActualCostId
		,@intItemId
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

	-- Do a follow-up retrieval of the new ActualCost id.
	SELECT @NewActualCostId = SCOPE_IDENTITY() WHERE @UpdatedActualCostId IS NOT NULL; 
END 

-- If Update was not performed, assume an insert was done. 
SELECT @NewActualCostId = SCOPE_IDENTITY() WHERE @UpdatedActualCostId IS NULL; 

