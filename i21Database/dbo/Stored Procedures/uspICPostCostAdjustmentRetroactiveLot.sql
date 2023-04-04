﻿/*

*/
CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentRetroactiveLot]
	@dtmDate AS DATETIME
	,@intItemId AS INT
	,@intItemLocationId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT 
	,@intItemUOMId AS INT	
	,@dblQty AS NUMERIC(38,20)
	,@intCostUOMId AS INT 
	,@dblNewCost AS NUMERIC(38,20)
	,@dblNewValue AS NUMERIC(38,20)
	,@dblNewForexValue AS NUMERIC(38,20)
	,@intTransactionId AS INT
	,@intTransactionDetailId AS INT
	,@strTransactionId AS NVARCHAR(20)
	,@intSourceTransactionId AS INT
	,@intSourceTransactionDetailId AS INT 
	,@strSourceTransactionId AS NVARCHAR(20)
	,@strBatchId AS NVARCHAR(40)
	,@intTransactionTypeId AS INT
	,@intEntityUserSecurityId AS INT
	,@intRelatedInventoryTransactionId AS INT = NULL 
	,@strTransactionForm AS NVARCHAR(50) = 'Bill'
	,@intFobPointId AS TINYINT = NULL
	,@intInTransitSourceLocationId AS INT = NULL  
	,@ysnPost AS BIT = 1
	,@intOtherChargeItemId AS INT = NULL
	,@ysnUpdateItemCostAndPrice AS BIT = 0 
	,@intLotId AS INT = NULL 
	,@IsEscalate AS BIT = 0 
	,@intSourceEntityId AS INT = NULL
	,@intCurrencyId AS INT = NULL 
	,@intForexRateTypeId AS INT = NULL
	,@dblForexRate AS NUMERIC(38, 20)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Create the CONSTANT variables for the costing methods
BEGIN 
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
			,@COST_ADJ_TYPE_Adjust_Value AS INT = 3
			,@COST_ADJ_TYPE_Adjust_Sold AS INT = 4
			,@COST_ADJ_TYPE_Adjust_WIP AS INT = 5
			,@COST_ADJ_TYPE_Adjust_InTransit AS INT = 6
			,@COST_ADJ_TYPE_Adjust_InTransit_Inventory AS INT = 7
			,@COST_ADJ_TYPE_Adjust_InTransit_Sold AS INT = 8
			,@COST_ADJ_TYPE_Adjust_InventoryAdjustment AS INT = 9
            ,@COST_ADJ_TYPE_Adjust_InTransit_Transfer_Order_Add AS INT = 11
            ,@COST_ADJ_TYPE_Adjust_InTransit_Transfer_Order_Reduce AS INT = 12

	-- Create the variables for the internal transaction types used by costing. 
	DECLARE
			@INV_TRANS_TYPE_Inventory_Receipt AS INT = 4
			,@INV_TRANS_TYPE_Inventory_Shipment AS INT = 5

			,@INV_TRANS_TYPE_Consume AS INT = 8
			,@INV_TRANS_TYPE_Produce AS INT = 9
			,@INV_TRANS_Inventory_Transfer AS INT = 12
            ,@INV_TRANS_Inventory_Transfer_With_Shipment AS INT = 13
			,@INV_TRANS_TYPE_ADJ_Item_Change AS INT = 15
			,@INV_TRANS_TYPE_ADJ_Split_Lot AS INT = 17
			,@INV_TRANS_TYPE_ADJ_Lot_Merge AS INT = 19
			,@INV_TRANS_TYPE_ADJ_Lot_Move AS INT = 20
			,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
			,@INV_TRANS_TYPE_Invoice AS INT = 33
			,@INV_TRANS_TYPE_NegativeStock AS INT = 35

	DECLARE	
			@CostAdjustment AS NUMERIC(38, 20)
			,@ForexCostAdjustment AS NUMERIC(38, 20)
			,@CostAdjustmentPerCb AS NUMERIC(38, 20) 
			,@ForexCostAdjustmentPerCb AS NUMERIC(38, 20) 
			,@CurrentCostAdjustment AS NUMERIC(38, 20)
			,@ForexCurrentCostAdjustment AS NUMERIC(38, 20)
			,@CostBucketNewCost AS NUMERIC(38, 20)			
			,@CostBucketNewForexCost AS NUMERIC(38, 20)			
			,@TotalCostAdjustment AS NUMERIC(38, 20)

			,@t_intInventoryTransactionId AS INT 
			,@t_intItemId AS INT 
			,@t_intItemLocationId AS INT 
			,@t_intItemUOMId AS INT 
			,@t_dblQty AS NUMERIC(38, 20)
			,@t_dblStockOut AS NUMERIC(38, 20)
			,@t_dblCost AS NUMERIC(38, 20)
			,@t_dblValue AS NUMERIC(38, 20)
			,@t_strTransactionId AS NVARCHAR(50)
			,@t_intTransactionId AS INT 
			,@t_intTransactionDetailId AS INT  
			,@t_intTransactionTypeId AS INT 
			,@t_strBatchId AS NVARCHAR(50) 
			,@t_intLocationId AS INT 
			,@t_intLotId AS INT 
			,@t_NegativeStockCost AS NUMERIC(38, 20) 

			,@EscalateInventoryTransactionId AS INT 
			,@EscalateInventoryTransactionTypeId AS INT 
			,@EscalateCostAdjustment AS NUMERIC(38, 20)

			,@InventoryTransactionIdentityId AS INT 

	DECLARE	@StockItemUOMId AS INT
			,@strDescription AS NVARCHAR(255)
			,@strNewCost AS NVARCHAR(50) 
			,@IsSourceTransaction AS BIT 
			,@strItemNo AS NVARCHAR(50) 
			,@dblNewCbCost AS NUMERIC(38, 20)
			,@intInventoryLotId AS INT

    DECLARE @strReceiptType AS NVARCHAR(50)
			,@self AS INT 
			,@costAdjustmentType_DETAILED AS TINYINT = 1
			,@costAdjustmentType_SUMMARIZED AS TINYINT = 2

	DECLARE @costAdjustmentType AS TINYINT 
	SET @costAdjustmentType = dbo.fnICGetCostAdjustmentSetup(@intItemId, @intItemLocationId) 
END 

