﻿
/*
	This is the stored procedure that handles the adjustment to the item cost. 
	
	It uses a cursor to iterate over the list of records found in @ItemsToAdjust, a table-valued parameter (variable). 

	Parameters: 
	@ItemsToAdjust - A user-defined table type. This is a table variable that tells this SP what items to process. 	
	
	@strBatchId - The generated batch id from the calling code. This is the same batch id this SP will use when posting the financials of an item. 

	@intEntityUserSecurityId - The user who is initiating the post. 
*/
CREATE PROCEDURE [dbo].[uspICPostCostAdjustment]
	@ItemsToAdjust AS ItemCostAdjustmentTableType READONLY
	,@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
	,@ysnPost AS BIT = 1
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage AS NVARCHAR(4000)
		,@ErrorSeverity AS INT
		,@ErrorState AS INT 
		,@TransactionName AS VARCHAR(32)		
		,@ReturnValue AS INT 
		,@TransCount AS INT = @@TRANCOUNT 

-- Clean-up for the temp tables. 
IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE ID = OBJECT_ID(N'tempdb..#tmpRevalueProducedItems')) 
	DROP TABLE #tmpRevalueProducedItems  

-- Create the temp table if it does not exists. 
BEGIN 
	CREATE TABLE #tmpRevalueProducedItems (
		[intId] INT IDENTITY PRIMARY KEY CLUSTERED	
		,[intItemId] INT NOT NULL								-- The item. 
		,[intItemLocationId] INT NULL							-- The location where the item is stored.
		,[intItemUOMId] INT NULL							-- The UOM used for the item.
		,[dtmDate] DATETIME NOT NULL							-- The date of the transaction
		,[dblQty] NUMERIC(38,20) NULL DEFAULT 0				-- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
		,[dblUOMQty] NUMERIC(38,20) NULL DEFAULT 1			-- The quantity of an item per UOM. For example, a box can contain 12 individual pieces of an item. 
		,[dblNewCost] NUMERIC(38,20) NULL DEFAULT 0				-- The cost of purchasing a item per UOM. For example, $12 is the cost for a 12-piece box. This parameter should hold a $12 value and not $1 per pieces found in a 12-piece box. The cost is stored in base currency. 
		,[dblNewValue] NUMERIC(38,20) NULL						-- 
		,[intCurrencyId] INT NULL								-- The currency id used in a transaction. 
		,[intTransactionId] INT NOT NULL						-- The integer id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
		,[intTransactionDetailId] INT NULL						-- Link id to the transaction detail. 
		,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL -- The string id of the source transaction. 
		,[intTransactionTypeId] INT NOT NULL					-- The transaction type. Source table for the types are found in tblICInventoryTransactionType
		,[intLotId] INT NULL									-- Place holder field for lot numbers
		,[intSubLocationId] INT NULL							-- Place holder field for lot numbers
		,[intStorageLocationId] INT NULL						-- Place holder field for lot numbers
		,[ysnIsStorage] BIT NULL								-- If Yes (value is 1), then the item is not owned by the company. The company is only the custodian of the item (like a consignor). Add or remove stock from Inventory-Lot-In-Storage table. 
		,[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- If there is a value, this means the item is used in Actual Costing. 
		,[intSourceTransactionId] INT NULL						-- The integer id for the cost bucket (Ex. The integer id of INVRCT-10001 is 1934). 
		,[intSourceTransactionDetailId] INT NULL				-- The integer id for the cost bucket in terms of tblICInventoryReceiptItem.intInventoryReceiptItemId (Ex. The value of tblICInventoryReceiptItem.intInventoryReceiptItemId is 1230). 
		,[strSourceTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL -- The string id for the cost bucket (Ex. "INVRCT-10001"). 
		,[intRelatedInventoryTransactionId] INT NULL 
		,[intFobPointId] TINYINT NULL 
		,[intInTransitSourceLocationId] INT NULL 
	)
END 

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INVENTORY_AUTO_NEGATIVE AS INT = 1
		,@INVENTORY_COST_VARIANCE AS INT = 1
		,@INVENTORY_AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK AS INT = 35

-- Declare the variables to use for the cursor
DECLARE @intId AS INT 
		,@intItemId AS INT
		,@intItemLocationId AS INT 
		,@intItemUOMId AS INT 
		,@intSubLocationId AS INT
		,@intStorageLocationId AS INT 
		,@dtmDate AS DATETIME
		,@dblQty AS NUMERIC(38,20)
		,@intCostUOMId AS INT 
		,@dblNewCost AS NUMERIC(38,20)
		,@dblNewValue AS NUMERIC(38,20)
		,@intTransactionId AS INT
		,@intTransactionDetailId AS INT
		,@strTransactionId AS NVARCHAR(40) 
		,@intSourceTransactionId AS INT
		,@intSourceTransactionDetailId AS INT
		,@strSourceTransactionId AS NVARCHAR(40) 
		,@intTransactionTypeId AS INT 
		,@intCurrencyId AS INT 
		,@strActualCostId NVARCHAR(50)
		,@intRelatedInventoryTransactionId INT 
		,@intLotId AS INT 
		,@intFobPointId AS TINYINT
		,@intInTransitSourceLocationId INT 

		,@strTransactionId_Batch AS NVARCHAR(40) 

DECLARE @CostingMethod AS INT 
		,@TransactionFormName AS NVARCHAR(200)
		,@InventoryTransactionIdentityId INT

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	

-- Initialize the transaction name. Use this as the transaction form name
SELECT	TOP 1 
		@TransactionFormName = strTransactionForm
FROM	tblICInventoryTransactionType transType INNER JOIN @ItemsToAdjust tmp
			ON transType.intTransactionTypeId = tmp.intTransactionTypeId

BEGIN 
	DECLARE @Internal_ItemsToAdjust AS ItemCostAdjustmentTableType 

	INSERT INTO @Internal_ItemsToAdjust (
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty] 
			,[intCostUOMId]
			,[dblVoucherCost] 
			,[dblNewValue]
			,[intCurrencyId]
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
			,[intSourceTransactionDetailId] 
			,[strSourceTransactionId]
			,[intRelatedInventoryTransactionId]	
			,[intFobPointId]
			,[intInTransitSourceLocationId]
	)
	SELECT 
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty] 
			,[intCostUOMId]
			,[dblVoucherCost] 
			,[dblNewValue]
			,[intCurrencyId] 
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
			,[intSourceTransactionDetailId] 
			,[strSourceTransactionId] 
			,[intRelatedInventoryTransactionId]
			,[intFobPointId]
			,[intInTransitSourceLocationId]
	FROM	@ItemsToAdjust 
	ORDER BY	
		[intItemId]
		, [intItemLocationId]
		, [strTransactionId]
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
		,intCostUOMId
		,dblVoucherCost
		,dblNewValue
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,intSourceTransactionId
		,intSourceTransactionDetailId
		,strSourceTransactionId
		,intTransactionTypeId
		,intCurrencyId
		,strActualCostId
		,intRelatedInventoryTransactionId
		,intLotId
		,intFobPointId
		,intInTransitSourceLocationId
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
	,@intCostUOMId
	,@dblNewCost
	,@dblNewValue
	,@intTransactionId
	,@intTransactionDetailId
	,@strTransactionId
	,@intSourceTransactionId
	,@intSourceTransactionDetailId
	,@strSourceTransactionId
	,@intTransactionTypeId
	,@intCurrencyId
	,@strActualCostId
	,@intRelatedInventoryTransactionId
	,@intLotId
	,@intFobPointId
	,@intInTransitSourceLocationId
