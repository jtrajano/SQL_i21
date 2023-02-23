﻿/*
	This stored procedure either inserts or updates an Actual-Cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReturnStockInActualCost]
	@strActualCostId AS NVARCHAR(50)
	,@intItemId AS INT
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
	,@ActualCostId AS INT OUTPUT
	,@intCurrencyId AS INT OUTPUT 
	,@intForexRateTypeId AS INT OUTPUT
	,@dblForexRate AS NUMERIC(38, 20) OUTPUT
	,@dblForexCost AS NUMERIC(38, 20) 
	,@ForexCostUsed AS NUMERIC(38,20) OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @dtmReceiptDate AS DATETIME 
		,@strReceiptSourceNumber AS NVARCHAR(50)

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty)

-- Initialize the remaining qty, cost used, ActualCost id to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @QtyOffset = NULL;
SET @ActualCostId = NULL;

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
			,@CostBucketId = cb.intInventoryActualCostId
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
				FROM	tblICInventoryActualCost cb INNER JOIN (
							tblICInventoryReceipt rSource INNER JOIN tblICInventoryReceipt r
								ON rSource.intInventoryReceiptId = r.intSourceInventoryReceiptId
						)
							ON cb.intTransactionId = rSource.intInventoryReceiptId
							AND cb.strTransactionId = rSource.strReceiptNumber
				WHERE	cb.strActualCostId = @strActualCostId 
						AND cb.intItemId = @intItemId
						AND cb.intItemLocationId = @intItemLocationId
						AND cb.intItemUOMId = @intItemUOMId
						AND r.intInventoryReceiptId = @intTransactionId
						AND r.strReceiptNumber = @strTransactionId
			) cb 

	IF (@UnitsOnHand - @dblQty) < 0 --AND @AllowNegativeInventory = @ALLOW_NEGATIVE_NO
	BEGIN 
		-- 'Negative stock quantity is not allowed for {Item No} at {Location}.'
		EXEC uspICRaiseError 80003, @strItemNo, @strLocationName;
		RETURN -80003
	END

	IF dbo.fnDateLessThan(@dtmReturnDate, @dtmReceiptDate) = 1
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
	INTO	dbo.tblICInventoryActualCost 
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
		ON 
		cb.strActualCostId = @strActualCostId 
		AND cb.intItemId = Source_Query.intItemId
		AND cb.intItemLocationId = Source_Query.intItemLocationId
		AND cb.intItemUOMId = Source_Query.intItemUOMId
		--AND (cb.dblStockIn - cb.dblStockOut) > 0 
		--AND dbo.fnDateLessThanEquals(cb.dtmDate, @dtmReturnDate) = 1
		AND FLOOR(CAST(cb.dtmDate AS FLOAT)) <= FLOOR(CAST(@dtmReturnDate AS FLOAT))
		AND cb.dblStockAvailable > 0
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

			-- retrieve the cost from the ActualCost bucket. 
			,@CostUsed = cb.dblCost
			,@ForexCostUsed = cb.dblForexCost

			-- retrieve the	qty reduced from a ActualCost bucket 
			,@QtyOffset = 
						CASE	WHEN (cb.dblStockIn - cb.dblStockOut) >= @dblQty THEN -@dblQty
								ELSE -(cb.dblStockIn - cb.dblStockOut) 
						END

			-- retrieve the id of the matching ActualCost bucket 
			,@ActualCostId = cb.intInventoryActualCostId

			-- retrieve the forex fields from the lot cost bucket. 
			,@intCurrencyId = cb.intCurrencyId 
			,@intForexRateTypeId = cb.intForexRateTypeId
			,@dblForexRate = cb.dblForexRate 

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
	SELECT @ActualCostId = SCOPE_IDENTITY() WHERE @ActualCostId IS NULL; 

	-- Update the Qty Offset 
	SELECT @QtyOffset = -@dblQty WHERE @QtyOffset IS NULL; 
END 