-- Compute the cost adjustment
BEGIN 
	SET @ForexCostAdjustment = 
		CASE	WHEN @dblNewForexValue IS NOT NULL THEN @dblNewForexValue
				WHEN @dblQty IS NOT NULL THEN @dblQty * ISNULL(@dblNewCost, 0) 
				ELSE NULL 
		END 	

	SET @CostAdjustment = 
		CASE	WHEN @dblNewValue IS NOT NULL THEN @dblNewValue
				WHEN @dblQty IS NOT NULL AND NULLIF(@dblForexRate, 0) <> 1 THEN @dblQty * ISNULL(@dblNewCost, 0) * @dblForexRate
				WHEN @dblQty IS NOT NULL THEN @dblQty * ISNULL(@dblNewCost, 0) 
				ELSE NULL 
		END 	

	-- If there is no cost adjustment, exit immediately. 
	IF @CostAdjustment IS NULL 
		RETURN; 
END

-- Create the temp table if it does not exists. 
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRevalueProducedItems')) 
	BEGIN 
		CREATE TABLE #tmpRevalueProducedItems (
			[intId] INT IDENTITY PRIMARY KEY CLUSTERED	
			,[intItemId] INT NOT NULL								-- The item. 
			,[intItemLocationId] INT NULL							-- The location where the item is stored.
			,[intItemUOMId] INT NULL								-- The UOM used for the item.
			,[dtmDate] DATETIME NOT NULL							-- The date of the transaction
			,[dblQty] NUMERIC(38,20) NULL DEFAULT 0					-- The quantity of an item in relation to its UOM. For example a box can have 12 pieces of an item. If you have 10 boxes, this parameter must be 10 and not 120 (10 boxes x 12 pieces per box). Positive unit qty means additional stock. Negative unit qty means reduction (selling) of the stock. 
			,[dblUOMQty] NUMERIC(38,20) NULL DEFAULT 1				-- The quantity of an item per UOM. For example, a box can contain 12 individual pieces of an item. 
			,[dblNewCost] NUMERIC(38,20) NULL DEFAULT 0				-- The cost of purchasing a item per UOM. For example, $12 is the cost for a 12-piece box. This parameter should hold a $12 value and not $1 per pieces found in a 12-piece box. The cost is stored in base currency. 
			,[dblNewValue] NUMERIC(38,20) NULL 						-- 
			,[intCurrencyId] INT NULL								-- The currency id used in a transaction. 
			,[intTransactionId] INT NOT NULL						-- The integer id of the source transaction (e.g. Sales Invoice, Inventory Adjustment id, etc. ). 
			,[intTransactionDetailId] INT NULL						-- Link id to the transaction detail. 
			,[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL -- The string id of the source transaction. 
			,[intTransactionTypeId] INT NOT NULL					-- The transaction type. Source table for the types are found in tblICInventoryTransactionType
			,[intLotId] INT NULL									
			,[intSubLocationId] INT NULL							
			,[intStorageLocationId] INT NULL						
			,[ysnIsStorage] BIT NULL								-- If Yes (value is 1), then the item is not owned by the company. The company is only the custodian of the item (like a consignor). Add or remove stock from Inventory-Lot-In-Storage table. 
			,[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- If there is a value, this means the item is used in Actual Costing. 
			,[intSourceTransactionId] INT NULL						-- The integer id for the cost bucket (Ex. The integer id of INVRCT-10001 is 1934). 
			,[intSourceTransactionDetailId] INT NULL				-- The integer id for the cost bucket in terms of tblICInventoryReceiptItem.intInventoryReceiptItemId (Ex. The value of tblICInventoryReceiptItem.intInventoryReceiptItemId is 1230). 
			,[strSourceTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL -- The string id for the cost bucket (Ex. "INVRCT-10001"). 
			,[intRelatedInventoryTransactionId] INT NULL 
			,[intFobPointId] TINYINT NULL 
			,[intInTransitSourceLocationId] INT NULL 
			,[dblNewAverageCost] NUMERIC(38,20) NULL
			,[intSourceEntityId] INT NULL
		)
	END 
END 

-- Get the top cost bucket.
BEGIN 
	DECLARE @InventoryTransactionStartId AS INT
			,@CostBucketId AS INT  
			,@CostBucketOriginalStockIn AS NUMERIC(38, 20)
			,@CostBucketOriginalCost AS NUMERIC(38, 20)
			,@CostBucketOriginalValue AS NUMERIC(38, 20) 
			,@CostBucketDate AS DATETIME 
			,@CostBucketOriginalForexCost AS NUMERIC(38, 20)
			,@CostBucketOriginalForexValue AS NUMERIC(38, 20) 

	--SELECT	TOP 1 
	--		@InventoryTransactionStartId = t.intInventoryTransactionId 
	--FROM	tblICInventoryTransaction t
	--WHERE	t.intItemId = @intItemId
	--		AND t.intItemLocationId = @intItemLocationId
	--		AND t.intTransactionId = @intSourceTransactionId
	--		AND ISNULL(t.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
	--		AND t.strTransactionId = @strSourceTransactionId
	--		AND ISNULL(t.ysnIsUnposted, 0) = 0 

	SELECT	TOP 1 
			@CostBucketId = cb.intInventoryLotId
			,@CostBucketOriginalStockIn = cb.dblStockIn
			,@CostBucketOriginalCost = cb.dblCost
			,@CostBucketOriginalValue = ROUND(dbo.fnMultiply(cb.dblStockIn, cb.dblCost), 2) 
			,@CostBucketDate = cb.dtmDate
	FROM	tblICInventoryLot cb
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
			AND cb.intLotId = ISNULL(@intLotId, cb.intLotId) 
		
	-- Validate the cost bucket
	BEGIN 
		SELECT	@strItemNo = CASE WHEN ISNULL(strItemNo, '') = '' THEN 'id: ' + CAST(@intItemId AS NVARCHAR(20)) ELSE strItemNo END 
		FROM	tblICItem 
		WHERE	intItemId = @intItemId

		IF @CostBucketId IS NULL
		BEGIN 
			-- 'Cost adjustment cannot continue. Unable to find the cost bucket for %s that was posted in %s.
			EXEC uspICRaiseError 80062, @strItemNo, @strSourceTransactionId;  
			RETURN -80062;
		END

		-- Check if cost adjustment date is earlier than the cost bucket date. 
		IF dbo.fnDateLessThan(@dtmDate, @CostBucketDate) = 1 AND ISNULL(@IsEscalate,0) = 0 
		BEGIN 
			-- 'Cost adjustment cannot continue. Cost adjustment for {Item} cannot be earlier than {Cost Bucket Date}.'
			EXEC uspICRaiseError 80219, @strItemNo, @CostBucketDate;  
			RETURN -80219;
		END
	END 

	SET @CostBucketOriginalValue = ISNULL(@CostBucketOriginalValue, 0) 
END 

-- Create the list of Inventory Transaction related to the cost bucket.
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRetroactiveTransactions')) 
	BEGIN 
		CREATE TABLE #tmpRetroactiveTransactions (
			[intInventoryTransactionId] INT PRIMARY KEY CLUSTERED	
			,[intSort] INT 
		)
	END 

	DELETE FROM #tmpRetroactiveTransactions
	INSERT INTO #tmpRetroactiveTransactions (
		intInventoryTransactionId
		,intSort
	)
	-- Self: 
	SELECT	t.intInventoryTransactionId 
			,1 
	FROM	tblICInventoryTransaction t
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND t.intTransactionId = @intSourceTransactionId
			AND ISNULL(t.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND t.strTransactionId = @strSourceTransactionId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.dblQty > 0 
			AND t.intLotId = ISNULL(@intLotId, t.intLotId) 
	-- Cost Bucket Out: 
	UNION ALL 
	SELECT	cbOut.intInventoryTransactionId
			,2 
	FROM	tblICInventoryLotOut cbOut INNER JOIN tblICInventoryLot cb 
				ON cbOut.intInventoryLotId = cb.intInventoryLotId
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
			AND cb.intLotId = ISNULL(@intLotId, cb.intLotId) 
			AND cbOut.intRevalueLotId IS NULL 	
	-- Negative stocks 
	 UNION ALL 
	SELECT	t.intInventoryTransactionId 
			,2	
	FROM	tblICInventoryLot cb INNER JOIN (
				tblICInventoryLotOut cbOut INNER JOIN tblICInventoryTransaction t 
					ON cbOut.intInventoryTransactionId = t.intInventoryTransactionId
					AND cbOut.intRevalueLotId IS NOT NULL 					
			)
				ON cb.intInventoryLotId = cbOut.intRevalueLotId		
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
			AND cb.intLotId = ISNULL(@intLotId, cb.intLotId) 
END 

-- Remember the original cost from the cost bucket
BEGIN 
	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpCostBucketOriginal')) 
	BEGIN 
		CREATE TABLE #tmpCostBucketOriginal (
			[intInventoryLotId] INT PRIMARY KEY CLUSTERED	
			,[intLotId] INT 
			,[dblCost] NUMERIC(38, 20)
			,[dblValue] NUMERIC(38, 20)
			,[dblForexCost] NUMERIC(38, 20)
			,[dblForexValue] NUMERIC(38, 20)

		)

		CREATE NONCLUSTERED INDEX [IX_tmpCostBucketOriginal] ON dbo.#tmpCostBucketOriginal(intLotId ASC);
	END 

	DELETE FROM #tmpCostBucketOriginal
	INSERT INTO #tmpCostBucketOriginal (
			[intInventoryLotId]
			,[intLotId] 
			,[dblCost] 
			,[dblValue] 
			,[dblForexCost] 
			,[dblForexValue]
	)
	SELECT cb.intInventoryLotId
			,cb.intLotId 
			,cb.dblCost 
			,dblValue = cb.dblStockIn * cb.dblCost
			,cb.dblForexCost 
			,dblForexValue = cb.dblStockIn * cb.dblForexCost
	FROM	tblICInventoryLot cb
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
END 

