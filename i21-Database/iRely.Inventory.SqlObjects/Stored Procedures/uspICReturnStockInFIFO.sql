/*
	This stored procedure either inserts or updates a fifo cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReturnStockInFIFO]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@strBatchId AS NVARCHAR(40)
	,@dtmReturnDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(38, 20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@intTransactionDetailId AS INT
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

DECLARE @dtmReceiptDate AS DATETIME 
		,@strReceiptSourceNumber AS NVARCHAR(50)

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty)

-- Initialize the remaining qty, cost used, fifo id to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @QtyOffset = NULL;
SET @FifoId = NULL;

DECLARE @cbOutOutId AS INT 
		,@cbId AS INT
		,@cbOutInventoryTransactionId AS INT
		,@cost AS NUMERIC(38, 20)
		,@intTransactionTypeId AS INT 

-- Validate if the cost bucket is negative. If Negative stock is not allowed, then block the posting. 
BEGIN 
	DECLARE @ALLOW_NEGATIVE_NO AS INT = 3

	DECLARE @strItemNo AS NVARCHAR(50) 
			,@strLocationName AS NVARCHAR(2000) 
			,@CostBucketId AS INT 
			,@AllowNegativeInventory AS INT 
			,@UnitsOnHand AS NUMERIC(38, 20)

	-- Get the on-hand qty for the item location regardless of date. 
	SELECT	@UnitsOnHand = s.dblUnitOnHand 
	FROM	tblICItemStock s
	WHERE	s.intItemId = @intItemId
			AND s.intItemLocationId = @intItemLocationId

	SELECT	@strItemNo = i.strItemNo
			,@AllowNegativeInventory = il.intAllowNegativeInventory
			,@strLocationName = cl.strLocationName
			,@CostBucketId = cb.intInventoryFIFOId
			,@dtmReceiptDate = cb.dtmDate
			,@strReceiptSourceNumber = cb.strTransactionId
			,@CostUsed = cb.dblCost 
	FROM	tblICItem i INNER JOIN tblICItemLocation il
				ON i.intItemId = il.intItemId
				AND il.intItemLocationId = @intItemLocationId
			INNER JOIN tblSMCompanyLocation cl
				ON cl.intCompanyLocationId = il.intLocationId
			OUTER APPLY (
				SELECT	TOP 1 
						cb.*
				FROM	tblICInventoryFIFO cb INNER JOIN (
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

	IF (@UnitsOnHand - @dblQty) < 0 AND @AllowNegativeInventory = @ALLOW_NEGATIVE_NO
	BEGIN 
		-- 'Negative stock quantity is not allowed for {Item No} at {Location}.'
		EXEC uspICRaiseError 80003, @strItemNo, @strLocationName;
		RETURN -80003
	END

	IF dbo.fnDateLessThan(@dtmReceiptDate, @dtmReturnDate) = 1
	BEGIN 
		DECLARE @strReturnDate AS VARCHAR(20) = CONVERT(NVARCHAR(20), @dtmReturnDate, 101) 
		DECLARE @strReceiptDate AS VARCHAR(20) = CONVERT(NVARCHAR(20), @dtmReceiptDate, 101) 
			
		-- 'Check the return date on the transaction. Return date is {Return date}, while {Item Id} in {Receipt Id} is dated {Receipt date}.'
		EXEC uspICRaiseError 80108, @strReturnDate, @strItemNo, @strReceiptSourceNumber, @strReceiptDate;
		RETURN -80108
	END 
END 

-- Upsert (update or insert) a record in the cost bucket.
IF @cbOutOutId IS NULL 
BEGIN 
	MERGE	TOP(1)
	INTO	dbo.tblICInventoryFIFO 
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
		AND dbo.fnDateLessThanEquals(cb.dtmDate, @dtmReturnDate) = 1
		AND cb.intTransactionId = Source_Query.intTransactionId
		AND cb.strTransactionId = Source_Query.strTransactionId 

	-- Update an existing cost bucket
	WHEN MATCHED THEN 
		UPDATE 
		SET	cb.dblStockOut = 
				ISNULL(cb.dblStockOut, 0) 
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
						CASE	WHEN (cb.dblStockIn - cb.dblStockOut) >= @dblQty THEN -@dblQty
								ELSE -(cb.dblStockIn - cb.dblStockOut) 
						END

			-- retrieve the id of the matching fifo bucket 
			,@FifoId = cb.intInventoryFIFOId

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
			,@dtmReturnDate
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

	-- If Update was not performed, assume an insert was done. 
	SELECT @FifoId = SCOPE_IDENTITY() WHERE @FifoId IS NULL; 

	-- Update the Qty Offset 
	SELECT @QtyOffset = -@dblQty WHERE @QtyOffset IS NULL; 
END 