/*
	This stored procedure either inserts or updates a LIFO cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInLIFOStorage]
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
	,@LIFOStorageId AS INT OUTPUT 
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
SET @LIFOStorageId = NULL;


-- Validate if the cost bucket is negative. If Negative stock is not allowed, then block the posting. 
BEGIN 
	DECLARE @ALLOW_NEGATIVE_NO AS INT = 3

	DECLARE @strItemNo AS NVARCHAR(50) 
			,@strLocationName AS NVARCHAR(2000) 
			,@CostBucketId AS INT 
			,@AllowNegativeInventory AS INT 
			,@UnitsOnStorage AS NUMERIC(38, 20)

	-- Get the on-hand qty 
	SELECT	@UnitsOnStorage = s.dblUnitStorage
	FROM	tblICItemStock s
	WHERE	s.intItemId = @intItemId
			AND s.intItemLocationId = @intItemLocationId

	SELECT	@strItemNo = i.strItemNo
			,@CostBucketId = cb.intInventoryLIFOStorageId
			,@AllowNegativeInventory = il.intAllowNegativeInventory
	FROM	tblICItem i INNER JOIN tblICItemLocation il
				ON i.intItemId = il.intItemId
				AND il.intItemLocationId = @intItemLocationId
			OUTER APPLY (
				SELECT	TOP 1 *
				FROM	tblICInventoryLIFOStorage cb
				WHERE	cb.intItemId = @intItemId
						AND cb.intItemLocationId = @intItemLocationId
						AND cb.intItemUOMId = @intItemUOMId
						AND ROUND((cb.dblStockIn - cb.dblStockOut), 6) > 0  
						AND dbo.fnDateGreaterThanEquals(cb.dtmDate, @dtmDate) = 1
			) cb 

	IF @CostBucketId IS NULL AND ISNULL(@AllowNegativeInventory, @ALLOW_NEGATIVE_NO) = @ALLOW_NEGATIVE_NO
	BEGIN 
		-- Get the available stock in the cost bucket. 
		DECLARE @strCostBucketDate AS VARCHAR(20) 
		SELECT	TOP 1 
				@strCostBucketDate = CONVERT(NVARCHAR(20), cb.dtmDate, 101)  
		FROM	tblICInventoryLIFOStorage cb
		WHERE	cb.intItemId = @intItemId
				AND cb.intItemLocationId = @intItemLocationId
				AND cb.intItemUOMId = @intItemUOMId
				AND ROUND((cb.dblStockIn - cb.dblStockOut), 6) <> 0  
		ORDER BY cb.dtmDate DESC, cb.intItemId ASC, cb.intItemLocationId ASC, cb.intInventoryLIFOStorageId DESC

		IF @UnitsOnStorage > 0 AND @strCostBucketDate IS NOT NULL 
		BEGIN 
			--'Stock is not available for {Item} at {Location} as of {Transaction Date}. Use the nearest stock available date of {Cost Bucket Date} or later.'
			DECLARE @strDate AS VARCHAR(20) = CONVERT(NVARCHAR(20), @dtmDate, 101) 

			SET @strLocationName = dbo.fnFormatMsg80003(@intItemLocationId, NULL, NULL)
			EXEC uspICRaiseError 80096, @strItemNo, @strLocationName, @strDate, @strCostBucketDate;
			RETURN -80096;
		END 
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
INTO	dbo.tblICInventoryLIFOStorage 
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

		-- retrieve the cost from the LIFO bucket. 
		,@CostUsed = cb.dblCost

		-- retrieve the	qty reduced from a LIFO bucket 
		,@QtyOffset = 
					CASE	WHEN (cb.dblStockIn - cb.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (cb.dblStockIn - cb.dblStockOut) 
					END

		-- retrieve the id of the matching LIFO bucket 
		,@LIFOStorageId = cb.intInventoryLIFOStorageId

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
