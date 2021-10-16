﻿/*

*/
CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentRetroactiveActual]
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
	,@intTransactionId AS INT
	,@intTransactionDetailId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@intSourceTransactionId AS INT
	,@intSourceTransactionDetailId AS INT 
	,@strSourceTransactionId AS NVARCHAR(40)
	,@strBatchId AS NVARCHAR(40)
	,@intTransactionTypeId AS INT
	,@intEntityUserSecurityId AS INT
	,@intRelatedInventoryTransactionId AS INT = NULL 
	,@strTransactionForm AS NVARCHAR(50) = 'Bill'
	,@intFobPointId AS TINYINT = NULL
	,@intInTransitSourceLocationId AS INT = NULL  
	,@strActualCostId AS NVARCHAR(50)
	,@ysnPost AS BIT = 1 
	,@intOtherChargeItemId AS INT = NULL
	,@ysnUpdateItemCostAndPrice AS BIT = 0 
	,@IsEscalate AS BIT = 0 
	,@dblNewAverageCost AS NUMERIC(38,20) = NULL
	,@intSourceEntityId AS INT = NULL  
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
			,@CurrentCostAdjustment AS NUMERIC(38, 20)
			,@CostBucketNewCost AS NUMERIC(38, 20)			
			,@TotalCostAdjustment AS NUMERIC(38, 20)
			,@CostAdjustmentPerQty AS NUMERIC(38, 20) 
			
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
			,@t_NegativeStockCost AS NUMERIC(38, 20)

			,@EscalateInventoryTransactionId AS INT 
			,@EscalateInventoryTransactionTypeId AS INT 
			,@EscalateCostAdjustment AS NUMERIC(38, 20)

			,@InventoryTransactionIdentityId AS INT 

	DECLARE	@StockItemUOMId AS INT
			,@strDescription AS NVARCHAR(255)	
			,@strNewCost AS NVARCHAR(50) 
			,@strItemNo AS NVARCHAR(50) 

	DECLARE @strReceiptType AS NVARCHAR(50)			
			,@costAdjustmentType_DETAILED AS TINYINT = 1
			,@costAdjustmentType_SUMMARIZED AS TINYINT = 2

	DECLARE @costAdjustmentType AS TINYINT 
	SET @costAdjustmentType = dbo.fnICGetCostAdjustmentSetup(@intItemId, @intItemLocationId) 
END 

-- Compute the cost adjustment
BEGIN 
	SET @CostAdjustment = 
		CASE	WHEN @dblNewValue IS NOT NULL THEN @dblNewValue
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

	SELECT	TOP 1 
			@InventoryTransactionStartId = t.intInventoryTransactionId 
	FROM	tblICInventoryTransaction t
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND t.intTransactionId = @intSourceTransactionId
			AND ISNULL(t.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND t.strTransactionId = @strSourceTransactionId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 

	SELECT	TOP 1 
			@CostBucketId = cb.intInventoryActualCostId
			,@CostBucketOriginalStockIn = cb.dblStockIn
			,@CostBucketOriginalCost = cb.dblCost
			,@CostBucketOriginalValue = ROUND(dbo.fnMultiply(cb.dblStockIn, cb.dblCost), 2) 
			,@CostBucketDate = cb.dtmDate
	FROM	tblICInventoryActualCost cb
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
			AND cb.strActualCostId = @strActualCostId
		
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
		IF dbo.fnDateLessThan(@dtmDate, @CostBucketDate) = 1 AND ISNULL(@IsEscalate, 0) = 0 
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
		)
	END 

	DELETE FROM #tmpRetroactiveTransactions
	INSERT INTO #tmpRetroactiveTransactions (
		intInventoryTransactionId
	)
	-- Self: 
	SELECT	@InventoryTransactionStartId 
	WHERE	@InventoryTransactionStartId IS NOT NULL 
	-- Cost Bucket Out: 
	UNION ALL 
	SELECT	cbOut.intInventoryTransactionId
	FROM	tblICInventoryActualCostOut cbOut
	WHERE	cbOut.intInventoryActualCostId = @CostBucketId
