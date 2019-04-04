﻿/*
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

-- Validate if the cost bucket is negative. If Negative stock is not allowed, then block the posting. 
BEGIN 
	DECLARE @ALLOW_NEGATIVE_NO AS INT = 3

	DECLARE @strItemNo AS NVARCHAR(50) 
			,@strLocationName AS NVARCHAR(2000) 
			,@CostBucketId AS INT 
			,@AllowNegativeInventory AS INT 
			,@UnitsOnStorage AS NUMERIC(38, 20)

	-- Get the Units in Storage 
	SELECT	@UnitsOnStorage = s.dblUnitStorage
	FROM	tblICItemStock s
	WHERE	s.intItemId = @intItemId
			AND s.intItemLocationId = @intItemLocationId

	SELECT	@strItemNo = i.strItemNo
			,@CostBucketId = cb.intInventoryFIFOStorageId
			,@AllowNegativeInventory = il.intAllowNegativeInventory
	FROM	tblICItem i INNER JOIN tblICItemLocation il
				ON i.intItemId = il.intItemId
				AND il.intItemLocationId = @intItemLocationId
			OUTER APPLY (
				SELECT	intInventoryFIFOStorageId = MIN(cb.intInventoryFIFOStorageId) 
				FROM	tblICInventoryFIFOStorage cb
				WHERE	cb.intItemId = @intItemId
						AND cb.intItemLocationId = @intItemLocationId
						AND cb.intItemUOMId = @intItemUOMId
						AND ROUND((cb.dblStockIn - cb.dblStockOut), 6) <> 0  
						AND dbo.fnDateLessThanEquals(cb.dtmDate, @dtmDate) = 1
				HAVING 
					SUM(ROUND((cb.dblStockIn - cb.dblStockOut), 6)) >=  ROUND(@dblQty, 6)
			) cb 

	IF @CostBucketId IS NULL AND ISNULL(@AllowNegativeInventory, @ALLOW_NEGATIVE_NO) = @ALLOW_NEGATIVE_NO
	BEGIN 
		---- Get the available stock in the cost bucket. 
		--DECLARE @strCostBucketDate AS VARCHAR(20) 
		--SELECT	@strCostBucketDate = CONVERT(NVARCHAR(20), MIN(cb.dtmDate), 101)
		--FROM	tblICInventoryFIFOStorage cb
		--WHERE	cb.intItemId = @intItemId
		--		AND cb.intItemLocationId = @intItemLocationId
		--		AND cb.intItemUOMId = @intItemUOMId
		--		AND ROUND((cb.dblStockIn - cb.dblStockOut), 6) <> 0  
		--HAVING 
		--	SUM(ROUND((cb.dblStockIn - cb.dblStockOut), 6)) >=  ROUND(@dblQty, 6)

		-- Get the available stock in the cost bucket. 
		DECLARE @strCostBucketDate AS VARCHAR(20) 
				,@dtmCostBucketDate AS DATETIME
				,@dblCostBucketQty AS NUMERIC(18, 6)
				,@dblTotalCostBucketQty AS NUMERIC(18, 6)

		DECLARE findBestDateToPost CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT	dblQty = ROUND((ISNULL(cb.dblStockIn, 0) - ISNULL(cb.dblStockOut, 0)), 6)
				,cb.dtmDate
		FROM	tblICInventoryFIFOStorage cb
		WHERE	cb.intItemId = @intItemId
				AND cb.intItemLocationId = @intItemLocationId
				AND cb.intItemUOMId = @intItemUOMId
				AND ROUND((cb.dblStockIn - cb.dblStockOut), 6) <> 0 
		ORDER BY 
			cb.dtmDate ASC 

		OPEN findBestDateToPost;
		FETCH NEXT FROM findBestDateToPost INTO @dblCostBucketQty, @dtmCostBucketDate

		SET @dblTotalCostBucketQty = 0 
		WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @dblTotalCostBucketQty += @dblCostBucketQty
			IF @dblTotalCostBucketQty >= ROUND(@dblQty, 6)
			BEGIN 
				SET @strCostBucketDate = CONVERT(NVARCHAR(20), @dtmCostBucketDate, 101) 
				GOTO breakLoopFindBestDateToPost
			END 
			
			FETCH NEXT FROM findBestDateToPost INTO @dblCostBucketQty, @dtmCostBucketDate
		END 
		breakLoopFindBestDateToPost: 
		CLOSE findBestDateToPost;
		DEALLOCATE findBestDateToPost;

		IF @strCostBucketDate IS NOT NULL 
		BEGIN 
			--'Stock is not available for {Item} at {Location} as of {Transaction Date}. Use the nearest stock available date of {Cost Bucket Date} or later.'
			DECLARE @strDate AS VARCHAR(20) = CONVERT(NVARCHAR(20), @dtmDate, 101) 

			SET @strLocationName = dbo.fnFormatMsg80003(@intItemLocationId, NULL, NULL)
			EXEC uspICRaiseError 80096, @strItemNo, @strLocationName, @strDate, @strCostBucketDate;
			RETURN -80096;
		END 
		ELSE 
		BEGIN
			SET @strLocationName = dbo.fnFormatMsg80003(@intItemLocationId, NULL, NULL)
		 
			--'Negative stock quantity is not allowed for {Item No} in {Location Name}.'
			EXEC uspICRaiseError 80003, @strItemNo, @strLocationName; 
			RETURN -80003;
		END 
	END 
END 

-- Upsert (update or insert) a record in the cost bucket.
MERGE	TOP(1)
INTO	dbo.tblICInventoryFIFOStorage
WITH	(HOLDLOCK) 
AS		cb	
USING (
	SELECT	intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intItemUOMId
) AS Source_Query  
	ON cb.intItemId = Source_Query.intItemId
	AND cb.intItemLocationId = Source_Query.intItemLocationId
	AND cb.intItemUOMId = Source_Query.intItemUOMId
	AND (cb.dblStockIn - cb.dblStockOut) > 0 
	AND dbo.fnDateLessThanEquals(cb.dtmDate, @dtmDate) = 1
	AND (cb.intInventoryFIFOStorageId = @CostBucketId OR @CostBucketId IS NULL) 

-- Update an existing cost bucket
WHEN MATCHED THEN 
	UPDATE 
	SET	cb.dblStockOut = ISNULL(cb.dblStockOut, 0) 
					+ CASE	WHEN (cb.dblStockIn - cb.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (cb.dblStockIn - cb.dblStockOut) 
					END 

		,cb.intConcurrencyId = ISNULL(cb.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (cb.dblStockIn - cb.dblStockOut) >= @dblQty THEN 0
							ELSE (cb.dblStockIn - cb.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the fifo bucket. 
		,@CostUsed = cb.dblCost

		-- retrieve the	qty reduced from a fifo bucket 
		,@QtyOffset = 
					CASE	WHEN (cb.dblStockIn - cb.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (cb.dblStockIn - cb.dblStockOut) 
					END

		-- retrieve the id of the matching fifo bucket 
		,@FIFOStorageId = cb.intInventoryFIFOStorageId

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