-- There could be more than one lot record per item received. 
-- Calculate how much cost adjustment goes for each lot qty. 
BEGIN 
	SELECT	@CostAdjustmentPerCb = dbo.fnDivide(@CostAdjustment, SUM(ISNULL(cb.dblStockIn, 0))) 
			,@ForexCostAdjustmentPerCb = dbo.fnDivide(@ForexCostAdjustment, SUM(ISNULL(cb.dblStockIn, 0))) 
	FROM	tblICInventoryLot cb
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 	
			AND cb.dblStockIn > 0 
			AND cb.intLotId = ISNULL(@intLotId, cb.intLotId) 

	-- If value of cost adjustment is zero, then exit immediately. 
	IF @CostAdjustmentPerCb IS NULL 
		RETURN; 
END 

-- Log the original cost
BEGIN 
	DECLARE @DummyInventoryTransactionId AS INT 
	SET @DummyInventoryTransactionId = -CAST(RAND() * 1000000 AS INT) 
	
	BEGIN 
		INSERT INTO tblICInventoryLotCostAdjustmentLog (
				[intInventoryLotId]
				,[intInventoryTransactionId] 
				,[intInventoryCostAdjustmentTypeId] 
				,[dblQty] 
				,[dblCost] 
				,[dblForexCost]
				,[dblValue] 
				,[ysnIsUnposted] 
				,[dtmCreated] 
				,[strRelatedTransactionId] 
				,[intRelatedTransactionId] 
				,[intCreatedUserId] 
				,[intCreatedEntityUserId] 
				,[intOtherChargeItemId] 
		)
		SELECT
				[intInventoryLotId] = cb.intInventoryLotId
				,[intInventoryTransactionId] = @DummyInventoryTransactionId 
				,[intInventoryCostAdjustmentTypeId] = @COST_ADJ_TYPE_Original_Cost
				,[dblQty] = cb.dblStockIn
				,[dblCost] = cb.dblCost
				,[dblForexCost] = cb.dblForexCost
				,[dblValue] = NULL 
				,[ysnIsUnposted]  = 0 
				,[dtmCreated] = GETDATE()
				,[strRelatedTransactionId] = cb.strTransactionId 
				,[intRelatedTransactionId] = cb.intTransactionId
				,[intCreatedUserId] = @intEntityUserSecurityId
				,[intCreatedEntityUserId] = @intEntityUserSecurityId
				,[intOtherChargeItemId] = @intOtherChargeItemId 
		FROM	tblICInventoryLot cb LEFT JOIN tblICInventoryLotCostAdjustmentLog cl
					ON cb.intInventoryLotId = cl.intInventoryLotId
		WHERE	cb.intItemId = @intItemId
				AND cb.intItemLocationId = @intItemLocationId
				AND cb.intTransactionId = @intSourceTransactionId
				AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
				AND cb.strTransactionId = @strSourceTransactionId
				AND ISNULL(cb.ysnIsUnposted, 0) = 0 
				AND cl.intInventoryLotId IS NULL 
	END 
