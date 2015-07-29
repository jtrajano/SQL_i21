/*
	This stored procedure either inserts or updates Lot under the company's custody. 
	When new stock is coming OUT, it will try to determine if an available postive stock. If found, the stock will be decreased. 
	Otherwise, it will throw an error. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInLotCustody]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME
	,@intLotId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT 
	,@intUserId AS INT
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
	,@CostUsed AS NUMERIC(18,6) OUTPUT 	 
	,@SourceInventoryLotInCustodyId AS INT OUTPUT 
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
SET @SourceInventoryLotInCustodyId = NULL;

DECLARE @intInventoryLotInCustodyId AS INT 

-- Validate for negative stock 
SELECT TOP  1 
		@intInventoryLotInCustodyId = intInventoryLotInCustodyId
FROM	dbo.tblICInventoryLotInCustody Lot_Custody
WHERE	Lot_Custody.intItemId = @intItemId
		AND Lot_Custody.intItemLocationId = @intItemLocationId
		AND Lot_Custody.intItemUOMId = @intItemUOMId
		AND Lot_Custody.intLotId = @intLotId
		AND ISNULL(Lot_Custody.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
		AND ISNULL(Lot_Custody.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
		AND ISNULL(Lot_Custody.dblStockIn, 0) - ISNULL(Lot_Custody.dblStockOut, 0) - ISNULL(@dblQty, 0) > 0

IF @intInventoryLotInCustodyId IS NULL 
BEGIN 
	-- Negative stock quantity is not allowed.
	RAISERROR(50029, 11, 1) 
	GOTO _Exit;
END 

-- Get the available stock in custody. 
SELECT TOP  1 
		@intInventoryLotInCustodyId = intInventoryLotInCustodyId
FROM	dbo.tblICInventoryLotInCustody Lot_Custody
WHERE	Lot_Custody.intItemId = @intItemId
		AND Lot_Custody.intItemLocationId = @intItemLocationId
		AND Lot_Custody.intItemUOMId = @intItemUOMId
		AND Lot_Custody.intLotId = @intLotId
		AND ISNULL(Lot_Custody.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
		AND ISNULL(Lot_Custody.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
		AND (Lot_Custody.dblStockIn - Lot_Custody.dblStockOut) > 0 
		AND dbo.fnDateGreaterThanEquals(@dtmDate, Lot_Custody.dtmDate) = 1

UPDATE	Lot_Custody
SET		Lot_Custody.dblStockOut = ISNULL(Lot_Custody.dblStockOut, 0) 
					+ CASE	WHEN (Lot_Custody.dblStockIn - Lot_Custody.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (Lot_Custody.dblStockIn - Lot_Custody.dblStockOut) 
					END 
		,Lot_Custody.intConcurrencyId = ISNULL(Lot_Custody.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (Lot_Custody.dblStockIn - Lot_Custody.dblStockOut) >= @dblQty THEN 0
							ELSE (Lot_Custody.dblStockIn - Lot_Custody.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the Lot bucket. 
		,@CostUsed = Lot_Custody.dblCost
FROM	dbo.tblICInventoryLotInCustody Lot_Custody
WHERE	intInventoryLotInCustodyId = @intInventoryLotInCustodyId;

SET @SourceInventoryLotInCustodyId = @intInventoryLotInCustodyId; 

_Exit: 