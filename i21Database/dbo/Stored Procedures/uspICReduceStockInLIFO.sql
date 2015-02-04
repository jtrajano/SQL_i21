/*
	This stored procedure either inserts or updates a LIFO cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInLIFO]
	@intItemId AS INT
	,@intLocationId AS INT
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@intUserId AS INT
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
	,@CostUsed AS NUMERIC(18,6) OUTPUT 
	,@QtyOffset AS NUMERIC(18,6) OUTPUT 
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
AS		LIFO_bucket	
USING (
	SELECT	intItemId = @intItemId
			,intLocationId = @intLocationId	
) AS Source_Query  
	ON LIFO_bucket.intItemId = Source_Query.intItemId
	AND LIFO_bucket.intLocationId = Source_Query.intLocationId
	AND (LIFO_bucket.dblStockIn - LIFO_bucket.dblStockOut) > 0 
	AND dbo.fnDateGreaterThanEquals(@dtmDate, LIFO_bucket.dtmDate) = 1

-- Update an existing cost bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	LIFO_bucket.dblStockOut = ISNULL(LIFO_bucket.dblStockOut, 0) 
					+ CASE	WHEN (LIFO_bucket.dblStockIn - LIFO_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (LIFO_bucket.dblStockIn - LIFO_bucket.dblStockOut) 
					END 

		,LIFO_bucket.intConcurrencyId = ISNULL(LIFO_bucket.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (LIFO_bucket.dblStockIn - LIFO_bucket.dblStockOut) >= @dblQty THEN 0
							ELSE (LIFO_bucket.dblStockIn - LIFO_bucket.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the LIFO bucket. 
		,@CostUsed = LIFO_bucket.dblCost

		-- retrieve the	qty reduced from a LIFO bucket 
		,@QtyOffset = 
					CASE	WHEN (LIFO_bucket.dblStockIn - LIFO_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (LIFO_bucket.dblStockIn - LIFO_bucket.dblStockOut) 
					END

		-- retrieve the id of the matching LIFO bucket 
		,@LIFOId = LIFO_bucket.intInventoryLIFOId

-- Insert a new LIFO bucket
WHEN NOT MATCHED THEN 
	INSERT (
		[intItemId]
		,[intLocationId]
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
		,@intLocationId
		,@dtmDate
		,0
		,@dblQty
		,@dblCost
		,@strTransactionId
		,@intTransactionId
		,GETDATE()
		,@intUserId
		,1	
	)
;