END 

-- Loop to perform the retroactive computation
BEGIN 
	DECLARE loopRetroactive CURSOR LOCAL FAST_FORWARD
	FOR 		
		SELECT  t.intInventoryTransactionId
				,t.intItemId
				,t.intItemLocationId
				,t.intItemUOMId
				,dblQty = t.dblQty
				,t.dblCost
				,t.dblValue
				,t.strTransactionId
				,t.intTransactionId
				,t.intTransactionDetailId
				,t.intTransactionTypeId
				,t.strBatchId 
				,t.intLotId 
				,il.intLocationId
				,[negative stock cost] = 0
		FROM	tblICInventoryTransaction t INNER JOIN #tmpRetroactiveTransactions tmp
					ON t.intInventoryTransactionId = tmp.intInventoryTransactionId
				INNER JOIN tblICItemLocation il
					ON t.intItemLocationId = il.intItemLocationId
					AND t.intItemId = il.intItemId
		WHERE	t.intItemId = @intItemId
				AND t.intItemLocationId = @intItemLocationId			
				AND ISNULL(t.ysnIsUnposted, 0) = 0 
				AND t.dblQty <> 0 
		ORDER BY 
				tmp.intSort
				,t.intInventoryTransactionId ASC 	
	OPEN loopRetroactive;

	-- Initial fetch attempt
	FETCH NEXT FROM loopRetroactive INTO 
		@t_intInventoryTransactionId 
		,@t_intItemId 
		,@t_intItemLocationId 
		,@t_intItemUOMId 
		,@t_dblQty 
		,@t_dblCost 
		,@t_dblValue
		,@t_strTransactionId
		,@t_intTransactionId
		,@t_intTransactionDetailId
		,@t_intTransactionTypeId
		,@t_strBatchId
		,@t_intLotId
		,@t_intLocationId
		,@t_NegativeStockCost
	;

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @t_dblQty = ISNULL(@t_dblQty, 0)
		SET @t_dblCost = ISNULL(@t_dblCost, 0)
		SET @t_dblValue = ISNULL(@t_dblValue, 0) 
		SET @CostBucketNewCost = ISNULL(@CostBucketNewCost, 0) 
		SET @CostBucketNewForexCost = ISNULL(@CostBucketNewForexCost, 0) 
		SET @CurrentCostAdjustment = ISNULL(@CurrentCostAdjustment, 0) 		

		SET @IsSourceTransaction = 0
		SELECT	@IsSourceTransaction = 1 
		WHERE	@t_intItemId = @intItemId
				AND @t_intItemLocationId = @intItemLocationId
				AND @t_strTransactionId = @strSourceTransactionId
				AND @t_intTransactionId = @intSourceTransactionId
				AND @t_intTransactionDetailId = @intSourceTransactionDetailId
				AND @t_dblQty > 0 

		---- DEBUG -------------------------------------------------
		--IF @strTransactionId = 'WO-232'
		--BEGIN 
		--	DECLARE @debugMsg AS NVARCHAR(MAX) 

		--	SET @debugMsg = dbo.fnICFormatErrorMessage(
		--		'Debug Lot: %s, %i, %i, %i, %s, %i, %i, %f'
		--		,@t_strTransactionId
		--		,@t_intLotId
		--		,@intItemId
		--		,@intItemLocationId
		--		,@strSourceTransactionId
		--		,@intSourceTransactionId
		--		,@intSourceTransactionDetailId
		--		,@t_dblQty
		--		,DEFAULT
		--		,DEFAULT
		--	)

		--	PRINT @debugMsg

		--	SET @debugMsg = dbo.fnICFormatErrorMessage(
		--		'Debug @IsSourceTransaction: item %i, il %i, strSource %s, intSource %i, intSourceDetail %i, Qty %f'
		--		,@intItemId
		--		,@intItemLocationId
		--		,@strSourceTransactionId
		--		,@intSourceTransactionId
		--		,@intSourceTransactionDetailId
		--		,@t_dblQty
		--		,DEFAULT
		--		,DEFAULT
		--		,DEFAULT
		--		,DEFAULT
		--	)

		--	PRINT @debugMsg
		--END 
		---- DEBUG -------------------------------------------------			

		-- Get the original cost bucket value
		IF @IsSourceTransaction = 1
		BEGIN 
			SET @intInventoryLotId = NULL 
			SELECT	@CostBucketOriginalValue = cbo.dblValue
					,@CostBucketOriginalCost = cbo.dblCost
					,@intInventoryLotId = cb.intInventoryLotId
					,@CostBucketOriginalForexCost  = cbo.dblForexCost 
					,@CostBucketOriginalForexValue = cbo.dblForexValue
			FROM	tblICInventoryLot cb INNER JOIN #tmpCostBucketOriginal cbo
						ON cb.intInventoryLotId = cbo.intInventoryLotId
			WHERE	cbo.intLotId = @t_intLotId
					AND cb.intItemId = @t_intItemId
					AND cb.intItemLocationId = @t_intItemLocationId
					AND cb.intItemUOMId = @t_intItemUOMId
					AND cb.dblStockIn = @t_dblQty 

			DELETE FROM #tmpCostBucketOriginal 
			WHERE intInventoryLotId = @intInventoryLotId
		END 

		-- Calculate the Cost Bucket cost 
		SET @CostBucketNewCost = 
			CASE	WHEN @IsSourceTransaction = 1 THEN 
						(@CostBucketOriginalValue + @CostAdjustmentPerCb * @t_dblQty) / @t_dblQty
					ELSE
						@CostBucketNewCost
			END 

		SET @CostBucketNewForexCost = 
			CASE	WHEN @IsSourceTransaction = 1 THEN 
						(@CostBucketOriginalForexValue + @ForexCostAdjustmentPerCb * @t_dblQty) / @t_dblQty
					ELSE
						@CostBucketNewForexCost
			END 
		
		-- Calculate the current cost adjustment
		SET @CurrentCostAdjustment = 
			CASE	WHEN @IsSourceTransaction = 1  THEN 
						@CostAdjustmentPerCb * @t_dblQty 
					WHEN 
						@t_dblQty < 0 
						AND @t_intTransactionTypeId = @INV_TRANS_TYPE_NegativeStock THEN
							@t_dblQty * @CostBucketNewCost
							+ (-@t_dblQty * @t_NegativeStockCost) 

					WHEN @t_dblQty < 0 THEN 
						(@t_dblQty * @CostBucketNewCost) - (@t_dblQty * @CostBucketOriginalCost) 
 					ELSE 
						0
			END 

		-- Update the cost bucket and last cost from the lot table. 
		IF  @IsSourceTransaction = 1
		BEGIN 
			-- Validate if the cost is going to be negative. 
			--IF ROUND(@CostBucketOriginalValue + (@CostAdjustmentPerCb * @t_dblQty), 2) < 0 
			IF ROUND(@CostBucketNewCost, 2) < 0 
			BEGIN 
				SELECT	@strItemNo = CASE WHEN ISNULL(strItemNo, '') = '' THEN 'id: ' + CAST(@intItemId AS NVARCHAR(20)) ELSE strItemNo END 
				FROM	tblICItem 
				WHERE	intItemId = @intItemId

				-- '{Item} will have a negative cost. Negative cost is not allowed.'
				EXEC uspICRaiseError 80196, @strItemNo
				RETURN -80196;
			END 

			UPDATE  cb
			SET		cb.dblCost = 
						CASE 
							WHEN NOT (ROUND(@CostBucketNewCost, 2) < 0) AND @CostBucketNewCost < 0 THEN 0 
							ELSE @CostBucketNewCost
						END 

					,cb.dblForexCost = 
						CASE 
							WHEN NOT (ROUND(@CostBucketNewForexCost, 2) < 0) AND @CostBucketNewForexCost < 0 THEN 0 
							ELSE @CostBucketNewForexCost
						END 
			FROM	tblICInventoryLot cb
			WHERE	cb.intInventoryLotId = @intInventoryLotId

			UPDATE	l
			SET		l.dblLastCost = dbo.fnCalculateCostBetweenUOM(cb.intItemUOMId, stockUOM.intItemUOMId, cb.dblCost) -- cb.dblCost
			FROM	tblICLot l INNER JOIN tblICInventoryLot cb
						ON l.intLotId = cb.intLotId
					INNER JOIN tblICItemUOM stockUOM
						ON stockUOM.intItemId = l.intItemId
						AND stockUOM.ysnStockUnit = 1
			WHERE	cb.intInventoryLotId = @intInventoryLotId
		END 

		-- Check if there is a transaction where the cost change needs escalation. 
		IF @costAdjustmentType = @costAdjustmentType_DETAILED
		BEGIN 
			SET @EscalateCostAdjustment = 0 
			SET @EscalateCostAdjustment = (@t_dblQty * @CostBucketNewCost) - (@t_dblQty * @CostBucketOriginalCost)
					--dbo.fnMultiply(@t_dblQty, @CostBucketNewCost)
					--- dbo.fnMultiply(@t_dblQty, @CostBucketOriginalCost)				

			SET @EscalateInventoryTransactionTypeId = NULL
			EXEC [uspICPostCostAdjustmentEscalate]
				@dtmDate 
				,@t_intItemId 
				,@t_intItemLocationId 
				,@t_dblQty 
				,@t_strBatchId 
				,@t_intTransactionId 
				,@t_intTransactionDetailId 
				,@t_strTransactionId 
				,@t_intInventoryTransactionId 
				,@EscalateCostAdjustment 
				,@intTransactionId 
				,@intTransactionDetailId 
				,@strTransactionId 
				,@EscalateInventoryTransactionTypeId OUTPUT 
		END 

		-- Log the cost adjustment 
		BEGIN 
            SET @strReceiptType = NULL 
            IF @t_intTransactionTypeId = @INV_TRANS_TYPE_Inventory_Receipt 
            BEGIN 
                SELECT    @strReceiptType = strReceiptType
                FROM    tblICInventoryReceipt r
                WHERE    r.strReceiptNumber = @t_strTransactionId
            END 

			---- DEBUG -------------------------------------------------		
			--IF @strTransactionId = 'WO-232'
			--BEGIN 
			--	DECLARE @debugMsg2 AS NVARCHAR(MAX) 

			--	SET @debugMsg2 = dbo.fnICFormatErrorMessage(
			--		'WHERE: source %i, qty %f, adj per lot %f, new cb cost %f, original cb cost %f'
			--		,@IsSourceTransaction
			--		,@t_dblQty
			--		,@CostAdjustmentPerCb
			--		,@CostBucketNewCost
			--		,@CostBucketOriginalCost
			--		,DEFAULT
			--		,DEFAULT
			--		,DEFAULT
			--		,DEFAULT
			--		,DEFAULT
			--	)

			--	PRINT @debugMsg2
			--END 
			---- DEBUG -------------------------------------------------		

			INSERT INTO tblICInventoryLotCostAdjustmentLog (
				[intInventoryLotId]
				,[intInventoryTransactionId] 
				,[intInventoryCostAdjustmentTypeId] 
				,[dblQty] 
				,[dblCost] 
				,[dblValue] 
				,[ysnIsUnposted] 
				,[dtmCreated] 
				,[strRelatedTransactionId] 
				,[intRelatedTransactionId] 
				,[intRelatedTransactionDetailId] 
				,[intRelatedInventoryTransactionId]
				,[intCreatedUserId] 
				,[intCreatedEntityUserId] 
				,[intOtherChargeItemId] 
				,[dblForexValue] 
				,[intCurrencyId] 
				,[intForexRateTypeId] 
				,[dblForexRate] 
			)
			SELECT
				[intInventoryLotId] = @CostBucketId
				,[intInventoryTransactionId] = @DummyInventoryTransactionId 
				,[intInventoryCostAdjustmentTypeId] = 
						CASE	WHEN @t_dblQty > 0 THEN 
									CASE	
											WHEN @costAdjustmentType = @costAdjustmentType_SUMMARIZED THEN 
												@COST_ADJ_TYPE_Adjust_Value
											WHEN @t_intTransactionTypeId = @INV_TRANS_TYPE_Produce THEN 
												@COST_ADJ_TYPE_Adjust_WIP
											WHEN @t_intTransactionTypeId IN (
													@INV_TRANS_TYPE_ADJ_Item_Change
													,@INV_TRANS_TYPE_ADJ_Split_Lot
													,@INV_TRANS_TYPE_ADJ_Lot_Merge
													,@INV_TRANS_TYPE_ADJ_Lot_Move
												) THEN 
													@COST_ADJ_TYPE_Adjust_InventoryAdjustment
											WHEN @t_intTransactionTypeId = @INV_TRANS_Inventory_Transfer THEN 
												@COST_ADJ_TYPE_Adjust_InTransit_Inventory
											WHEN @IsSourceTransaction = 1 AND @t_intLocationId IS NOT NULL THEN 
												@COST_ADJ_TYPE_Adjust_Value
											WHEN @t_intLocationId IS NULL THEN 
												@COST_ADJ_TYPE_Adjust_InTransit
                                            WHEN (
                                                @t_intTransactionTypeId = @INV_TRANS_TYPE_Inventory_Receipt 
                                                AND @strReceiptType = 'Transfer Order' 
                                            ) THEN 
                                                @COST_ADJ_TYPE_Adjust_InTransit_Transfer_Order_Add
											ELSE 
												@COST_ADJ_TYPE_Adjust_Value
									END 
								WHEN @t_dblQty < 0 THEN 
									CASE	
											WHEN @costAdjustmentType = @costAdjustmentType_SUMMARIZED THEN 
												@COST_ADJ_TYPE_Adjust_Sold									
											WHEN @t_intTransactionTypeId = @INV_TRANS_TYPE_Consume THEN 
												@COST_ADJ_TYPE_Adjust_WIP
											WHEN @EscalateInventoryTransactionTypeId = @INV_TRANS_TYPE_Inventory_Shipment THEN 
												@COST_ADJ_TYPE_Adjust_InTransit_Inventory	
											WHEN @t_intLocationId IS NULL AND @t_intTransactionTypeId = @INV_TRANS_TYPE_Invoice THEN 
												@COST_ADJ_TYPE_Adjust_InTransit_Sold
											WHEN @t_intLocationId IS NULL THEN 
												@COST_ADJ_TYPE_Adjust_InTransit
											WHEN @t_intTransactionTypeId IN (
													@INV_TRANS_TYPE_ADJ_Item_Change
													,@INV_TRANS_TYPE_ADJ_Split_Lot
													,@INV_TRANS_TYPE_ADJ_Lot_Merge
													,@INV_TRANS_TYPE_ADJ_Lot_Move
												) THEN 
													@COST_ADJ_TYPE_Adjust_InventoryAdjustment
                                            WHEN @t_intTransactionTypeId IN (@INV_TRANS_Inventory_Transfer, @INV_TRANS_Inventory_Transfer_With_Shipment) THEN  
												@COST_ADJ_TYPE_Adjust_InTransit_Inventory
                                            WHEN (
                                                @t_intTransactionTypeId = @INV_TRANS_TYPE_Inventory_Receipt 
                                                AND @strReceiptType = 'Transfer Order' 
                                            ) THEN 
                                                @COST_ADJ_TYPE_Adjust_InTransit_Transfer_Order_Reduce
											ELSE 
												@COST_ADJ_TYPE_Adjust_Sold
									END 
						END 
				,[dblQty] = NULL 
				,[dblCost] = NULL 
				,[dblValue] = 
					CASE	WHEN @IsSourceTransaction = 1 THEN 
								@t_dblQty * @CostAdjustmentPerCb
							WHEN @t_dblQty < 0 THEN 
								@t_dblQty * @CostAdjustmentPerCb
							ELSE 
								0
					END 
				,[ysnIsUnposted]  = CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
				,[dtmCreated] = GETDATE()
				,[strRelatedTransactionId] = @t_strTransactionId 
				,[intRelatedTransactionId] = @t_intTransactionId
				,[intRelatedTransactionDetailId] = @t_intTransactionDetailId
				,[intRelatedInventoryTransactionId] = @t_intInventoryTransactionId
				,[intCreatedUserId] = @intEntityUserSecurityId
				,[intCreatedEntityUserId] = @intEntityUserSecurityId
				,[intOtherChargeItemId] = @intOtherChargeItemId 
				,[dblForexValue] = 
					CASE	WHEN @IsSourceTransaction = 1 THEN 
								@t_dblQty * @ForexCostAdjustmentPerCb
							WHEN @t_dblQty < 0 THEN 
								@t_dblQty * @ForexCostAdjustmentPerCb
							ELSE 
								0
					END 
				,[intCurrencyId] = @intCurrencyId
				,[intForexRateTypeId] = @intForexRateTypeId
				,[dblForexRate] = @dblForexRate
			WHERE		
				CASE	WHEN @IsSourceTransaction = 1 THEN 
							@t_dblQty * @CostAdjustmentPerCb
						WHEN @t_dblQty < 0 THEN 
							@t_dblQty * @CostAdjustmentPerCb
						ELSE 
							0
				END <> 0 
		END 

		-- Initial fetch attempt
		FETCH NEXT FROM loopRetroactive INTO 
			@t_intInventoryTransactionId 
			,@t_intItemId 
			,@t_intItemLocationId 
			,@t_intItemUOMId 
			,@t_dblQty 
			,@t_dblCost 
			,@t_dblValue
			,@t_strTransactionId
			,@t_intTransactionId
			,@t_intTransactionDetailId
			,@t_intTransactionTypeId
			,@t_strBatchId
			,@t_intLotId
			,@t_intLocationId
			,@t_NegativeStockCost
		;		
	END 

	CLOSE loopRetroactive;
	DEALLOCATE loopRetroactive;
