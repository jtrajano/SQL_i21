﻿/*
	This is the stored procedure that handles the adjustment of the cost for an item on Average Costing. 
*/
CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentOnAverageCosting]
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
	--,@dblExchangeRate AS NUMERIC(38,20)	
	,@intEntityUserSecurityId AS INT
	,@intRelatedInventoryTransactionId AS INT = NULL 
	,@strTransactionForm AS NVARCHAR(50) = 'Bill'
	,@intFobPointId AS TINYINT = NULL
	,@intInTransitSourceLocationId AS INT = NULL  
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT OFF
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
		--,[dblExchangeRate] DECIMAL (38, 20) DEFAULT 1 NOT NULL	-- The exchange rate used in the transaction. It is used to convert the cost or sales price (both in base currency) to the foreign currency value.
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
DECLARE @INV_TRANS_TYPE_Auto_Variance AS INT = 1
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
		,@RunningValue AS NUMERIC(38, 20)
		,@PreviousRunningQty AS NUMERIC(38, 20)

		,@t_intInventoryTransactionId AS INT 
		,@t_intItemId AS INT 
		,@t_intItemLocationId AS INT 
		,@t_intItemUOMId AS INT 
		,@t_dblQty AS NUMERIC(38, 20)
		,@t_dblStockOut AS NUMERIC(38, 20)
		,@t_dblCost AS NUMERIC(38, 20)
		,@t_strTransactionId AS NVARCHAR(50)
		,@t_intTransactionId AS INT 
		,@t_intTransactionDetailId AS INT  

		,@AdjustQty AS NUMERIC(38, 20)
		,@AdjustmentValue AS NUMERIC(38, 20) 
		,@AdjustOutValue AS NUMERIC(38, 20) 
		,@NewCost AS NUMERIC(38, 20)
		,@AdjustAverageCost AS NUMERIC(38, 20)
		,@CostAdjustmentTransactionType AS INT 
		,@InventoryTransactionIdentityId AS INT 
		,@StockItemUOMId AS INT 
		,@BreakOnNextLoop AS BIT = 0

		,@CBOut_Id AS INT 

DECLARE		
		@strDescription AS NVARCHAR(255)
		,@strCurrentValuation AS NVARCHAR(50) 
		,@strRunningQty AS NVARCHAR(50) 
		,@strNewCost AS NVARCHAR(50) 
		,@strNewValuation AS NVARCHAR(50) 
						
-- Exit immediately if item is a lot type. 
IF dbo.fnGetItemLotType(@intItemId) <> 0 
BEGIN 
	GOTO Post_Exit;
END 

-- Get the top cost bucket.
DECLARE @TransactionIdStartingPoint AS INT
		,@TopCostBucketId AS INT  

SELECT	TOP 1 
		@TransactionIdStartingPoint = t.intInventoryTransactionId 
