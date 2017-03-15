/*
	This is the stored procedure that handles the adjustment of the cost for an item on Average Costing. 
*/
CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentOnAverageCosting2]
	@dtmDate AS DATETIME
	,@intItemId AS INT
	,@intItemLocationId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT 
	,@intItemUOMId AS INT	
	,@dblQty AS NUMERIC(38,20)
	,@intCostUOMId AS INT 
	,@dblVoucherCost AS NUMERIC(38,20)
	,@dblNewValue AS NUMERIC(38,20)
	,@intTransactionId AS INT
	,@intTransactionDetailId AS INT
	,@strTransactionId AS NVARCHAR(20)
	,@intSourceTransactionId AS INT
	,@intSourceTransactionDetailId AS INT 
	,@strSourceTransactionId AS NVARCHAR(20)
	,@strBatchId AS NVARCHAR(20)
	,@intTransactionTypeId AS INT
	,@intCurrencyId AS INT 
	,@dblExchangeRate AS NUMERIC(38,20)	
	,@intEntityUserSecurityId AS INT
	,@intRelatedInventoryTransactionId AS INT = NULL 
	,@strTransactionForm AS NVARCHAR(50) = 'Bill'
	,@intFobPointId AS TINYINT = NULL
	,@intInTransitSourceLocationId AS INT = NULL  
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the temp table if it does not exists. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRevalueProducedItems')) 
BEGIN 
	CREATE TABLE #tmpRevalueProducedItems (
		[intId] INT IDENTITY PRIMARY KEY CLUSTERED	
		,[intItemId] INT NOT NULL								-- The item. 
		,[intItemLocationId] INT NULL							-- The location where the item is stored.
		,[intItemUOMId] INT NOT NULL							-- The UOM used for the item.
		,[dtmDate] DATETIME NOT NULL							-- The date of the transaction
		,[dblQty] NUMERIC(38,20) NOT NULL DEFAULT 0				-- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
		,[dblUOMQty] NUMERIC(38,20) NOT NULL DEFAULT 1			-- The quantity of an item per UOM. For example, a box can contain 12 individual pieces of an item. 
		,[dblNewCost] NUMERIC(38,20) NULL DEFAULT 0				-- The cost of purchasing a item per UOM. For example, $12 is the cost for a 12-piece box. This parameter should hold a $12 value and not $1 per pieces found in a 12-piece box. The cost is stored in base currency. 
		,[dblNewValue] NUMERIC(38,20) NULL 						-- 
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
		,[intSourceTransactionId] INT NULL						-- The integer id for the cost bucket (Ex. The integer id of INVRCT-10001 is 1934). 
		,[intSourceTransactionDetailId] INT NULL				-- The integer id for the cost bucket in terms of tblICInventoryReceiptItem.intInventoryReceiptItemId (Ex. The value of tblICInventoryReceiptItem.intInventoryReceiptItemId is 1230). 
		,[strSourceTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL -- The string id for the cost bucket (Ex. "INVRCT-10001"). 
		,[intRelatedInventoryTransactionId] INT NULL 
		,[intFobPointId] TINYINT NULL 
		,[intInTransitSourceLocationId] INT NULL 
	)
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Initialize
-----------------------------------------------------------------------------------------------------------------------------

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	

		,@FOB_ORIGIN AS TINYINT = 1
		,@FOB_DESTINATION AS TINYINT = 2

