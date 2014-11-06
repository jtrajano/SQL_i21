/*
	This is the stored procedure that handles the moving average costing method. 
	
	Parameters: 

*/

CREATE PROCEDURE [dbo].[uspICIncreaseStockInFIFO]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@dtmDate AS DATETIME
	,@dblPurchasedQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@intUserId AS INT
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the purchased qty is a positive number
SET @dblPurchasedQty = ABS(@dblPurchasedQty)

-- Initialize the remaining qty to NULL
SET @RemainingQty = NULL 

-- Upsert (update or insert) a record in the cost bucket.
MERGE	[dbo].[tblICInventoryFIFO] WITH (HOLDLOCK) AS fifo_bucket
USING (
	SELECT	TOP 1 
			intInventoryFIFOId 
	FROM	[dbo].[tblICInventoryFIFO] 
	WHERE	ISNULL(dblStockIn, 0) < ISNULL(dblStockOut, 0) -- stock-in is less than stock-out
) AS negative_stock
	ON fifo_bucket.intInventoryFIFOId = negative_stock.intInventoryFIFOId

-- Update statement
WHEN MATCHED THEN 
	UPDATE 
	SET	fifo_bucket.dblStockIn = ISNULL(fifo_bucket.dblStockIn, 0) + @dblPurchasedQty
		,fifo_bucket.intConcurrencyId = ISNULL(fifo_bucket.intConcurrencyId, 0) + 1
		-- update the remaining qty
		,@RemainingQty = (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) - @dblPurchasedQty

-- Insert statement
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
		,@dblPurchasedQty
		,@dblCost
		,GETDATE()
		,@intUserId
		,1	
	)
;