FROM	tblICInventoryTransaction t
WHERE	t.intItemId = @intItemId
		AND t.intItemLocationId = @intItemLocationId
		AND t.intTransactionId = @intSourceTransactionId
		AND ISNULL(t.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
		AND t.strTransactionId = @strSourceTransactionId
		AND ISNULL(t.ysnIsUnposted, 0) = 0 

SELECT	TOP 1 
		@TopCostBucketId = cb.intInventoryFIFOId
FROM	tblICInventoryFIFO cb
WHERE	cb.intItemId = @intItemId
		AND cb.intItemLocationId = @intItemLocationId
		AND cb.intTransactionId = @intSourceTransactionId
		AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
		AND cb.strTransactionId = @strSourceTransactionId
		AND ISNULL(cb.ysnIsUnposted, 0) = 0 
		
-- Validate the cost bucket
BEGIN 
	IF @TransactionIdStartingPoint IS NULL
	BEGIN 
		DECLARE @strItemNo AS NVARCHAR(50)				

		SELECT	@strItemNo = CASE WHEN ISNULL(strItemNo, '') = '' THEN 'id: ' + CAST(@intItemId AS NVARCHAR(20)) ELSE strItemNo END 
		FROM	tblICItem 
		WHERE	intItemId = @intItemId

		-- 'Cost adjustment cannot continue. Unable to find the cost bucket for %s that was posted in %s.
		EXEC uspICRaiseError 80062, @strItemNo, @strSourceTransactionId;  
		RETURN -80062;
	END
END 

-- Initialize the Running Qty (converted to stock UOM) 
BEGIN 
	SELECT	@StockItemUOMId = dbo.fnGetItemStockUOM(@intItemId) 			

	SELECT	TOP 1 
			@RunningQty = SUM (
				dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, @StockItemUOMId, t.dblQty)
			) 
	FROM	tblICInventoryTransaction t INNER JOIN tblICItemUOM iUOM
				ON t.intItemUOMId = iUOM.intItemUOMId
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.intInventoryTransactionId < @TransactionIdStartingPoint

	SET @RunningQty = ISNULL(@RunningQty, 0) 
	SET @PreviousRunningQty = ISNULL(@RunningQty, 0) 
END 