-- Declare the cost types
DECLARE @COST_ADJ_TYPE_Original_Cost AS INT = 1
		,@COST_ADJ_TYPE_New_Cost AS INT = 2

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INV_TRANS_TYPE_Auto_Negative AS INT = 1
		,@INV_TRANS_TYPE_Write_Off_Sold AS INT = 2
		,@INV_TRANS_TYPE_Revalue_Sold AS INT = 3

		,@INV_TRANS_TYPE_Inventory_Receipt AS INT = 4
		,@INV_TRANS_TYPE_Inventory_Shipment AS INT = 5

		,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
		,@INV_TRANS_TYPE_Revalue_WIP AS INT = 28
		,@INV_TRANS_TYPE_Revalue_Produced AS INT = 29
		,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 30
		,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 31

		,@INV_TRANS_TYPE_Revalue_Item_Change AS INT = 36
		,@INV_TRANS_TYPE_Revalue_Split_Lot AS INT = 37
		,@INV_TRANS_TYPE_Revalue_Lot_Merge AS INT = 38
		,@INV_TRANS_TYPE_Revalue_Lot_Move AS INT = 39		
		,@INV_TRANS_TYPE_Revalue_Shipment AS INT = 40

		,@INV_TRANS_TYPE_Consume AS INT = 8
		,@INV_TRANS_TYPE_Produce AS INT = 9
		,@INV_TRANS_TYPE_Build_Assembly AS INT = 11
		,@INV_TRANS_Inventory_Transfer AS INT = 12

		,@INV_TRANS_TYPE_ADJ_Item_Change AS INT = 15
		,@INV_TRANS_TYPE_ADJ_Split_Lot AS INT = 17
		,@INV_TRANS_TYPE_ADJ_Lot_Merge AS INT = 19
		,@INV_TRANS_TYPE_ADJ_Lot_Move AS INT = 20

DECLARE	@RunningQty AS NUMERIC(38, 20)

		,@CB_intInventoryFIFOId AS INT 
		,@CB_intItemId AS INT 
		,@CB_intItemLocationId AS INT 
		,@CB_intItemUOMId AS INT 
		,@CB_dblStockIn AS NUMERIC(38, 20)
		,@CB_dblStockOut AS NUMERIC(38, 20)
		,@CB_dblCost AS NUMERIC(38, 20)
		,@CB_strTransactionId AS NVARCHAR(50)
		,@CB_intTransactionId AS INT 
		,@CB_intTransactionDetailId AS INT  

		,@AdjustQty AS NUMERIC(38, 20)
		,@AdjustmentValue AS NUMERIC(38, 20) 
		,@NewCost AS NUMERIC(38, 20)
		,@CostAdjustmentTransactionType AS INT 
		,@InventoryTransactionIdentityId AS INT 
		,@StockItemUOMId AS INT 
						
-- Exit immediately if item is a lot type. 
IF dbo.fnGetItemLotType(@intItemId) <> 0 
BEGIN 
	GOTO Post_Exit;
END 

-- Get the top cost bucket.
DECLARE @CostBucketStartingPoint AS INT 

SELECT	TOP 1 
		@CostBucketStartingPoint = cb.intInventoryFIFOId
FROM	tblICInventoryFIFO cb 
WHERE	cb.intItemId = @intItemId
		AND cb.intItemLocationId = @intItemLocationId
		AND cb.intTransactionId = @intSourceTransactionId
		AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
		AND cb.strTransactionId = @strSourceTransactionId
		AND ISNULL(cb.ysnIsUnposted, 0) = 0 

-- Validate the cost bucket
BEGIN 
	IF @CostBucketStartingPoint IS NULL
	BEGIN 
		DECLARE @strItemNo AS NVARCHAR(50)				

		SELECT	@strItemNo = CASE WHEN ISNULL(strItemNo, '') = '' THEN 'id: ' + CAST(@intItemId AS NVARCHAR(20)) ELSE strItemNo END 
		FROM	tblICItem 
		WHERE	intItemId = @intItemId

		-- 'Cost adjustment cannot continue. Unable to find the cost bucket for %s that was posted in %s.
		RAISERROR(80062, 11, 1, @strItemNo, @strSourceTransactionId)  
		RETURN -1 
	END
END 

-- Initialize the Running Qty (converted to stock UOM) 
BEGIN 
	SELECT	TOP 1 
			@StockItemUOMId = intItemUOMId
	FROM	tblICItemUOM iUOM
	WHERE	iUOM.intItemId = @intItemId	

	SELECT	TOP 1 
			@RunningQty = SUM (
				dbo.fnCalculateQtyBetweenUOM(cb.intItemUOMId, @StockItemUOMId, cb.dblStockIn)
				- dbo.fnCalculateQtyBetweenUOM(cb.intItemUOMId, @StockItemUOMId, cb.dblStockOut)
			) 
	FROM	tblICInventoryFIFO cb INNER JOIN tblICItemUOM iUOM
				ON cb.intItemUOMId = iUOM.intItemUOMId
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
			AND cb.intInventoryFIFOId < @CostBucketStartingPoint

	SET @RunningQty = ISNULL(@RunningQty, 0) 
