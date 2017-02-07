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
				Receive stocks from AP module may use "AP Clearing".

	@intEntityUserSecurityId - The user who is initiating the post. 
*/
CREATE PROCEDURE [dbo].[uspICPostInTransitCosting]
	@ItemsToPost AS ItemInTransitCostingTableType READONLY
	,@strBatchId AS NVARCHAR(20)
	,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
	
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
		,@dblQty AS NUMERIC(38, 20) 
		,@dblUOMQty AS NUMERIC(38, 20)
		,@dblCost AS NUMERIC(38, 20)
		,@dblSalesPrice AS NUMERIC(18, 6)
		,@intCurrencyId AS INT 
		--,@dblExchangeRate AS DECIMAL (38, 20) 
		,@intTransactionId AS INT
		,@intTransactionDetailId AS INT 
		,@strTransactionId AS NVARCHAR(40) 
		,@intTransactionTypeId AS INT 
		,@intLotId AS INT
		,@intSourceTransactionId AS INT
		,@intSourceTransactionDetailId AS INT 
		,@strSourceTransactionId AS NVARCHAR(40)
		,@intFobPointId AS TINYINT 
		,@intInTransitSourceLocationId AS INT
		,@intForexRateTypeId AS INT
		,@dblForexRate NUMERIC(38, 20)
		
		,@intInventoryTransactionId INT 
		,@strTransactionForm AS NVARCHAR(255)

-- Declare the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_VARIANCE AS INT = 1

-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
--BEGIN 
--	DECLARE @returnValue AS INT 

--	EXEC @returnValue = dbo.uspICValidateCostingOnPost
--		@ItemsToValidate = @ItemsToPost

--	IF @returnValue < 0 RETURN -1;
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
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblSalesPrice
		,intCurrencyId
		--,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,intTransactionTypeId
		,intLotId
		,intSourceTransactionId
		,intSourceTransactionDetailId
		,strSourceTransactionId
		,intFobPointId
		,intInTransitSourceLocationId
		,intForexRateTypeId
		,dblForexRate
FROM	@ItemsToPost

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
	--,@dblExchangeRate
	,@intTransactionId
	,@intTransactionDetailId
	,@strTransactionId
	,@intTransactionTypeId
	,@intLotId
	,@intSourceTransactionId
	,@intSourceTransactionDetailId
	,@strSourceTransactionId
	,@intFobPointId
	,@intInTransitSourceLocationId
	,@intForexRateTypeId
	,@dblForexRate
;
	
-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 

	-- Initialize the transaction form
	SELECT	@strTransactionForm = strTransactionForm
	FROM	dbo.tblICInventoryTransactionType
	WHERE	intTransactionTypeId = @intTransactionTypeId
			AND strTransactionForm IS NOT NULL 

	-- Get the correct item location 
	EXEC uspICGetItemInTransitLocation @intItemId, NULL, @intItemLocationId OUTPUT 

	--------------------------------------------------------------------------------
	-- Call the SP that can process the In-Transit Costing 
	--------------------------------------------------------------------------------
	-- LOT 
	IF @intLotId IS NOT NULL 
	BEGIN 
		EXEC dbo.uspICPostLotInTransit
			@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@dtmDate
			,@intLotId
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@dblSalesPrice
			,@intCurrencyId
			--,@dblExchangeRate
			,@intTransactionId
			,@intTransactionDetailId
			,@strTransactionId
			,@strBatchId
			,@intTransactionTypeId
			,@strTransactionForm
			,@intEntityUserSecurityId
			,@intFobPointId
			,@intInTransitSourceLocationId
			,@intForexRateTypeId
			,@dblForexRate
			;
	END

	-- ACTUAL COST 
	ELSE 
	BEGIN 
		EXEC dbo.uspICPostActualCostInTransit
			@strSourceTransactionId -- @strActualCostId 
			,@intItemId 
			,@intItemLocationId 
			,@intItemUOMId 
			,@dtmDate 
			,@dblQty 
			,@dblUOMQty 
			,@dblCost 
			,@dblSalesPrice 
			,@intCurrencyId 
			--,@dblExchangeRate 
			,@intTransactionId 
			,@intTransactionDetailId 
			,@strTransactionId 
			,@strBatchId 
			,@intTransactionTypeId 
			,@strTransactionForm 
			,@intEntityUserSecurityId 
			,@intFobPointId
			,@intInTransitSourceLocationId
			,@intForexRateTypeId
			,@dblForexRate
			;
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
		--,@dblExchangeRate
		,@intTransactionId
		,@intTransactionDetailId
		,@strTransactionId
		,@intTransactionTypeId
		,@intLotId
		,@intSourceTransactionId
		,@intSourceTransactionDetailId
		,@strSourceTransactionId
		,@intFobPointId
		,@intInTransitSourceLocationId
		,@intForexRateTypeId
		,@dblForexRate

END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

CLOSE loopItems;
DEALLOCATE loopItems;

