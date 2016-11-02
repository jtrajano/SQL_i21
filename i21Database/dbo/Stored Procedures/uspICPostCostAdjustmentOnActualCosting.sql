/*
	This is the stored procedure that handles the adjustment of the cost for an item on Actual Cost Costing. 
*/
CREATE PROCEDURE [uspICPostCostAdjustmentOnActualCosting]
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
	,@strActualCostId AS NVARCHAR(50) 
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

---- Create the temp table if it does not exists. 
--IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRevaluedInventoryTransaction')) 
--BEGIN 
--	CREATE TABLE #tmpRevaluedInventoryTransaction (
--		[intInventoryTransactionId] INT PRIMARY KEY CLUSTERED 
--	)
--END 

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

DECLARE @CostBucketId AS INT
		,@CostBucketCost AS NUMERIC(38,20)
		,@CostBucketStockInQty AS NUMERIC(38,20)
		,@CostBucketStockOutQty AS NUMERIC(38,20)
		,@CostBucketUOMQty AS NUMERIC(38,20)
		,@CostBucketIntTransactionId AS INT
		,@CostBucketStrTransactionId AS NVARCHAR(40)

		,@InventoryTransactionIdentityId AS INT
		,@OriginalCost AS NUMERIC(38,20)
		,@dblNewCalculatedCost AS NUMERIC(38,20)
		,@InventoryTransactionIdentityId_SoldOrUsed AS INT 
		,@ysnNoGLPosting_ForInvTransfer AS BIT = 0 

DECLARE @InvTranId AS INT
		,@InvTranQty AS NUMERIC(38,20)
		,@InvTranUOMQty AS NUMERIC(38,20)
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
		,@InvFobPointId AS TINYINT 

DECLARE	@OriginalTransactionValue AS NUMERIC(38,20)
		,@NewTransactionValue AS NUMERIC(38,20)
		,@CostAdjustmentValue AS NUMERIC(38,20)

DECLARE @LoopTransactionTypeId AS INT 
		,@CostAdjustmentTransactionType AS INT = @intTransactionTypeId		
		
DECLARE @dblRemainingQty AS NUMERIC(38,20)
		,@AdjustedQty AS NUMERIC(38,20) 
		,@AdjustableQty AS NUMERIC(38,20)
		,@dblNewCost AS NUMERIC(38,20)

		,@dblAdjustQty AS NUMERIC(38,20)
		,@intInventoryTrnasactionId_EscalateValue AS INT 
		,@intLotId AS INT 
		
-- Exit immediately if item is a lot type. 
IF dbo.fnGetItemLotType(@intItemId) <> 0 
BEGIN 
	GOTO Post_Exit;
END 

-- Get the number of cost buckets to process. 
DECLARE @CbWithOldCost AS INT = 0 
SELECT	@CbWithOldCost = COUNT(intInventoryActualCostId) 
FROM	tblICInventoryActualCost LEFT JOIN tblICItemUOM 
			ON tblICInventoryActualCost.intItemUOMId = tblICItemUOM.intItemUOMId
