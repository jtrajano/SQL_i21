/*

*/
CREATE PROCEDURE [dbo].[uspICPostAdjustAvgCost]
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
			,@COST_ADJ_Adjust_Stock_Value AS INT = 3

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
			,@CurrentValue AS NUMERIC(38, 20)

			,@CostAdjustment AS NUMERIC(38, 20)			
			,@RetroactiveAverageCost AS NUMERIC(38, 20)

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
	SET @PreviousRunningQty = ISNULL(@RunningQty, 0) 

	SELECT	@RunningValue = SUM (
				ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0) 
			) 
	FROM	tblICInventoryTransaction t 
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.intInventoryTransactionId < @InventoryTransactionStartId

	SELECT @RetroactiveAverageCost = 
		CASE	WHEN @RunningQty > 0 THEN ISNULL(@RunningValue, 0) / @RunningQty
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
	SET @RetroactiveAverageCost = ISNULL(@RetroactiveAverageCost, 0) 			
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
	FROM	tblICInventoryTransaction t 
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId			
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND t.intInventoryTransactionId >= @InventoryTransactionStartId

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
	;

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @t_dblQty = ISNULL(@t_dblQty, 0)
		SET @t_dblCost = ISNULL(@t_dblCost, 0)
		SET @t_dblValue = ISNULL(@t_dblValue, 0) 
		SET @RunningValue = ISNULL(@RunningValue, 0) 
		SET @RunningQty = ISNULL(@RunningQty, 0) 
		SET @CurrentValue = ISNULL(@CurrentValue, 0) 

		-- Calculate the current value 
		SET @CurrentValue = @t_dblQty * @t_dblCost + @t_dblValue
		
		-- Calculate the Running Value. 
		SET @RunningValue += 
			CASE	WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
						@CurrentValue + @CostAdjustment
					WHEN @t_dblQty < 0 THEN 
						@t_dblQty * @RetroactiveAverageCost -- Reduce the stock using the retroactive avg cost. 
					ELSE 
						@CurrentValue
			END 

		-- Calculate the running qty. 
		SET @PreviousRunningQty = @RunningQty
		SET @RunningQty += dbo.fnCalculateQtyBetweenUOM(@t_intItemUOMId, @StockItemUOMId, @t_dblQty)

		-- Calculate the Average Cost 
		SET @RetroactiveAverageCost = 
			CASE	WHEN @t_dblQty > 0 AND @RunningQty > 0 THEN 
						@RunningValue / @RunningQty
					WHEN @t_dblQty > 0 AND @RunningQty <= 0 THEN 
						@t_dblQty * @t_dblCost / @t_dblQty
					ELSE 
						@RetroactiveAverageCost
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
			SET @EscalateCostAdjustment -= 
					(dbo.fnCalculateQtyBetweenUOM(@t_intItemUOMId, @StockItemUOMId, @t_dblQty) * @RetroactiveAverageCost)
					- (@t_dblQty * @t_dblCost)
			
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
					,[strActualCostId]				= CASE WHEN t.intCostingMethod = @ACTUALCOST THEN t.strTransactionId ELSE NULL END 
					,[intSourceTransactionId]		= t.intTransactionId
					,[intSourceTransactionDetailId]	= t.intTransactionDetailId
					,[strSourceTransactionId]		= t.strTransactionId
					,[intRelatedInventoryTransactionId] = t.intInventoryTransactionId	
					,[intFobPointId]				= t.intFobPointId
					,[intInTransitSourceLocationId]	= t.intInTransitSourceLocationId
			FROM	dbo.tblICInventoryTransaction t
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
				,[intCreatedUserId] 
				,[intCreatedEntityUserId] 
			)
			SELECT
				[intInventoryFIFOId] = @CostBucketId
				,[intInventoryTransactionId] = @DummyInventoryTransactionId 
				,[intInventoryCostAdjustmentTypeId] = @COST_ADJ_Adjust_Stock_Value
				,[dblQty] = NULL 
				,[dblCost] = NULL 
				,[dblValue] = 
					CASE	WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
								@CostAdjustment
							WHEN @t_dblQty < 0 THEN 
								(dbo.fnCalculateQtyBetweenUOM(@t_intItemUOMId, @StockItemUOMId, @t_dblQty) * @RetroactiveAverageCost)
								- (@t_dblQty * @t_dblCost)
							ELSE 
								0
					END 
				,[ysnIsUnposted]  = CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
				,[dtmCreated] = GETDATE()
				,[strRelatedTransactionId] = @strTransactionId 
				,[intRelatedTransactionId] = @intTransactionId
				,[intCreatedUserId] = @intEntityUserSecurityId
				,[intCreatedEntityUserId] = @intEntityUserSecurityId
			WHERE		
				CASE	WHEN @t_dblQty > 0 AND @t_intInventoryTransactionId = @InventoryTransactionStartId THEN 
							@CostAdjustment
						WHEN @t_dblQty < 0 THEN 
							(dbo.fnCalculateQtyBetweenUOM(@t_intItemUOMId, @StockItemUOMId, @t_dblQty) * @RetroactiveAverageCost)
							- (@t_dblQty * @t_dblCost)
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
		;		
	END 

	CLOSE loopRetroactive;
	DEALLOCATE loopRetroactive;
END 

-- Book the cost adjustment. 
BEGIN 
	-- Get the current valuation 
	SET @CurrentValue = NULL 
	SELECT	@CurrentValue = SUM(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0)) 
	FROM	tblICInventoryTransaction t
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 

	SET @strNewCost = CONVERT(NVARCHAR, CAST(@CostAdjustment AS MONEY), 1)

	SELECT	@strDescription = 'A value of ' + @strNewCost + ' is adjusted for ' + i.strItemNo + '. It is posted in ' + @strSourceTransactionId + '.'
	FROM	tblICItem i 
	WHERE	i.intItemId = @intItemId

	-- Calculate the cost adjustment. 
	SET @CostAdjustment = @RunningValue - @CurrentValue

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
		,@dblValue								= @CostAdjustment
		,@dblSalesPrice							= 0
		,@intCurrencyId							= NULL 
		,@intTransactionId						= @intTransactionId
		,@intTransactionDetailId				= @intTransactionDetailId
		,@strTransactionId						= @strTransactionId
		,@strBatchId							= @strBatchId
		,@intTransactionTypeId					= @intTransactionTypeId 
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
	SET		p.dblAverageCost = @RetroactiveAverageCost
			,p.ysnIsPendingUpdate = 1
	FROM	tblICItemPricing p
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND @RetroactiveAverageCost IS NOT NULL 

	-- Update the Item Pricing
	EXEC uspICUpdateItemPricing
		@intItemId
		,@intItemLocationId
END