;

-----------------------------------------------------------------------------------------------------------------------------
-- Start of the loop
-----------------------------------------------------------------------------------------------------------------------------
WHILE @@FETCH_STATUS = 0
BEGIN 
	SET @ReturnValue = 0;

	-- Initialize the @strTransactionId_Batch
	-- Create a new transaction or do a save point. 
	IF @strTransactionId_Batch IS NULL 
	BEGIN 
		SET @strTransactionId_Batch = @strTransactionId
		SET @TransactionName = 'Cost Adj ' + @strTransactionId

		-- Create a new transaction if it is missing. 
		IF ISNULL(@TransCount, 0) = 0 
		BEGIN 
			BEGIN TRANSACTION 
		END 

		-- Do a save point. 
		SAVE TRAN @TransactionName
	END 
	-- If switching from one transaction id to another. 
	ELSE IF @strTransactionId_Batch <> @strTransactionId
	BEGIN 
		-- Create a new save point. 
		SET @TransactionName = 'Cost Adj ' + @strTransactionId
		BEGIN 
			SAVE TRAN @TransactionName
		END 		
	END 

	-- Initialize the costing method and negative inventory option. 
	SET @CostingMethod = NULL;

	-- Get the costing method of an item 
	SELECT	@CostingMethod = CostingMethod 
	FROM	dbo.fnGetCostingMethodAsTable(@intItemId, @intItemLocationId)

	--------------------------------------------------------------------------------
	-- Call the SP that can process the item's costing method
	--------------------------------------------------------------------------------
	-- Average Cost
	IF (@CostingMethod = @AVERAGECOST) AND (@strActualCostId IS NULL)
	BEGIN TRY
		EXEC @ReturnValue = dbo.uspICPostAdjustRetroactiveAvgCost
			@dtmDate
			,@intItemId 
			,@intItemLocationId 
			,@intSubLocationId
			,@intStorageLocationId 
			,@intItemUOMId
			,@dblQty
			,@intCostUOMId 
			,@dblNewCost
			,@dblNewValue 
			,@intTransactionId 
			,@intTransactionDetailId 
			,@strTransactionId 
			,@intSourceTransactionId 
			,@intSourceTransactionDetailId 
			,@strSourceTransactionId 
			,@strBatchId 
			,@intTransactionTypeId 
			,@intEntityUserSecurityId 
			,@intRelatedInventoryTransactionId 
			,@TransactionFormName 
			,@intFobPointId 
			,@intInTransitSourceLocationId 
			,@ysnPost
	END TRY
	BEGIN CATCH
		-- Get the error details. 
		SELECT 
			@ErrorMessage = ERROR_MESSAGE()
			,@ReturnValue = ERROR_NUMBER()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = XACT_STATE()

		-- Rollback to the last save point. 
		ROLLBACK TRAN @TransactionName
	END CATCH

	-- FIFO
	IF (@CostingMethod = @FIFO) AND (@strActualCostId IS NULL)
	BEGIN TRY
		EXEC @ReturnValue = dbo.uspICPostCostAdjustmentRetroactiveFIFO
				@dtmDate
				,@intItemId 
				,@intItemLocationId 
				,@intSubLocationId 
				,@intStorageLocationId 
				,@intItemUOMId 
				,@dblQty 
				,@intCostUOMId 
				,@dblNewCost 
				,@dblNewValue 
				,@intTransactionId 
				,@intTransactionDetailId 
				,@strTransactionId 
				,@intSourceTransactionId 
				,@intSourceTransactionDetailId 
				,@strSourceTransactionId 
				,@strBatchId 
				,@intTransactionTypeId 
				,@intEntityUserSecurityId 
				,@intRelatedInventoryTransactionId 
				,@TransactionFormName 
				,@intFobPointId 
				,@intInTransitSourceLocationId 
	END TRY
	BEGIN CATCH
		-- Get the error details. 
		SELECT 
			@ErrorMessage = ERROR_MESSAGE()
			,@ReturnValue = ERROR_NUMBER()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = XACT_STATE()

		-- Rollback to the last save point. 
		ROLLBACK TRAN @TransactionName
	END CATCH

	-- LIFO
	IF (@CostingMethod = @LIFO) AND (@strActualCostId IS NULL)
	BEGIN TRY
		EXEC @ReturnValue = dbo.uspICPostCostAdjustmentRetroactiveLIFO
				@dtmDate
				,@intItemId 
				,@intItemLocationId 
				,@intSubLocationId 
				,@intStorageLocationId 
				,@intItemUOMId 
				,@dblQty 
				,@intCostUOMId 
				,@dblNewCost 
				,@dblNewValue 
				,@intTransactionId 
				,@intTransactionDetailId 
				,@strTransactionId 
				,@intSourceTransactionId 
				,@intSourceTransactionDetailId 
				,@strSourceTransactionId 
				,@strBatchId 
				,@intTransactionTypeId 
				,@intEntityUserSecurityId 
				,@intRelatedInventoryTransactionId 
				,@TransactionFormName 
				,@intFobPointId 
				,@intInTransitSourceLocationId 
	END TRY
	BEGIN CATCH
		-- Get the error details. 
		SELECT 
			@ErrorMessage = ERROR_MESSAGE()
			,@ReturnValue = ERROR_NUMBER()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = XACT_STATE()

		-- Rollback to the last save point. 
		ROLLBACK TRAN @TransactionName
	END CATCH

	-- Lot Costing
	IF (@CostingMethod = @LOTCOST) AND (@strActualCostId IS NULL)
	BEGIN TRY
		EXEC @ReturnValue = dbo.uspICPostCostAdjustmentRetroactiveLot 
			@dtmDate 
			,@intItemId 
			,@intItemLocationId 
			,@intSubLocationId 
			,@intStorageLocationId 
			,@intItemUOMId 
			,@dblQty 
			,@intCostUOMId 
			,@dblNewCost 
			,@dblNewValue 
			,@intTransactionId 
			,@intTransactionDetailId 
			,@strTransactionId 
			,@intSourceTransactionId 
			,@intSourceTransactionDetailId 
			,@strSourceTransactionId 
			,@strBatchId 
			,@intTransactionTypeId 
			,@intEntityUserSecurityId 
			,@intRelatedInventoryTransactionId 
			,@TransactionFormName 
			,@intFobPointId 
			,@intInTransitSourceLocationId 
	END TRY
	BEGIN CATCH
		-- Get the error details. 
		SELECT 
			@ErrorMessage = ERROR_MESSAGE()
			,@ReturnValue = ERROR_NUMBER()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = XACT_STATE()

		-- Rollback to the last save point. 
		ROLLBACK TRAN @TransactionName
	END CATCH

	-- Actual Costing
	IF (ISNULL(@strActualCostId, '') <> '')
	BEGIN TRY
		EXEC @ReturnValue = dbo.uspICPostCostAdjustmentRetroactiveActual
			@dtmDate 
			,@intItemId 
			,@intItemLocationId 
			,@intSubLocationId 
			,@intStorageLocationId 
			,@intItemUOMId 
			,@dblQty 
			,@intCostUOMId 
			,@dblNewCost 
			,@dblNewValue 
			,@intTransactionId 
			,@intTransactionDetailId 
			,@strTransactionId 
			,@intSourceTransactionId 
			,@intSourceTransactionDetailId 
			,@strSourceTransactionId
			,@strBatchId 
			,@intTransactionTypeId 
			,@intEntityUserSecurityId 
			,@intRelatedInventoryTransactionId 
			,@TransactionFormName 
			,@intFobPointId 
			,@intInTransitSourceLocationId 
			,@strActualCostId 
	END TRY
	BEGIN CATCH
		-- Get the error details. 
		SELECT 
			@ErrorMessage = ERROR_MESSAGE()
			,@ReturnValue = ERROR_NUMBER()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = XACT_STATE()

		-- Rollback to the last save point. 
		ROLLBACK TRAN @TransactionName
	END CATCH

	---- FIFO
	--IF (@CostingMethod = @FIFO) AND (@strActualCostId IS NULL)
	--BEGIN TRY
	--	EXEC @ReturnValue = dbo.uspICPostCostAdjustmentOnFIFOCosting
	--		@dtmDate
	--		,@intItemId
	--		,@intItemLocationId
	--		,@intSubLocationId
	--		,@intStorageLocationId
	--		,@intItemUOMId
	--		,@dblQty			
	--		,@intCostUOMId
	--		,@dblNewCost 
	--		,@dblNewValue
	--		,@intTransactionId
	--		,@intTransactionDetailId
	--		,@strTransactionId
	--		,@intSourceTransactionId
	--		,@intSourceTransactionDetailId
	--		,@strSourceTransactionId
	--		,@strBatchId
	--		,@intTransactionTypeId
	--		,@intCurrencyId
	--		--,@dblExchangeRate			
	--		,@intEntityUserSecurityId
	--		,@intRelatedInventoryTransactionId
	--		,@TransactionFormName
	--		,@intFobPointId
	--		,@intInTransitSourceLocationId
	--END TRY
	--BEGIN CATCH
	--	-- Get the error details. 
	--	SELECT 
	--		@ErrorMessage = ERROR_MESSAGE()
	--		,@ReturnValue = ERROR_NUMBER()
	--		,@ErrorSeverity = ERROR_SEVERITY()
	--		,@ErrorState = XACT_STATE()

	--	-- Rollback to the last save point. 
	--	ROLLBACK TRAN @TransactionName
	--END CATCH

	---- LIFO
	--IF (@CostingMethod = @LIFO) AND (@strActualCostId IS NULL)
	--BEGIN TRY
	--	EXEC @ReturnValue = dbo.uspICPostCostAdjustmentOnLIFOCosting
	--		@dtmDate
	--		,@intItemId
	--		,@intItemLocationId
	--		,@intSubLocationId
	--		,@intStorageLocationId
	--		,@intItemUOMId
	--		,@dblQty		
	--		,@intCostUOMId	
	--		,@dblNewCost 
	--		,@dblNewValue
	--		,@intTransactionId
	--		,@intTransactionDetailId
	--		,@strTransactionId
	--		,@intSourceTransactionId
	--		,@intSourceTransactionDetailId
	--		,@strSourceTransactionId
	--		,@strBatchId
	--		,@intTransactionTypeId
	--		,@intCurrencyId
	--		--,@dblExchangeRate			
	--		,@intEntityUserSecurityId
	--		,@intRelatedInventoryTransactionId
	--		,@TransactionFormName
	--		,@intFobPointId
	--		,@intInTransitSourceLocationId
	--END TRY
	--BEGIN CATCH
	--	-- Get the error details. 
	--	SELECT 
	--		@ErrorMessage = ERROR_MESSAGE()
	--		,@ReturnValue = ERROR_NUMBER()
	--		,@ErrorSeverity = ERROR_SEVERITY()
	--		,@ErrorState = XACT_STATE()

	--	-- Rollback to the last save point. 
	--	ROLLBACK TRAN @TransactionName
	--END CATCH

	---- Lot Costing
	--IF (@CostingMethod = @LOTCOST) AND (@strActualCostId IS NULL)
	--BEGIN TRY
	--	EXEC @ReturnValue = dbo.uspICPostCostAdjustmentOnLotCosting
	--		@dtmDate
	--		,@intItemId
	--		,@intItemLocationId
	--		,@intSubLocationId
	--		,@intStorageLocationId
	--		,@intItemUOMId
	--		,@dblQty
	--		,@intCostUOMId			
	--		,@dblNewCost 
	--		,@dblNewValue
	--		,@intTransactionId
	--		,@intTransactionDetailId
	--		,@strTransactionId
	--		,@intSourceTransactionId
	--		,@intSourceTransactionDetailId
	--		,@strSourceTransactionId
	--		,@strBatchId
	--		,@intTransactionTypeId
	--		,@intCurrencyId
	--		--,@dblExchangeRate			
	--		,@intEntityUserSecurityId
	--		,@intRelatedInventoryTransactionId
	--		,@intLotId
	--		,@TransactionFormName
	--		,@intFobPointId
	--		,@intInTransitSourceLocationId
	--END TRY
	--BEGIN CATCH
	--	-- Get the error details. 
	--	SELECT 
	--		@ErrorMessage = ERROR_MESSAGE()
	--		,@ReturnValue = ERROR_NUMBER()
	--		,@ErrorSeverity = ERROR_SEVERITY()
	--		,@ErrorState = XACT_STATE()

	--	-- Rollback to the last save point. 
	--	ROLLBACK TRAN @TransactionName
	--END CATCH

	---- Actual Costing
	--IF (ISNULL(@strActualCostId, '') <> '')
	--BEGIN TRY
	--	EXEC @ReturnValue = dbo.uspICPostCostAdjustmentOnActualCosting
	--		@dtmDate
	--		,@intItemId
	--		,@intItemLocationId
	--		,@intSubLocationId
	--		,@intStorageLocationId
	--		,@intItemUOMId
	--		,@dblQty
	--		,@intCostUOMId			
	--		,@dblNewCost 
	--		,@dblNewValue
	--		,@intTransactionId
	--		,@intTransactionDetailId
	--		,@strTransactionId
	--		,@intSourceTransactionId
	--		,@intSourceTransactionDetailId
	--		,@strSourceTransactionId
	--		,@strBatchId
	--		,@intTransactionTypeId
	--		,@intCurrencyId
	--		--,@dblExchangeRate			
	--		,@intEntityUserSecurityId
	--		,@strActualCostId
	--		,@intRelatedInventoryTransactionId
	--		,@TransactionFormName
	--		,@intFobPointId
	--		,@intInTransitSourceLocationId
	--END TRY
	--BEGIN CATCH
	--	-- Get the error details. 
	--	SELECT 
	--		@ErrorMessage = ERROR_MESSAGE()
	--		,@ReturnValue = ERROR_NUMBER()
	--		,@ErrorSeverity = ERROR_SEVERITY()
	--		,@ErrorState = XACT_STATE()

	--	-- Rollback to the last save point. 
	--	ROLLBACK TRAN @TransactionName
	--END CATCH

	-- If there is an error, do a rollback for that particular cost adjustment, 
	-- log the error, 
	-- remove that transaction,  
	-- and continue with loop to process the next item in line. 
	IF ISNULL(@ReturnValue, 0) <> 0 
	BEGIN 
		EXEC uspICLogPostResult
			@strMessage = @ErrorMessage
			,@intErrorId = @ReturnValue
			,@strTransactionType = 'Cost Adjustment'
			,@strTransactionId = @strTransactionId
			,@intTransactionId = @intTransactionId
			,@strBatchNumber = @strBatchId
			,@intItemId = @intItemId
			,@intItemLocationId = @intItemLocationId

		DELETE FROM @Internal_ItemsToAdjust WHERE strTransactionId = @strTransactionId
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
		,@intCostUOMId
		,@dblNewCost
		,@dblNewValue
		,@intTransactionId
		,@intTransactionDetailId
		,@strTransactionId
		,@intSourceTransactionId
		,@intSourceTransactionDetailId
		,@strSourceTransactionId
		,@intTransactionTypeId
		,@intCurrencyId
		,@strActualCostId
		,@intRelatedInventoryTransactionId
		,@intLotId
		,@intFobPointId
		,@intInTransitSourceLocationId
	;