WHERE	tblICInventoryActualCost.intItemId = @intItemId
		AND tblICInventoryActualCost.intItemLocationId = @intItemLocationId
		AND tblICInventoryActualCost.intTransactionId = @intSourceTransactionId
		AND ISNULL(tblICInventoryActualCost.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
		AND tblICInventoryActualCost.strTransactionId = @strSourceTransactionId
		AND ISNULL(tblICInventoryActualCost.ysnIsUnposted, 0) = 0 
		AND tblICInventoryActualCost.strActualCostId = @strActualCostId

-- Convert the Remaining Qty to the UOM used in the cost bucket
BEGIN 

	SELECT	TOP 1 
			@dblRemainingQty = dbo.fnCalculateQtyBetweenUOM(@intItemUOMId, cb.intItemUOMId, @dblQty) 
	FROM	tblICInventoryActualCost cb 
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
			AND cb.strActualCostId = @strActualCostId
END 

-----------------------------------------------------------------------------------------------------------------------------
-- Start loop for the lot numbers. 
-----------------------------------------------------------------------------------------------------------------------------

SET @CostBucketId = NULL 

WHILE ISNULL(@CbWithOldCost, 0) > 0
BEGIN 	

	-----------------------------------------------------------------------------------------------------------------------------
	-- 1. Get the cost bucket and original cost. 
	-----------------------------------------------------------------------------------------------------------------------------
	BEGIN 
		SELECT	TOP 1
				@CostBucketId = intInventoryActualCostId
				,@CostBucketCost = dblCost			
				,@CostBucketStockInQty = dblStockIn
				,@CostBucketStockOutQty = dblStockOut
				,@CostBucketUOMQty = tblICItemUOM.dblUnitQty
				,@CostBucketIntTransactionId = intTransactionId
				,@CostBucketStrTransactionId = strTransactionId
				,@dblNewCost = dbo.fnCalculateCostBetweenUOM(@intCostUOMId, tblICInventoryActualCost.intItemUOMId, @dblVoucherCost)
		FROM	tblICInventoryActualCost LEFT JOIN tblICItemUOM 
					ON tblICInventoryActualCost.intItemUOMId = tblICItemUOM.intItemUOMId
		WHERE	tblICInventoryActualCost.intItemId = @intItemId
				AND tblICInventoryActualCost.intItemLocationId = @intItemLocationId
				AND tblICInventoryActualCost.intTransactionId = @intSourceTransactionId
				AND ISNULL(tblICInventoryActualCost.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
				AND tblICInventoryActualCost.strTransactionId = @strSourceTransactionId
				AND ISNULL(tblICInventoryActualCost.ysnIsUnposted, 0) = 0 
				--AND tblICInventoryActualCost.intInventoryActualCostId > ISNULL(@CostBucketId, 0) 
				AND tblICInventoryActualCost.strActualCostId = @strActualCostId
	END 

	-- Validate the cost bucket
	BEGIN 
		IF @CostBucketId IS NULL
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

	-- Reduce the counter. 
	SET @CbWithOldCost -= 1		

	-----------------------------------------------------------------------------------------------------------------------------
	-- 3. Compute the cost difference. 
	-- 4. Update the cost bucket with the new cost. 
	-- 5. Create the 'Inventory Transaction' as 'Cost Adjustment' type. 
	-----------------------------------------------------------------------------------------------------------------------------
	BEGIN 
		-- Get the original cost. 
		BEGIN 
			-- Get the original cost from the Lot cost adjustment log table. 
			SET @OriginalCost = NULL
			 
			SELECT	@OriginalCost = dblCost
			FROM	tblICInventoryActualCostAdjustmentLog
			WHERE	intInventoryActualCostId = @CostBucketId
					AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
					AND ysnIsUnposted = 0 
		
			-- If none found, the original cost is the cost bucket cost. 
			SET @OriginalCost = ISNULL(@OriginalCost, @CostBucketCost) 
		END 

		-- Compute the stock Qty available for cost adjustment. 
		IF @dblNewValue IS NULL 
		BEGIN 
			SET @AdjustedQty = NULL 

			SELECT	@AdjustedQty = SUM(dblQty) 
			FROM	tblICInventoryActualCostAdjustmentLog
			WHERE	intInventoryActualCostId = @CostBucketId
					AND intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
					AND ysnIsUnposted = 0 
					
			-- Determine the stock Qty it can process. 
			SET @AdjustableQty = @CostBucketStockInQty - ISNULL(@AdjustedQty, 0) 
			
			-- Initialize the Qty
			SET @dblAdjustQty = 
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

			-- Compute the new transaction value. 
			SELECT	@NewTransactionValue = dbo.fnMultiply(@dblAdjustQty, @dblNewCost) 

			-- Compute the original transaction value. 
			SELECT	@OriginalTransactionValue = dbo.fnMultiply(@dblAdjustQty, @OriginalCost) 

			-- Compute the new cost. 
			SELECT @dblNewCalculatedCost =	@CostBucketCost 
											+ dbo.fnDivide((@NewTransactionValue - @OriginalTransactionValue), @CostBucketStockInQty)	

			-- Compute value to adjust the item valuation. 
			SELECT @CostAdjustmentValue = dbo.fnMultiply(@dblAdjustQty, (@dblNewCost - @OriginalCost)) 

		END 

		ELSE IF @dblNewValue IS NOT NULL 
		BEGIN 
			SET @CostAdjustmentValue = @dblNewValue
			SET @dblAdjustQty = 0
			SET @dblNewCalculatedCost =  dbo.fnDivide(
					dbo.fnMultiply(
						@CostBucketStockInQty
						, @CostBucketCost
					) + @dblNewValue
					, @CostBucketStockInQty
				)
			SET @dblNewCost = @dblNewCalculatedCost
		END

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
			,@dblValue								= @CostAdjustmentValue
			,@dblSalesPrice							= 0
			,@intCurrencyId							= @intCurrencyId 
			,@dblExchangeRate						= @dblExchangeRate
			,@intTransactionId						= @intTransactionId
			,@intTransactionDetailId				= @intTransactionDetailId
			,@strTransactionId						= @strTransactionId
			,@strBatchId							= @strBatchId
			,@intTransactionTypeId					= @CostAdjustmentTransactionType 
			,@intLotId								= @intLotId 
			,@intRelatedInventoryTransactionId		= @intRelatedInventoryTransactionId 
			,@intRelatedTransactionId				= @CostBucketIntTransactionId 
			,@strRelatedTransactionId				= @CostBucketStrTransactionId
			,@strTransactionForm					= @strTransactionForm
			,@intEntityUserSecurityId				= @intEntityUserSecurityId
			,@intCostingMethod						= @ACTUALCOST
			,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
			,@intFobPointId							= @intFobPointId 
			,@intInTransitSourceLocationId			= @intInTransitSourceLocationId

		-- Check if gl entries are required for inventory transfer
		IF @CostAdjustmentTransactionType = @INV_TRANS_TYPE_Revalue_Transfer 
		BEGIN 
			SET @ysnNoGLPosting_ForInvTransfer = 1
			SELECT	TOP 1 
					@ysnNoGLPosting_ForInvTransfer = 0
			FROM	tblICInventoryTransaction t_lvl_0
					OUTER APPLY (
						SELECT	intCount = COUNT(1)  
						FROM	tblICInventoryTransaction t_lvl_1
						WHERE	t_lvl_1.strTransactionId = t_lvl_0.strTransactionId
								AND t_lvl_1.strBatchId = t_lvl_0.strBatchId
								AND t_lvl_1.ysnIsUnposted = 0 
								AND t_lvl_1.intInventoryTransactionId <> t_lvl_0.intInventoryTransactionId
								AND ISNULL(t_lvl_1.intItemLocationId, 0) <> ISNULL(t_lvl_0.intItemLocationId, 0)
					) non_matching_location
			WHERE	t_lvl_0.strTransactionId = @CostBucketStrTransactionId
					AND t_lvl_0.ysnIsUnposted = 0 
					AND ISNULL(non_matching_location.intCount, 0) > 0 

			UPDATE	tblICInventoryTransaction
			SET		ysnNoGLPosting = @ysnNoGLPosting_ForInvTransfer
			WHERE	intInventoryTransactionId = @InventoryTransactionIdentityId
		END 

		-- Log original cost to tblICInventoryActualCostAdjustmentLog
		IF NOT EXISTS (
				SELECT	TOP 1 1 
				FROM	tblICInventoryActualCostAdjustmentLog
				WHERE	intInventoryActualCostId = @CostBucketId
						AND intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
						AND ysnIsUnposted = 0 
		)
		BEGIN 
			INSERT INTO tblICInventoryActualCostAdjustmentLog (
					[intInventoryActualCostId]
					,[intInventoryTransactionId]
					,[intInventoryCostAdjustmentTypeId]
					,[dblQty]
					,[dblCost]
					,[dtmCreated]
					,[intCreatedUserId]		
			)
			SELECT	[intInventoryActualCostId]			= @CostBucketId
					,[intInventoryTransactionId]		= @InventoryTransactionIdentityId
					,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_Original_Cost
					,[dblQty]							= @CostBucketStockInQty
					,[dblCost]							= @CostBucketCost
					,[dtmCreated]						= GETDATE()
					,[intCreatedEntityUserId]			= @intEntityUserSecurityId
		END 

		-- Log a new cost. 
		BEGIN 
			INSERT INTO tblICInventoryActualCostAdjustmentLog (
					[intInventoryActualCostId]
					,[intInventoryTransactionId]
					,[intInventoryCostAdjustmentTypeId]
					,[dblQty]
					,[dblCost]
					,[dtmCreated]
					,[intCreatedUserId]		
			)
			SELECT	[intInventoryActualCostId]			= @CostBucketId
					,[intInventoryTransactionId]		= @InventoryTransactionIdentityId
					,[intInventoryCostAdjustmentTypeId]	= @COST_ADJ_TYPE_New_Cost
					,[dblQty]							= @dblAdjustQty
					,[dblCost]							= @dblNewCost
					,[dtmCreated]						= GETDATE()
					,[intCreatedEntityUserId]			= @intEntityUserSecurityId
		END 
			
		-- Calculate the new cost
		UPDATE	CostBucket
		SET		dblCost = @dblNewCalculatedCost
		FROM	tblICInventoryActualCost CostBucket
		WHERE	CostBucket.intInventoryActualCostId = @CostBucketId
				AND CostBucket.dblStockIn > 0 
				AND ISNULL(ysnIsUnposted, 0) = 0 
	END 

	-----------------------------------------------------------------------------------------------------------------------------
	-- Begin loop for sold or consumed stocks
	-----------------------------------------------------------------------------------------------------------------------------
	IF @dblNewCalculatedCost IS NOT NULL 
	BEGIN 
		-- Get the Lot Out records. 
		DECLARE @ActualCostOutId AS INT 
				,@ActualCostOutInventoryActualCostId AS INT 
				,@ActualCostOutInventoryTransactionId AS INT 
				,@ActualCostOutRevalueLotId AS INT 
				,@ActualCostOutQty AS NUMERIC(38,20)
				,@ActualCostAdjustQty AS NUMERIC(38,20)

				,@StockQtyAvailableToRevalue AS NUMERIC(38,20) = @dblAdjustQty
				,@StockQtyToRevalue AS NUMERIC(38,20) = @dblAdjustQty

				,@dblCostAdjId AS INT 

		-----------------------------------------------------------------------------------------------------------------------------
		-- Create the cursor
		-- Make sure the following options are used: 
		-- LOCAL >> It specifies that the scope of the cursor is local to the stored procedure where it was created. The cursor name is only valid within this scope. 
		-- FAST_FORWARD >> It specifies a FORWARD_ONLY, READ_ONLY cursor with performance optimizations enabled. 
		-----------------------------------------------------------------------------------------------------------------------------
		DECLARE loopActualCostOut CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT  ActualCostOut.intId
				,ActualCostOut.intInventoryActualCostId
				,ActualCostOut.intInventoryTransactionId
				,ActualCostOut.intRevalueActualCostId
				,ActualCostOut.dblQty
				,ActualCostOut.dblCostAdjustQty
		FROM	tblICInventoryActualCostOut ActualCostOut INNER JOIN tblICInventoryTransaction t 
					ON ActualCostOut.intInventoryTransactionId = t.intInventoryTransactionId
		WHERE	ActualCostOut.intInventoryActualCostId = @CostBucketId
				AND 1 = 
					CASE WHEN	@dblNewValue IS NULL 
								AND ISNULL(ActualCostOut.dblCostAdjustQty, 0) < ActualCostOut.dblQty -- If stocks can have a cost adjustment; [Cost Adj Qty] is less than [Lot Out Qty]
									THEN 1

						WHEN	@dblNewValue IS NOT NULL THEN 1
						ELSE	0
					END 
				AND ISNULL(t.ysnIsUnposted, 0) = 0

		OPEN loopActualCostOut;

		-- Initial fetch attempt
		FETCH NEXT FROM loopActualCostOut INTO 
				@ActualCostOutId
				,@ActualCostOutInventoryActualCostId 
				,@ActualCostOutInventoryTransactionId 
				,@ActualCostOutRevalueLotId 
				,@ActualCostOutQty 
				,@ActualCostAdjustQty
		;
		-----------------------------------------------------------------------------------------------------------------------------
		-- Start of the loop for sold/produced items. 
		-----------------------------------------------------------------------------------------------------------------------------
		WHILE	@@FETCH_STATUS = 0 
				AND 1 = CASE	WHEN @dblNewValue IS NULL AND @StockQtyToRevalue > 0 THEN 1 
								WHEN @dblNewValue IS NOT NULL THEN 1
								ELSE 0 
						END
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
					,@InvFobPointId					= NULL 

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
					,@InvFobPointId					= InvTran.intFobPointId
			FROM	tblICInventoryTransaction InvTran
			WHERE	InvTran.intInventoryTransactionId = @ActualCostOutInventoryTransactionId

			-- Calculate the available 'out' stocks that the system can revalue. 
			SELECT @StockQtyAvailableToRevalue = 
						CASE	WHEN @dblNewValue IS NULL THEN ISNULL(@ActualCostOutQty, 0) - ISNULL(@ActualCostAdjustQty, 0)
								ELSE ISNULL(@ActualCostOutQty, 0)
						END 
		
			-- If there are available out stocks, then revalue it.  
			IF	@InvTranId IS NOT NULL 
				AND 1 = CASE	WHEN @dblNewValue IS NULL AND @StockQtyAvailableToRevalue > 0 AND @StockQtyToRevalue > 0  THEN 1 
								WHEN @dblNewValue IS NOT NULL THEN 1
								ELSE 0 
						END
			BEGIN 
				-- Flag the escalated inventory transaction not to create the gl entries if it has a lot out. 
				UPDATE t
				SET		ysnNoGLPosting = 1
				FROM	tblICInventoryTransaction t
				WHERE	t.intInventoryTransactionId = @InventoryTransactionIdentityId
						AND t.intTransactionTypeId <> @INV_TRANS_TYPE_Cost_Adjustment
						AND ISNULL(t.ysnNoGLPosting, 0) = 0 

				-- Calculate the revalue amount for the lot-out qty. 
				SET @InvTranValue = NULL 
				SELECT	@InvTranValue =
							-
							(
								dbo.fnMultiply(@ActualCostOutQty, @dblNewCalculatedCost) -- New cost
								- dbo.fnMultiply(@ActualCostOutQty, @CostBucketCost) -- minus by the original cost. 
							)

				---------------------------------------------------------------------------
				-- 7. If stock was shipped or reduced from adj, then do the "Revalue Sold". 
				---------------------------------------------------------------------------
				IF	@InvTranTypeId NOT IN (
						@INV_TRANS_TYPE_Consume
						, @INV_TRANS_TYPE_Build_Assembly
						, @INV_TRANS_Inventory_Transfer
						, @INV_TRANS_TYPE_ADJ_Item_Change
						, @INV_TRANS_TYPE_ADJ_Split_Lot
						, @INV_TRANS_TYPE_ADJ_Lot_Merge
						, @INV_TRANS_TYPE_ADJ_Lot_Move
						, @INV_TRANS_TYPE_Inventory_Shipment
					)
					AND @InvTranValue <> 0 
				BEGIN 
					EXEC [uspICPostInventoryTransaction]
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
						,@intRelatedInventoryTransactionId		= @ActualCostOutInventoryTransactionId
						,@intRelatedTransactionId				= @InvTranIntTransactionId 
						,@strRelatedTransactionId				= @InvTranStringTransactionId 
						,@strTransactionForm					= @strTransactionForm
						,@intEntityUserSecurityId				= @intEntityUserSecurityId
						,@intCostingMethod						= @ACTUALCOST
						,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId_SoldOrUsed OUTPUT
						,@intFobPointId							= @intFobPointId 
						,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
				END 	

				---------------------------------------------------------------------------
				-- 8. If stock was consumed in a production, transfer, or lot adjustment
				---------------------------------------------------------------------------
				ELSE IF @InvTranTypeId IN (
							@INV_TRANS_TYPE_Consume
							, @INV_TRANS_TYPE_Build_Assembly
							, @INV_TRANS_Inventory_Transfer
							, @INV_TRANS_TYPE_ADJ_Item_Change
							, @INV_TRANS_TYPE_ADJ_Split_Lot
							, @INV_TRANS_TYPE_ADJ_Lot_Merge
							, @INV_TRANS_TYPE_ADJ_Lot_Move
							, @INV_TRANS_TYPE_Inventory_Shipment						
						)
						AND @InvTranValue <> 0 
				BEGIN 
					SELECT	@CostAdjustmentTransactionType 
								= CASE	WHEN @InvTranTypeId = @INV_TRANS_Inventory_Transfer		THEN @INV_TRANS_TYPE_Revalue_Transfer
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_Consume			THEN @INV_TRANS_TYPE_Revalue_WIP
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_Build_Assembly	THEN @INV_TRANS_TYPE_Revalue_Build_Assembly

										WHEN @InvTranTypeId = @INV_TRANS_TYPE_ADJ_Item_Change	THEN @INV_TRANS_TYPE_Revalue_Item_Change
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_ADJ_Lot_Merge		THEN @INV_TRANS_TYPE_Revalue_Lot_Merge
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_ADJ_Lot_Move		THEN @INV_TRANS_TYPE_Revalue_Lot_Move
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_ADJ_Split_Lot		THEN @INV_TRANS_TYPE_Revalue_Split_Lot
										
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_Inventory_Shipment THEN @INV_TRANS_TYPE_Revalue_Shipment

								END
							,@LoopTransactionTypeId
								= CASE	WHEN @InvTranTypeId = @INV_TRANS_Inventory_Transfer		THEN @INV_TRANS_TYPE_Revalue_Transfer
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_Consume			THEN @INV_TRANS_TYPE_Revalue_Produced
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_Build_Assembly	THEN @INV_TRANS_TYPE_Revalue_Build_Assembly

										WHEN @InvTranTypeId = @INV_TRANS_TYPE_ADJ_Item_Change	THEN @INV_TRANS_TYPE_Revalue_Item_Change
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_ADJ_Lot_Merge		THEN @INV_TRANS_TYPE_Revalue_Lot_Merge
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_ADJ_Lot_Move		THEN @INV_TRANS_TYPE_Revalue_Lot_Move
										WHEN @InvTranTypeId = @INV_TRANS_TYPE_ADJ_Split_Lot		THEN @INV_TRANS_TYPE_Revalue_Split_Lot
										--WHEN @InvTranTypeId = @INV_TRANS_TYPE_Inventory_Shipment THEN 

										WHEN @InvTranTypeId = @INV_TRANS_TYPE_Inventory_Shipment THEN @INV_TRANS_TYPE_Revalue_Shipment
								END

					EXEC [uspICPostInventoryTransaction]
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
						,@intRelatedInventoryTransactionId		= @ActualCostOutInventoryTransactionId
						,@intRelatedTransactionId				= @InvTranIntTransactionId 
						,@strRelatedTransactionId				= @InvTranStringTransactionId 
						,@strTransactionForm					= @strTransactionForm
						,@intEntityUserSecurityId				= @intEntityUserSecurityId
						,@intCostingMethod						= @ACTUALCOST
						,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId_SoldOrUsed OUTPUT
						,@intFobPointId							= @intFobPointId 
						,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
					
					-----------------------------------------------------------------------------------------------------------
					-- 9. Get the 'produced/transferred/in-transit item'. Insert it in a temporary table for later processing. 
					-----------------------------------------------------------------------------------------------------------
					IF @InvTranTypeId IN (
							@INV_TRANS_TYPE_Consume						
						)
					BEGIN 
						SELECT	TOP 1 
								@intInventoryTrnasactionId_EscalateValue = InvTran.intInventoryTransactionId							
						FROM	tblICInventoryTransaction InvTran
						WHERE	InvTran.strBatchId = @InvTranBatchId
								AND InvTran.intTransactionId = @InvTranIntTransactionId
								AND InvTran.strTransactionId = @InvTranStringTransactionId
								AND ISNULL(InvTran.ysnIsUnposted, 0) = 0
								AND ISNULL(InvTran.dblQty, 0) > 0 
								AND InvTran.intTransactionTypeId = @INV_TRANS_TYPE_Produce
					END 
					IF	@InvTranTypeId = @INV_TRANS_TYPE_Inventory_Shipment	
					BEGIN 
						SELECT	TOP 1 
								@intInventoryTrnasactionId_EscalateValue = InvTran.intInventoryTransactionId							
						FROM	tblICInventoryTransaction InvTran
						WHERE	InvTran.strBatchId = @InvTranBatchId
								AND InvTran.intTransactionId = @InvTranIntTransactionId
								AND InvTran.strTransactionId = @InvTranStringTransactionId
								AND ISNULL(InvTran.ysnIsUnposted, 0) = 0
								AND ISNULL(InvTran.dblQty, 0) > 0 
								AND InvTran.intTransactionTypeId = @INV_TRANS_TYPE_Inventory_Shipment
								AND InvTran.intFobPointId = @FOB_DESTINATION

						-- If @intInventoryTrnasactionId_EscalateValue is null, then the buck stops at the shipment.
						-- Change the type to Revalue Sold. 
						BEGIN 
							UPDATE	t
							SET		t.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Sold
							FROM	tblICInventoryTransaction t
							WHERE	t.intInventoryTransactionId = @InventoryTransactionIdentityId_SoldOrUsed
									AND @intInventoryTrnasactionId_EscalateValue IS NULL 
						END 
					END 
					ELSE 
					BEGIN 
						SELECT	TOP 1 
								@intInventoryTrnasactionId_EscalateValue = InvTran.intInventoryTransactionId							
						FROM	tblICInventoryTransaction InvTran
						WHERE	InvTran.strBatchId = @InvTranBatchId
								AND InvTran.intTransactionId = @InvTranIntTransactionId
								AND InvTran.strTransactionId = @InvTranStringTransactionId
								AND ISNULL(InvTran.ysnIsUnposted, 0) = 0
								AND ISNULL(InvTran.dblQty, 0) > 0 
								AND InvTran.intTransactionTypeId IN (
									@INV_TRANS_TYPE_Build_Assembly
									, @INV_TRANS_Inventory_Transfer
									, @INV_TRANS_TYPE_ADJ_Item_Change
									, @INV_TRANS_TYPE_ADJ_Split_Lot
									, @INV_TRANS_TYPE_ADJ_Lot_Merge
									, @INV_TRANS_TYPE_ADJ_Lot_Move
								)
					END
					
					IF @intInventoryTrnasactionId_EscalateValue IS NOT NULL 
					BEGIN 		
						-- Insert data into the #tmpRevalueProducedItems table. 
						INSERT INTO #tmpRevalueProducedItems (
								[intItemId] 
								,[intItemLocationId] 
								,[intItemUOMId] 
								,[dtmDate] 
								,[dblQty] 
								,[dblUOMQty] 
								,[dblNewValue]
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
								,[intRelatedInventoryTransactionId]
								,[intFobPointId]
								,[intInTransitSourceLocationId]
						)
						SELECT 
								[intItemId]						= InvTran.intItemId
								,[intItemLocationId]			= InvTran.intItemLocationId
								,[intItemUOMId]					= InvTran.intItemUOMId
								,[dtmDate]						= @dtmDate
								,[dblQty]						= InvTran.dblQty
								,[dblUOMQty]					= InvTran.dblUOMQty
								,[dblNewValue]					= -@InvTranValue
								,[intCurrencyId]				= InvTran.intCurrencyId
								,[dblExchangeRate]				= InvTran.dblExchangeRate
								,[intTransactionId]				= @intTransactionId
								,[intTransactionDetailId]		= @intTransactionDetailId
								,[strTransactionId]				= @strTransactionId
								,[intTransactionTypeId]			= @LoopTransactionTypeId 
								,[intLotId]						= InvTran.intLotId
								,[intSubLocationId]				= InvTran.intSubLocationId
								,[intStorageLocationId]			= InvTran.intStorageLocationId
								,[ysnIsStorage]					= NULL 
								,[strActualCostId]				= @strActualCostId 
								,[intSourceTransactionId]		= InvTran.intTransactionId
								,[intSourceTransactionDetailId]	= InvTran.intTransactionDetailId
								,[strSourceTransactionId]		= InvTran.strTransactionId
								,[intRelatedInventoryTransactionId] = InvTran.intInventoryTransactionId	
								,[intFobPointId]				= InvTran.intFobPointId
								,[intInTransitSourceLocationId]	= InvTran.intInTransitSourceLocationId
						FROM	tblICInventoryTransaction InvTran
						WHERE	intInventoryTransactionId = @intInventoryTrnasactionId_EscalateValue

						-- Flag the inventory transaction not to create the gl entries
						UPDATE t
						SET		ysnNoGLPosting = 1
						FROM	tblICInventoryTransaction t
						WHERE	t.intInventoryTransactionId = @InventoryTransactionIdentityId_SoldOrUsed
					END 
				END 

				-- Update the dblCostAdjustQty field in the Lot Out table. 
				UPDATE	ActualCostOut
				SET		dblCostAdjustQty =	ISNULL(ActualCostOut.dblCostAdjustQty, 0) + 
											CASE WHEN ISNULL(@StockQtyAvailableToRevalue, 0) > @StockQtyToRevalue THEN 
													@StockQtyToRevalue
												ELSE 
													ISNULL(@StockQtyAvailableToRevalue, 0)
											END 	
				FROM	tblICInventoryActualCostOut ActualCostOut
				WHERE	intId = @ActualCostOutId
						AND @dblNewValue IS NULL 

				-- Compute the remaining Revalued Qty. 
				SET @StockQtyToRevalue = @StockQtyToRevalue - @StockQtyAvailableToRevalue
			END 				

			-- Attempt to fetch the next row from cursor. 
			FETCH NEXT FROM loopActualCostOut INTO 
					@ActualCostOutId
					,@ActualCostOutInventoryActualCostId 
					,@ActualCostOutInventoryTransactionId 
					,@ActualCostOutRevalueLotId 
					,@ActualCostOutQty
					,@ActualCostAdjustQty
			; 
		END;
	END;

	CLOSE loopActualCostOut;
	DEALLOCATE loopActualCostOut;
	-----------------------------------------------------------------------------------------------------------------------------
	-- End loop for sold stocks
	-----------------------------------------------------------------------------------------------------------------------------
END
-----------------------------------------------------------------------------------------------------------------------------
-- End loop for the lot numbers. 
-----------------------------------------------------------------------------------------------------------------------------

-- Immediate exit
Post_Exit: 