---------------------------------------------------------------------------------------
-- Make sure valuation is zero if stock is going to be zero. 
---------------------------------------------------------------------------------------
BEGIN 
	DECLARE @ItemsWithZeroStock AS ItemCostingZeroStockTableType
			,@currentItemValue AS NUMERIC(38, 20)

	-- Get the qualified items for auto-negative. 
	INSERT INTO @ItemsWithZeroStock (
			intItemId
			,intItemLocationId
	)
	SELECT	DISTINCT 
			i2p.intItemId
			,i2p.intItemLocationId
	FROM	@ItemsToPost i2p INNER JOIN tblICItemStock i
				on i2p.intItemId = i.intItemId
				AND i2p.intItemLocationId = i.intItemLocationId			
	WHERE	dbo.fnGetCostingMethod(i2p.intItemId, i2p.intItemLocationId) <> @AVERAGECOST
			AND i.dblUnitOnHand = 0 

	SELECT	TOP 1 
			@intInventoryTransactionId	= intInventoryTransactionId
			,@intCurrencyId				= intCurrencyId
			,@dtmDate					= dtmDate
			--,@dblExchangeRate			= dblExchangeRate
			,@intTransactionId			= intTransactionId
			,@strTransactionId			= strTransactionId
			,@strTransactionForm		= strTransactionForm
	FROM	dbo.tblICInventoryTransaction
	WHERE	strBatchId = @strBatchId
			AND ISNULL(ysnIsUnposted, 0) = 0 

	IF EXISTS (SELECT TOP 1 1 FROM @ItemsWithZeroStock) 
	BEGIN 
		INSERT INTO dbo.tblICInventoryTransaction (
					[intItemId]
					,[intItemLocationId]
					,[intItemUOMId]
					,[intSubLocationId]
					,[intStorageLocationId]
					,[dtmDate]
					,[dblQty]
					,[dblUOMQty]
					,[dblCost]
					,[dblValue]
					,[dblSalesPrice]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[intTransactionId]
					,[strTransactionId]
					,[strBatchId]
					,[intTransactionTypeId]
					,[intLotId]
					,[ysnIsUnposted]
					,[intRelatedInventoryTransactionId]
					,[intRelatedTransactionId]
					,[strRelatedTransactionId]
					,[strTransactionForm]
					,[dtmCreated]
					,[intCreatedEntityId]
					,[intConcurrencyId]
					,[intCostingMethod]
					,[strDescription]
					,[intFobPointId]
					,[intInTransitSourceLocationId]
					,[intForexRateTypeId]
					,[dblForexRate]
			)			
		SELECT	
				[intItemId]								= iWithZeroStock.intItemId
				,[intItemLocationId]					= iWithZeroStock.intItemLocationId
				,[intItemUOMId]							= NULL 
				,[intSubLocationId]						= NULL 
				,[intStorageLocationId]					= NULL 
				,[dtmDate]								= @dtmDate
				,[dblQty]								= 0
				,[dblUOMQty]							= 0
				,[dblCost]								= 0
				,[dblValue]								= -currentValuation.floatingValue
				,[dblSalesPrice]						= 0
				,[intCurrencyId]						= @intCurrencyId
				,[dblExchangeRate]						= 1 -- @dblExchangeRate
				,[intTransactionId]						= @intTransactionId
				,[strTransactionId]						= @strTransactionId
				,[strBatchId]							= @strBatchId
				,[intTransactionTypeId]					= @AUTO_VARIANCE
				,[intLotId]								= NULL 
				,[ysnIsUnposted]						= 0
				,[intRelatedInventoryTransactionId]		= NULL 
				,[intRelatedTransactionId]				= NULL 
				,[strRelatedTransactionId]				= NULL 
				,[strTransactionForm]					= @strTransactionForm
				,[dtmCreated]							= GETDATE()
				,[intCreatedEntityId]					= @intEntityUserSecurityId
				,[intConcurrencyId]						= 1
				,[intCostingMethod]						= @ACTUALCOST
				,[strDescription]						=	-- Stock quantity is now zero on {Item} in {Location}. Auto variance is posted to zero out its inventory valuation.
															FORMATMESSAGE(
															80093
															,i.strItemNo
															,cl.strLocationName														
														)
				,[intFobPointId]						= @FOB_DESTINATION 
				,[intInTransitSourceLocationId]			= @intInTransitSourceLocationId
				,[intForexRateTypeId]					= @intForexRateTypeId
				,[dblForexRate]							= @dblForexRate
		FROM	@ItemsWithZeroStock iWithZeroStock INNER JOIN tblICItemStock iStock
					ON iWithZeroStock.intItemId = iStock.intItemId
					AND iWithZeroStock.intItemLocationId = iStock.intItemLocationId
				INNER JOIN tblICItem i
					ON i.intItemId = iWithZeroStock.intItemId
				INNER JOIN tblICItemLocation il
					ON il.intItemId = iWithZeroStock.intItemId
					AND il.intItemLocationId = iWithZeroStock.intItemLocationId
				INNER JOIN tblSMCompanyLocation cl
					ON cl.intCompanyLocationId = il.intLocationId
				OUTER APPLY (
					SELECT	floatingValue = SUM(
								ROUND(t.dblQty * t.dblCost + t.dblValue, 2)
							)
					FROM	tblICInventoryTransaction t
					WHERE	t.intItemId = iWithZeroStock.intItemId
							AND t.intItemLocationId = iWithZeroStock.intItemLocationId
				) currentValuation
		WHERE	ISNULL(currentValuation.floatingValue, 0) <> 0
	END 
END 

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
--IF @strAccountToCounterInventory IS NOT NULL 
BEGIN 
	DECLARE @intReturnValue INT

	EXEC @intReturnValue = dbo.uspICCreateGLEntriesForInTransitCosting 
		@strBatchId
		,@strAccountToCounterInventory
		,@intEntityUserSecurityId
		,@strGLDescription
		--,@intContraInventory_ItemLocationId

	IF @intReturnValue < 0 RETURN -1
END 