END;
-----------------------------------------------------------------------------------------------------------------------------
-- End of the loop
-----------------------------------------------------------------------------------------------------------------------------

CLOSE loopItemsToAdjust;
DEALLOCATE loopItemsToAdjust;

-- Do the final save point. 
IF @TransactionName IS NOT NULL 
BEGIN 
	SAVE TRAN @TransactionName	
END 

-- Do the commit if this sp created the transaction. 
IF ISNULL(@TransCount, 0) = 0 AND @@TRANCOUNT > 0 
BEGIN 
	COMMIT TRANSACTION 
END 

-------------------------------------------------------------------------------------------------------------------------------
---- Create the Auto Variance
-------------------------------------------------------------------------------------------------------------------------------
--BEGIN 

--	-----------------------------------------------------------------------------------------------------------------------------
--	-- Begin of the loop
--	-----------------------------------------------------------------------------------------------------------------------------
--	DECLARE loopItemsToAdjustForAutoNegative CURSOR LOCAL FAST_FORWARD
--	FOR 
--	SELECT  intId
--			,intItemId
--			,intItemLocationId
--			,intItemUOMId
--			,intSubLocationId
--			,intStorageLocationId
--			,dtmDate
--			,intCostUOMId
--			,dblVoucherCost
--			,intTransactionId
--			,intTransactionDetailId
--			,strTransactionId
--			,intTransactionTypeId
--			,strActualCostId
--			,intRelatedInventoryTransactionId
--			,intFobPointId
--			,intInTransitSourceLocationId
--	FROM	@Internal_ItemsToAdjust

