/*
	This stored procedure either inserts or updates a fifo cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInFIFOStorage]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(38,20) 
	,@dblCost AS NUMERIC(38,20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@intTransactionDetailId AS INT
	,@intEntityUserSecurityId AS INT
	,@RemainingQty AS NUMERIC(38,20) OUTPUT
	,@CostUsed AS NUMERIC(38,20) OUTPUT 
	,@QtyOffset AS NUMERIC(38,20) OUTPUT 
	,@FIFOStorageId AS INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty)

-- Initialize the remaining qty, cost used, fifo id to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @QtyOffset = NULL;
SET @FIFOStorageId = NULL;

-- Upsert (update or insert) a record in the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryFIFOStorage
WITH	(HOLDLOCK) 
AS		fifo_storage_bucket	
USING (
	SELECT	intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intItemUOMId
) AS Source_Query  
	ON fifo_storage_bucket.intItemId = Source_Query.intItemId
	AND fifo_storage_bucket.intItemLocationId = Source_Query.intItemLocationId
	AND fifo_storage_bucket.intItemUOMId = Source_Query.intItemUOMId
	AND (fifo_storage_bucket.dblStockIn - fifo_storage_bucket.dblStockOut) > 0 
	AND dbo.fnDateGreaterThanEquals(@dtmDate, fifo_storage_bucket.dtmDate) = 1

-- Update an existing cost bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	fifo_storage_bucket.dblStockOut = ISNULL(fifo_storage_bucket.dblStockOut, 0) 
					+ CASE	WHEN (fifo_storage_bucket.dblStockIn - fifo_storage_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (fifo_storage_bucket.dblStockIn - fifo_storage_bucket.dblStockOut) 
					END 

		,fifo_storage_bucket.intConcurrencyId = ISNULL(fifo_storage_bucket.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (fifo_storage_bucket.dblStockIn - fifo_storage_bucket.dblStockOut) >= @dblQty THEN 0
							ELSE (fifo_storage_bucket.dblStockIn - fifo_storage_bucket.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the fifo bucket. 
		,@CostUsed = fifo_storage_bucket.dblCost

		-- retrieve the	qty reduced from a fifo bucket 
		,@QtyOffset = 
					CASE	WHEN (fifo_storage_bucket.dblStockIn - fifo_storage_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (fifo_storage_bucket.dblStockIn - fifo_storage_bucket.dblStockOut) 
					END

		-- retrieve the id of the matching fifo bucket 
		,@FIFOStorageId = fifo_storage_bucket.intInventoryFIFOStorageId

-- Insert a new fifo bucket
WHEN NOT MATCHED THEN
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
	)
	VALUES (
		@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@dtmDate
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