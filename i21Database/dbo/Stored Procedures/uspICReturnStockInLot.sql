﻿/*
	This stored procedure either inserts or updates a Lot cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReturnStockInLot]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME	
	,@intLotId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(38, 20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@intEntityUserSecurityId AS INT
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
	,@CostUsed AS NUMERIC(18,6) OUTPUT 
	,@QtyOffset AS NUMERIC(18,6) OUTPUT 
	,@InventoryLotId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty)

-- Initialize the remaining qty, cost used, Lot id to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @QtyOffset = NULL;
SET @InventoryLotId = NULL;

-- Upsert (update or insert) a record in the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryLot 
WITH	(HOLDLOCK) 
AS		lot_bucket	
USING (
	SELECT	intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intItemUOMId							
			,intLotId = @intLotId
			,intSubLocationId = @intSubLocationId
			,intStorageLocationId = @intStorageLocationId
) AS Source_Query 
	ON lot_bucket.intItemId = Source_Query.intItemId
	AND lot_bucket.intItemLocationId = Source_Query.intItemLocationId
	AND lot_bucket.intItemUOMId = Source_Query.intItemUOMId
	AND lot_bucket.intLotId = Source_Query.intLotId	
	AND ISNULL(lot_bucket.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(lot_bucket.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)
	AND (lot_bucket.dblStockIn - lot_bucket.dblStockOut) > 0 
	AND dbo.fnDateGreaterThanEquals(@dtmDate, lot_bucket.dtmDate) = 1

-- Update an existing cost bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	lot_bucket.dblStockOut = ISNULL(lot_bucket.dblStockOut, 0) 
					+ CASE	WHEN (lot_bucket.dblStockIn - lot_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (lot_bucket.dblStockIn - lot_bucket.dblStockOut) 
					END 

		,lot_bucket.intConcurrencyId = ISNULL(lot_bucket.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (lot_bucket.dblStockIn - lot_bucket.dblStockOut) >= @dblQty THEN 0
							ELSE (lot_bucket.dblStockIn - lot_bucket.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the Lot bucket. 
		,@CostUsed = lot_bucket.dblCost

		-- retrieve the	qty reduced from a Lot bucket 
		,@QtyOffset = 
					CASE	WHEN (lot_bucket.dblStockIn - lot_bucket.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (lot_bucket.dblStockIn - lot_bucket.dblStockOut) 
					END

		-- retrieve the id of the matching Lot bucket 
		,@InventoryLotId = lot_bucket.intInventoryLotId

-- Insert a new Lot bucket
WHEN NOT MATCHED THEN 
	INSERT (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[dtmDate]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
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
		,@intLotId
		,@intSubLocationId
		,@intStorageLocationId
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