-- BEGIN: Loop thru the inventory transactions
BEGIN 
	-----------------------------------------------------------------------------------------------------------------------------
	-- Create the cursor
	-- Make sure the following options are used: 
	-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
	-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
	-----------------------------------------------------------------------------------------------------------------------------
	DECLARE loopInvTransactions CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  t.intInventoryTransactionId
			,t.intItemId
			,t.intItemLocationId
			,t.intItemUOMId
			,t.dblQty
			,t.dblCost
			,t.strTransactionId
			,t.intTransactionId
			,t.intTransactionDetailId
	FROM	tblICInventoryTransaction t 
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId			
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.intInventoryTransactionId >= @TransactionIdStartingPoint
			AND t.dblQty <> 0 

	OPEN loopInvTransactions;

	-- Initial fetch attempt
	FETCH NEXT FROM loopInvTransactions INTO 
		@t_intInventoryTransactionId 
		,@t_intItemId 
		,@t_intItemLocationId 
		,@t_intItemUOMId 
		,@t_dblQty 
		,@t_dblCost 
		,@t_strTransactionId
		,@t_intTransactionId
		,@t_intTransactionDetailId
	;
	-----------------------------------------------------------------------------------------------------------------------------
	-- Start of the loop for sold/produced items. 
	-----------------------------------------------------------------------------------------------------------------------------
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		-- Calculate the running qty. 
		SET @RunningQty += dbo.fnCalculateQtyBetweenUOM(@t_intItemUOMId, @StockItemUOMId, @t_dblQty)

		-- 1. Process the source transaction. 
		IF	@t_strTransactionId = @strSourceTransactionId 
			AND @t_dblQty > 0 
		BEGIN 
			SET @AdjustQty = CASE WHEN @dblNewValue IS NULL THEN dbo.fnCalculateQtyBetweenUOM(@intItemUOMId, @t_intItemUOMId, @dblQty) ELSE 0 END 

			-- Calculate the new cost for the source transaction. 
			SET @AdjustmentValue = 
				CASE	WHEN @dblNewValue IS NULL THEN 
							dbo.fnMultiply(
								@AdjustQty
								,dbo.fnCalculateCostBetweenUOM(@intCostUOMId, @t_intItemUOMId, @dblVoucherCost)
							) 
							- dbo.fnMultiply(@t_dblCost, @t_dblQty)
						ELSE 
							@dblNewValue
				END 				

			-- Calculate the average cost adjustment 
			SET @AdjustAverageCost = 						
				dbo.fnDivide(
					@AdjustmentValue
					,CASE WHEN @RunningQty > 0 THEN @RunningQty ELSE @t_dblQty END 
				) 

			SET @NewCost = 
				dbo.fnDivide(
					dbo.fnMultiply(@t_dblCost, @t_dblQty) + @AdjustmentValue
					,@t_dblQty
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

			SET @strNewCost = CONVERT(NVARCHAR, CAST(@AdjustmentValue AS MONEY), 1)
			SELECT	@strDescription = 'A value of ' + @strNewCost + ' is adjusted for ' + i.strItemNo + '. It is posted in ' + @t_strTransactionId + '.'
			FROM	tblICItem i 
			WHERE	i.intItemId = @intItemId

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
				,@intRelatedTransactionId				= @t_intTransactionId 
				,@strRelatedTransactionId				= @t_strTransactionId
				,@strTransactionForm					= @strTransactionForm
				,@intEntityUserSecurityId				= @intEntityUserSecurityId
				,@intCostingMethod						= @AVERAGECOST
				,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
				,@intFobPointId							= @intFobPointId 
				,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
				,@intForexRateTypeId					= NULL
				,@dblForexRate							= 1
				,@strDescription						= @strDescription

			-- Log original cost to tblICInventoryFIFOCostAdjustmentLog
			IF NOT EXISTS (
					SELECT	TOP 1 1 
					FROM	tblICInventoryFIFOCostAdjustmentLog
					WHERE	intInventoryFIFOId = @t_intInventoryTransactionId
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
				SELECT	[intInventoryFIFOId]				= @TopCostBucketId
						,[intInventoryTransactionId]		= @InventoryTransactionIdentityId
						,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_Original_Cost
						,[dblQty]							= @t_dblQty
						,[dblCost]							= @t_dblCost
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
				SELECT	[intInventoryFIFOId]				= @TopCostBucketId
						,[intInventoryTransactionId]		= @InventoryTransactionIdentityId
						,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_New_Cost
						,[dblQty]							= @AdjustQty
						,[dblCost]							= @NewCost
						,[dtmCreated]						= GETDATE()
						,[intCreatedEntityUserId]			= @intEntityUserSecurityId
			END 

			-- Update cb with the new cost. 
			UPDATE	cb
			SET		cb.dblCost = @NewCost
			FROM	tblICInventoryFIFO cb
			WHERE	cb.intInventoryFIFOId = @TopCostBucketId
		END 

		-- Process the next cost bucket. 
		ELSE IF @t_dblQty > 0  
		BEGIN 		
			-- Calculate a new average cost adjustment 
			SET @AdjustAverageCost = 						
					CASE	WHEN @PreviousRunningQty < 0  THEN 
								0
							ELSE 
								dbo.fnDivide(
									dbo.fnMultiply(@PreviousRunningQty, @AdjustAverageCost) 
									,CASE WHEN @RunningQty > 0 THEN @RunningQty ELSE @t_dblQty END 
								) 
					END								
			
			-- Otherwise, add an adjustment to re-align the average cost. 
			IF @RunningQty <= 0 
			BEGIN 
				-- Get the running value 
				SELECT	@RunningValue = SUM(ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2))
				FROM	tblICInventoryTransaction t
						OUTER APPLY (
							SELECT	TOP 1 
									t2.intInventoryTransactionId
							FROM	tblICInventoryTransaction t2
							WHERE	t2.intItemId = @t_intItemId
									AND t2.intItemLocationId = @t_intItemLocationId
									AND t2.strTransactionId = @t_strTransactionId
									AND t2.intTransactionId = @t_intTransactionId
									AND t2.intTransactionDetailId = @t_intTransactionDetailId
						) t2
				WHERE	t.intItemId = @intItemId
						AND t.intItemLocationId = @intItemLocationId 
						AND t.intInventoryTransactionId <= t2.intInventoryTransactionId

				SET @AdjustmentValue = 
					@t_dblCost 
					* (
						@t_dblQty 
						- dbo.fnCalculateQtyBetweenUOM(@StockItemUOMId, @t_intItemUOMId, @RunningQty)
					)
					- @RunningValue

				-- 'Inventory variance is created. The current item valuation is %s. The new valuation is (Qty x New Average Cost) %s x %s = %s.'
				SET @strCurrentValuation = CONVERT(NVARCHAR, CAST(@RunningValue AS MONEY), 1)
				SET @strRunningQty = CONVERT(NVARCHAR, CAST(dbo.fnCalculateQtyBetweenUOM(@StockItemUOMId, @t_intItemUOMId, @RunningQty) AS MONEY), 1)
				SET @strNewCost = CONVERT(NVARCHAR, CAST(@t_dblCost AS MONEY), 1)
				SET @strNewValuation = CONVERT(NVARCHAR, CAST(@AdjustmentValue AS MONEY), 1)
	
				SELECT	@strDescription = dbo.fnFormatMessage(
							dbo.fnICGetErrorMessage(80078)
							, @strCurrentValuation
							, @strRunningQty
							, @strNewCost
							, @strNewValuation
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
							, DEFAULT
						)

				-- Create the 'Auto Variance'
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
					,@intTransactionTypeId					= @INV_TRANS_TYPE_Auto_Variance 
					,@intLotId								= NULL  
					,@intRelatedInventoryTransactionId		= @intRelatedInventoryTransactionId 
					,@intRelatedTransactionId				= @t_intTransactionId 
					,@strRelatedTransactionId				= @t_strTransactionId
					,@strTransactionForm					= @strTransactionForm
					,@intEntityUserSecurityId				= @intEntityUserSecurityId
					,@intCostingMethod						= @AVERAGECOST
					,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
					,@intFobPointId							= @intFobPointId 
					,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
					,@intForexRateTypeId					= NULL
					,@dblForexRate							= 1
					,@strDescription						= @strDescription

			END 
		END 

		-- Process reduce stocks 
		ELSE IF @t_dblQty < 0 AND @AdjustAverageCost <> 0 
		BEGIN 	
			EXEC uspICPostCostAdjustmentOnAverageCostingStockOut
				@intInventoryTransactionId  = @t_intInventoryTransactionId
				,@AdjustCost = @AdjustAverageCost
				,@AdjustDate  = @dtmDate
				,@strVoucherId = @strTransactionId
				,@intVoucherId = @intTransactionId
				,@intVoucherDetailId = @intTransactionDetailId
				,@strBatchId = @strBatchId
				,@intEntityUserSecurityId = @intEntityUserSecurityId
		END 

		-- If stocks was recovering from negative stock. 
		IF @t_dblQty > 0 AND @PreviousRunningQty < 0 AND @AdjustAverageCost <> 0 
		BEGIN 
			SELECT	TOP 1 
					@TopCostBucketId = cb.intInventoryFIFOId
			FROM	tblICInventoryFIFO cb
			WHERE	cb.intItemId = @intItemId
					AND cb.intItemLocationId = @intItemLocationId
					AND cb.intTransactionId = @t_intTransactionId
					AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@t_intTransactionDetailId, 0)
					AND cb.strTransactionId = @t_strTransactionId
					AND ISNULL(cb.ysnIsUnposted, 0) = 0 

			EXEC uspICPostCostAdjustmentOnAverageCostingCBOut
				@CostBucketId  = @TopCostBucketId
				,@AdjustCost = @AdjustAverageCost
				,@AdjustDate  = @dtmDate
				,@strVoucherId = @strTransactionId
				,@intVoucherId = @intTransactionId
				,@intVoucherDetailId = @intTransactionDetailId
				,@strBatchId = @strBatchId
				,@intEntityUserSecurityId = @intEntityUserSecurityId
		END 

		-- Execute the stopper (if true). 
		IF @BreakOnNextLoop = 1 
		BEGIN 
			BREAK; 
		END 

		-- Get the next cb record. 
		FETCH NEXT FROM loopInvTransactions INTO 
			@t_intInventoryTransactionId 
			,@t_intItemId 
			,@t_intItemLocationId 
			,@t_intItemUOMId 
			,@t_dblQty 
			,@t_dblCost 
			,@t_strTransactionId
			,@t_intTransactionId
			,@t_intTransactionDetailId
		;
	
		-- Add a stopper if Running Qty is Less-Than zero and next cost bucket is Greater-Than zero. 
		IF @RunningQty <= 0 AND @t_dblQty > 0 
		BEGIN 
			SET @BreakOnNextLoop = 1 
		END 

		SET @PreviousRunningQty = @RunningQty
	END 

	CLOSE loopInvTransactions;
	DEALLOCATE loopInvTransactions;