--	OPEN loopItemsToAdjustForAutoNegative;

--	-- Initial fetch attempt
--	FETCH NEXT FROM loopItemsToAdjustForAutoNegative INTO 
--		@intId
--		,@intItemId
--		,@intItemLocationId
--		,@intItemUOMId
--		,@intSubLocationId
--		,@intStorageLocationId
--		,@dtmDate
--		,@intCostUOMId
--		,@dblNewCost
--		,@intTransactionId
--		,@intTransactionDetailId
--		,@strTransactionId
--		,@intTransactionTypeId
--		,@strActualCostId
--		,@intRelatedInventoryTransactionId
--		,@intFobPointId 
--		,@intInTransitSourceLocationId
--	;

--	DECLARE @AutoNegativeAmount AS NUMERIC(38, 20)
--	WHILE @@FETCH_STATUS = 0
--	BEGIN 
--		-- Initialize the costing method 
--		SET @CostingMethod = NULL;
--		SET @AutoNegativeAmount = 0

--		-- Get the costing method of an item 
--		SELECT	@CostingMethod = CostingMethod 
--		FROM	dbo.fnGetCostingMethodAsTable(@intItemId, @intItemLocationId)

--		--------------------------------------------------------------------------------
--		-- Perform the Auto-Negative on Items using the Average Costing
--		--------------------------------------------------------------------------------
--		-- Average Cost
--		IF (@CostingMethod = @AVERAGECOST) AND ISNULL(@strActualCostId, '') = ''
--		BEGIN 
--			SELECT	@AutoNegativeAmount = 
--						dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) 
--						- dbo.fnGetItemTotalValueFromTransactions(
--							Stock.intItemId, 
--							Stock.intItemLocationId
--						)
--			FROM	dbo.tblICItemStock Stock INNER JOIN dbo.tblICItemPricing ItemPricing
--						ON	Stock.intItemId = ItemPricing.intItemId
--							AND Stock.intItemLocationId = ItemPricing.intItemLocationId
--			WHERE	Stock.intItemId = @intItemId
--					AND Stock.intItemLocationId = @intItemLocationId

