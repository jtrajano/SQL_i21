/*
	This stored procedure either inserts or updates a LIFO cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReturnStockInLIFO]
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
	,@LIFOId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @dtmReceiptDate AS DATETIME 
		,@strReceiptSourceNumber AS NVARCHAR(50)

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty)

-- Initialize the remaining qty, cost used, LIFO id to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @QtyOffset = NULL;
SET @LIFOId = NULL;

DECLARE @cbOutOutId AS INT 
		,@cbId AS INT
		,@cbOutInventoryTransactionId AS INT
		,@cost AS NUMERIC(38, 20)
		,@intTransactionTypeId AS INT 

-- Check if there is available stocks to return from the Inventory Adjustment - Quantity Change. 
BEGIN 
	SELECT	TOP 1 
			@cbId = cb.intInventoryLIFOId
			,@cbOutOutId = cbOut.intId
			,@cbOutInventoryTransactionId = cbOut.intInventoryTransactionId
			,@cost = cb.dblCost --cbOut.dblCost
			,@intTransactionTypeId = cbOut.intTransactionTypeId
	FROM	tblICInventoryLIFO cb INNER JOIN (
				tblICInventoryReceipt rSource INNER JOIN tblICInventoryReceipt r
					ON rSource.intInventoryReceiptId = r.intSourceInventoryReceiptId
			)
				ON cb.intTransactionId = rSource.intInventoryReceiptId
				AND cb.strTransactionId = rSource.strReceiptNumber
			OUTER APPLY (
				SELECT  TOP 1 
						cbOut.intId
						,cbOut.intInventoryTransactionId							
						,t.intTransactionTypeId
						,t.dblCost
				FROM	tblICInventoryLIFOOut cbOut INNER JOIN tblICInventoryTransaction t
							ON cbOut.intInventoryTransactionId = t.intInventoryTransactionId
						INNER JOIN tblICInventoryTransactionType ty
							ON ty.intTransactionTypeId = t.intTransactionTypeId
				WHERE	cbOut.intInventoryLIFOId = cb.intInventoryLIFOId 
						AND ty.strName = 'Inventory Adjustment - Quantity Change'
						AND (cbOut.dblQty - ISNULL(cbOut.dblQtyReturned, 0)) > 0 
						AND ISNULL(t.ysnIsUnposted, 0) = 0 
			) cbOut
	WHERE	r.intInventoryReceiptId = @intTransactionId
			AND r.strReceiptNumber = @strTransactionId
			AND cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intItemUOMId = @intItemUOMId

	IF @cbOutOutId IS NOT NULL 
	BEGIN 
		UPDATE	cbOut 
		SET		-- Increase the return qty 
				dblQtyReturned = 
					ISNULL(cbOut.dblQtyReturned, 0) 
					+ CASE	WHEN (cbOut.dblQty - ISNULL(cbOut.dblQtyReturned, 0)) >= @dblQty THEN @dblQty
							ELSE (cbOut.dblQty - ISNULL(cbOut.dblQtyReturned, 0)) 
					END 
				-- update the remaining qty
				,@RemainingQty = 
						CASE	WHEN (cbOut.dblQty - ISNULL(cbOut.dblQtyReturned, 0)) >= @dblQty THEN 0
								ELSE (cbOut.dblQty - ISNULL(cbOut.dblQtyReturned, 0)) - @dblQty
						END
				-- retrieve the cost from the lifo bucket. 
				,@CostUsed = NULL 

				-- retrieve the	qty reduced from a lifo bucket 
				,@QtyOffset = 							
							CASE	WHEN (cbOut.dblQty - ISNULL(cbOut.dblQtyReturned, 0)) >= @dblQty THEN -@dblQty
									ELSE -(cbOut.dblQty - ISNULL(cbOut.dblQtyReturned, 0)) 
							END

				-- retrieve the id of the matching lifo bucket 
				,@LIFOId = NULL 
		FROM	tblICInventoryLIFOOut cbOut
		WHERE	cbOut.intId = @cbOutOutId 

		-- Create a log of the return transaction. 
		INSERT INTO tblICInventoryReturned (
			intInventoryLIFOId
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
			intInventoryLIFOId			= @cbId
			,intInventoryTransactionId	= @cbOutInventoryTransactionId
			,intOutId					= @cbOutOutId
			,dblQtyReturned				= -@QtyOffset
			,dblCost					= @cost
			,intTransactionId			= @intTransactionId 
			,strTransactionId			= @strTransactionId
			,strBatchId					= @strBatchId
			,intTransactionTypeId		= @intTransactionTypeId
	END 
END 

---- Validate if the cost bucket is negative. If Negative stock is not allowed, then block the posting. 
--IF @cbOutOutId IS NULL 
--BEGIN 
--	DECLARE @ALLOW_NEGATIVE_NO AS INT = 3

--	DECLARE @strItemNo AS NVARCHAR(50) 
--			,@strLocationName AS NVARCHAR(MAX) 
--			,@CostBucketId AS INT 
--			,@AllowNegativeInventory AS INT 
--			,@UnitsOnHand AS NUMERIC(38, 20)

--	-- Get the on-hand qty 
--	SELECT	@UnitsOnHand = s.dblUnitOnHand
--	FROM	tblICItemStock s
--	WHERE	s.intItemId = @intItemId
--			AND s.intItemLocationId = @intItemLocationId

--	SELECT	@strItemNo = i.strItemNo
--			,@CostBucketId = cb.intInventoryLIFOId
--			,@AllowNegativeInventory = il.intAllowNegativeInventory
--			,@strLocationName = cl.strLocationName
--	FROM	tblICItem i INNER JOIN tblICItemLocation il
--				ON i.intItemId = il.intItemId
--				AND il.intItemLocationId = @intItemLocationId
--			INNER JOIN tblSMCompanyLocation cl
--				ON cl.intCompanyLocationId = il.intLocationId
--			OUTER APPLY (
--				SELECT	TOP 1 cb.*
--				FROM	tblICInventoryLIFO cb INNER JOIN (
--							tblICInventoryReceipt rSource INNER JOIN tblICInventoryReceipt r
--								ON rSource.intInventoryReceiptId = r.intSourceInventoryReceiptId
--						)
--							ON cb.intTransactionId = rSource.intInventoryReceiptId
--							AND cb.strTransactionId = rSource.strReceiptNumber
--				WHERE	cb.intItemId = @intItemId
--						AND cb.intItemLocationId = @intItemLocationId
--						AND cb.intItemUOMId = @intItemUOMId
--						AND ROUND((cb.dblStockIn - cb.dblStockOut), 6) > 0  
--						AND dbo.fnDateGreaterThanEquals(cb.dtmDate, @dtmDate) = 1
--						AND r.intInventoryReceiptId = @intTransactionId
--						AND r.strReceiptNumber = @strTransactionId
--			) cb 

--	IF @CostBucketId IS NULL AND @AllowNegativeInventory = @ALLOW_NEGATIVE_NO
--	BEGIN 
--		IF @UnitsOnHand > 0 
--		BEGIN 
--			DECLARE @strDate AS VARCHAR(20) = CONVERT(NVARCHAR(20), @dtmDate, 101) 
--			RAISERROR(80096, 11, 1, @strDate, @strItemNo, @strLocationName)
--		END 
--		ELSE 
--		BEGIN 
--			RAISERROR(80003, 11, 1, @strItemNo, @strLocationName)
--		END 
--		RETURN -1
--	END 
--END 

-- Validate if the cost bucket is negative. If Negative stock is not allowed, then block the posting. 
IF @cbOutOutId IS NULL 
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
			,@CostBucketId = cb.intInventoryLIFOId
			,@AllowNegativeInventory = il.intAllowNegativeInventory
			,@strLocationName = cl.strLocationName
	FROM	tblICItem i INNER JOIN tblICItemLocation il
				ON i.intItemId = il.intItemId
				AND il.intItemLocationId = @intItemLocationId
			INNER JOIN tblSMCompanyLocation cl
				ON cl.intCompanyLocationId = il.intLocationId
			OUTER APPLY (
				SELECT	TOP 1 cb.*
				FROM	tblICInventoryLIFO cb INNER JOIN (
							tblICInventoryReceipt rSource INNER JOIN tblICInventoryReceipt r
								ON rSource.intInventoryReceiptId = r.intSourceInventoryReceiptId
						)
							ON cb.intTransactionId = rSource.intInventoryReceiptId
							AND cb.strTransactionId = rSource.strReceiptNumber
				WHERE	cb.intItemId = @intItemId
						AND cb.intItemLocationId = @intItemLocationId
						AND cb.intItemUOMId = @intItemUOMId
						AND ROUND((cb.dblStockIn - cb.dblStockOut), 6) > 0  
						AND dbo.fnDateLessThanEquals(cb.dtmDate, @dtmDate) = 1
						AND r.intInventoryReceiptId = @intTransactionId
						AND r.strReceiptNumber = @strTransactionId
			) cb 

	IF @CostBucketId IS NULL  
	BEGIN 
		-- Check the stock from the cb. 
		SET @UnitsOnHand = 0
		SELECT	@UnitsOnHand = ISNULL(ROUND((cb.dblStockIn - cb.dblStockOut), 6), 0) 
				,@strReceiptSourceNumber = cb.strTransactionId
				,@dtmReceiptDate = cb.dtmDate
		FROM	tblICItem i INNER JOIN tblICItemLocation il
					ON i.intItemId = il.intItemId
					AND il.intItemLocationId = @intItemLocationId
				INNER JOIN tblSMCompanyLocation cl
					ON cl.intCompanyLocationId = il.intLocationId
				OUTER APPLY (
					SELECT	TOP 1 cb.*
					FROM	tblICInventoryLIFO cb INNER JOIN (
								tblICInventoryReceipt rSource INNER JOIN tblICInventoryReceipt r
									ON rSource.intInventoryReceiptId = r.intSourceInventoryReceiptId
							)
								ON cb.intTransactionId = rSource.intInventoryReceiptId
								AND cb.strTransactionId = rSource.strReceiptNumber
					WHERE	cb.intItemId = @intItemId
							AND cb.intItemLocationId = @intItemLocationId
							AND cb.intItemUOMId = @intItemUOMId
							AND r.intInventoryReceiptId = @intTransactionId
							AND r.strReceiptNumber = @strTransactionId
				) cb 

		IF @UnitsOnHand > 0 
		BEGIN 
			DECLARE @strReturnDate AS VARCHAR(20) = CONVERT(NVARCHAR(20), @dtmDate, 101) 
			DECLARE @strReceiptDate AS VARCHAR(20) = CONVERT(NVARCHAR(20), @dtmReceiptDate, 101) 
			
			-- 'Check the return date on the transaction. Return date is {Return date}, while {Item Id} in {Receipt Id} is dated {Receipt date}.'
			RAISERROR('Check the return date on the transaction. Return date is %s, while %s in %s is dated %s.', 11, 1, @strReturnDate, @strItemNo, @strReceiptSourceNumber, @strReceiptDate)
		END 
		ELSE 
		BEGIN 
			-- 'Unable to do the return. All the stocks in {item id} from {receipt id} are fully returned already.'
			RAISERROR('Return is stopped. All of the stocks in %s that is received in %s are either sold, consumed, returned, or over-return is going to happen.', 11, 1, @strItemNo, @strReceiptSourceNumber)
		END 
		RETURN -1
	END 
END 

-- Upsert (update or insert) a record in the cost bucket.
IF @cbOutOutId IS NULL 
BEGIN
	MERGE	TOP(1)
	INTO	dbo.tblICInventoryLIFO 
	WITH	(HOLDLOCK) 
	AS		cb	
	USING (
		SELECT	intItemId = @intItemId
				,intItemLocationId = @intItemLocationId
				,intItemUOMId = @intItemUOMId
				,intTransactionId = rSource.intInventoryReceiptId
				,strTransactionId = rSource.strReceiptNumber
		FROM	tblICInventoryReceipt rSource INNER JOIN tblICInventoryReceipt r
					ON rSource.intInventoryReceiptId = r.intSourceInventoryReceiptId
		WHERE	r.intInventoryReceiptId = @intTransactionId
				AND r.strReceiptNumber = @strTransactionId
	) AS Source_Query 
		ON cb.intItemId = Source_Query.intItemId
		AND cb.intItemLocationId = Source_Query.intItemLocationId
		AND cb.intItemUOMId = Source_Query.intItemUOMId
		AND (cb.dblStockIn - cb.dblStockOut) > 0 
		AND dbo.fnDateLessThanEquals(cb.dtmDate, @dtmDate) = 1
		AND cb.intTransactionId = Source_Query.intTransactionId
		AND cb.strTransactionId = Source_Query.strTransactionId 

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
						CASE	WHEN (cb.dblStockIn - cb.dblStockOut) >= @dblQty THEN -@dblQty
								ELSE -(cb.dblStockIn - cb.dblStockOut) 
						END

			-- retrieve the id of the matching LIFO bucket 
			,@LIFOId = cb.intInventoryLIFOId

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