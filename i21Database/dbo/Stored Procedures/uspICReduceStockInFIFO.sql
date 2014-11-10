/*
	This stored procedure either inserts or updates a fifo cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInFIFO]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@intUserId AS INT
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
	,@CostUsed AS NUMERIC(18,6) OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty)

-- Initialize the remaining qty and cost used to NULL
SET @RemainingQty = NULL 
SET @CostUsed = NULL 

-- Upsert (update or insert) a record in the cost bucket.
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
	AND (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) > 0 
	AND dbo.fnDateGreaterThanEquals(@dtmDate, fifo_bucket.dtmDate) = 1

-- Update an existing cost bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	fifo_bucket.dblStockOut = ISNULL(fifo_bucket.dblStockOut, 0) 
					+ CASE	WHEN (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) 
					END 

		,fifo_bucket.intConcurrencyId = ISNULL(fifo_bucket.intConcurrencyId, 0) + 1
		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) >= @dblQty THEN 0
							ELSE (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) - @dblQty
					END
		-- retrieve the cost from the cost bucket. 
		,@CostUsed = fifo_bucket.dblCost

-- Insert a new fifo bucket
WHEN NOT MATCHED THEN 
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
		,0
		,@dblQty
		,@dblCost
		,GETDATE()
		,@intUserId
		,1	
	)
;