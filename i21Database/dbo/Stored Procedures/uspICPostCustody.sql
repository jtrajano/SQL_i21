
/*
	This is the stored procedure that handles the receiving and release of custodial items. 
	
	It uses a cursor to iterate over the list of records found in @ItemsInCustody, a table-valued parameter (variable). 

	In each iteration, it does the following: 
		1. Determines if a stock is for incoming or outgoing then calls the appropriate stored procedure. 

	Parameters: 
	@ItemsInCustody - A user-defined table type. This is a table variable that tells this SP what items to process. 	
	
	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@intUserId - The user who is initiating the post. 
*/
CREATE PROCEDURE [dbo].[uspICPostCustody]
	@ItemsInCustody AS ItemCostingTableType READONLY
	,@strBatchId AS NVARCHAR(20)
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the variables to use for the cursor
DECLARE @intId AS INT 
		,@intItemId AS INT
		,@intItemLocationId AS INT 
		,@intItemUOMId AS INT 
		,@dtmDate AS DATETIME
		,@dblQty AS NUMERIC(18, 6) 
		,@dblUOMQty AS NUMERIC(18, 6)
		,@dblCost AS NUMERIC(18, 6)
		,@dblSalesPrice AS NUMERIC(18, 6)
		,@intCurrencyId AS INT 
		,@dblExchangeRate AS DECIMAL (38, 20) 
		,@intTransactionId AS INT
		,@intTransactionDetailId AS INT 
		,@strTransactionId AS NVARCHAR(40) 
		,@intTransactionTypeId AS INT 
		,@intLotId AS INT
		,@intSubLocationId AS INT
		,@intStorageLocationId AS INT 

DECLARE @CostingMethod AS INT 

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@STANDARDCOST AS INT = 4
		,@LOTCOST AS INT = 5

-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICValidateCostingOnPost
		@ItemsToValidate = @ItemsInCustody
END

-----------------------------------------------------------------------------------------------------------------------------
-- Create the cursor
-- Make sure the following options are used: 
-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
-----------------------------------------------------------------------------------------------------------------------------
DECLARE loopItems CURSOR LOCAL FAST_FORWARD
FOR 
SELECT  intId
		,intItemId
		,intItemLocationId
		,intItemUOMId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,intTransactionTypeId
		,intLotId
		,intSubLocationId
		,intStorageLocationId
FROM	@ItemsInCustody

OPEN loopItems;

-- Initial fetch attempt
FETCH NEXT FROM loopItems INTO 
	@intId
	,@intItemId
	,@intItemLocationId
	,@intItemUOMId
	,@dtmDate
	,@dblQty
	,@dblUOMQty
	,@dblCost
	,@dblSalesPrice
	,@intCurrencyId
	,@dblExchangeRate
	,@intTransactionId
	,@intTransactionDetailId
	,@strTransactionId
	,@intTransactionTypeId
	,@intLotId
	,@intSubLocationId
	,@intStorageLocationId;

