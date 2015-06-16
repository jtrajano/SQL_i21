/*
	This stored procedure either inserts or updates a fifo cost bucket. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 
	Otherwise, it will insert a negative cost bucket. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInFIFOCustody]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@intUserId AS INT
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
	,@CostUsed AS NUMERIC(18,6) OUTPUT 
	,@SourceInventoryFIFOInCustodyId AS INT OUTPUT
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
SET @SourceInventoryFIFOInCustodyId = NULL;

DECLARE @intInventoryFIFOInCustodyId AS INT 

-- Validate for negative stock 
SELECT TOP  1 
		@intInventoryFIFOInCustodyId = intInventoryFIFOInCustodyId
FROM	dbo.tblICInventoryFIFOInCustody FIFO_Custody
WHERE	FIFO_Custody.intItemId = @intItemId
		AND FIFO_Custody.intItemLocationId = @intItemLocationId
		AND FIFO_Custody.intItemUOMId = @intItemUOMId
		AND ISNULL(FIFO_Custody.dblStockIn, 0) - ISNULL(FIFO_Custody.dblStockOut, 0) - ISNULL(@dblQty, 0) > 0

IF @intInventoryFIFOInCustodyId IS NULL 
BEGIN 
	-- Negative stock quantity is not allowed.
	RAISERROR(50029, 11, 1) 
	GOTO _Exit;
END 

-- Get the available stock in custody. 
SELECT TOP  1 
		@intInventoryFIFOInCustodyId = intInventoryFIFOInCustodyId
FROM	dbo.tblICInventoryFIFOInCustody FIFO_Custody
WHERE	FIFO_Custody.intItemId = @intItemId
		AND FIFO_Custody.intItemLocationId = @intItemLocationId
		AND FIFO_Custody.intItemUOMId = @intItemUOMId
		AND (FIFO_Custody.dblStockIn - FIFO_Custody.dblStockOut) > 0 

UPDATE	FIFO_Custody
SET		FIFO_Custody.dblStockOut = ISNULL(FIFO_Custody.dblStockOut, 0) 
					+ CASE	WHEN (FIFO_Custody.dblStockIn - FIFO_Custody.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (FIFO_Custody.dblStockIn - FIFO_Custody.dblStockOut) 
					END 
		,FIFO_Custody.intConcurrencyId = ISNULL(FIFO_Custody.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (FIFO_Custody.dblStockIn - FIFO_Custody.dblStockOut) >= @dblQty THEN 0
							ELSE (FIFO_Custody.dblStockIn - FIFO_Custody.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the Lot bucket. 
		,@CostUsed = FIFO_Custody.dblCost
FROM	dbo.tblICInventoryFIFOInCustody FIFO_Custody
WHERE	intInventoryFIFOInCustodyId = @intInventoryFIFOInCustodyId;

SET @SourceInventoryFIFOInCustodyId = @intInventoryFIFOInCustodyId; 

_Exit: 