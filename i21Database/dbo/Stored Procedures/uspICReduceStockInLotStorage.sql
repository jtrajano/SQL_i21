/*
	This stored procedure either inserts or updates Lot under the company's Storage. 
	When new stock is coming OUT, it will try to determine if an available postive stock. If found, the stock will be decreased. 
	Otherwise, it will throw an error. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInLotStorage]
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
	,@SourceInventoryLotStorageId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strItemNo AS NVARCHAR(50)

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty)

-- Initialize the remaining qty, cost used, Lot id to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @SourceInventoryLotStorageId = NULL;

DECLARE @intInventoryLotStorageId AS INT 

-- Validate for negative stock 
SELECT TOP  1 
		@intInventoryLotStorageId = intInventoryLotStorageId
FROM	dbo.tblICInventoryLotStorage Lot_Storage
WHERE	Lot_Storage.intItemId = @intItemId
		AND Lot_Storage.intItemLocationId = @intItemLocationId
		AND Lot_Storage.intItemUOMId = @intItemUOMId
		AND Lot_Storage.intLotId = @intLotId
		AND ISNULL(Lot_Storage.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
		AND ISNULL(Lot_Storage.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
		AND ISNULL(Lot_Storage.dblStockIn, 0) - ISNULL(Lot_Storage.dblStockOut, 0) - ISNULL(@dblQty, 0) > 0

IF @intInventoryLotStorageId IS NULL 
BEGIN 
	DECLARE @strLocationName AS NVARCHAR(MAX)

	SELECT @strItemNo = strItemNo
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId
			
	SELECT	@strItemNo = ISNULL(@strItemNo, '(Item id: ' + ISNULL(CAST(@intItemId AS NVARCHAR(10)), 'Blank') + ')')
			,@strLocationName = dbo.fnFormatMsg80003 (
					@intItemLocationId
					,NULL -- @intSubLocationId
					,NULL -- @intStorageLocationId
			)
						
	-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Sub Location Name}, and {Storage Location Name}.'	
	RAISERROR(80003, 11, 1, @strItemNo, @strLocationName) 
	GOTO _Exit;
END 

-- Get the available stock in Storage. 
SELECT TOP  1 
		@intInventoryLotStorageId = intInventoryLotStorageId
FROM	dbo.tblICInventoryLotStorage Lot_Storage
WHERE	Lot_Storage.intItemId = @intItemId
		AND Lot_Storage.intItemLocationId = @intItemLocationId
		AND Lot_Storage.intItemUOMId = @intItemUOMId
		AND Lot_Storage.intLotId = @intLotId
		AND ISNULL(Lot_Storage.intSubLocationId, 0) = ISNULL(@intSubLocationId, 0)
		AND ISNULL(Lot_Storage.intStorageLocationId, 0) = ISNULL(@intStorageLocationId, 0)
		AND (Lot_Storage.dblStockIn - Lot_Storage.dblStockOut) > 0 
		AND dbo.fnDateGreaterThanEquals(@dtmDate, Lot_Storage.dtmDate) = 1

UPDATE	Lot_Storage
SET		Lot_Storage.dblStockOut = ISNULL(Lot_Storage.dblStockOut, 0) 
					+ CASE	WHEN (Lot_Storage.dblStockIn - Lot_Storage.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (Lot_Storage.dblStockIn - Lot_Storage.dblStockOut) 
					END 
		,Lot_Storage.intConcurrencyId = ISNULL(Lot_Storage.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (Lot_Storage.dblStockIn - Lot_Storage.dblStockOut) >= @dblQty THEN 0
							ELSE (Lot_Storage.dblStockIn - Lot_Storage.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the Lot bucket. 
		,@CostUsed = Lot_Storage.dblCost
FROM	dbo.tblICInventoryLotStorage Lot_Storage
WHERE	intInventoryLotStorageId = @intInventoryLotStorageId;

SET @SourceInventoryLotStorageId = @intInventoryLotStorageId; 

_Exit: 