END 

---- Book the cost adjustment. 
--IF @costAdjustmentType = @costAdjustmentType_SUMMARIZED
--BEGIN 


--	SET 	@CurrentCostAdjustment = NULL 
--	SELECT	@CurrentCostAdjustment = SUM(ROUND(ISNULL(dblValue, 0), 2)) 
--	FROM	tblICInventoryLotCostAdjustmentLog	
--	WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
--			AND intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost	

--	SET @strNewCost = CONVERT(NVARCHAR, CAST(ISNULL(@CostAdjustment, 0) AS MONEY), 1)

--	SELECT	@strDescription = 'A value of ' + @strNewCost + ' is adjusted for ' + i.strItemNo + '. It is posted in ' + @strSourceTransactionId + '.'
--	FROM	tblICItem i 
--	WHERE	i.intItemId = @intItemId

--	-- Create the 'Cost Adjustment' inventory transaction. 
--	--IF ISNULL(@CurrentCostAdjustment, 0) <> 0
--	BEGIN 
--		EXEC [uspICPostInventoryTransaction]
--			@intItemId								= @intItemId
--			,@intItemLocationId						= @intItemLocationId
--			,@intItemUOMId							= @intItemUOMId
--			,@intSubLocationId						= @intSubLocationId
--			,@intStorageLocationId					= @intStorageLocationId
--			,@dtmDate								= @dtmDate
--			,@dblQty								= 0
--			,@dblUOMQty								= 0
--			,@dblCost								= 0
--			,@dblValue								= @CurrentCostAdjustment
--			,@dblSalesPrice							= 0
--			,@intCurrencyId							= NULL 
--			,@intTransactionId						= @intTransactionId
--			,@intTransactionDetailId				= @intTransactionDetailId
--			,@strTransactionId						= @strTransactionId
--			,@strBatchId							= @strBatchId
--			,@intTransactionTypeId					= @INV_TRANS_TYPE_Cost_Adjustment 
--			,@intLotId								= @intLotId  
--			,@intRelatedInventoryTransactionId		= @intRelatedInventoryTransactionId 
--			,@intRelatedTransactionId				= @intSourceTransactionId
--			,@strRelatedTransactionId				= @strSourceTransactionId
--			,@strTransactionForm					= @strTransactionForm
--			,@intEntityUserSecurityId				= @intEntityUserSecurityId
--			,@intCostingMethod						= @LOTCOST -- TODO: Double check the costing method. Make sure it matches with the SP. 
--			,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
--			,@intFobPointId							= @intFobPointId 
--			,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
--			,@intForexRateTypeId					= NULL
--			,@dblForexRate							= 1
--			,@strDescription						= @strDescription	

