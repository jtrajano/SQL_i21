/*
	This stored procedure either inserts or updates an Actual-Cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReturnStockInActualCost]
	@strActualCostId AS NVARCHAR(50)
	,@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(38, 20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@intEntityUserSecurityId AS INT
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
	,@CostUsed AS NUMERIC(18,6) OUTPUT 
	,@QtyOffset AS NUMERIC(18,6) OUTPUT 
	,@ActualCostId AS INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty)

-- Initialize the remaining qty, cost used, ActualCost id to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @QtyOffset = NULL;
SET @ActualCostId = NULL;

-- Upsert (update or insert) a record in the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryActualCost 
WITH	(HOLDLOCK) 
AS		actualCost_bucket	
USING (
	SELECT	strActualCostId = @strActualCostId
			,intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intItemUOMId
) AS Source_Query  
	ON actualCost_bucket.strActualCostId = Source_Query.strActualCostId 
	AND actualCost_bucket.intItemId = Source_Query.intItemId
	AND actualCost_bucket.intItemLocationId = Source_Query.intItemLocationId
	AND actualCost_bucket.intItemUOMId = Source_Query.intItemUOMId
	AND (actualCost_bucket.dblStockIn - actualCost_bucket.dblStockOut) > 0 
	AND dbo.fnDateGreaterThanEquals(@dtmDate, actualCost_bucket.dtmDate) = 1
	AND actualCost_bucket.dblCost = @dblCost

-- Update an existing cost bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	actualCost_bucket.dblStockOut = ISNULL(actualCost_bucket.dblStockOut, 0) 
					+ CASE	WHEN (actualCost_bucket.dblStockIn - actualCost_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (actualCost_bucket.dblStockIn - actualCost_bucket.dblStockOut) 
					END 

		,actualCost_bucket.intConcurrencyId = ISNULL(actualCost_bucket.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (actualCost_bucket.dblStockIn - actualCost_bucket.dblStockOut) >= @dblQty THEN 0
							ELSE (actualCost_bucket.dblStockIn - actualCost_bucket.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the ActualCost bucket. 
		,@CostUsed = actualCost_bucket.dblCost

		-- retrieve the	qty reduced from a ActualCost bucket 
		,@QtyOffset = 
					CASE	WHEN (actualCost_bucket.dblStockIn - actualCost_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (actualCost_bucket.dblStockIn - actualCost_bucket.dblStockOut) 
					END

		-- retrieve the id of the matching ActualCost bucket 
		,@ActualCostId = actualCost_bucket.intInventoryActualCostId

-- Insert a new ActualCost bucket
WHEN NOT MATCHED THEN
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
		,[intCreatedEntityId]
		,[intConcurrencyId]
	)
	VALUES (
		@strActualCostId
		,@intItemId
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