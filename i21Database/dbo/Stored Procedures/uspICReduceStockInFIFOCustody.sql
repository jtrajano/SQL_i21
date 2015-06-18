/*
	This stored procedure updates a fifo cost bucket for custody items. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 

	Negative stock is not allowed for custody items. 
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

-- Initialize the remaining qty, cost used, fifo id to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @SourceInventoryFIFOInCustodyId = NULL;

-- Update the TOP top record of the cost bucket. 
UPDATE  TOP(1) fifo_bucket_custody		
SET		fifo_bucket_custody.dblStockOut = ISNULL(fifo_bucket_custody.dblStockOut, 0) 
					+ CASE	WHEN (fifo_bucket_custody.dblStockIn - fifo_bucket_custody.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (fifo_bucket_custody.dblStockIn - fifo_bucket_custody.dblStockOut) 
					END 

		,fifo_bucket_custody.intConcurrencyId = ISNULL(fifo_bucket_custody.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (fifo_bucket_custody.dblStockIn - fifo_bucket_custody.dblStockOut) >= @dblQty THEN 0
							ELSE (fifo_bucket_custody.dblStockIn - fifo_bucket_custody.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the fifo bucket. 
		,@CostUsed = fifo_bucket_custody.dblCost

		-- retrieve the id of the matching fifo bucket 
		,@SourceInventoryFIFOInCustodyId = fifo_bucket_custody.intInventoryFIFOInCustodyId

FROM	dbo.tblICInventoryFIFOInCustody fifo_bucket_custody
WHERE	fifo_bucket_custody.intItemId = @intItemId
		AND fifo_bucket_custody.intItemLocationId = @intItemLocationId
		AND fifo_bucket_custody.intItemUOMId = @intItemUOMId
		AND (fifo_bucket_custody.dblStockIn - fifo_bucket_custody.dblStockOut) > 0 
		AND dbo.fnDateGreaterThanEquals(@dtmDate, fifo_bucket_custody.dtmDate) = 1

IF @SourceInventoryFIFOInCustodyId IS NULL 
BEGIN 
	-- Negative stock quantity is not allowed.
	RAISERROR(50029, 11, 1) 
	GOTO _Exit;
END 

_Exit: 