--			IF ROUND(ISNULL(@AutoNegativeAmount, 0),6) <> 0.00
--			BEGIN 
--				EXEC [dbo].[uspICPostInventoryTransaction]
--						@intItemId								= @intItemId
--						,@intItemLocationId						= @intItemLocationId
--						,@intItemUOMId							= @intItemUOMId
--						,@intSubLocationId						= @intSubLocationId
--						,@intStorageLocationId					= @intStorageLocationId
--						,@dtmDate								= @dtmDate
--						,@dblQty								= 0
--						,@dblUOMQty								= 0
--						,@dblCost								= 0
--						,@dblValue								= @AutoNegativeAmount
--						,@dblSalesPrice							= 0
--						,@intCurrencyId							= NULL
--						,@intTransactionId						= @intTransactionId
--						,@intTransactionDetailId				= @intTransactionDetailId
--						,@strTransactionId						= @strTransactionId
--						,@strBatchId							= @strBatchId
--						,@intTransactionTypeId					= @INVENTORY_AUTO_NEGATIVE
--						,@intLotId								= NULL
--						,@intRelatedInventoryTransactionId		= @intRelatedInventoryTransactionId
--						,@intRelatedTransactionId				= NULL 
--						,@strRelatedTransactionId				= NULL						
--						,@strTransactionForm					= @TransactionFormName
--						,@intEntityUserSecurityId				= @intEntityUserSecurityId
--						,@intCostingMethod						= @AVERAGECOST
--						,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT 
--						,@intFobPointId							= @intFobPointId
--						,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
--			END 
--		END