--			UPDATE	tblICInventoryTransaction 
--			SET		ysnIsUnposted = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END 
--			WHERE	intInventoryTransactionId = @InventoryTransactionIdentityId

--			-- Update the log with correct inventory transaction id
--			IF @InventoryTransactionIdentityId IS NOT NULL 
--			BEGIN 
--				UPDATE	tblICInventoryLotCostAdjustmentLog 
--				SET		intInventoryTransactionId = @InventoryTransactionIdentityId
--				WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
--			END 
--	END 
--END 
IF @costAdjustmentType = @costAdjustmentType_SUMMARIZED
BEGIN 

	DECLARE loopCostAdjustmentLogSummarized CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	dblCurrentAdjustment = SUM(ROUND(ISNULL(dblValue, 0), 2)) 
			,dblForexCurrentAdjustment = SUM(ROUND(ISNULL(dblForexValue, 0), 2)) 
			,intLotId 
	FROM	tblICInventoryLotCostAdjustmentLog cbLog INNER JOIN tblICInventoryLot cb
				ON cbLog.intInventoryLotId = cb.intInventoryLotId
	WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
			AND intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	GROUP BY
			cb.intLotId

	OPEN loopCostAdjustmentLogSummarized
	FETCH NEXT FROM loopCostAdjustmentLogSummarized INTO 
		@CurrentCostAdjustment 
		,@ForexCurrentCostAdjustment 
		,@intLotId 

	WHILE @@FETCH_STATUS = 0 
	BEGIN

		SET @strNewCost = CONVERT(NVARCHAR, CAST(ISNULL(@CostAdjustment, 0) AS MONEY), 1)

		SELECT	@strDescription = 'A value of ' + @strNewCost + ' is adjusted for ' + i.strItemNo + '. It is posted in ' + @strSourceTransactionId + '.'
		FROM	tblICItem i 
		WHERE	i.intItemId = @intItemId

		SET @InventoryTransactionIdentityId = NULL 
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
			,@dblForexCost							= 0 
			,@dblValue								= @CurrentCostAdjustment
			,@dblForexValue							= @ForexCurrentCostAdjustment
			,@dblSalesPrice							= 0
			,@intCurrencyId							= @intCurrencyId 
			,@intTransactionId						= @intTransactionId
			,@intTransactionDetailId				= @intTransactionDetailId
			,@strTransactionId						= @strTransactionId
			,@strBatchId							= @strBatchId
			,@intTransactionTypeId					= @INV_TRANS_TYPE_Cost_Adjustment 
			,@intLotId								= @intLotId  
			,@intRelatedInventoryTransactionId		= @intRelatedInventoryTransactionId 
			,@intRelatedTransactionId				= @intSourceTransactionId
			,@strRelatedTransactionId				= @strSourceTransactionId
			,@strTransactionForm					= @strTransactionForm
			,@intEntityUserSecurityId				= @intEntityUserSecurityId
			,@intCostingMethod						= @LOTCOST -- TODO: Double check the costing method. Make sure it matches with the SP. 
			,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
			,@intFobPointId							= @intFobPointId 
			,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
			,@intForexRateTypeId					= @intForexRateTypeId
			,@dblForexRate							= @dblForexRate
			,@strDescription						= @strDescription	
			,@intSourceEntityId						= @intSourceEntityId

		-- Update ysnIsUnposted flag. 
		BEGIN 
			UPDATE	tblICInventoryTransaction 
			SET		ysnIsUnposted = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END 
			WHERE	intInventoryTransactionId = @InventoryTransactionIdentityId
		END 

		-- Update the log with correct inventory transaction id
		IF @InventoryTransactionIdentityId IS NOT NULL 
		BEGIN 
			UPDATE	tblICInventoryLotCostAdjustmentLog 
			SET		intInventoryTransactionId = @InventoryTransactionIdentityId
			WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
		END 

		FETCH NEXT FROM loopCostAdjustmentLogSummarized INTO 
			@CurrentCostAdjustment 
			,@ForexCurrentCostAdjustment 
			,@intLotId 
	END 

	CLOSE loopCostAdjustmentLogSummarized;
	DEALLOCATE loopCostAdjustmentLogSummarized;