END 

-- Loop thru the cost buckets. 
BEGIN 
	-----------------------------------------------------------------------------------------------------------------------------
	-- Create the cursor
	-- Make sure the following options are used: 
	-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
	-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
	-----------------------------------------------------------------------------------------------------------------------------
	DECLARE loopCostBuckets CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  cb.intInventoryFIFOId
			,cb.intItemId
			,cb.intItemLocationId
			,cb.intItemUOMId
			,cb.dblStockIn
			,cb.dblStockOut
			,cb.dblCost
			,cb.strTransactionId
			,cb.intTransactionId
			,cb.intTransactionDetailId
	FROM	tblICInventoryFIFO cb 
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
			AND cb.intInventoryFIFOId >= @CostBucketStartingPoint

	OPEN loopCostBuckets;

	-- Initial fetch attempt
	FETCH NEXT FROM loopCostBuckets INTO 
		@CB_intInventoryFIFOId 
		,@CB_intItemId 
		,@CB_intItemLocationId 
		,@CB_intItemUOMId 
		,@CB_dblStockIn 
		,@CB_dblStockOut 
		,@CB_dblCost 
		,@CB_strTransactionId
		,@CB_intTransactionId
		,@CB_intTransactionDetailId
	;
	-----------------------------------------------------------------------------------------------------------------------------
	-- Start of the loop for sold/produced items. 
	-----------------------------------------------------------------------------------------------------------------------------
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		-- Calculate the running qty. 
		SET @RunningQty += dbo.fnCalculateQtyBetweenUOM(@CB_intItemUOMId, @StockItemUOMId, @CB_dblStockIn - @CB_dblStockOut)

		-- 1. Process the source transaction. 
		IF @CB_strTransactionId = @strSourceTransactionId AND @CB_dblStockIn > 0 
		BEGIN 
			SET @AdjustQty = CASE WHEN @dblNewValue IS NULL THEN dbo.fnCalculateQtyBetweenUOM(@intItemUOMId, @CB_intItemUOMId, @dblQty) ELSE 0 END 

			-- Calculate the new cost for the source transaction. 
			SET @AdjustmentValue = 
				CASE	WHEN @dblNewValue IS NULL THEN 
							dbo.fnMultiply(
								@AdjustQty
								,dbo.fnCalculateCostBetweenUOM(@intCostUOMId, @CB_intItemUOMId, @dblVoucherCost)
							) 
						ELSE 
							@dblNewValue
				END 
				- dbo.fnMultiply(
					@CB_dblCost
					,@CB_dblStockIn
				)

			SET @NewCost = dbo.fnDivide(
				dbo.fnMultiply(@CB_dblCost, @CB_dblStockIn) + @AdjustmentValue
				, @CB_dblStockIn
			) 

			-- Determine the transaction type to use. 
			SELECT @CostAdjustmentTransactionType =		
					CASE	WHEN @intTransactionTypeId NOT IN (
									@INV_TRANS_TYPE_Revalue_WIP
									,@INV_TRANS_TYPE_Revalue_Produced
									,@INV_TRANS_TYPE_Revalue_Transfer
									,@INV_TRANS_TYPE_Revalue_Build_Assembly						
									,@INV_TRANS_TYPE_Revalue_Item_Change
									,@INV_TRANS_TYPE_Revalue_Lot_Merge
									,@INV_TRANS_TYPE_Revalue_Lot_Move
									,@INV_TRANS_TYPE_Revalue_Split_Lot
									,@INV_TRANS_TYPE_Revalue_Shipment
							) THEN 
								@INV_TRANS_TYPE_Cost_Adjustment
							ELSE 
								@intTransactionTypeId
					END

			-- Create the 'Cost Adjustment'
			EXEC [uspICPostInventoryTransaction]
				@intItemId								= @intItemId
				,@intItemLocationId						= @intItemLocationId
				,@intItemUOMId							= @intItemUOMId
				,@intSubLocationId						= @intSubLocationId
				,@intStorageLocationId					= @intStorageLocationId
				,@dtmDate								= @dtmDate
				,@dblQty								= 0
				,@dblUOMQty								= 0
				,@dblCost								= 0
				,@dblValue								= @AdjustmentValue
				,@dblSalesPrice							= 0
				,@intCurrencyId							= @intCurrencyId 
				--,@dblExchangeRate						= @dblExchangeRate
				,@intTransactionId						= @intTransactionId
				,@intTransactionDetailId				= @intTransactionDetailId
				,@strTransactionId						= @strTransactionId
				,@strBatchId							= @strBatchId
				,@intTransactionTypeId					= @CostAdjustmentTransactionType 
				,@intLotId								= NULL  
				,@intRelatedInventoryTransactionId		= @intRelatedInventoryTransactionId 
				,@intRelatedTransactionId				= @CB_intTransactionId 
				,@strRelatedTransactionId				= @CB_strTransactionId
				,@strTransactionForm					= @strTransactionForm
				,@intEntityUserSecurityId				= @intEntityUserSecurityId
				,@intCostingMethod						= @AVERAGECOST
				,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
				,@intFobPointId							= @intFobPointId 
				,@intInTransitSourceLocationId			= @intInTransitSourceLocationId

			-- Log original cost to tblICInventoryFIFOCostAdjustmentLog
			IF NOT EXISTS (
					SELECT	TOP 1 1 
					FROM	tblICInventoryFIFOCostAdjustmentLog
					WHERE	intInventoryFIFOId = @CB_intInventoryFIFOId
							AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
							AND ysnIsUnposted = 0 
			)
			BEGIN 
				INSERT INTO tblICInventoryFIFOCostAdjustmentLog (
						[intInventoryFIFOId]
						,[intInventoryTransactionId]
						,[intInventoryCostAdjustmentTypeId]
						,[dblQty]
						,[dblCost]
						,[dtmCreated]
						,[intCreatedUserId]		
				)
				SELECT	[intInventoryFIFOId]				= @CB_intInventoryFIFOId
						,[intInventoryTransactionId]		= @InventoryTransactionIdentityId
						,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_Original_Cost
						,[dblQty]							= @AdjustQty
						,[dblCost]							= @CB_dblCost
						,[dtmCreated]						= GETDATE()
						,[intCreatedEntityUserId]			= @intEntityUserSecurityId
			END 

			-- Log a new cost. 
			BEGIN 
				INSERT INTO tblICInventoryFIFOCostAdjustmentLog (
						[intInventoryFIFOId]
						,[intInventoryTransactionId]
						,[intInventoryCostAdjustmentTypeId]
						,[dblQty]
						,[dblCost]
						,[dtmCreated]
						,[intCreatedUserId]		
				)
				SELECT	[intInventoryFIFOId]				= @CB_intInventoryFIFOId
						,[intInventoryTransactionId]		= @InventoryTransactionIdentityId
						,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_New_Cost
						,[dblQty]							= @dblQty
						,[dblCost]							= @NewCost
						,[dtmCreated]						= GETDATE()
						,[intCreatedEntityUserId]			= @intEntityUserSecurityId
			END 

			-- Update cb with the new cost. 
			UPDATE	cb
			SET		cb.dblCost = @NewCost
			FROM	tblICInventoryFIFO cb
			WHERE	cb.intInventoryFIFOId = @CB_intInventoryFIFOId
		END 

		-- 2. Process the lot out. 
		BEGIN 
			SET @NewCost = @NewCost;


			SELECT	* 
			FROM	tblICInventoryFIFOOut cbOut
			WHERE	cbOut.intInventoryFIFOId = @CB_intInventoryFIFOId
		END

		-- Stop the loop if running qty becomes zero or negative. 
		IF @RunningQty <= 0 
		BREAK; 

		FETCH NEXT FROM loopCostBuckets INTO 
			@CB_intInventoryFIFOId 
			,@CB_intItemId 
			,@CB_intItemLocationId 
			,@CB_intItemUOMId 
			,@CB_dblStockIn 
			,@CB_dblStockOut 
			,@CB_dblCost 
			,@CB_strTransactionId
			,@CB_intTransactionId
			,@CB_intTransactionDetailId
		;
	END 

	CLOSE loopCostBuckets;
	DEALLOCATE loopCostBuckets;

END 


-- Immediate exit
Post_Exit: 
