
/*
	This is the stored procedure that handles the adjustment to the item cost. 
	
	It uses a cursor to iterate over the list of records found in @ItemsToAdjust, a table-valued parameter (variable). 

	Parameters: 
	@ItemsToAdjust - A user-defined table type. This is a table variable that tells this SP what items to process. 	
	
	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@strAccountDescription - The contra g/l account id to use when posting an item. By default, it is set to "Cost of Goods". 
				The calling code needs to specify it because each module may use a different contra g/l account against the 
				Inventory account. For example, a Sales transaction will contra Inventory account with "Cost of Goods" while 
				Receive stocks from AP module may use "AP Clearing".

	@intUserId - The user who is initiating the post. 
*/
CREATE PROCEDURE [dbo].[uspICPostCostAdjustment]
	@ItemsToAdjust AS ItemCostAdjustmentTableType READONLY
	,@strBatchId AS NVARCHAR(20)
	,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost Adjustment'
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INVENTORY_AUTO_NEGATIVE AS INT = 1;
DECLARE @INVENTORY_WRITE_OFF_SOLD AS INT = 2;
DECLARE @INVENTORY_REVALUE_SOLD AS INT = 3;
DECLARE @INVENTORY_COST_VARIANCE AS INT = 11;

-- Declare the variables to use for the cursor
DECLARE @intId AS INT 
		,@intItemId AS INT
		,@intItemLocationId AS INT 
		,@intItemUOMId AS INT 
		,@intSubLocationId AS INT
		,@intStorageLocationId AS INT 
		,@dtmDate AS DATETIME
		,@dblQty AS NUMERIC(18,6)
		,@dblNewCost AS NUMERIC(38, 20)
		,@intTransactionId AS INT
		,@intTransactionDetailId AS INT
		,@strTransactionId AS NVARCHAR(40) 
		,@intSourceTransactionId AS INT
		,@strSourceTransactionId AS NVARCHAR(40) 
		,@intTransactionTypeId AS INT 
		,@intCurrencyId AS INT 
		,@dblExchangeRate AS NUMERIC(38,20)
		,@intLotId AS INT 

DECLARE @CostingMethod AS INT 
		,@TransactionTypeName AS NVARCHAR(200) 
		,@InventoryTransactionIdentityId INT

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	

-- Initialize the transaction name. Use this as the transaction form name
SELECT	TOP 1 
		@TransactionTypeName = strName
FROM	dbo.tblICInventoryTransactionType
WHERE	intTransactionTypeId = @intTransactionTypeId

-----------------------------------------------------------------------------------------------------------------------------
-- TODO: Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
--BEGIN 
--	EXEC [dbo].[uspICValidateCostingOnPost] 
--		@ItemsToValidate = @ItemsToAdjust
--END

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
		,intSubLocationId
		,intStorageLocationId
		,dtmDate
		,dblQty 
		,dblNewCost
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,intSourceTransactionId
		,strSourceTransactionId
		,intTransactionTypeId
		,intLotId 
		,intCurrencyId
		,dblExchangeRate
FROM	@ItemsToAdjust

OPEN loopItems;

-- Initial fetch attempt
FETCH NEXT FROM loopItems INTO 
	@intId
	,@intItemId
	,@intItemLocationId
	,@intItemUOMId
	,@intSubLocationId
	,@intStorageLocationId
	,@dtmDate
	,@dblQty
	,@dblNewCost
	,@intTransactionId
	,@intTransactionDetailId
	,@strTransactionId
	,@intSourceTransactionId
	,@strSourceTransactionId
	,@intTransactionTypeId
	,@intLotId
	,@intCurrencyId
	,@dblExchangeRate
;

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
	-- Average Cost
	IF (@CostingMethod = @AVERAGECOST)
	BEGIN 
		EXEC dbo.uspICPostCostAdjustmentOnAverageCosting
			@dtmDate
			,@intItemId
			,@intItemLocationId
			,@intSubLocationId
			,@intStorageLocationId
			,@intItemUOMId
			,@dblQty			
			,@dblNewCost 
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@intSourceTransactionId
			,@strSourceTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@intCurrencyId
			,@dblExchangeRate			
			,@intUserId
	END

	-- Attempt to fetch the next row from cursor. 
	FETCH NEXT FROM loopItems INTO 
		@intId
		,@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@intSubLocationId
		,@intStorageLocationId
		,@dtmDate
		,@dblQty
		,@dblNewCost
		,@intTransactionId
		,@intTransactionDetailId
		,@strTransactionId
		,@intSourceTransactionId
		,@strSourceTransactionId
		,@intTransactionTypeId
		,@intLotId
		,@intCurrencyId
		,@dblExchangeRate
	;
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

CLOSE loopItems;
DEALLOCATE loopItems;

