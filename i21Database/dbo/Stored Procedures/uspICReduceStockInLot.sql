/*
	This stored procedure either inserts or updates a Lot cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInLot]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME	
	,@intLotId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT
	,@dblQty NUMERIC(38,20) 
	,@dblCost AS NUMERIC(38,20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@intEntityUserSecurityId AS INT
	,@RemainingQty AS NUMERIC(38,20) OUTPUT
	,@CostUsed AS NUMERIC(38,20) OUTPUT 
	,@QtyOffset AS NUMERIC(38,20) OUTPUT 
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

-- Validate if the cost bucket is negative. If Negative stock is not allowed, then block the posting. 
BEGIN 
	DECLARE @ALLOW_NEGATIVE_NO AS INT = 3

	DECLARE @strItemNo AS NVARCHAR(50) 
			,@strLocationName AS NVARCHAR(MAX) 
			,@CostBucketId AS INT 
			,@AllowNegativeInventory AS INT 
			,@UnitsOnHand AS NUMERIC(38, 20)

	-- Get the on-hand qty 
	SELECT	@UnitsOnHand = s.dblUnitOnHand
	FROM	tblICItemStock s
	WHERE	s.intItemId = @intItemId
			AND s.intItemLocationId = @intItemLocationId

	SELECT	@strItemNo = i.strItemNo
			,@CostBucketId = cb.intInventoryLotId
			,@AllowNegativeInventory = il.intAllowNegativeInventory
			,@strLocationName = cl.strLocationName
	FROM	tblICItem i INNER JOIN tblICItemLocation il
				ON i.intItemId = il.intItemId
				AND il.intItemLocationId = @intItemLocationId
			INNER JOIN tblSMCompanyLocation cl
				ON cl.intCompanyLocationId = il.intLocationId
			OUTER APPLY (
				SELECT	TOP 1 *
				FROM	tblICInventoryLot cb
				WHERE	cb.intItemId = @intItemId
						AND cb.intItemLocationId = @intItemLocationId
						AND cb.intLotId = @intLotId
						AND ISNULL(cb.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
						AND ISNULL(cb.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
						AND ROUND((cb.dblStockIn - cb.dblStockOut), 6) > 0  
						AND dbo.fnDateLessThanEquals(cb.dtmDate, @dtmDate) = 1
			) cb 

	IF @CostBucketId IS NULL AND @AllowNegativeInventory = @ALLOW_NEGATIVE_NO
	BEGIN 
		IF @UnitsOnHand > 0 
		BEGIN 
			DECLARE @strDate AS VARCHAR(20) = CONVERT(NVARCHAR(20), @dtmDate, 101) 
			EXEC uspICRaiseError 80096, @strDate, @strItemNo, @strLocationName;
		END 
		ELSE 
		BEGIN 
			--'Negative stock quantity is not allowed for {Item No} in {Location Name}.'
			EXEC uspICRaiseError 80003, @strItemNo, @strLocationName; 
		END 
		RETURN -1
	END 
END 

-- Upsert (update or insert) a record in the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryLot 
WITH	(HOLDLOCK) 
AS		cb	
USING (
	SELECT	intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intItemUOMId							
			,intLotId = @intLotId
			,intSubLocationId = @intSubLocationId
			,intStorageLocationId = @intStorageLocationId
) AS Source_Query 
	ON cb.intItemId = Source_Query.intItemId
	AND cb.intItemLocationId = Source_Query.intItemLocationId
	AND cb.intItemUOMId = Source_Query.intItemUOMId
	AND cb.intLotId = Source_Query.intLotId	
	AND ISNULL(cb.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(cb.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)
	AND ROUND((cb.dblStockIn - cb.dblStockOut), 6) > 0  -- Round out the remaining stock. If it becomes zero, then stock bucket is considered fully consumed already. 
	AND dbo.fnDateLessThanEquals(cb.dtmDate, @dtmDate) = 1

-- Update an existing cost bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	cb.dblStockOut =	
					ISNULL(cb.dblStockOut, 0) +
					CASE	WHEN (cb.dblStockIn - cb.dblStockOut) >= @dblQty THEN 
								 @dblQty
							ELSE 
								cb.dblStockIn - cb.dblStockOut
					END 

		,cb.intConcurrencyId = ISNULL(cb.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	--WHEN (cb.dblStockIn - cb.dblStockOut) >= @dblQty THEN 0
							WHEN ROUND((cb.dblStockIn - cb.dblStockOut), 6) >= ROUND(@dblQty, 6) THEN 0
							WHEN ROUND((cb.dblStockIn - cb.dblStockOut) - @dblQty, 6) = 0 THEN 0 
							ELSE (cb.dblStockIn - cb.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the Lot bucket. 
		,@CostUsed = cb.dblCost

		-- retrieve the	qty reduced from a Lot bucket 
		,@QtyOffset = 
					CASE	WHEN (cb.dblStockIn - cb.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (cb.dblStockIn - cb.dblStockOut) 
					END

		-- retrieve the id of the matching Lot bucket 
		,@InventoryLotId = cb.intInventoryLotId

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