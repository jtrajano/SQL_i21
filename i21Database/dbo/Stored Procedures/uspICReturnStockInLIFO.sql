/*
	This stored procedure either inserts or updates a LIFO cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReturnStockInLIFO]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(38,20) 
	,@dblCost AS NUMERIC(38,20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@intEntityUserSecurityId AS INT
	,@RemainingQty AS NUMERIC(38,20) OUTPUT
	,@CostUsed AS NUMERIC(38,20) OUTPUT 
	,@QtyOffset AS NUMERIC(38,20) OUTPUT 
	,@LIFOId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty)

-- Initialize the remaining qty, cost used, LIFO id to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @QtyOffset = NULL;
SET @LIFOId = NULL;

-- Upsert (update or insert) a record in the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryLIFO 
WITH	(HOLDLOCK) 
AS		lifo_bucket	
USING (
	SELECT	intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intItemUOMId
) AS Source_Query  
	ON lifo_bucket.intItemId = Source_Query.intItemId
	AND lifo_bucket.intItemLocationId = Source_Query.intItemLocationId
	AND lifo_bucket.intItemUOMId = Source_Query.intItemUOMId
	AND (lifo_bucket.dblStockIn - lifo_bucket.dblStockOut) > 0 
	AND dbo.fnDateGreaterThanEquals(@dtmDate, lifo_bucket.dtmDate) = 1
	AND lifo_bucket.dblCost = @dblCost

-- Update an existing cost bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	lifo_bucket.dblStockOut = ISNULL(lifo_bucket.dblStockOut, 0) 
					+ CASE	WHEN (lifo_bucket.dblStockIn - lifo_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (lifo_bucket.dblStockIn - lifo_bucket.dblStockOut) 
					END 

		,lifo_bucket.intConcurrencyId = ISNULL(lifo_bucket.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (lifo_bucket.dblStockIn - lifo_bucket.dblStockOut) >= @dblQty THEN 0
							ELSE (lifo_bucket.dblStockIn - lifo_bucket.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the LIFO bucket. 
		,@CostUsed = lifo_bucket.dblCost

		-- retrieve the	qty reduced from a LIFO bucket 
		,@QtyOffset = 
					CASE	WHEN (lifo_bucket.dblStockIn - lifo_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (lifo_bucket.dblStockIn - lifo_bucket.dblStockOut) 
					END

		-- retrieve the id of the matching LIFO bucket 
		,@LIFOId = lifo_bucket.intInventoryLIFOId

-- Insert a new LIFO bucket
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
		,GETDATE()
		,@intEntityUserSecurityId
		,1	
	)
;