-----------------------------------------------------------------------------------------------------------------------------
-- Adjust the average cost regardless of costing method.
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 						
	-- Update the Item Pricing table
	MERGE	
	INTO	dbo.tblICItemPricing 
	WITH	(HOLDLOCK) 
	AS		ItemPricing
	USING (
			SELECT	tblICItemStock.intItemId
					,tblICItemStock.intItemLocationId
					,tblICItemStock.dblUnitOnHand
			FROM	dbo.tblICItemStock INNER JOIN @ItemsToAdjust ItemsToAdjust
						ON tblICItemStock.intItemId = ItemsToAdjust.intItemId
						AND tblICItemStock.intItemLocationId = ItemsToAdjust.intItemLocationId
	) AS Stock
		ON ItemPricing.intItemId = Stock.intItemId
		AND ItemPricing.intItemLocationId = Stock.intItemLocationId

	-- If matched, update the average cost, last cost, and standard cost
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblAverageCost =	CASE	WHEN ISNULL(Stock.dblUnitOnHand, 0) > 0 THEN 
												-- Recalculate the average cost
												dbo.fnRecalculateAverageCost(Stock.intItemId, Stock.intItemLocationId, ItemPricing.dblAverageCost) 
											ELSE 
												-- Use the same average cost. 
												ItemPricing.dblAverageCost
									END
	;
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Create the Auto Negative
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 

	-----------------------------------------------------------------------------------------------------------------------------
	-- Begin of the loop
	-----------------------------------------------------------------------------------------------------------------------------
	DECLARE loopItemsForAutoNegative CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  intId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dtmDate
			,dblNewCost
			,intTransactionId
			,intTransactionDetailId
			,strTransactionId
			,intTransactionTypeId
			,intLotId 
	FROM	@ItemsToAdjust

	OPEN loopItemsForAutoNegative;

	-- Initial fetch attempt
	FETCH NEXT FROM loopItemsForAutoNegative INTO 
		@intId
		,@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@intSubLocationId
		,@intStorageLocationId
		,@dtmDate
		,@dblNewCost
		,@intTransactionId
		,@intTransactionDetailId
		,@strTransactionId
		,@intTransactionTypeId
		,@intLotId
	;

	DECLARE @AutoNegativeAmount AS NUMERIC(38, 20)
	WHILE @@FETCH_STATUS = 0
	BEGIN 
		-- Initialize the costing method 
		SET @CostingMethod = NULL;
		SET @AutoNegativeAmount = 0

		-- Get the costing method of an item 
		SELECT	@CostingMethod = CostingMethod 
		FROM	dbo.fnGetCostingMethodAsTable(@intItemId, @intItemLocationId)

		--------------------------------------------------------------------------------
		-- Perform the Auto-Negative on Items using the Average Costing
		--------------------------------------------------------------------------------
		-- Average Cost
		IF (@CostingMethod = @AVERAGECOST)
		BEGIN 
			SELECT	@AutoNegativeAmount = 
						(Stock.dblUnitOnHand * ItemPricing.dblAverageCost) 
						- dbo.fnGetItemTotalValueFromTransactions(
							Stock.intItemId, 
							Stock.intItemLocationId
						)
			FROM	dbo.tblICItemStock Stock INNER JOIN dbo.tblICItemPricing ItemPricing
						ON	Stock.intItemId = ItemPricing.intItemId
							AND Stock.intItemLocationId = ItemPricing.intItemLocationId
			WHERE	Stock.intItemId = @intItemId
					AND Stock.intItemLocationId = @intItemLocationId

			IF ROUND(ISNULL(@AutoNegativeAmount, 0),6) <> 0.00
			BEGIN 
				EXEC [dbo].[uspICPostInventoryTransaction]
						@intItemId								= @intItemId
						,@intItemLocationId						= @intItemLocationId
						,@intItemUOMId							= @intItemUOMId
						,@intSubLocationId						= @intSubLocationId
						,@intStorageLocationId					= @intStorageLocationId
						,@dtmDate								= @dtmDate
						,@dblQty								= 0
						,@dblUOMQty								= 0
						,@dblCost								= 0
						,@dblValue								= @AutoNegativeAmount
						,@dblSalesPrice							= 0
						,@intCurrencyId							= NULL
						,@dblExchangeRate						= 1
						,@intTransactionId						= @intTransactionId
						,@intTransactionDetailId				= @intTransactionDetailId
						,@strTransactionId						= @strTransactionId
						,@strBatchId							= @strBatchId
						,@intTransactionTypeId					= @INVENTORY_AUTO_NEGATIVE
						,@intLotId								= NULL
						,@intRelatedInventoryTransactionId		= NULL
						,@intRelatedTransactionId				= NULL
						,@strRelatedTransactionId				= NULL						
						,@strTransactionForm					= @TransactionTypeName
						,@intUserId								= @intUserId
						,@intCostingMethod						= @AVERAGECOST
						,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT 
			END 
		END

		FETCH NEXT FROM loopItemsForAutoNegative INTO 
			@intId
			,@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dtmDate
			,@dblNewCost
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@intTransactionTypeId
			,@intLotId
		;
	END 

	-----------------------------------------------------------------------------------------------------------------------------
	-- End of the loop
	-----------------------------------------------------------------------------------------------------------------------------
	CLOSE loopItemsForAutoNegative;
	DEALLOCATE loopItemsForAutoNegative;
END 

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
EXEC dbo.uspICCreateGLEntries 
	@strBatchId
	,@strAccountToCounterInventory
	,@intUserId