/*

*/
CREATE PROCEDURE [dbo].[uspICPostAdjustRetroactiveAvgCost]
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
	,@strTransactionId AS NVARCHAR(20)
	,@intSourceTransactionId AS INT
	,@intSourceTransactionDetailId AS INT 
	,@strSourceTransactionId AS NVARCHAR(20)
	,@strBatchId AS NVARCHAR(20)
	,@intTransactionTypeId AS INT
	,@intEntityUserSecurityId AS INT
	,@intRelatedInventoryTransactionId AS INT = NULL 
	,@strTransactionForm AS NVARCHAR(50) = 'Bill'
	,@intFobPointId AS TINYINT = NULL
	,@intInTransitSourceLocationId AS INT = NULL  
	,@ysnPost AS BIT = 1 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
			,@COST_ADJ_TYPE_Adjust_InventoryAdjustment AS INT = 7

	-- Create the variables for the internal transaction types used by costing. 
	DECLARE
			@INV_TRANS_TYPE_Inventory_Receipt AS INT = 4
			,@INV_TRANS_TYPE_Inventory_Shipment AS INT = 5

			,@INV_TRANS_TYPE_Consume AS INT = 8
			,@INV_TRANS_TYPE_Produce AS INT = 9
			,@INV_TRANS_Inventory_Transfer AS INT = 12
			,@INV_TRANS_TYPE_ADJ_Item_Change AS INT = 15
			,@INV_TRANS_TYPE_ADJ_Split_Lot AS INT = 17
			,@INV_TRANS_TYPE_ADJ_Lot_Merge AS INT = 19
			,@INV_TRANS_TYPE_ADJ_Lot_Move AS INT = 20
			,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26

	DECLARE	@RunningQty AS NUMERIC(38, 20)
			,@NewRunningValue AS NUMERIC(38, 20)
			,@OriginalRunningValue AS NUMERIC(38, 20)
			,@CurrentValue AS NUMERIC(38, 20)

			,@CostAdjustment AS NUMERIC(38, 20)			
			,@OriginalAverageCost AS NUMERIC(38, 20)
			,@NewAverageCost AS NUMERIC(38, 20)

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

			,@EscalateInventoryTransactionId AS INT 
			,@EscalateInventoryTransactionTypeId AS INT 
			,@EscalateCostAdjustment AS NUMERIC(38, 20)

			,@InventoryTransactionIdentityId AS INT 

	DECLARE	@StockItemUOMId AS INT
			,@strDescription AS NVARCHAR(255)
			,@strNewCost AS NVARCHAR(50) 

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
		)
	END 
END 

-- Get the top cost bucket.
BEGIN 
	DECLARE @InventoryTransactionStartId AS INT
			,@CostBucketId AS INT  
			,@CostBucketOriginalCost AS NUMERIC(38, 20)
			,@CostBucketOriginalValue AS NUMERIC(38, 20) 

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
			@CostBucketId = cb.intInventoryFIFOId
			,@CostBucketOriginalCost = cb.dblCost
			,@CostBucketOriginalValue = ISNULL(cb.dblStockIn, 0) * ISNULL(cb.dblCost, 0)
	FROM	tblICInventoryFIFO cb
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
		
	-- Validate the cost bucket
	BEGIN 
		IF @InventoryTransactionStartId IS NULL
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

	SET @CostBucketOriginalValue = ISNULL(@CostBucketOriginalValue, 0) 
END 

-- Log the original cost
BEGIN 
	DECLARE @DummyInventoryTransactionId AS INT 
	SET @DummyInventoryTransactionId = -CAST(RAND() * 1000000 AS INT) 
	
	IF NOT EXISTS (
		SELECT	* 
		FROM	tblICInventoryFIFOCostAdjustmentLog cl
		WHERE	cl.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Original_Cost
				AND cl.intInventoryFIFOId = @CostBucketId
	)
	BEGIN 
		INSERT INTO tblICInventoryFIFOCostAdjustmentLog (
			[intInventoryFIFOId]
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
		)
		SELECT
			[intInventoryFIFOId] = cb.intInventoryFIFOId
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
		FROM tblICInventoryFIFO cb 
		WHERE	cb.intInventoryFIFOId = @CostBucketId
	END 
END 