-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 
	-- Initialize the costing method and negative inventory option. 
	SET @CostingMethod = NULL;

	-- Get the costing method of an item 
	SELECT	@CostingMethod = CostingMethod 
	FROM	dbo.fnGetCostingMethodAsTable(@intItemId, @intItemLocationId)

	--------------------------------------------------------------------------------
	-- Call the SP that can process the item's costing method
	--------------------------------------------------------------------------------
	-- TODO: Average Cost
	-- TODO: FIFO 
	-- TODO: LIFO 

	-- LOT 
	IF (@CostingMethod = @LOTCOST)
	BEGIN 
		EXEC dbo.uspICPostLotInCustody
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@intSubLocationId
				,@intStorageLocationId
				,@dtmDate
				,@intLotId
				,@dblQty
				,@dblUOMQty
				,@dblCost
				,@dblSalesPrice
				,@intCurrencyId
				,@dblExchangeRate
				,@intTransactionId
				,@intTransactionDetailId
				,@strTransactionId
				,@strBatchId
				,@intTransactionTypeId
				,@intUserId
	END

	-----------------------------------
	-- Update the Item Stock table
	-----------------------------------
	BEGIN 
		MERGE	
		INTO	dbo.tblICItemStock 
		WITH	(HOLDLOCK) 
		AS		ItemStock	
		USING (
				SELECT	intItemId = @intItemId
						,intItemLocationId = @intItemLocationId
						,Qty = dbo.fnCalculateStockUnitQty(@dblQty, @dblUOMQty) 
		) AS StockToUpdate
			ON ItemStock.intItemId = StockToUpdate.intItemId
			AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId

		-- If matched, update the unit on hand qty. 
		WHEN MATCHED THEN 
			UPDATE 
			SET		dblUnitInCustody = ISNULL(ItemStock.dblUnitInCustody, 0) + StockToUpdate.Qty

		-- If none found, insert a new item stock record
		WHEN NOT MATCHED THEN 
			INSERT (
				intItemId
				,intItemLocationId
				,dblUnitOnHand
				,dblUnitInCustody
				,dblOrderCommitted
				,dblOnOrder
				,dblLastCountRetail
				,intSort
				,intConcurrencyId
			)
			VALUES (
				StockToUpdate.intItemId
				,StockToUpdate.intItemLocationId
				,0					-- dblUnitOnHand
				,StockToUpdate.Qty	-- dblUnitInCustody
				,0					-- dblOrderCommitted
				,0					-- dblOnOrder
				,0					-- dblLastCountRetail
				,NULL				--  intSort
				,1					-- intConcurrencyId
			)
		;

		---------------------------------------
		-- Update the Item Stock UOM table
		---------------------------------------
		MERGE	
		INTO	dbo.tblICItemStockUOM 
		WITH	(HOLDLOCK) 
		AS		ItemStock	
		USING (
				SELECT	intItemId = @intItemId
						,intItemLocationId = @intItemLocationId
						,intItemUOMId = @intItemUOMId
						,intSubLocationId = @intSubLocationId 
						,intStorageLocationId = @intStorageLocationId
						,Qty = ISNULL(@dblQty, 0) 
		) AS StockToUpdate
			ON ItemStock.intItemId = StockToUpdate.intItemId
			AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId
			AND ItemStock.intItemUOMId = StockToUpdate.intItemUOMId
			AND ISNULL(ItemStock.intSubLocationId, 0) = ISNULL(StockToUpdate.intSubLocationId, 0)
			AND ISNULL(ItemStock.intStorageLocationId, 0) = ISNULL(StockToUpdate.intStorageLocationId, 0)

		-- If matched, update the unit on hand qty. 
		WHEN MATCHED THEN 
			UPDATE 
			SET		dblInCustody = ISNULL(ItemStock.dblInCustody, 0) + StockToUpdate.Qty

		-- If none found, insert a new item stock record
		WHEN NOT MATCHED THEN 
			INSERT (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,dblOnHand
				,dblInCustody
				,dblOnOrder
				,intConcurrencyId
			)
			VALUES (
				StockToUpdate.intItemId
				,StockToUpdate.intItemLocationId
				,StockToUpdate.intItemUOMId
				,StockToUpdate.intSubLocationId
				,StockToUpdate.intStorageLocationId
				,0
				,StockToUpdate.Qty 
				,0
				,1	
			)
		;

		-- Update the Lot's Qty and Weights. 
		UPDATE	Lot 
		SET		Lot.dblQty = dbo.fnCalculateLotQty(Lot.intItemUOMId, @intItemUOMId, Lot.dblQty, Lot.dblWeight, @dblQty, Lot.dblWeightPerQty)
				,Lot.dblWeight = dbo.fnCalculateLotWeight(Lot.intItemUOMId, Lot.intWeightUOMId, @intItemUOMId, Lot.dblWeight, @dblQty, Lot.dblWeightPerQty)
				,Lot.dblLastCost = CASE WHEN @dblQty > 0 THEN @dblCost ELSE Lot.dblLastCost END 
		FROM	dbo.tblICLot Lot
		WHERE	Lot.intItemLocationId = @intItemLocationId
				AND Lot.intLotId = @intLotId
	END 

	-- Attempt to fetch the next row from cursor. 
	FETCH NEXT FROM loopItems INTO 
		@intId
		,@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@dtmDate
		,@dblQty
		,@dblUOMQty
		,@dblCost
		,@dblSalesPrice
		,@intCurrencyId
		,@dblExchangeRate
		,@intTransactionId
		,@intTransactionDetailId
		,@strTransactionId
		,@intTransactionTypeId
		,@intLotId
		,@intSubLocationId
		,@intStorageLocationId
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

CLOSE loopItems;
DEALLOCATE loopItems;