﻿
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
	,@intUserId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @returnValue AS INT 

-- Clean-up for the temp table. 
IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE ID = OBJECT_ID(N'tempdb..#tmpRevalueProducedItems')) 
	DROP TABLE #tmpRevalueProducedItems  

-- Create the temp table if it does not exists. 
BEGIN 
	CREATE TABLE #tmpRevalueProducedItems (
		[intId] INT IDENTITY PRIMARY KEY CLUSTERED	
		,[intItemId] INT NOT NULL								-- The item. 
		,[intItemLocationId] INT NULL							-- The location where the item is stored.
		,[intItemUOMId] INT NOT NULL							-- The UOM used for the item.
		,[dtmDate] DATETIME NOT NULL							-- The date of the transaction
		,[dblQty] NUMERIC(18, 6) NOT NULL DEFAULT 0				-- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
		,[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 1			-- The quantity of an item per UOM. For example, a box can contain 12 individual pieces of an item. 
		,[dblNewCost] NUMERIC(38, 20) NOT NULL DEFAULT 0		-- The cost of purchasing a item per UOM. For example, $12 is the cost for a 12-piece box. This parameter should hold a $12 value and not $1 per pieces found in a 12-piece box. The cost is stored in base currency. 
		,[intCurrencyId] INT NULL								-- The currency id used in a transaction. 
		,[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL	-- The exchange rate used in the transaction. It is used to convert the cost or sales price (both in base currency) to the foreign currency value.
		,[intTransactionId] INT NOT NULL						-- The integer id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
		,[intTransactionDetailId] INT NULL						-- Link id to the transaction detail. 
		,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL -- The string id of the source transaction. 
		,[intTransactionTypeId] INT NOT NULL					-- The transaction type. Source table for the types are found in tblICInventoryTransactionType
		,[intLotId] INT NULL									-- Place holder field for lot numbers
		,[intSubLocationId] INT NULL							-- Place holder field for lot numbers
		,[intStorageLocationId] INT NULL						-- Place holder field for lot numbers
		,[ysnIsStorage] BIT NULL								-- If Yes (value is 1), then the item is not owned by the company. The company is only the custodian of the item (like a consignor). Add or remove stock from Inventory-Lot-In-Storage table. 
		,[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- If there is a value, this means the item is used in Actual Costing. 
		,[intSourceTransactionId] INT NULL						-- The integer id for the cost bucket (Ex. INVRCT-10001). 
		,[strSourceTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL -- The string id for the cost bucket (Ex. INVRCT-10001). 
	)
END 

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
		--,@intLotId AS INT 

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
--	EXEC [dbo].[uspICValidateCostingOnPost] 
--		@ItemsToValidate = @ItemsToAdjust
--END


BEGIN 
	DECLARE @Internal_ItemsToAdjust AS ItemCostAdjustmentTableType 

	INSERT INTO @Internal_ItemsToAdjust (
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblNewCost] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[intTransactionId]
			,[intTransactionDetailId] 
			,[strTransactionId] 
			,[intTransactionTypeId] 
			,[intLotId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[ysnIsStorage] 
			,[strActualCostId] 
			,[intSourceTransactionId] 
			,[strSourceTransactionId] 	
	)
	SELECT 
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblNewCost] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[intTransactionId]
			,[intTransactionDetailId] 
			,[strTransactionId] 
			,[intTransactionTypeId] 
			,[intLotId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[ysnIsStorage] 
			,[strActualCostId] 
			,[intSourceTransactionId] 
			,[strSourceTransactionId] 	 
	FROM	@ItemsToAdjust
END 

START_LOOP:

-----------------------------------------------------------------------------------------------------------------------------
-- Create the cursor
-- Make sure the following options are used: 
-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
-----------------------------------------------------------------------------------------------------------------------------
DECLARE loopItemsToAdjust CURSOR LOCAL FAST_FORWARD
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
		-- ,intLotId 
		,intCurrencyId
		,dblExchangeRate
FROM	@Internal_ItemsToAdjust

OPEN loopItemsToAdjust;

-- Initial fetch attempt
FETCH NEXT FROM loopItemsToAdjust INTO 
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
	--,@intLotId
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
		EXEC @returnValue = dbo.uspICPostCostAdjustmentOnAverageCosting
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

		IF @returnValue < 0 RETURN -1;
	END

	-- FIFO
	IF (@CostingMethod = @FIFO)
	BEGIN 
		EXEC @returnValue = dbo.uspICPostCostAdjustmentOnFIFOCosting
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

		IF @returnValue < 0 RETURN -1;
	END

	-- LIFO
	IF (@CostingMethod = @LIFO)
	BEGIN 
		EXEC @returnValue = dbo.uspICPostCostAdjustmentOnLIFOCosting
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

		IF @returnValue < 0 RETURN -1;
	END

	-- Lot Costing
	IF (@CostingMethod = @LOTCOST)
	BEGIN 
		EXEC @returnValue = dbo.uspICPostCostAdjustmentOnLotCosting
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

		IF @returnValue < 0 RETURN -1;
	END

	-- Attempt to fetch the next row from cursor. 
	FETCH NEXT FROM loopItemsToAdjust INTO 
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
		--,@intLotId
		,@intCurrencyId
		,@dblExchangeRate
	;
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

CLOSE loopItemsToAdjust;
DEALLOCATE loopItemsToAdjust;

-----------------------------------------------------------------------------------------------------------------------------
-- Create the Auto Negative
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 

	-----------------------------------------------------------------------------------------------------------------------------
	-- Begin of the loop
	-----------------------------------------------------------------------------------------------------------------------------
	DECLARE loopItemsToAdjustForAutoNegative CURSOR LOCAL FAST_FORWARD
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
			-- ,intLotId 
	FROM	@Internal_ItemsToAdjust

	OPEN loopItemsToAdjustForAutoNegative;

	-- Initial fetch attempt
	FETCH NEXT FROM loopItemsToAdjustForAutoNegative INTO 
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
		-- ,@intLotId
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

		FETCH NEXT FROM loopItemsToAdjustForAutoNegative INTO 
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
			--,@intLotId
		;
	END 

	-----------------------------------------------------------------------------------------------------------------------------
	-- End of the loop
	-----------------------------------------------------------------------------------------------------------------------------
	CLOSE loopItemsToAdjustForAutoNegative;
	DEALLOCATE loopItemsToAdjustForAutoNegative;
END 

-------------------------------------------------------------------------------------------
-- Repeat the cost adjustment process if there are 'Produced/Transferred' stocks affected. 
-------------------------------------------------------------------------------------------
IF EXISTS (SELECT TOP 1 1 FROM #tmpRevalueProducedItems) 
BEGIN 
	-- Clear the contents of the @Internal_ItemsToAdjust table variable. 
	DELETE FROM @Internal_ItemsToAdjust

	-- Transfer the data from the temp table into @Internal_ItemsToAdjust. These are the 'Produced' items inserted into #tmpRevalueProducedItems by the costing SP's above. (ex: uspICPostCostAdjustmentOnAverageCosting)
	INSERT INTO @Internal_ItemsToAdjust (
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblNewCost] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[intTransactionId]
			,[intTransactionDetailId] 
			,[strTransactionId] 
			,[intTransactionTypeId] 
			,[intLotId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[ysnIsStorage] 
			,[strActualCostId] 
			,[intSourceTransactionId] 
			,[strSourceTransactionId] 		
	)
	SELECT 
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblNewCost] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[intTransactionId]
			,[intTransactionDetailId] 
			,[strTransactionId] 
			,[intTransactionTypeId] 
			,[intLotId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[ysnIsStorage] 
			,[strActualCostId] 
			,[intSourceTransactionId] 
			,[strSourceTransactionId] 	
	FROM	#tmpRevalueProducedItems

	-- Clear the contents of the temp table.
	DELETE FROM #tmpRevalueProducedItems

	-- Do the loop. 
	GOTO START_LOOP
END 

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
EXEC dbo.uspICCreateGLEntriesOnCostAdjustment 
	@strBatchId
	,@intUserId