-- Initialize the Running Qty (converted to stock UOM), Running Value, and Average Cost. 
BEGIN 	
	SELECT	@StockItemUOMId = dbo.fnGetItemStockUOM(@intItemId) 			

	SELECT	@RunningQty = SUM (
				dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, @StockItemUOMId, t.dblQty)
			) 
	FROM	tblICInventoryTransaction t INNER JOIN tblICItemUOM iUOM
				ON t.intItemUOMId = iUOM.intItemUOMId
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.intInventoryTransactionId < @InventoryTransactionStartId

	SET @RunningQty = ISNULL(@RunningQty, 0) 
	SELECT	@NewRunningValue = SUM (
				ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0) 
			) 
	FROM	tblICInventoryTransaction t 
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.intInventoryTransactionId < @InventoryTransactionStartId

	SELECT @NewAverageCost = 
		CASE	WHEN @RunningQty > 0 THEN ISNULL(@NewRunningValue, 0) / @RunningQty
				ELSE 
					(
						SELECT	TOP 1 
								dbo.fnCalculateCostBetweenUOM(t.intItemUOMId, @StockItemUOMId, t.dblCost) 								
						FROM	tblICInventoryTransaction t 
						WHERE	t.intItemId = @intItemId
								AND t.intItemLocationId = @intItemLocationId
								AND ISNULL(t.ysnIsUnposted, 0) = 0 
								AND t.intInventoryTransactionId < @InventoryTransactionStartId
								AND t.dblQty < 0 
						ORDER BY 
							t.intInventoryTransactionId DESC 
					)
		END 	
	SET @NewAverageCost = ISNULL(@NewAverageCost, 0) 			
	SET @OriginalAverageCost = @NewAverageCost 
END 