END 

-- There could be more than one lot record per item received. 
-- Calculate how much cost adjustment goes for each cost bucket. 
BEGIN 
	SELECT	@CostAdjustmentPerQty = dbo.fnDivide(@CostAdjustment, SUM(ISNULL(cb.dblStockIn, 0))) 
	FROM	tblICInventoryActualCost cb
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 	
			AND cb.dblStockIn > 0 
			AND cb.strActualCostId = @strActualCostId

	-- If value of cost adjustment is zero, then exit immediately. 
	IF @CostAdjustmentPerQty IS NULL 
		RETURN; 
END 

-- Log the original cost
BEGIN 
	DECLARE @DummyInventoryTransactionId AS INT 
	SET @DummyInventoryTransactionId = -CAST(RAND() * 1000000 AS INT) 
	
	IF NOT EXISTS (
		SELECT	* 
		FROM	tblICInventoryActualCostAdjustmentLog cl
		WHERE	cl.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
				AND cl.intInventoryActualCostId = @CostBucketId
	)
	BEGIN 
		INSERT INTO tblICInventoryActualCostAdjustmentLog (
			[intInventoryActualCostId]
			,[intInventoryTransactionId] 
			,[intInventoryCostAdjustmentTypeId] 
			,[dblQty] 
			,[dblCost] 
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
			[intInventoryActualCostId] = cb.intInventoryActualCostId
			,[intInventoryTransactionId] = @DummyInventoryTransactionId 
			,[intInventoryCostAdjustmentTypeId] = @COST_ADJ_TYPE_Original_Cost
			,[dblQty] = cb.dblStockIn
			,[dblCost] = cb.dblCost
			,[dblValue] = NULL 
			,[ysnIsUnposted]  = 0 
			,[dtmCreated] = GETDATE()
			,[strRelatedTransactionId] = cb.strTransactionId 
			,[intRelatedTransactionId] = cb.intTransactionId
			,[intCreatedUserId] = @intEntityUserSecurityId
			,[intCreatedEntityUserId] = @intEntityUserSecurityId
			,[intOtherChargeItemId] = @intOtherChargeItemId 
		FROM	
			tblICInventoryActualCost cb
		WHERE	
			cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 	
			AND cb.dblStockIn > 0 
			AND cb.strActualCostId = @strActualCostId
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
			,dblQty = ISNULL(-cbOut.dblQty, t.dblQty)
			,t.dblCost
			,t.dblValue
			,t.strTransactionId
			,t.intTransactionId
			,t.intTransactionDetailId
			,t.intTransactionTypeId
			,t.strBatchId 
			,il.intLocationId
			,[negative stock cost] = cb.dblCost 
	FROM	tblICInventoryTransaction t INNER JOIN #tmpRetroactiveTransactions tmp
				ON t.intInventoryTransactionId = tmp.intInventoryTransactionId
			INNER JOIN tblICItemLocation il
				ON t.intItemLocationId = il.intItemLocationId
				AND t.intItemId = il.intItemId
			LEFT JOIN tblICInventoryActualCostOut cbOut 
				ON cbOut.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbOut.intRevalueActualCostId IS NOT NULL 
			LEFT JOIN tblICInventoryActualCost cb
				ON cb.intInventoryActualCostId = cbOut.intRevalueActualCostId
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId			
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.dblQty <> 0 
	ORDER BY t.intInventoryTransactionId ASC 

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
		,@t_intLocationId
		,@t_NegativeStockCost
	;

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @t_dblQty = ISNULL(@t_dblQty, 0)
		SET @t_dblCost = ISNULL(@t_dblCost, 0)
		SET @t_dblValue = ISNULL(@t_dblValue, 0) 
		SET @CostBucketNewCost = ISNULL(@CostBucketNewCost, 0) 
		SET @CurrentCostAdjustment = ISNULL(@CurrentCostAdjustment, 0) 		

		-- Calculate the Cost Bucket cost 
		SET @CostBucketNewCost = 
			CASE	
				WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
					CASE 
						WHEN @dblNewAverageCost IS NOT NULL  THEN 
							@dblNewAverageCost 
						ELSE 
							--(@CostBucketOriginalValue + @CostAdjustment) / @t_dblQty
							(@CostBucketOriginalValue + @CostAdjustmentPerQty * @t_dblQty) / @t_dblQty
					END 
				ELSE
					@CostBucketNewCost
			END 
		
		-- Calculate the current cost adjustment
		SET @CurrentCostAdjustment = 
			CASE	WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
						CASE 
							WHEN @dblNewAverageCost IS NOT NULL  THEN 
								(@t_dblQty * @dblNewAverageCost) - (@t_dblQty * @CostBucketOriginalCost) 
							ELSE 
								--@CostAdjustment 
								@CostAdjustmentPerQty * @t_dblQty
						END 
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

		-- Update the cost bucket cost. 
		IF @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId  
		BEGIN 
			-- Validate if the cost is going to be negative. 
			IF (
				1 = CASE 
						WHEN ISNULL(@dblNewAverageCost, 0) < 0 THEN 1
						--WHEN (@CostBucketOriginalValue + @CostAdjustment) < 0 THEN 1
						WHEN (@CostBucketOriginalValue + @CostAdjustmentPerQty * @t_dblQty) < 0 THEN 1
						ELSE 0
					END 
			)
			BEGIN 
				SELECT	@strItemNo = CASE WHEN ISNULL(strItemNo, '') = '' THEN 'id: ' + CAST(@intItemId AS NVARCHAR(20)) ELSE strItemNo END 
				FROM	tblICItem 
				WHERE	intItemId = @intItemId

				-- '{Item} will have a negative cost. Negative cost is not allowed.'
				EXEC uspICRaiseError 80196, @strItemNo
				RETURN -80196;
			END 

			-- Keep this code for debugging purposes. 
			---- DEBUG -------------------------------------------------
			--IF @strSourceTransactionId = 'IS-2318'
			--BEGIN 
			--	DECLARE @beforeUpdateCost AS NUMERIC(38, 20)
			--			,@afterUpdateCost AS NUMERIC(38, 20)

			--	BEGIN 
			--		SELECT	@beforeUpdateCost = cb.dblCost
			--		FROM	tblICInventoryActualCost cb
			--		WHERE	cb.intItemId = @intItemId
			--				AND cb.intInventoryActualCostId = @CostBucketId
			--				AND cb.dblStockIn <> 0 
			--	END 
			--END
			---- DEBUG -------------------------------------------------

			UPDATE	cb
			SET		cb.dblCost = 
						CASE 
							WHEN @dblNewAverageCost IS NOT NULL THEN @dblNewAverageCost 
							ELSE  
								dbo.fnDivide(
									--(@CostBucketOriginalValue + @CostAdjustment) 
									(@CostBucketOriginalValue + @CostAdjustmentPerQty * @t_dblQty)
									,cb.dblStockIn 
								) 
						END 
			FROM	tblICInventoryActualCost cb
			WHERE	cb.intItemId = @intItemId
					AND cb.intInventoryActualCostId = @CostBucketId
					AND cb.dblStockIn <> 0 

			-- Keep this code for debugging purposes. 
			---- DEBUG -------------------------------------------------
			--IF @strSourceTransactionId = 'IS-2318'
			--BEGIN 
			--	SELECT	@afterUpdateCost = cb.dblCost
			--	FROM	tblICInventoryActualCost cb
			--	WHERE	cb.intItemId = @intItemId
			--			AND cb.intInventoryActualCostId = @CostBucketId
			--			AND cb.dblStockIn <> 0 

			--	SELECT	'Debug: updating of the cb cost.'
			--			,[cost before update] = @beforeUpdateCost
			--			,[cost after update] = @afterUpdateCost
			--			,cb.* 
			--	FROM	tblICInventoryActualCost cb
			--	WHERE	cb.intItemId = @intItemId
			--			AND cb.intInventoryActualCostId = @CostBucketId
			--			AND cb.dblStockIn <> 0 
			--			--AND @beforeUpdateCost <> @afterUpdateCost
			--END 
			---- DEBUG -------------------------------------------------

		END

		-- Check if there is a transaction where the cost change needs escalation. 
		IF @costAdjustmentType = @costAdjustmentType_DETAILED 
		BEGIN 
			SET @EscalateCostAdjustment = 0 
			SET @EscalateCostAdjustment = (@t_dblQty * @CostBucketNewCost) - (@t_dblQty * @CostBucketOriginalCost)

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
				,@dblNewAverageCost

			-- Keep this code for debugging purposes. 
			---- DEBUG -------------------------------------------------
			--IF @EscalateInventoryTransactionTypeId IS NOT NULL 
			--BEGIN 
			--	DECLARE @debugMsg AS NVARCHAR(MAX) 

			--	SET @debugMsg = dbo.fnICFormatErrorMessage(
			--		'Debug: Escalate a value of %f for %s. Qty is %f. Type is %i. Location is %i'
			--		,-@EscalateCostAdjustment
			--		,@t_strTransactionId			
			--		,@t_dblQty
			--		,@t_intTransactionTypeId
			--		,isnull(@t_intLocationId, -1)
			--		,DEFAULT
			--		,DEFAULT
			--		,DEFAULT
			--		,DEFAULT
			--		,DEFAULT
			--	)

			--	PRINT @debugMsg
			--END 
			---- DEBUG -------------------------------------------------
		END 

		-- Log the cost adjustment 
		BEGIN 
			SET @strReceiptType = NULL 
			IF @t_intTransactionTypeId = @INV_TRANS_TYPE_Inventory_Receipt 
			BEGIN 
				SELECT	@strReceiptType = strReceiptType
				FROM	tblICInventoryReceipt r
				WHERE	r.strReceiptNumber = @t_strTransactionId						
			END 

			INSERT INTO tblICInventoryActualCostAdjustmentLog (
				[intInventoryActualCostId]
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
			)
			SELECT
				[intInventoryActualCostId] = @CostBucketId
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
											WHEN (
												@t_intInventoryTransactionId = @InventoryTransactionStartId 
												AND @t_intLocationId IS NOT NULL 
												AND @strReceiptType <> 'Transfer Order'
											) THEN 										
												@COST_ADJ_TYPE_Adjust_Value
											WHEN (
												@t_intTransactionTypeId = @INV_TRANS_TYPE_Inventory_Receipt 
												AND @strReceiptType = 'Transfer Order'
											) THEN 
												@COST_ADJ_TYPE_Adjust_InTransit_Transfer_Order_Add
											WHEN @t_intLocationId IS NULL THEN 
												@COST_ADJ_TYPE_Adjust_InTransit
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
											WHEN (
												@t_intTransactionTypeId = @INV_TRANS_TYPE_Inventory_Receipt 
												AND @strReceiptType = 'Transfer Order'
											) THEN 
												@COST_ADJ_TYPE_Adjust_InTransit_Transfer_Order_Reduce
											WHEN @t_intLocationId IS NULL THEN 
												@COST_ADJ_TYPE_Adjust_InTransit
											WHEN @t_intTransactionTypeId IN (
													@INV_TRANS_TYPE_ADJ_Item_Change
													,@INV_TRANS_TYPE_ADJ_Split_Lot
													,@INV_TRANS_TYPE_ADJ_Lot_Merge
													,@INV_TRANS_TYPE_ADJ_Lot_Move
												) THEN 
													@COST_ADJ_TYPE_Adjust_InventoryAdjustment
											WHEN @t_intTransactionTypeId = @INV_TRANS_Inventory_Transfer THEN 
												@COST_ADJ_TYPE_Adjust_InTransit_Inventory
											ELSE 
												@COST_ADJ_TYPE_Adjust_Sold
									END 
						END 
				,[dblQty] = NULL 
				,[dblCost] = NULL 
				,[dblValue] = 
					CASE	WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
								CASE 
									WHEN @dblNewAverageCost IS NOT NULL THEN 
										(@t_dblQty * @dblNewAverageCost) - (@t_dblQty * @CostBucketOriginalCost) 
									ELSE 
										@CostAdjustmentPerQty * @t_dblQty
								END 
							WHEN @t_dblQty < 0 THEN 
								--(@t_dblQty * @CostBucketNewCost) - (@t_dblQty * @CostBucketOriginalCost)
								@t_dblQty * @CostAdjustmentPerQty
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
			WHERE		
				CASE	WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
							CASE 
								WHEN @dblNewAverageCost IS NOT NULL THEN 
									(@t_dblQty * @dblNewAverageCost) - (@t_dblQty * @CostBucketOriginalCost) 
								ELSE 
									@CostAdjustmentPerQty * @t_dblQty
							END 
						WHEN @t_dblQty < 0 THEN 
							--(@t_dblQty * @CostBucketNewCost) - (@t_dblQty * @CostBucketOriginalCost)
							@t_dblQty * @CostAdjustmentPerQty
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
			,@t_intLocationId
			,@t_NegativeStockCost
		;		
	END 

	CLOSE loopRetroactive;
	DEALLOCATE loopRetroactive;
END 

-- Book the cost adjustment. 
IF @costAdjustmentType = @costAdjustmentType_SUMMARIZED
BEGIN 
	-- Calculate the value to book. 
	SET 	@CurrentCostAdjustment = NULL 
	SELECT	@CurrentCostAdjustment = SUM(ROUND(ISNULL(dblValue, 0), 2)) 
	FROM	tblICInventoryActualCostAdjustmentLog	
	WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
			AND intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost	

	IF @dblNewAverageCost IS NOT NULL 
	BEGIN 
		SET @strNewCost = CONVERT(NVARCHAR, CAST(ISNULL(@dblNewAverageCost, 0) AS MONEY), 1)

		SELECT	@strDescription = 'A new average cost, ' + @strNewCost + ', is adjusted for ' + i.strItemNo + '. It is posted in ' + @strSourceTransactionId + '.'
		FROM	tblICItem i 
		WHERE	i.intItemId = @intItemId
	END 
	ELSE 
	BEGIN 
		SET @strNewCost = CONVERT(NVARCHAR, CAST(ISNULL(@CostAdjustment, 0) AS MONEY), 1)

		SELECT	@strDescription = 'A value of ' + @strNewCost + ' is adjusted for ' + i.strItemNo + '. It is posted in ' + @strSourceTransactionId + '.'
		FROM	tblICItem i 
		WHERE	i.intItemId = @intItemId
	END

	-- Create the 'Cost Adjustment' inventory transaction. 
	--IF ISNULL(@CurrentCostAdjustment, 0) <> 0 
	BEGIN 
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
			,@dblValue								= @CurrentCostAdjustment
			,@dblSalesPrice							= 0
			,@intCurrencyId							= NULL 
			,@intTransactionId						= @intTransactionId
			,@intTransactionDetailId				= @intTransactionDetailId
			,@strTransactionId						= @strTransactionId
			,@strBatchId							= @strBatchId
			,@intTransactionTypeId					= @INV_TRANS_TYPE_Cost_Adjustment 
			,@intLotId								= NULL  
			,@intRelatedInventoryTransactionId		= @intRelatedInventoryTransactionId 
			,@intRelatedTransactionId				= @intSourceTransactionId
			,@strRelatedTransactionId				= @strSourceTransactionId
			,@strTransactionForm					= @strTransactionForm
			,@intEntityUserSecurityId				= @intEntityUserSecurityId
			,@intCostingMethod						= @ACTUALCOST -- TODO: Double check the costing method. Make sure it matches with the SP. 
			,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
			,@intFobPointId							= @intFobPointId 
			,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
			,@intForexRateTypeId					= NULL
			,@dblForexRate							= 1
			,@strDescription						= @strDescription	
			,@strActualCostId						= @strActualCostId
			,@intSourceEntityId						= @intSourceEntityId 

		UPDATE	tblICInventoryTransaction 
		SET		ysnIsUnposted = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END 
			, dtmDateModified = GETUTCDATE()
		WHERE	intInventoryTransactionId = @InventoryTransactionIdentityId

		-- Update the log with correct inventory transaction id
		IF @InventoryTransactionIdentityId IS NOT NULL 
		BEGIN 
			UPDATE	tblICInventoryActualCostAdjustmentLog 
			SET		intInventoryTransactionId = @InventoryTransactionIdentityId
			WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
		END 
	END 
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
			ROUND(ISNULL(dblValue, 0), 2) 
			,strRelatedTransactionId
			,intRelatedTransactionId
			,intRelatedTransactionDetailId
			,intId
	FROM	tblICInventoryActualCostAdjustmentLog	
	WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
			AND intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost		

	OPEN loopCostAdjustmentLog
	FETCH NEXT FROM loopCostAdjustmentLog INTO 
		@CurrentCostAdjustment 
		,@strTransactionIdCostAdjLog
		,@intTransactionIdCostAdjLog
		,@intTransactionDetailIdCostAdjLog
		,@intCostAdjId

	WHILE @@FETCH_STATUS = 0 
	BEGIN
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
			,@dblValue								= @CurrentCostAdjustment
			,@dblSalesPrice							= 0
			,@intCurrencyId							= NULL 
			,@intTransactionId						= @intTransactionId
			,@intTransactionDetailId				= @intTransactionDetailId
			,@strTransactionId						= @strTransactionId
			,@strBatchId							= @strBatchId
			,@intTransactionTypeId					= @INV_TRANS_TYPE_Cost_Adjustment 
			,@intLotId								= NULL  
			,@intRelatedInventoryTransactionId		= @intRelatedInventoryTransactionId 
			,@intRelatedTransactionId				= @intTransactionIdCostAdjLog
			,@strRelatedTransactionId				= @strTransactionIdCostAdjLog
			,@strTransactionForm					= @strTransactionForm
			,@intEntityUserSecurityId				= @intEntityUserSecurityId
			,@intCostingMethod						= @ACTUALCOST -- TODO: Double check the costing method. Make sure it matches with the SP. 
			,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
			,@intFobPointId							= @intFobPointId 
			,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
			,@intForexRateTypeId					= NULL
			,@dblForexRate							= 1
			,@strDescription						= @strDescription	
			,@strActualCostId						= @strActualCostId
			,@intSourceEntityId						= @intSourceEntityId 
					   
		-- Update ysnIsUnposted flag. 
		BEGIN 
			UPDATE	tblICInventoryTransaction 
			SET		ysnIsUnposted = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END 
				, dtmDateModified = GETUTCDATE()
			WHERE	intInventoryTransactionId = @InventoryTransactionIdentityId
		END 

		-- Update the log with correct inventory transaction id
		IF @InventoryTransactionIdentityId IS NOT NULL 
		BEGIN 
			UPDATE	tblICInventoryActualCostAdjustmentLog 
			SET		intInventoryTransactionId = @InventoryTransactionIdentityId
			WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
					AND intId = @intCostAdjId
		END 

		FETCH NEXT FROM loopCostAdjustmentLog INTO 
			@CurrentCostAdjustment 
			,@strTransactionIdCostAdjLog
			,@intTransactionIdCostAdjLog
			,@intTransactionDetailIdCostAdjLog
			,@intCostAdjId
	END 

	CLOSE loopCostAdjustmentLog;
	DEALLOCATE loopCostAdjustmentLog;
END 

-- Update the last cost and standard cost. 
BEGIN 
	IF @ysnUpdateItemCostAndPrice = 1 AND @CostBucketId IS NOT NULL 
	BEGIN 
		UPDATE	p
		SET		p.dblLastCost = dbo.fnCalculateCostBetweenUOM(cb.intItemUOMId, stockUOM.intItemUOMId, cb.dblCost)
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
		FROM	tblICItemPricing p INNER JOIN tblICInventoryActualCost cb
					ON p.intItemId = cb.intItemId
					AND p.intItemLocationId = cb.intItemLocationId
				INNER JOIN tblICItemUOM stockUOM
					ON stockUOM.intItemId = p.intItemId
					AND stockUOM.ysnStockUnit = 1
		WHERE	cb.intInventoryActualCostId = @CostBucketId
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
