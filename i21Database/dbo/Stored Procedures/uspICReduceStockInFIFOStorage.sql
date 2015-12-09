﻿/*
	This stored procedure updates a fifo cost bucket for Storage items. 
	When new stock is coming OUT, it will try to determine if any postive stock it can update and decrease. 

	Negative stock is not allowed for Storage items. 
*/

CREATE PROCEDURE [dbo].[uspICReduceStockInFIFOStorage]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT 
	,@dtmDate AS DATETIME
	,@dblQty NUMERIC(18,6) 
	,@dblCost AS NUMERIC(18,6)
	,@strTransactionId AS NVARCHAR(40)
	,@intTransactionId AS INT
	,@intEntityUserSecurityId AS INT
	,@RemainingQty AS NUMERIC(18,6) OUTPUT
	,@CostUsed AS NUMERIC(18,6) OUTPUT 
	,@SourceInventoryFIFOStorageId AS INT OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strItemNo AS NVARCHAR(50)

-- Ensure the qty is a positive number
SET @dblQty = ABS(@dblQty)

-- Initialize the remaining qty, cost used, fifo id to NULL
SET @RemainingQty = NULL;
SET @CostUsed = NULL;
SET @SourceInventoryFIFOStorageId = NULL;

-- Update the TOP top record of the cost bucket. 
UPDATE  TOP(1) fifo_bucket_Storage		
SET		fifo_bucket_Storage.dblStockOut = ISNULL(fifo_bucket_Storage.dblStockOut, 0) 
					+ CASE	WHEN (fifo_bucket_Storage.dblStockIn - fifo_bucket_Storage.dblStockOut) >= @dblQty THEN @dblQty
							ELSE (fifo_bucket_Storage.dblStockIn - fifo_bucket_Storage.dblStockOut) 
					END 

		,fifo_bucket_Storage.intConcurrencyId = ISNULL(fifo_bucket_Storage.intConcurrencyId, 0) + 1

		-- update the remaining qty
		,@RemainingQty = 
					CASE	WHEN (fifo_bucket_Storage.dblStockIn - fifo_bucket_Storage.dblStockOut) >= @dblQty THEN 0
							ELSE (fifo_bucket_Storage.dblStockIn - fifo_bucket_Storage.dblStockOut) - @dblQty
					END

		-- retrieve the cost from the fifo bucket. 
		,@CostUsed = fifo_bucket_Storage.dblCost

		-- retrieve the id of the matching fifo bucket 
		,@SourceInventoryFIFOStorageId = fifo_bucket_Storage.intInventoryFIFOStorageId

FROM	dbo.tblICInventoryFIFOStorage fifo_bucket_Storage
WHERE	fifo_bucket_Storage.intItemId = @intItemId
		AND fifo_bucket_Storage.intItemLocationId = @intItemLocationId
		AND fifo_bucket_Storage.intItemUOMId = @intItemUOMId
		AND (fifo_bucket_Storage.dblStockIn - fifo_bucket_Storage.dblStockOut) > 0 
		AND dbo.fnDateGreaterThanEquals(@dtmDate, fifo_bucket_Storage.dtmDate) = 1

IF @SourceInventoryFIFOStorageId IS NULL 
BEGIN 
	DECLARE @strLocationName AS NVARCHAR(50)

	SELECT @strItemNo = strItemNo
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	SELECT	@strLocationName = CompanyLocation.strLocationName
	FROM	dbo.tblICItemLocation ItemLocation INNER JOIN dbo.tblSMCompanyLocation CompanyLocation
				ON ItemLocation.intLocationId = CompanyLocation.intCompanyLocationId
	WHERE	ItemLocation.intItemId = @intItemId
			AND ItemLocation.intItemLocationId = @intItemLocationId
			
	SELECT	@strItemNo = ISNULL(@strItemNo, '(Item id: ' + ISNULL(CAST(@intItemId AS NVARCHAR(10)), 'Blank') + ')')
			,@strLocationName = ISNULL(@strLocationName, '(Item Location id: ' + ISNULL(CAST(@intItemLocationId AS NVARCHAR(10)), 'Blank') + ')')
						
	-- 'Negative stock quantity is not allowed for {Item Name} on {Location Name}, {Sub Location Name}, and {Storage Location Name}.'	
	RAISERROR(80003, 11, 1, @strItemNo, @strLocationName, '(Blank Sub Location)', '(Blank Storage Location)') 
	GOTO _Exit;
END 

_Exit: 