-- Loop to perform the retroactive computation
BEGIN 
	DECLARE loopRetroactive CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  t.intInventoryTransactionId
			,t.intItemId
			,t.intItemLocationId
			,t.intItemUOMId
			,t.dblQty
			,t.dblCost
			,t.dblValue
			,t.strTransactionId
			,t.intTransactionId
			,t.intTransactionDetailId
			,t.intTransactionTypeId
			,t.strBatchId 
			,il.intLocationId
	FROM	tblICInventoryTransaction t INNER JOIN tblICItemLocation il
				ON t.intItemLocationId = il.intItemLocationId
				AND t.intItemId = il.intItemId
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId			
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.intInventoryTransactionId >= @InventoryTransactionStartId
			AND t.intTransactionTypeId <> @INV_TRANS_TYPE_Cost_Adjustment
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
	;

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @t_dblQty = ISNULL(@t_dblQty, 0)
		SET @t_dblCost = ISNULL(@t_dblCost, 0)
		SET @t_dblValue = ISNULL(@t_dblValue, 0) 
		SET @NewRunningValue = ISNULL(@NewRunningValue, 0) 
		SET @OriginalRunningValue = ISNULL(@OriginalRunningValue, 0) 
		SET @RunningQty = ISNULL(@RunningQty, 0) 
		SET @CurrentValue = ISNULL(@CurrentValue, 0) 

		-- Calculate the current value 
		SET @CurrentValue = @t_dblQty * @t_dblCost + @t_dblValue
		
		-- Calcualte the New Running Value.
		SET @OriginalRunningValue += 
			CASE	WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
						@CostBucketOriginalValue
					WHEN @t_dblQty < 0 THEN 
						@t_dblQty * @OriginalAverageCost
					ELSE 
						@CurrentValue
			END 

		-- Calculate the New Running Value. 
		SET @NewRunningValue += 
			CASE	WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
						@CostBucketOriginalValue + @CostAdjustment
					WHEN @t_dblQty < 0 THEN 
						@t_dblQty * @NewAverageCost -- Reduce the stock using the new avg cost. 
					ELSE 
						@CurrentValue
			END 

		-- Calculate the running qty. 
		SET @RunningQty += dbo.fnCalculateQtyBetweenUOM(@t_intItemUOMId, @StockItemUOMId, @t_dblQty)

		-- Calculate the Original Average Cost 
		SET @OriginalAverageCost = 
			CASE	WHEN @t_dblQty > 0 AND @RunningQty > 0 THEN 
						@OriginalRunningValue / @RunningQty
					WHEN @t_dblQty > 0 AND @RunningQty <= 0 THEN 
						@t_dblQty * @CostBucketOriginalCost / @t_dblQty
					ELSE 
						@OriginalAverageCost
			END 		

		-- Calculate the New Average Cost 
		SET @NewAverageCost = 
			CASE	WHEN @t_dblQty > 0 AND @RunningQty > 0 THEN 
						@NewRunningValue / @RunningQty
					WHEN @t_dblQty > 0 AND @RunningQty <= 0 THEN 
						@t_dblQty * @CostBucketOriginalCost / @t_dblQty
					ELSE 
						@NewAverageCost
			END 

		-- Update the cost bucket cost. 
		IF @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId
		BEGIN 
			UPDATE	cb
			SET		cb.dblCost = (@CostBucketOriginalValue + @CostAdjustment) / cb.dblStockIn
			FROM	tblICInventoryFIFO cb
			WHERE	cb.intItemId = @intItemId
					AND cb.intInventoryFIFOId = @CostBucketId
					AND cb.dblStockIn <> 0 
		END

		-- Check if the system needs to escalate the cost adjustment. 
		SET @EscalateInventoryTransactionId = NULL 
		SELECT	TOP 1 
				@EscalateInventoryTransactionId = t.intInventoryTransactionId							
				,@EscalateInventoryTransactionTypeId = t.intTransactionTypeId
		FROM	dbo.tblICInventoryTransaction t
		WHERE	@t_dblQty < 0 
				AND t.strBatchId = @t_strBatchId 
				AND t.intTransactionId = @t_intTransactionId
				AND t.strTransactionId = @t_strTransactionId
				AND ISNULL(t.ysnIsUnposted, 0) = 0
				AND ISNULL(t.dblQty, 0) > 0 				
				AND 1 = 
					CASE WHEN t.intTransactionTypeId = @INV_TRANS_TYPE_Produce THEN 1 
						 WHEN t.intItemId = @t_intItemId AND t.intTransactionDetailId = @t_intTransactionDetailId THEN 1 
						 ELSE 0 
					END 

		IF @EscalateInventoryTransactionId IS NOT NULL 
		BEGIN 
			-- Calculate the value to be escalated. 
			SET @EscalateCostAdjustment = 0 
			SET @EscalateCostAdjustment -= (@t_dblQty * @NewAverageCost) - (@t_dblQty * @OriginalAverageCost)
			
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
					[intItemId]						= t.intItemId
					,[intItemLocationId]			= t.intItemLocationId
					,[intItemUOMId]					= t.intItemUOMId
					,[dtmDate]						= @dtmDate
					,[dblQty]						= t.dblQty
					,[dblUOMQty]					= t.dblUOMQty
					,[dblNewValue]					= @EscalateCostAdjustment
					,[intCurrencyId]				= t.intCurrencyId
					,[intTransactionId]				= @intTransactionId
					,[intTransactionDetailId]		= @intTransactionDetailId
					,[strTransactionId]				= @strTransactionId
					,[intTransactionTypeId]			= @EscalateInventoryTransactionTypeId
					,[intLotId]						= t.intLotId
					,[intSubLocationId]				= t.intSubLocationId
					,[intStorageLocationId]			= t.intStorageLocationId
					,[ysnIsStorage]					= NULL 
					,[strActualCostId]				= actualCostCb.strActualCostId 
					,[intSourceTransactionId]		= t.intTransactionId
					,[intSourceTransactionDetailId]	= t.intTransactionDetailId
					,[strSourceTransactionId]		= t.strTransactionId
					,[intRelatedInventoryTransactionId] = t.intInventoryTransactionId	
					,[intFobPointId]				= t.intFobPointId
					,[intInTransitSourceLocationId]	= t.intInTransitSourceLocationId
			FROM	dbo.tblICInventoryTransaction t LEFT JOIN tblICInventoryActualCost actualCostCb
						ON actualCostCb.strTransactionId = t.strTransactionId
						AND actualCostCb.intTransactionId = t.intTransactionId
						AND actualCostCb.intTransactionDetailId = t.intTransactionDetailId
						AND actualCostCb.intItemId = t.intItemId
						AND actualCostCb.intItemLocationId = t.intItemLocationId
						AND t.intCostingMethod = @ACTUALCOST
						AND actualCostCb.ysnIsUnposted = 0 
			WHERE	intInventoryTransactionId = @EscalateInventoryTransactionId
		END 

		-- Log the cost adjustment 
		BEGIN 
			INSERT INTO tblICInventoryFIFOCostAdjustmentLog (
				[intInventoryFIFOId]
				,[intInventoryTransactionId] 
				,[intInventoryCostAdjustmentTypeId] 
				,[dblQty] 
				,[dblCost] 
				,[dblValue] 
				,[ysnIsUnposted] 
				,[dtmCreated] 
				,[strRelatedTransactionId] 
				,[intRelatedTransactionId] 
				,[intRelatedInventoryTransactionId]
				,[intCreatedUserId] 
				,[intCreatedEntityUserId] 
			)
			SELECT
				[intInventoryFIFOId] = @CostBucketId
				,[intInventoryTransactionId] = @DummyInventoryTransactionId 
				,[intInventoryCostAdjustmentTypeId] = 
						CASE	WHEN @t_dblQty > 0 THEN 
									CASE	WHEN @t_intTransactionTypeId = @InventoryTransactionStartId THEN 
												@COST_ADJ_TYPE_Adjust_Value
											WHEN @t_intTransactionTypeId = @INV_TRANS_TYPE_Produce THEN 
												@COST_ADJ_TYPE_Adjust_WIP
											WHEN @t_intLocationId IS NULL THEN 
												@COST_ADJ_TYPE_Adjust_InTransit
											WHEN @t_intTransactionTypeId IN (
													@INV_TRANS_TYPE_ADJ_Item_Change
													,@INV_TRANS_TYPE_ADJ_Split_Lot
													,@INV_TRANS_TYPE_ADJ_Lot_Merge
													,@INV_TRANS_TYPE_ADJ_Lot_Move
												) THEN 
													@COST_ADJ_TYPE_Adjust_InventoryAdjustment
											ELSE 
												@COST_ADJ_TYPE_Adjust_Value
									END 
								WHEN @t_dblQty < 0 THEN 
									CASE	WHEN @t_intTransactionTypeId = @INV_TRANS_TYPE_Consume THEN 
												@COST_ADJ_TYPE_Adjust_WIP
											WHEN @t_intLocationId IS NULL THEN 
												@COST_ADJ_TYPE_Adjust_InTransit
											WHEN @EscalateInventoryTransactionTypeId = @INV_TRANS_TYPE_Inventory_Shipment THEN 
												@COST_ADJ_TYPE_Adjust_InTransit	
											WHEN @t_intTransactionTypeId IN (
													@INV_TRANS_TYPE_ADJ_Item_Change
													,@INV_TRANS_TYPE_ADJ_Split_Lot
													,@INV_TRANS_TYPE_ADJ_Lot_Merge
													,@INV_TRANS_TYPE_ADJ_Lot_Move
												) THEN 
													@COST_ADJ_TYPE_Adjust_InventoryAdjustment
											ELSE 
												@COST_ADJ_TYPE_Adjust_Sold
									END 
						END 
				,[dblQty] = NULL 
				,[dblCost] = NULL 
				,[dblValue] = 
					CASE	WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
								@CostAdjustment
							WHEN @t_dblQty < 0 THEN 
								(@t_dblQty * @NewAverageCost) - (@t_dblQty * @OriginalAverageCost)
							ELSE 
								0
					END 
				,[ysnIsUnposted]  = CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
				,[dtmCreated] = GETDATE()
				,[strRelatedTransactionId] = @t_strTransactionId 
				,[intRelatedTransactionId] = @t_intTransactionId
				,[intRelatedInventoryTransactionId] = @t_intInventoryTransactionId
				,[intCreatedUserId] = @intEntityUserSecurityId
				,[intCreatedEntityUserId] = @intEntityUserSecurityId
			WHERE		
				CASE	WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
							@CostAdjustment
						WHEN @t_dblQty < 0 THEN 
							(@t_dblQty * @NewAverageCost) - (@t_dblQty * @OriginalAverageCost)
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
		;		
	END 

	CLOSE loopRetroactive;
	DEALLOCATE loopRetroactive;
