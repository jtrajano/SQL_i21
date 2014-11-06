﻿/*
	This is the stored procedure that handles the moving average costing method. 
	
	Parameters: 

*/

CREATE PROCEDURE [dbo].[uspICReduceStockInFIFO]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@dtmDate AS DATETIME
	,@dblSoldQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@intUserId AS INT
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the sold qty is a positive number
SET @dblSoldQty = ABS(@dblSoldQty)

-- Initialize the remaining qty to NULL
SET @RemainingQty = NULL 

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

-- Update statement
WHEN MATCHED THEN 
	UPDATE 
	SET	fifo_bucket.dblStockOut = ISNULL(fifo_bucket.dblStockOut, 0) 
					+ CASE	WHEN (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) >= @dblSoldQty THEN @dblSoldQty
							ELSE (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) 
					END 

		,fifo_bucket.intConcurrencyId = ISNULL(fifo_bucket.intConcurrencyId, 0) + 1
		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) >= @dblSoldQty THEN 0
							ELSE (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) - @dblSoldQty
					END

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
		,@dblSoldQty
		,@dblCost
		,GETDATE()
		,@intUserId
		,1	
	)
;