/*
	This stored procedure updates a LIFO cost bucket for Storage items. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 

	Negative stock is not allowed for Storage items. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInLIFOStorage]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(38, 20)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@intUserId AS INT
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
	,@CostUsed AS NUMERIC(18,6) OUTPUT 
	,@SourceInventoryLIFOStorageId AS INT OUTPUT
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
SET @SourceInventoryLIFOStorageId = NULL;

-- Update the TOP top record of the cost bucket. 
UPDATE  TOP(1) LIFO_bucket_Storage		
SET		LIFO_bucket_Storage.dblStockOut = ISNULL(LIFO_bucket_Storage.dblStockOut, 0) 
					+ CASE	WHEN (LIFO_bucket_Storage.dblStockIn - LIFO_bucket_Storage.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (LIFO_bucket_Storage.dblStockIn - LIFO_bucket_Storage.dblStockOut) 
					END 

		,LIFO_bucket_Storage.intConcurrencyId = ISNULL(LIFO_bucket_Storage.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (LIFO_bucket_Storage.dblStockIn - LIFO_bucket_Storage.dblStockOut) >= @dblQty THEN 0
							ELSE (LIFO_bucket_Storage.dblStockIn - LIFO_bucket_Storage.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the LIFO bucket. 
		,@CostUsed = LIFO_bucket_Storage.dblCost

		-- retrieve the id of the matching LIFO bucket 
		,@SourceInventoryLIFOStorageId = LIFO_bucket_Storage.intInventoryLIFOStorageId

FROM	dbo.tblICInventoryLIFOStorage LIFO_bucket_Storage
WHERE	LIFO_bucket_Storage.intItemId = @intItemId
		AND LIFO_bucket_Storage.intItemLocationId = @intItemLocationId
		AND LIFO_bucket_Storage.intItemUOMId = @intItemUOMId
		AND (LIFO_bucket_Storage.dblStockIn - LIFO_bucket_Storage.dblStockOut) > 0 
		AND dbo.fnDateGreaterThanEquals(@dtmDate, LIFO_bucket_Storage.dtmDate) = 1

IF @SourceInventoryLIFOStorageId IS NULL 
BEGIN 
	-- Negative stock quantity is not allowed.
	RAISERROR(50029, 11, 1) 
	GOTO _Exit;
END 

_Exit: 