END 

-- Book the cost adjustment. 
BEGIN 
	SET @strNewCost = CONVERT(NVARCHAR, CAST(@CostAdjustment AS MONEY), 1)

	SELECT	@strDescription = 'A value of ' + @strNewCost + ' is adjusted for ' + i.strItemNo + '. It is posted in ' + @strSourceTransactionId + '.'
	FROM	tblICItem i 
	WHERE	i.intItemId = @intItemId

	-- Calculate the value to book. 
	-- Formula: (New Running Value) - (Original Running Value)
	SET @CurrentValue = NULL 
	SELECT	@CurrentValue = 
				ISNULL(@NewRunningValue, 0) 
				- SUM(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0)) 
	FROM	tblICInventoryTransaction t
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 

	-- Create the 'Cost Adjustment' inventory transaction. 
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
		,@dblValue								= @CurrentValue
		,@dblSalesPrice							= 0
		,@intCurrencyId							= NULL 
		,@intTransactionId						= @intTransactionId
		,@intTransactionDetailId				= @intTransactionDetailId
		,@strTransactionId						= @strTransactionId
		,@strBatchId							= @strBatchId
		,@intTransactionTypeId					= @INV_TRANS_TYPE_Cost_Adjustment 
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

		UPDATE	tblICInventoryTransaction 
		SET		ysnIsUnposted = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END 
		WHERE	intInventoryTransactionId = @InventoryTransactionIdentityId
END 

-- Update the log with correct inventory transaction id
BEGIN 
	UPDATE	tblICInventoryFIFOCostAdjustmentLog 
	SET		intInventoryTransactionId = @InventoryTransactionIdentityId
	WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
END 

-- Update the average cost
BEGIN 
	UPDATE	p
	SET		p.dblAverageCost = @NewAverageCost
	FROM	tblICItemPricing p 
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND @NewAverageCost IS NOT NULL 
END