END 

ELSE IF @costAdjustmentType = @costAdjustmentType_DETAILED
BEGIN 

	DECLARE @strTransactionIdCostAdjLog AS NVARCHAR(50)
			,@intTransactionIdCostAdjLog AS INT
			,@intTransactionDetailIdCostAdjLog AS INT 
			,@intCostAdjId AS INT 

	DECLARE loopCostAdjustmentLog CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	
			ROUND(ISNULL(cbLog.dblValue, 0), 2) 
			,ROUND(ISNULL(cbLog.dblForexValue, 0), 2) 
			,cbLog.strRelatedTransactionId
			,cbLog.intRelatedTransactionId
			,cbLog.intRelatedTransactionDetailId
			,cbLog.intId 
			,cb.intLotId
	FROM	tblICInventoryLotCostAdjustmentLog cbLog INNER JOIN tblICInventoryLot cb
				ON cbLog.intInventoryLotId = cb.intInventoryLotId
	WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
			AND intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost		

	OPEN loopCostAdjustmentLog
	FETCH NEXT FROM loopCostAdjustmentLog INTO 
		@CurrentCostAdjustment 
		,@ForexCurrentCostAdjustment 
		,@strTransactionIdCostAdjLog
		,@intTransactionIdCostAdjLog
		,@intTransactionDetailIdCostAdjLog
		,@intCostAdjId
		,@intLotId 

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @strNewCost = CONVERT(NVARCHAR, CAST(ISNULL(@CostAdjustment, 0) AS MONEY), 1)

		SELECT	@strDescription = 'A value of ' + @strNewCost + ' is adjusted for ' + i.strItemNo + '. It is posted in ' + @strSourceTransactionId + '.'
		FROM	tblICItem i 
		WHERE	i.intItemId = @intItemId

		SET @InventoryTransactionIdentityId = NULL 
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
			,@dblForexCost							= 0 
			,@dblValue								= @CurrentCostAdjustment
			,@dblForexValue							= @ForexCurrentCostAdjustment
			,@dblSalesPrice							= 0
			,@intCurrencyId							= @intCurrencyId 
			,@intTransactionId						= @intTransactionId
			,@intTransactionDetailId				= @intTransactionDetailId
			,@strTransactionId						= @strTransactionId
			,@strBatchId							= @strBatchId
			,@intTransactionTypeId					= @INV_TRANS_TYPE_Cost_Adjustment 
			,@intLotId								= @intLotId  
			,@intRelatedInventoryTransactionId		= @intRelatedInventoryTransactionId 
			,@intRelatedTransactionId				= @intTransactionIdCostAdjLog
			,@strRelatedTransactionId				= @strTransactionIdCostAdjLog
			,@strTransactionForm					= @strTransactionForm
			,@intEntityUserSecurityId				= @intEntityUserSecurityId
			,@intCostingMethod						= @LOTCOST -- TODO: Double check the costing method. Make sure it matches with the SP. 
			,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
			,@intFobPointId							= @intFobPointId 
			,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
			,@intForexRateTypeId					= @intForexRateTypeId
			,@dblForexRate							= @dblForexRate
			,@strDescription						= @strDescription	
			,@intSourceEntityId						= @intSourceEntityId

		-- Update ysnIsUnposted flag. 
		BEGIN 
			UPDATE	tblICInventoryTransaction 
			SET		ysnIsUnposted = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END 
			WHERE	intInventoryTransactionId = @InventoryTransactionIdentityId
		END 

		-- Update the log with correct inventory transaction id
		IF @InventoryTransactionIdentityId IS NOT NULL 
		BEGIN 
			UPDATE	tblICInventoryLotCostAdjustmentLog 
			SET		intInventoryTransactionId = @InventoryTransactionIdentityId
			WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
					AND intId = @intCostAdjId
		END 

		FETCH NEXT FROM loopCostAdjustmentLog INTO 
			@CurrentCostAdjustment 
			,@ForexCurrentCostAdjustment
			,@strTransactionIdCostAdjLog
			,@intTransactionIdCostAdjLog
			,@intTransactionDetailIdCostAdjLog
			,@intCostAdjId
			,@intLotId
	END 

	CLOSE loopCostAdjustmentLog;
	DEALLOCATE loopCostAdjustmentLog;