--		FETCH NEXT FROM loopItemsToAdjustForAutoNegative INTO 
--			@intId
--			,@intItemId
--			,@intItemLocationId
--			,@intItemUOMId
--			,@intSubLocationId
--			,@intStorageLocationId
--			,@dtmDate
--			,@intCostUOMId
--			,@dblNewCost
--			,@intTransactionId
--			,@intTransactionDetailId
--			,@strTransactionId
--			,@intTransactionTypeId
--			,@strActualCostId
--			,@intRelatedInventoryTransactionId
--			,@intFobPointId
--			,@intInTransitSourceLocationId
--		;
--	END 

--	-----------------------------------------------------------------------------------------------------------------------------
--	-- End of the loop
--	-----------------------------------------------------------------------------------------------------------------------------
--	CLOSE loopItemsToAdjustForAutoNegative;
--	DEALLOCATE loopItemsToAdjustForAutoNegative;
--END 

-------------------------------------------------------------------------------------------
-- Repeat the cost adjustment process if there are 'Produced/Transferred' stocks affected. 
-------------------------------------------------------------------------------------------
IF EXISTS (SELECT TOP 1 1 FROM #tmpRevalueProducedItems) 
BEGIN 
	-- Clear the contents of the @Internal_ItemsToAdjust table variable. 
	DELETE FROM @Internal_ItemsToAdjust

	-- Transfer the data from the temp table into @Internal_ItemsToAdjust. 
	-- These are the 'Produced' items inserted into #tmpRevalueProducedItems by the costing SP's above. (ex: uspICPostCostAdjustmentOnAverageCosting)
	INSERT INTO @Internal_ItemsToAdjust (
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty] 
			,[intCostUOMId]
			,[dblVoucherCost] 
			,[dblNewValue]
			,[intCurrencyId] 
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
			,[intSourceTransactionDetailId] 
			,[strSourceTransactionId]
			,[intRelatedInventoryTransactionId]
			,[intFobPointId]
			,[intInTransitSourceLocationId]
	)
	SELECT 
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty] 
			,[intItemUOMId] -- Use the cost bucket item uom id as the Cost UOM id. 
			,[dblNewCost] 
			,[dblNewValue]
			,[intCurrencyId] 
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
			,[intSourceTransactionDetailId] 
			,[strSourceTransactionId] 
			,[intRelatedInventoryTransactionId]
			,[intFobPointId]
			,[intInTransitSourceLocationId]
	FROM	#tmpRevalueProducedItems
	ORDER BY [intItemId]
			,[intItemLocationId]
			,[strTransactionId]

	-- Clear the contents of the temp table.
	DELETE FROM #tmpRevalueProducedItems

	-- Do the loop. 
	GOTO START_LOOP
END 

-- Comment it out because of: "Cannot use the ROLLBACK statement within an INSERT-EXEC statement"
-- Caller module will have manually call uspICCreateGLEntriesOnCostAdjustment after calling uspICPostCostAdjustment. 
-------------------------------------------------
---------- Generate the g/l entries
-------------------------------------------------
----------EXEC dbo.uspICCreateGLEntriesOnCostAdjustment 
----------	@strBatchId
----------	,@intEntityUserSecurityId

-- If there is an error, return top error code id back to the caller to inform about the error. 
-- The caller can now do the roll back or ignore those records with error. 
SET @ReturnValue = NULL 
SELECT	TOP 1 
		@ReturnValue = intErrorId
FROM	tblICPostResult 
WHERE	strBatchNumber = @strBatchId

RETURN ISNULL(@ReturnValue, 0);