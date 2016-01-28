﻿/*
	This is the stored procedure that handles the adjustment of the cost for an item on Lot Costing. 
*/
CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentOnLotCosting]
	@dtmDate AS DATETIME
	,@intItemId AS INT
	,@intItemLocationId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT 
	,@intItemUOMId AS INT	
	,@dblQty AS NUMERIC(18,6)
	,@dblNewCost AS NUMERIC(38,20)
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
	,@strTransactionForm AS NVARCHAR(50) = 'Bill'
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
		,[intSourceTransactionId] INT NULL						-- The integer id for the cost bucket (Ex. The integer id of INVRCT-10001 is 1934). 
		,[intSourceTransactionDetailId] INT NULL				-- The integer id for the cost bucket in terms of tblICInventoryReceiptItem.intInventoryReceiptItemId (Ex. The value of tblICInventoryReceiptItem.intInventoryReceiptItemId is 1230). 
		,[strSourceTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL -- The string id for the cost bucket (Ex. "INVRCT-10001"). 
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

-- Declare the cost types
DECLARE @COST_ADJ_TYPE_Original_Cost AS INT = 1
		,@COST_ADJ_TYPE_New_Cost AS INT = 2

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INV_TRANS_TYPE_Auto_Negative AS INT = 1
		,@INV_TRANS_TYPE_Write_Off_Sold AS INT = 2
		,@INV_TRANS_TYPE_Revalue_Sold AS INT = 3

		,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
		,@INV_TRANS_TYPE_Revalue_WIP AS INT = 28
		,@INV_TRANS_TYPE_Revalue_Produced AS INT = 29
		,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 30
		,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 31

		,@INV_TRANS_TYPE_Consume AS INT = 8
		,@INV_TRANS_TYPE_Produce AS INT = 9
		,@INV_TRANS_TYPE_Build_Assembly AS INT = 11
		,@INV_TRANS_Inventory_Transfer AS INT = 12

DECLARE @CostBucketId AS INT
		,@CostBucketCost AS NUMERIC(38,20)
		,@CostBucketStockInQty AS NUMERIC(18,6)
		,@CostBucketStockOutQty AS NUMERIC(18,6)
		,@CostBucketUOMQty AS NUMERIC(18,6)
		,@CostBucketIntTransactionId AS INT
		,@CostBucketStrTransactionId AS NVARCHAR(40)

		,@InventoryTransactionIdentityId AS INT
		,@OriginalCost AS NUMERIC(38,20)
		,@dblNewCalculatedCost AS NUMERIC(38,20)

DECLARE @InvTranId AS INT
		,@InvTranQty AS NUMERIC(18,6)
		,@InvTranUOMQty AS NUMERIC(18,6)
		,@InvTranCost AS NUMERIC(38,20)
		,@InvTranValue AS NUMERIC(38,20)
		,@InvTranSubLocationId AS INT
		,@InvTranStorageLocationId AS INT 
		,@InvTranCurrencyId AS INT
		,@InvTranExchangeRate AS INT
		,@InvTranStringTransactionId AS NVARCHAR(40)
		,@InvTranIntTransactionId AS INT
		,@InvTranTypeName AS NVARCHAR(200)
		,@InvTranTypeId AS INT 
		,@InvTranBatchId AS NVARCHAR(20)

DECLARE	@OriginalTransactionValue AS NUMERIC(38,20)
		,@NewTransactionValue AS NUMERIC(38,20)
		,@CostAdjustmentValue AS NUMERIC(38,20)

DECLARE @LoopTransactionTypeId AS INT 
		,@CostAdjustmentTransactionType AS INT = @intTransactionTypeId		
		,@intLotId AS INT 
		
DECLARE @dblRemainingQty AS NUMERIC(18,6)
		,@AdjustedQty AS NUMERIC(18,6) 
		,@AdjustableQty AS NUMERIC(18,6)

-- Exit immediately if item is a non-lot type. 
IF dbo.fnGetItemLotType(@intItemId) = 0 
BEGIN 
	GOTO Post_Exit;
END 

-- Get the number of Lots to process. 
DECLARE @LotWithOldCost AS INT = 0 
SELECT	@LotWithOldCost = COUNT(intLotId) 
FROM	dbo.tblICInventoryLot LEFT JOIN dbo.tblICItemUOM 
			ON tblICInventoryLot.intItemUOMId = tblICItemUOM.intItemUOMId
WHERE	tblICInventoryLot.intItemId = @intItemId
		AND tblICInventoryLot.intItemLocationId = @intItemLocationId
		AND tblICInventoryLot.intTransactionId = @intSourceTransactionId
		AND tblICInventoryLot.intTransactionDetailId = @intSourceTransactionDetailId
		AND tblICInventoryLot.strTransactionId = @strSourceTransactionId
		AND ISNULL(tblICInventoryLot.ysnIsUnposted, 0) = 0 


-- Initialize the Remaining Qty 
SET @dblRemainingQty = ISNULL(@dblQty, 0) 

-----------------------------------------------------------------------------------------------------------------------------
-- Start loop for the lot numbers. 
-----------------------------------------------------------------------------------------------------------------------------
WHILE ISNULL(@LotWithOldCost, 0) > 0 AND @dblRemainingQty > 0 
BEGIN 
	SET @CostBucketId = NULL 

	-----------------------------------------------------------------------------------------------------------------------------
	-- 1. Get the cost bucket and original cost. 
	-----------------------------------------------------------------------------------------------------------------------------
	BEGIN 
		SELECT	TOP 1
				@CostBucketId = intInventoryLotId
				,@CostBucketCost = dblCost			
				,@CostBucketStockInQty = dblStockIn
				,@CostBucketStockOutQty = dblStockOut
				,@CostBucketUOMQty = tblICItemUOM.dblUnitQty
				,@CostBucketIntTransactionId = intTransactionId
				,@CostBucketStrTransactionId = strTransactionId
				,@intLotId = intLotId
		FROM	dbo.tblICInventoryLot LEFT JOIN dbo.tblICItemUOM 
					ON tblICInventoryLot.intItemUOMId = tblICItemUOM.intItemUOMId
		WHERE	tblICInventoryLot.intItemId = @intItemId
				AND tblICInventoryLot.intItemUOMId = @intItemUOMId
				AND tblICInventoryLot.intItemLocationId = @intItemLocationId
				AND tblICInventoryLot.intTransactionId = @intSourceTransactionId
				AND tblICInventoryLot.intTransactionDetailId = @intSourceTransactionDetailId
				AND tblICInventoryLot.strTransactionId = @strSourceTransactionId
				AND ISNULL(tblICInventoryLot.ysnIsUnposted, 0) = 0 
				AND tblICInventoryLot.intLotId > ISNULL(@intLotId, 0) 
				AND tblICInventoryLot.dblCost <> @dblNewCost
	END 

	-- Validate the cost bucket
	BEGIN 
		IF @CostBucketId IS NULL
		BEGIN 
			DECLARE @strItemNo AS NVARCHAR(50)				

			SELECT	@strItemNo = CASE WHEN ISNULL(strItemNo, '') = '' THEN 'id: ' + CAST(@intItemId AS NVARCHAR(20)) ELSE strItemNo END 
			FROM	dbo.tblICItem 
			WHERE	intItemId = @intItemId

			-- 'Cost adjustment cannot continue. Unable to find the cost bucket for the lot in item {Item No}.'
			RAISERROR(80071, 11, 1, @strItemNo)  
			RETURN -1 
		END
	END 

	-- Reduce the counter. 
	SET @LotWithOldCost -= 1		

	-----------------------------------------------------------------------------------------------------------------------------
	-- 3. Compute the cost difference. 
	-- 4. Update the cost bucket with the new cost. 
	-- 5. Create the 'Inventory Transaction' as 'Cost Adjustment' type. 
	-----------------------------------------------------------------------------------------------------------------------------
	BEGIN 
		-- Get the original cost. 
		BEGIN 
			-- Get the original cost from the Lot cost adjustment log table. 
			SELECT	@OriginalCost = dblCost
			FROM	dbo.tblICInventoryLotCostAdjustmentLog
			WHERE	intInventoryLotId = @CostBucketId
					AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
					AND ysnIsUnposted = 0 
		
			-- If none found, the original cost is the cost bucket cost. 
			SET @OriginalCost = ISNULL(@OriginalCost, @CostBucketCost) 
		END 

		-- Compute the stock Qty available for cost adjustment. 
		BEGIN 
			SET @AdjustedQty = NULL 

			SELECT	@AdjustedQty = SUM(dblQty) 
			FROM	dbo.tblICInventoryLotCostAdjustmentLog
			WHERE	intInventoryLotId = @CostBucketId
					AND intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
					AND ysnIsUnposted = 0 

			-- Determine the stock Qty it can process. 
			SET @AdjustableQty = @CostBucketStockInQty - ISNULL(@AdjustedQty, 0) 

			-- Initialize the Qty
			SET @dblQty = 
				CASE	WHEN @dblRemainingQty >= @AdjustableQty THEN 
							@AdjustableQty 
						ELSE 
							@dblRemainingQty
				END 

			-- Calculate the remaining Qty
			SET @dblRemainingQty = 
				CASE	WHEN @dblRemainingQty >= @AdjustableQty THEN 
							@dblRemainingQty - @AdjustableQty 
						ELSE 
							0 
				END 
		END 

		-- Compute the new transaction value. 
		SELECT	@NewTransactionValue = @dblQty * @dblNewCost

		-- Compute the original transaction value. 
		SELECT	@OriginalTransactionValue = @dblQty * @OriginalCost

		-- Compute the new cost. 
		SELECT @dblNewCalculatedCost =	@CostBucketCost 
										+ ((@NewTransactionValue - @OriginalTransactionValue) / @CostBucketStockInQty)	

		-- Compute value to adjust the item valuation. 
		SELECT @CostAdjustmentValue = @dblQty * (@dblNewCost - @OriginalCost)

		-- Determine the transaction type to use. 
		SELECT @CostAdjustmentTransactionType =		
				CASE	WHEN @intTransactionTypeId NOT IN (
								@INV_TRANS_TYPE_Revalue_WIP
								, @INV_TRANS_TYPE_Revalue_Produced
								, @INV_TRANS_TYPE_Revalue_Transfer
								, @INV_TRANS_TYPE_Revalue_Build_Assembly
						) THEN 
							@INV_TRANS_TYPE_Cost_Adjustment
						ELSE 
							@intTransactionTypeId
				END

		-- Create the 'Cost Adjustment'
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
			,@dblValue								= @CostAdjustmentValue
			,@dblSalesPrice							= 0
			,@intCurrencyId							= @intCurrencyId 
			,@dblExchangeRate						= @dblExchangeRate
			,@intTransactionId						= @intTransactionId
			,@intTransactionDetailId				= @intTransactionDetailId
			,@strTransactionId						= @strTransactionId
			,@strBatchId							= @strBatchId
			,@intTransactionTypeId					= @CostAdjustmentTransactionType -- @INV_TRANS_TYPE_Cost_Adjustment
			,@intLotId								= @intLotId 
			,@intRelatedInventoryTransactionId		= NULL 
			,@intRelatedTransactionId				= @CostBucketIntTransactionId 
			,@strRelatedTransactionId				= @CostBucketStrTransactionId
			,@strTransactionForm					= @strTransactionForm
			,@intEntityUserSecurityId				= @intEntityUserSecurityId
			,@intCostingMethod						= @LOTCOST
			,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT

		-- Log original cost to tblICInventoryLotCostAdjustmentLog
		IF NOT EXISTS (
				SELECT	TOP 1 1 
				FROM	dbo.tblICInventoryLotCostAdjustmentLog
				WHERE	intInventoryLotId = @CostBucketId
						AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
		)
		BEGIN 
			INSERT INTO tblICInventoryLotCostAdjustmentLog (
					[intInventoryLotId]
					,[intInventoryTransactionId]
					,[intInventoryCostAdjustmentTypeId]
					,[dblQty]
					,[dblCost]
					,[dtmCreated]
					,[intCreatedUserId]		
			)
			SELECT	[intInventoryLotId]					= @CostBucketId
					,[intInventoryTransactionId]		= @InventoryTransactionIdentityId
					,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_Original_Cost
					,[dblQty]							= @CostBucketStockInQty
					,[dblCost]							= @CostBucketCost
					,[dtmCreated]						= GETDATE()
					,[intCreatedEntityUserId]			= @intEntityUserSecurityId
		END 

		-- Log a new cost. 
		BEGIN 
			INSERT INTO tblICInventoryLotCostAdjustmentLog (
					[intInventoryLotId]
					,[intInventoryTransactionId]
					,[intInventoryCostAdjustmentTypeId]
					,[dblQty]
					,[dblCost]
					,[dtmCreated]
					,[intCreatedUserId]		
			)
			SELECT	[intInventoryLotId]					= @CostBucketId
					,[intInventoryTransactionId]		= @InventoryTransactionIdentityId
					,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_New_Cost
					,[dblQty]							= @dblQty
					,[dblCost]							= @dblNewCost
					,[dtmCreated]						= GETDATE()
					,[intCreatedEntityUserId]			= @intEntityUserSecurityId
		END 
			
		-- Calculate the new cost
		UPDATE	CostBucket
		SET		dblCost = @dblNewCalculatedCost
		FROM	tblICInventoryLot CostBucket
		WHERE	CostBucket.intInventoryLotId = @CostBucketId
				AND CostBucket.dblStockIn > 0 
				AND ISNULL(ysnIsUnposted, 0) = 0 
	END 

	-----------------------------------------------------------------------------------------------------------------------------
	-- Begin loop for sold or consumed stocks
	-----------------------------------------------------------------------------------------------------------------------------
	IF @dblNewCalculatedCost IS NOT NULL 
	BEGIN 
		-- Get the Lot Out records. 
		DECLARE @LotOutId AS INT 
				,@LotOutInventoryLotId AS INT 
				,@LotOutInventoryTransactionId AS INT 
				,@LotOutRevalueLotId AS INT 
				,@LotOutQty AS NUMERIC(18, 6)
				,@LotCostAdjustQty AS NUMERIC(18, 6)

				,@StockQtyAvailableToRevalue AS NUMERIC(18, 6) = @dblQty
				,@StockQtyToRevalue AS NUMERIC(18, 6) = @dblQty

		-----------------------------------------------------------------------------------------------------------------------------
		-- Create the cursor
		-- Make sure the following options are used: 
		-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
		-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
		-----------------------------------------------------------------------------------------------------------------------------
		DECLARE loopLotOut CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT  intId
				,intInventoryLotId
				,intInventoryTransactionId
				,intRevalueLotId
				,dblQty
				,dblCostAdjustQty
		FROM	dbo.tblICInventoryLotOut LotOut
		WHERE	LotOut.intInventoryLotId = @CostBucketId
				AND ISNULL(LotOut.dblCostAdjustQty, 0) < LotOut.dblQty -- If stocks can have a cost adjustment; [Cost Adj Qty] is less than [Lot Out Qty]

		OPEN loopLotOut;

		-- Initial fetch attempt
		FETCH NEXT FROM loopLotOut INTO 
				@LotOutId
				,@LotOutInventoryLotId 
				,@LotOutInventoryTransactionId 
				,@LotOutRevalueLotId 
				,@LotOutQty 
				,@LotCostAdjustQty
		;
		-----------------------------------------------------------------------------------------------------------------------------
		-- Start of the loop for sold/produced items. 
		-----------------------------------------------------------------------------------------------------------------------------
		WHILE @@FETCH_STATUS = 0
		BEGIN 
		
			-- Initialize the variables
			SELECT	@InvTranId						= NULL 
					,@InvTranSubLocationId			= NULL
					,@InvTranStorageLocationId		= NULL
					,@InvTranQty					= NULL
					,@InvTranUOMQty					= NULL
					,@InvTranCost					= NULL
					,@InvTranValue					= NULL
					,@InvTranCurrencyId				= NULL
					,@InvTranExchangeRate			= NULL
					,@InvTranIntTransactionId		= NULL
					,@InvTranStringTransactionId	= NULL
					,@InvTranTypeId					= NULL 
					,@InvTranBatchId				= NULL 

			-- Get the Stock Out data from the Inventory Transaction
			SELECT	@InvTranId						= InvTran.intInventoryTransactionId
					,@InvTranSubLocationId			= InvTran.intSubLocationId
					,@InvTranStorageLocationId		= InvTran.intStorageLocationId
					,@InvTranQty					= InvTran.dblQty 
					,@InvTranUOMQty					= InvTran.dblUOMQty
					,@InvTranCost					= InvTran.dblCost
					,@InvTranValue					= InvTran.dblValue 
					,@InvTranCurrencyId				= InvTran.intCurrencyId
					,@InvTranExchangeRate			= InvTran.dblExchangeRate
					,@InvTranIntTransactionId		= InvTran.intTransactionId
					,@InvTranStringTransactionId	= InvTran.strTransactionId
					,@InvTranTypeId					= InvTran.intTransactionTypeId
					,@InvTranBatchId				= InvTran.strBatchId
			FROM	dbo.tblICInventoryTransaction InvTran
			WHERE	InvTran.intInventoryTransactionId = @LotOutInventoryTransactionId

			-- Calculate the available 'out' stocks that the system can revalue. 
			SET @StockQtyAvailableToRevalue = ISNULL(@LotOutQty, 0) - ISNULL(@LotCostAdjustQty, 0)
		
			-- If there are available out stocks, then revalue it.  
			IF	 @StockQtyAvailableToRevalue > 0 
				AND @StockQtyToRevalue > 0
				AND @InvTranId IS NOT NULL 
			BEGIN 
				-- Calculate the revalue amount for the inventory transaction. 
				SELECT @InvTranValue =	-1 	
										* CASE WHEN ISNULL(@StockQtyAvailableToRevalue, 0) > @StockQtyToRevalue THEN 
												@StockQtyToRevalue
											ELSE 
												ISNULL(@StockQtyAvailableToRevalue, 0)
										END 																								
										* (@dblNewCost - @InvTranCost) 

				----------------------------------------------------------
				-- 7. If stock was sold, then do the "Revalue Sold". 
				----------------------------------------------------------
				IF @InvTranTypeId NOT IN (@INV_TRANS_TYPE_Consume, @INV_TRANS_TYPE_Build_Assembly, @INV_TRANS_Inventory_Transfer)
				BEGIN 
					EXEC [dbo].[uspICPostInventoryTransaction]
						@intItemId								= @intItemId
						,@intItemLocationId						= @intItemLocationId
						,@intItemUOMId							= @intItemUOMId
						,@intSubLocationId						= @InvTranSubLocationId 
						,@intStorageLocationId					= @InvTranStorageLocationId 
						,@dtmDate								= @dtmDate
						,@dblQty								= 0
						,@dblUOMQty								= 0
						,@dblCost								= 0
						,@dblValue								= @InvTranValue
						,@dblSalesPrice							= 0
						,@intCurrencyId							= @InvTranCurrencyId
						,@dblExchangeRate						= @InvTranExchangeRate
						,@intTransactionId						= @intTransactionId
						,@intTransactionDetailId				= @intTransactionDetailId
						,@strTransactionId						= @strTransactionId
						,@strBatchId							= @strBatchId
						,@intTransactionTypeId					= @INV_TRANS_TYPE_Revalue_Sold
						,@intLotId								= @intLotId 
						,@intRelatedInventoryTransactionId		= @LotOutInventoryTransactionId
						,@intRelatedTransactionId				= @InvTranIntTransactionId 
						,@strRelatedTransactionId				= @InvTranStringTransactionId 
						,@strTransactionForm					= @strTransactionForm
						,@intEntityUserSecurityId				= @intEntityUserSecurityId
						,@intCostingMethod						= @LOTCOST
						,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
				END 	

				---------------------------------------------------------------
				-- 8. If stock was consumed in a production or transfer
				---------------------------------------------------------------
				ELSE IF @InvTranTypeId IN (@INV_TRANS_TYPE_Consume, @INV_TRANS_TYPE_Build_Assembly, @INV_TRANS_Inventory_Transfer)
				BEGIN 
					SELECT	@CostAdjustmentTransactionType 
								= CASE	WHEN @InvTranTypeId = @INV_TRANS_Inventory_Transfer		THEN @INV_TRANS_TYPE_Revalue_Transfer
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_Consume			THEN @INV_TRANS_TYPE_Revalue_WIP
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_Build_Assembly	THEN @INV_TRANS_TYPE_Revalue_Build_Assembly
								END
							,@LoopTransactionTypeId
								= CASE	WHEN @InvTranTypeId = @INV_TRANS_Inventory_Transfer		THEN @INV_TRANS_TYPE_Revalue_Transfer
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_Consume			THEN @INV_TRANS_TYPE_Revalue_Produced
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_Build_Assembly	THEN @INV_TRANS_TYPE_Revalue_Build_Assembly
								END

					EXEC [dbo].[uspICPostInventoryTransaction]
						@intItemId								= @intItemId
						,@intItemLocationId						= @intItemLocationId
						,@intItemUOMId							= @intItemUOMId
						,@intSubLocationId						= @InvTranSubLocationId 
						,@intStorageLocationId					= @InvTranStorageLocationId 
						,@dtmDate								= @dtmDate
						,@dblQty								= 0
						,@dblUOMQty								= 0
						,@dblCost								= 0
						,@dblValue								= @InvTranValue
						,@dblSalesPrice							= 0
						,@intCurrencyId							= @InvTranCurrencyId
						,@dblExchangeRate						= @InvTranExchangeRate
						,@intTransactionId						= @intTransactionId
						,@intTransactionDetailId				= @intTransactionDetailId
						,@strTransactionId						= @strTransactionId
						,@strBatchId							= @strBatchId
						,@intTransactionTypeId					= @CostAdjustmentTransactionType
						,@intLotId								= @intLotId 
						,@intRelatedInventoryTransactionId		= @LotOutInventoryTransactionId
						,@intRelatedTransactionId				= @InvTranIntTransactionId 
						,@strRelatedTransactionId				= @InvTranStringTransactionId 
						,@strTransactionForm					= @strTransactionForm
						,@intEntityUserSecurityId				= @intEntityUserSecurityId
						,@intCostingMethod						= @LOTCOST
						,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
					
					----------------------------------------------------------------------------------------------------
					-- 9. Get the 'produced/transferred item'. Insert it in a temporary table for later processing. 
					----------------------------------------------------------------------------------------------------
					INSERT INTO #tmpRevalueProducedItems (
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
							,[intSourceTransactionDetailId] 
							,[strSourceTransactionId] 				
					)
					SELECT 
							[intItemId]						= InvTran.intItemId
							,[intItemLocationId]			= InvTran.intItemLocationId
							,[intItemUOMId]					= InvTran.intItemUOMId
							,[dtmDate]						= @dtmDate
							,[dblQty]						= InvTran.dblQty
							,[dblUOMQty]					= InvTran.dblUOMQty
							,[dblNewCost]					= ((InvTran.dblQty * InvTran.dblCost) + (-1 * @InvTranValue)) / InvTran.dblQty
							,[intCurrencyId]				= InvTran.intCurrencyId
							,[dblExchangeRate]				= InvTran.dblExchangeRate
							,[intTransactionId]				= @intTransactionId
							,[intTransactionDetailId]		= @intTransactionDetailId
							,[strTransactionId]				= @strTransactionId
							,[intTransactionTypeId]			= @LoopTransactionTypeId -- @intTransactionTypeId
							,[intLotId]						= InvTran.intLotId
							,[intSubLocationId]				= InvTran.intSubLocationId
							,[intStorageLocationId]			= InvTran.intStorageLocationId
							,[ysnIsStorage]					= NULL 
							,[strActualCostId]				= NULL 
							,[intSourceTransactionId]		= InvTran.intTransactionId
							,[intSourceTransactionDetailId]	= InvTran.intTransactionDetailId
							,[strSourceTransactionId]		= InvTran.strTransactionId						
					FROM	dbo.tblICInventoryTransaction InvTran
					WHERE	InvTran.strBatchId = @InvTranBatchId
							AND InvTran.intTransactionId = @InvTranIntTransactionId
							AND InvTran.strTransactionId = @InvTranStringTransactionId
							AND ISNULL(InvTran.ysnIsUnposted, 0) = 0
							AND ISNULL(InvTran.dblQty, 0) > 0 
							AND InvTran.intTransactionTypeId IN (
								@INV_TRANS_TYPE_Produce
								, @INV_TRANS_TYPE_Build_Assembly
								, @INV_TRANS_Inventory_Transfer
							)
				END 

				-- Compute the remaining Revalued Qty. 
				SET @StockQtyToRevalue = @StockQtyToRevalue - @StockQtyAvailableToRevalue

				-- Update the dblCostAdjustQty field in the Lot Out table. 
				UPDATE	LotOut
				SET		dblCostAdjustQty =	ISNULL(LotOut.dblCostAdjustQty, 0) + 
											CASE WHEN ISNULL(@StockQtyAvailableToRevalue, 0) > @StockQtyToRevalue THEN 
													@StockQtyToRevalue
												ELSE 
													ISNULL(@StockQtyAvailableToRevalue, 0)
											END 	
				FROM	dbo.tblICInventoryLotOut LotOut
				WHERE	intId = @LotOutId
			END 				

			-- Attempt to fetch the next row from cursor. 
			FETCH NEXT FROM loopLotOut INTO 
					@LotOutId
					,@LotOutInventoryLotId 
					,@LotOutInventoryTransactionId 
					,@LotOutRevalueLotId 
					,@LotOutQty
					,@LotCostAdjustQty
			; 
		END;
	END;

	CLOSE loopLotOut;
	DEALLOCATE loopLotOut;
	-----------------------------------------------------------------------------------------------------------------------------
	-- End loop for sold stocks
	-----------------------------------------------------------------------------------------------------------------------------
	

	-----------------------------------------------------------------------------------------------------------------------------
	-- 6. Update the average cost 
	-----------------------------------------------------------------------------------------------------------------------------
	BEGIN 
		EXEC dbo.uspICRecalcAveCostOnCostAdjustment
			@intItemId
			,@intItemLocationId
			,@StockQtyToRevalue
			,@CostBucketUOMQty
			,@dblNewCost
			,@CostBucketCost
		;
	END 

END
-----------------------------------------------------------------------------------------------------------------------------
-- End loop for the lot numbers. 
-----------------------------------------------------------------------------------------------------------------------------

-- Immediate exit
Post_Exit: 