END 

-- Update the last cost and standard cost. 
BEGIN 
	IF @ysnUpdateItemCostAndPrice = 1 AND @CostBucketId IS NOT NULL 
	BEGIN 
		UPDATE	p
		SET		p.dblAverageCost = 
						ISNULL(
							dbo.fnRecalculateAverageCost(p.intItemId, p.intItemLocationId)
							, p.dblAverageCost
						) 
				,p.dblLastCost = dbo.fnCalculateCostBetweenUOM(cb.intItemUOMId, stockUOM.intItemUOMId, cb.dblCost)
				,p.dblStandardCost = 
					CASE 
						WHEN ISNULL(p.dblStandardCost, 0) = 0 THEN 
							dbo.fnCalculateCostBetweenUOM(cb.intItemUOMId, stockUOM.intItemUOMId, cb.dblCost)
						ELSE 
							p.dblStandardCost 
					END 
				,p.ysnIsPendingUpdate = 
						CASE	WHEN p.ysnIsPendingUpdate = 1 THEN 1
								WHEN 
									p.dblLastCost <> dbo.fnCalculateCostBetweenUOM(cb.intItemUOMId, stockUOM.intItemUOMId, cb.dblCost) 
									OR dblStandardCost <> (
											CASE 
												WHEN ISNULL(p.dblStandardCost, 0) = 0 THEN 
													dbo.fnCalculateCostBetweenUOM(cb.intItemUOMId, stockUOM.intItemUOMId, cb.dblCost)
												ELSE 
													p.dblStandardCost 
											END 
										)
									THEN 
									1
								ELSE 
									0
						END
		FROM	tblICItemPricing p INNER JOIN tblICInventoryLot cb
					ON p.intItemId = cb.intItemId
					AND p.intItemLocationId = cb.intItemLocationId
				INNER JOIN tblICItemUOM stockUOM
					ON stockUOM.intItemId = p.intItemId
					AND stockUOM.ysnStockUnit = 1
		WHERE	cb.intInventoryLotId = @CostBucketId
				AND cb.dblStockIn <> 0 
				AND cb.intItemId = @intItemId 
				AND cb.intItemLocationId = @intItemLocationId
				AND ISNULL(cb.dblCost, 0) <> 0
	END 

	-- Update the Item Pricing
	EXEC uspICUpdateItemPricing
		@intItemId
		,@intItemLocationId
END


IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRetroactiveTransactions')) 
	DROP TABLE #tmpRetroactiveTransactions 
