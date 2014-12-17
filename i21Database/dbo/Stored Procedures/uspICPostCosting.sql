
/*
	This is the stored procedure that handles the "posting" of items. 
	
	It uses a cursor to iterate over the list of records found in @ItemsToPost, a table-valued parameter (variable). 

	In each iteration, it does the following: 
		1. Determines if a stock is for incoming or outgoing then calls the appropriate stored procedure. 
		2. Adjust the stock quantity and current average cost. 
		3. Calls another stored procedure that will return the generated G/L entries

	Parameters: 
	@ItemsToPost - A user-defined table type. This is a table variable that tells this SP what items to process. 	
	
	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@strAccountDescription - The contra g/l account id to use when posting an item. By default, it is set to "Cost of Goods". 
				The calling code needs to specify it because each module may use a different contra g/l account against the 
				Inventory account. For example, a Sales transaction will contra Inventory account with "Cost of Goods" while 
				Receive stocks from AP module may use "A/P Clearing".

	@intUserId - The user who is initiating the post. 
*/
CREATE PROCEDURE [dbo].[uspICPostCosting]
	@ItemsToPost AS ItemCostingTableType READONLY
	,@strBatchId AS NVARCHAR(20)
	,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
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
		,@intLocationId AS INT 
		,@dtmDate AS DATETIME
		,@dblUnitQty AS NUMERIC(18, 6) 
		,@dblUOMQty AS NUMERIC(18, 6)
		,@dblCost AS NUMERIC(18, 6)
		,@dblSalesPrice AS NUMERIC(18, 6)
		,@intCurrencyId AS INT 
		,@dblExchangeRate AS DECIMAL (38, 20) 
		,@intTransactionId AS INT
		,@strTransactionId AS NVARCHAR(40) 
		,@intTransactionTypeId AS INT 
		,@intLotId AS INT

DECLARE @CostingMethod AS INT 

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@STANDARDCOST AS INT = 4 	


-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC [dbo].[uspICValidateCostingOnPost] 
		@ItemsToValidate = @ItemsToPost
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
		,intLocationId
		,dtmDate
		,dblUnitQty
		,dblUOMQty
		,dblCost
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,strTransactionId
		,intTransactionTypeId
		,intLotId
FROM	@ItemsToPost

OPEN loopItems;

-- Initial fetch attempt
FETCH NEXT FROM loopItems INTO @intId, @intItemId, @intLocationId, @dtmDate, @dblUnitQty, @dblUOMQty, @dblCost, @dblSalesPrice, @intCurrencyId, @dblExchangeRate, @intTransactionId, @strTransactionId, @intTransactionTypeId, @intLotId;

-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 
	-- Initialize the costing method and negative inventory option. 
	SET @CostingMethod = NULL;

	-- Get the costing method of an item 
	SELECT	@CostingMethod = CostingMethod 
	FROM	dbo.fnGetCostingMethodAsTable(@intItemId, @intLocationId)

	--------------------------------------------------------------------------------
	-- Call the SP that can process the item's costing method
	--------------------------------------------------------------------------------
	-- Moving Average Cost
	IF (@CostingMethod = @AVERAGECOST)
	BEGIN 
		EXEC dbo.uspICPostAverageCosting
			@intItemId
			,@intLocationId
			,@dtmDate
			,@dblUnitQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			,@dblExchangeRate
			,@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@intUserId
	END

	-- FIFO 
	IF (@CostingMethod = @FIFO)
	BEGIN 
		EXEC dbo.uspICPostFIFO
			@intItemId
			,@intLocationId
			,@dtmDate
			,@dblUnitQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			,@dblExchangeRate
			,@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@intUserId;
	END

	-- LIFO 
	IF (@CostingMethod = @LIFO)
	BEGIN 
		EXEC dbo.uspICPostLIFO
			@intItemId
			,@intLocationId
			,@dtmDate
			,@dblUnitQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			,@dblExchangeRate
			,@intTransactionId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@intUserId;
	END

	--------------------------------------------------
	-- Adjust the average cost and units on hand. 
	--------------------------------------------------
	BEGIN 
		UPDATE	Stock
		SET		Stock.dblAverageCost = dbo.fnCalculateAverageCost((@dblUnitQty * @dblUOMQty), @dblCost, Stock.dblUnitOnHand, Stock.dblAverageCost)
				,Stock.dblUnitOnHand = (@dblUnitQty * @dblUOMQty) + Stock.dblUnitOnHand
				,Stock.intConcurrencyId = ISNULL(Stock.intConcurrencyId, 0) + 1 
		FROM	dbo.tblICItemStock AS Stock
		WHERE	Stock.intItemId = @intItemId
				AND Stock.intLocationId = @intLocationId;
	END 

	-- Attempt to fetch the next row from cursor. 
	FETCH NEXT FROM loopItems INTO @intId, @intItemId, @intLocationId, @dtmDate, @dblUnitQty, @dblUOMQty, @dblCost, @dblSalesPrice, @intCurrencyId, @dblExchangeRate, @intTransactionId, @strTransactionId, @intTransactionTypeId, @intLotId
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

CLOSE loopItems;
DEALLOCATE loopItems;

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
EXEC dbo.uspICCreateGLEntries 
	@strBatchId
	,@strAccountToCounterInventory
	,@intUserId