END 
-- END: Loop thru the inventory transactions

-- Create an auto-variance if the adjusted stock is the last in the loop. 
IF @t_strTransactionId = @strSourceTransactionId AND @t_dblQty > 0 AND @NewCost <> 0 
BEGIN 
	-- Get the running value 
	SELECT	@RunningValue =  SUM (
				dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) 
				+ ISNULL(t.dblValue, 0)
			)
	FROM	tblICInventoryTransaction t
			OUTER APPLY (
				SELECT	TOP 1 
						t2.intInventoryTransactionId
				FROM	tblICInventoryTransaction t2
				WHERE	t2.intItemId = @intItemId
						AND t2.intItemLocationId = @intItemLocationId
						AND t2.strTransactionId = @strTransactionId
						AND t2.intTransactionId = @intTransactionId
						AND t2.intTransactionDetailId = @intTransactionDetailId
				ORDER BY t2.intInventoryTransactionId DESC 
			) t2
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId 
			AND t.intInventoryTransactionId <= t2.intInventoryTransactionId

	SET @AdjustmentValue = dbo.fnMultiply(@NewCost, @RunningQty) - @RunningValue

	-- 'Inventory variance is created. The current item valuation is %s. The new valuation is (Qty x New Average Cost) %s x %s = %s.'
	SET @strCurrentValuation = CONVERT(NVARCHAR, CAST(@RunningValue AS MONEY), 1)
	SET @strRunningQty = CONVERT(NVARCHAR, CAST(@RunningQty AS MONEY), 1)
	SET @strNewCost = CONVERT(NVARCHAR, CAST(@NewCost AS MONEY), 1)
	SET @strNewValuation = CONVERT(NVARCHAR, CAST(@AdjustmentValue AS MONEY), 1)
	
	SELECT	@strDescription = dbo.fnFormatMessage(
				dbo.fnICGetErrorMessage(80078)
				, @strCurrentValuation
				, @strRunningQty
				, @strNewCost
				, @strNewValuation
				, DEFAULT
				, DEFAULT
				, DEFAULT
				, DEFAULT
				, DEFAULT
				, DEFAULT
			)

	-- Create the 'Auto Variance'
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
		,@intTransactionTypeId					= @INV_TRANS_TYPE_Auto_Variance 
		,@intLotId								= NULL  
		,@intRelatedInventoryTransactionId		= @intRelatedInventoryTransactionId 
		,@intRelatedTransactionId				= @t_intTransactionId 
		,@strRelatedTransactionId				= @t_strTransactionId
		,@strTransactionForm					= @strTransactionForm
		,@intEntityUserSecurityId				= @intEntityUserSecurityId
		,@intCostingMethod						= @AVERAGECOST
		,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
		,@intFobPointId							= @intFobPointId 
		,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
		,@intForexRateTypeId					= NULL
		,@dblForexRate							= 1
		,@strDescription						= @strDescription

END 

-- Recalculate the average cost. 
BEGIN 
	EXEC dbo.uspICRecalcAveCostOnCostAdjustment
		@intItemId
		,@intItemLocationId	
		,@strTransactionId
		,@strBatchId
	;
END 


-- Immediate exit
Post_Exit: 
