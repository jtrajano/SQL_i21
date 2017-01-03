/*
	This stored procedure either inserts or updates a fifo cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReturnStockInFIFO]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@strBatchId AS NVARCHAR(20)
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(38, 20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@intEntityUserSecurityId AS INT
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
	,@CostUsed AS NUMERIC(18,6) OUTPUT 
	,@QtyOffset AS NUMERIC(18,6) OUTPUT 
	,@FifoId AS INT OUTPUT
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
SET @FifoId = NULL;

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
			,@CostBucketId = cb.intInventoryFIFOId
			,@AllowNegativeInventory = il.intAllowNegativeInventory
			,@strLocationName = cl.strLocationName
	FROM	tblICItem i INNER JOIN tblICItemLocation il
				ON i.intItemId = il.intItemId
				AND il.intItemLocationId = @intItemLocationId
			INNER JOIN tblSMCompanyLocation cl
				ON cl.intCompanyLocationId = il.intLocationId
			OUTER APPLY (
				SELECT	TOP 1 *
				FROM	tblICInventoryFIFO cb
				WHERE	cb.intItemId = @intItemId
						AND cb.intItemLocationId = @intItemLocationId
						AND cb.intItemUOMId = @intItemUOMId
						AND ROUND((cb.dblStockIn - cb.dblStockOut), 6) > 0  
						AND dbo.fnDateLessThanEquals(cb.dtmDate, @dtmDate) = 1
			) cb 

	IF @CostBucketId IS NULL AND @AllowNegativeInventory = @ALLOW_NEGATIVE_NO
	BEGIN 
		IF @UnitsOnHand > 0 
		BEGIN 
			DECLARE @strDate AS VARCHAR(20) = CONVERT(NVARCHAR(20), @dtmDate, 101) 
			RAISERROR(80096, 11, 1, @strDate, @strItemNo, @strLocationName)
		END 
		ELSE 
		BEGIN 
			RAISERROR(80003, 11, 1, @strItemNo, @strLocationName)
		END 
		RETURN -1
	END 
END 

DECLARE @cbOutOutId AS INT 
		,@cbId AS INT
		,@cbOutInventoryTransactionId AS INT
		,@cost AS NUMERIC(38, 20)
		,@intTransactionTypeId AS INT 

-- Check if there is available stocks to return from the Inventory Adjustment - Quantity Change. 
BEGIN 
	SELECT	TOP 1 
			@cbId = cb.intInventoryFIFOId
			,@cbOutOutId = cbOut.intId
			,@cbOutInventoryTransactionId = cbOut.intInventoryTransactionId
			,@cost = cb.dblCost
			,@intTransactionTypeId = cbOut.intTransactionTypeId
	FROM	tblICInventoryFIFO cb 
			OUTER APPLY (
				SELECT  TOP 1 
						cbOut.intId
						,cbOut.intInventoryTransactionId							
						,t.intTransactionTypeId
				FROM	tblICInventoryFIFOOut cbOut INNER JOIN tblICInventoryTransaction t
							ON cbOut.intInventoryTransactionId = t.intInventoryTransactionId
						INNER JOIN tblICInventoryTransactionType ty
							ON ty.intTransactionTypeId = t.intTransactionTypeId
				WHERE	cbOut.intInventoryFIFOId = cb.intInventoryFIFOId 
						AND ty.strName = 'Inventory Adjustment - Quantity Change'
						AND  (cbOut.dblQty - ISNULL(cbOut.dblQtyReturned, 0)) > 0 
			) cbOut
	WHERE	cb.intTransactionId = @intTransactionId
			AND cb.strTransactionId = @strTransactionId
			AND cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intItemUOMId = @intItemUOMId

	IF @cbOutOutId IS NOT NULL 
	BEGIN 
		UPDATE	cbOut 
		SET		-- Increase the return qty 
				dblQtyReturned = 
					ISNULL(cbOut.dblQtyReturned, 0) 
					+ CASE	WHEN (cbOut.dblQty - cbOut.dblQtyReturned) >= @dblQty THEN @dblQty
							ELSE (cbOut.dblQty - cbOut.dblQtyReturned) 
					END 
				-- update the remaining qty
				,@RemainingQty = 
						CASE	WHEN (cbOut.dblQty - cbOut.dblQtyReturned) >= @dblQty THEN 0
								ELSE (cbOut.dblQty - cbOut.dblQtyReturned) - @dblQty
						END
				-- retrieve the cost from the fifo bucket. 
				,@CostUsed = NULL 

				-- retrieve the	qty reduced from a fifo bucket 
				,@QtyOffset = 							
							CASE	WHEN (cbOut.dblQty - cbOut.dblQtyReturned) >= @dblQty THEN -@dblQty
									ELSE -(cbOut.dblQty - cbOut.dblQtyReturned) 
							END

				-- retrieve the id of the matching fifo bucket 
				,@FifoId = NULL 
		FROM	tblICInventoryFIFOOut cbOut
		WHERE	cbOut.intId = @cbOutOutId 

		-- Create a log of the return transaction. 
		INSERT INTO tblICInventoryReturned (
			intInventoryFIFOId
			,intInventoryTransactionId
			,intOutId
			,dblQtyReturned
			,dblCost
			,intTransactionId
			,strTransactionId
			,strBatchId
			,intTransactionTypeId 
		)
		SELECT 
			intInventoryFIFOId			= @cbId
			,intInventoryTransactionId	= @cbOutInventoryTransactionId
			,intOutId					= @cbOutOutId
			,dblQtyReturned				= @QtyOffset
			,dblCost					= @cost
			,intTransactionId			= @intTransactionId 
			,strTransactionId			= @strTransactionId
			,strBatchId					= @strBatchId
			,intTransactionTypeId		= @intTransactionTypeId
	END 
END 

-- Upsert (update or insert) a record in the cost bucket.
IF @cbOutOutId IS NULL 
BEGIN 
	MERGE	TOP(1)
	INTO	dbo.tblICInventoryFIFO 
	WITH	(HOLDLOCK) 
	AS		fifo_bucket	
	USING (
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,intItemUOMId = @intItemUOMId
				,intTransactionId = @intTransactionId
				,strTransactionId = @strTransactionId
	) AS Source_Query  
		ON fifo_bucket.intItemId = Source_Query.intItemId
		AND fifo_bucket.intItemLocationId = Source_Query.intItemLocationId
		AND fifo_bucket.intItemUOMId = Source_Query.intItemUOMId
		AND (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) > 0 
		AND dbo.fnDateGreaterThanEquals(@dtmDate, fifo_bucket.dtmDate) = 1
		--AND fifo_bucket.dblCost = @dblCost 
		AND fifo_bucket.intTransactionId = fifo_bucket.intTransactionId
		AND fifo_bucket.strTransactionId = fifo_bucket.strTransactionId 

	-- Update an existing cost bucket
	WHEN MATCHED THEN 
		UPDATE 
		SET	fifo_bucket.dblStockOut = 
				ISNULL(fifo_bucket.dblStockOut, 0) 
				+ CASE	WHEN (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) >= @dblQty THEN @dblQty
						ELSE (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) 
				END 

			,fifo_bucket.intConcurrencyId = ISNULL(fifo_bucket.intConcurrencyId, 0) + 1

			-- update the remaining qty
			,@RemainingQty = 
						CASE	WHEN (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) >= @dblQty THEN 0
								ELSE (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) - @dblQty
						END

			-- retrieve the cost from the fifo bucket. 
			,@CostUsed = fifo_bucket.dblCost

			-- retrieve the	qty reduced from a fifo bucket 
			,@QtyOffset = 
						CASE	WHEN (fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) >= @dblQty THEN -@dblQty
								ELSE -(fifo_bucket.dblStockIn - fifo_bucket.dblStockOut) 
						END

			-- retrieve the id of the matching fifo bucket 
			,@FifoId = fifo_bucket.intInventoryFIFOId

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
END 