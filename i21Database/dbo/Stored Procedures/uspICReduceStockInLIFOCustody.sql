﻿/*
	This stored procedure updates a LIFO cost bucket for custody items. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 

	Negative stock is not allowed for custody items. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInLIFOCustody]
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
	,@SourceInventoryLIFOInCustodyId AS INT OUTPUT
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
SET @SourceInventoryLIFOInCustodyId = NULL;

-- Update the TOP top record of the cost bucket. 
UPDATE  TOP(1) LIFO_bucket_custody		
SET		LIFO_bucket_custody.dblStockOut = ISNULL(LIFO_bucket_custody.dblStockOut, 0) 
					+ CASE	WHEN (LIFO_bucket_custody.dblStockIn - LIFO_bucket_custody.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (LIFO_bucket_custody.dblStockIn - LIFO_bucket_custody.dblStockOut) 
					END 

		,LIFO_bucket_custody.intConcurrencyId = ISNULL(LIFO_bucket_custody.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (LIFO_bucket_custody.dblStockIn - LIFO_bucket_custody.dblStockOut) >= @dblQty THEN 0
							ELSE (LIFO_bucket_custody.dblStockIn - LIFO_bucket_custody.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the LIFO bucket. 
		,@CostUsed = LIFO_bucket_custody.dblCost

		-- retrieve the id of the matching LIFO bucket 
		,@SourceInventoryLIFOInCustodyId = LIFO_bucket_custody.intInventoryLIFOInCustodyId

FROM	dbo.tblICInventoryLIFOInCustody LIFO_bucket_custody
WHERE	LIFO_bucket_custody.intItemId = @intItemId
		AND LIFO_bucket_custody.intItemLocationId = @intItemLocationId
		AND LIFO_bucket_custody.intItemUOMId = @intItemUOMId
		AND (LIFO_bucket_custody.dblStockIn - LIFO_bucket_custody.dblStockOut) > 0 
		AND dbo.fnDateGreaterThanEquals(@dtmDate, LIFO_bucket_custody.dtmDate) = 1

IF @SourceInventoryLIFOInCustodyId IS NULL 
BEGIN 
	-- Negative stock quantity is not allowed.
	RAISERROR(50029, 11, 1) 
	GOTO _Exit;
END 

_Exit: 