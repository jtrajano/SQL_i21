CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentCurrentAvg]
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
	,@ysnPost AS BIT = 1 
	,@intOtherChargeItemId AS INT = NULL
	,@ysnUpdateItemCostAndPrice AS BIT = 0 
	,@IsEscalate AS BIT = 0 
	,@intSourceEntityId AS INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @isStockRebuilding AS BIT 

IF OBJECT_ID('tempdb..#tmpAutoVarianceBatchesForAVGCosting') IS NULL  
BEGIN
	SET @isStockRebuilding = 0

	CREATE TABLE #tmpAutoVarianceBatchesForAVGCosting (
		intItemId INT
		,intItemLocationId INT
		,strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	)
END
ELSE 
BEGIN 
	SET @isStockRebuilding = 1 
END 

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
			@INV_TRANS_TYPE_Inventory_Auto_Variance AS INT = 1
			,@INV_TRANS_TYPE_Inventory_Receipt AS INT = 4
			,@INV_TRANS_TYPE_Inventory_Shipment AS INT = 5
			,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26


	---- Create the variables for the internal transaction types used by costing. 
	--DECLARE
	--		@INV_TRANS_TYPE_Inventory_Receipt AS INT = 4
	--		,@INV_TRANS_TYPE_Inventory_Shipment AS INT = 5

	--		,@INV_TRANS_TYPE_Consume AS INT = 8
	--		,@INV_TRANS_TYPE_Produce AS INT = 9
	--		,@INV_TRANS_Inventory_Transfer AS INT = 12
 --           ,@INV_TRANS_Inventory_Transfer_With_Shipment AS INT = 13
	--		,@INV_TRANS_TYPE_ADJ_Item_Change AS INT = 15
	--		,@INV_TRANS_TYPE_ADJ_Split_Lot AS INT = 17
	--		,@INV_TRANS_TYPE_ADJ_Lot_Merge AS INT = 19
	--		,@INV_TRANS_TYPE_ADJ_Lot_Move AS INT = 20
	
	--		,@INV_TRANS_TYPE_Invoice AS INT = 33
	--		,@INV_TRANS_TYPE_NegativeStock AS INT = 35

	DECLARE	
			@RunningQty AS NUMERIC(38, 20)
			,@OriginalAverageCost AS NUMERIC(38, 20)
			,@NewAverageCost AS NUMERIC(38, 20)
			,@CostAdjustment AS NUMERIC(38, 20)
			,@CostAdjustmentPerCb AS NUMERIC(38, 20) 
			,@CurrentCostAdjustment AS NUMERIC(38, 20)
			,@CostBucketNewCost AS NUMERIC(38, 20)			
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
			,@t_NegativeStockCost AS NUMERIC(38, 20)
			,@t_NegativeStockStrBatchId AS NVARCHAR(50) 
			,@t_NegativeStockIntTransactionId AS INT 
			,@t_NegativeStockStrTransactionId AS NVARCHAR(50)
			,@t_NegativeStockIntTransactionDetailId AS INT

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

	DECLARE @intInventoryTransactionIdentityId AS INT
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
			@t_intInventoryTransactionId = t.intInventoryTransactionId 
			,@t_intTransactionId = t.intTransactionId
			,@t_strTransactionId = t.strTransactionId
			,@t_intTransactionDetailId = t.intTransactionDetailId

	FROM	tblICInventoryTransaction t
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND t.intTransactionId = @intSourceTransactionId
			AND ISNULL(t.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND t.strTransactionId = @strSourceTransactionId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 

	SELECT	TOP 1 
			@CostBucketId = cb.intInventoryFIFOId
			,@CostBucketOriginalStockIn = cb.dblStockIn
			,@CostBucketOriginalCost = cb.dblCost
			,@CostBucketOriginalValue = ROUND(dbo.fnMultiply(cb.dblStockIn, cb.dblCost), 2) 
			,@CostBucketDate = cb.dtmDate
	FROM	tblICInventoryFIFO cb
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
		
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

---- Create the list of Inventory Transaction related to the cost bucket.
--BEGIN 
--	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpRetroactiveTransactions')) 
--	BEGIN 
--		CREATE TABLE #tmpRetroactiveTransactions (
--			[intInventoryTransactionId] INT PRIMARY KEY CLUSTERED
--			,[intSort] INT 
--		)
--	END 

--	DELETE FROM #tmpRetroactiveTransactions
--	INSERT INTO #tmpRetroactiveTransactions (
--		intInventoryTransactionId
--		,intSort
--	)
--	-- Self: 
--	SELECT	@InventoryTransactionStartId 
--			,1
--	WHERE	@InventoryTransactionStartId IS NOT NULL 
--	---- Negative Stocks 
--	--UNION ALL 
--	--SELECT	DISTINCT 
--	--		-cbOut.intInventoryTransactionId
--	--		,2 
--	--FROM	tblICInventoryFIFOOut cbOut 
--	--WHERE	cbOut.intInventoryFIFOId = @CostBucketId			
--	--		AND cbOut.intRevalueFifoId IS NOT NULL 
--	---- Cost Bucket Out: 
--	--UNION ALL 
--	--SELECT	cbOut.intInventoryTransactionId
--	--		,3
--	--FROM	tblICInventoryFIFOOut cbOut
--	--WHERE	cbOut.intInventoryFIFOId = @CostBucketId			
--	--		AND cbOut.intRevalueFifoId IS NULL 			
--END 

-- Calculate how much cost adjustment goes for each qty. 
BEGIN 
	SELECT	@CostAdjustmentPerCb = dbo.fnDivide(@CostAdjustment, SUM(ISNULL(cb.dblStockIn, 0))) 
	FROM	tblICInventoryFIFO cb
	WHERE	cb.intItemId = @intItemId
			AND cb.intItemLocationId = @intItemLocationId
			AND cb.intTransactionId = @intSourceTransactionId
			AND ISNULL(cb.intTransactionDetailId, 0) = ISNULL(@intSourceTransactionDetailId, 0)
			AND cb.strTransactionId = @strSourceTransactionId
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 

	-- If value of cost adjustment is zero, then exit immediately. 
	IF @CostAdjustmentPerCb IS NULL 
		RETURN; 
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
			,[intOtherChargeItemId] 
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
			,[intOtherChargeItemId] = @intOtherChargeItemId 
		FROM tblICInventoryFIFO cb 
		WHERE	cb.intInventoryFIFOId = @CostBucketId
	END 
END 

-- Process the cost adjustment. 
BEGIN
	-- Update the cost bucket cost. 
	BEGIN 
		-- Validate if the cost is going to be negative. 
		IF (@CostBucketOriginalValue + @CostAdjustment) < 0 
		BEGIN 
			SELECT	@strItemNo = CASE WHEN ISNULL(strItemNo, '') = '' THEN 'id: ' + CAST(@intItemId AS NVARCHAR(20)) ELSE strItemNo END 
			FROM	tblICItem 
			WHERE	intItemId = @intItemId

			-- '{Item} will have a negative cost. Negative cost is not allowed.'
			EXEC uspICRaiseError 80196, @strItemNo
			RETURN -80196;
		END 

		-- Update the cost bucket cost. 
		UPDATE	cb
		SET		cb.dblCost = 
					dbo.fnDivide(
						(@CostBucketOriginalValue + @CostAdjustment) 
						,cb.dblStockIn 
					) 
		FROM	tblICInventoryFIFO cb
		WHERE	cb.intItemId = @intItemId
				AND cb.intInventoryFIFOId = @CostBucketId
				AND cb.dblStockIn <> 0 
	END		

	-- Get the running qty 
	SELECT	@StockItemUOMId = dbo.fnGetItemStockUOM(@intItemId)
	SELECT	@RunningQty = SUM (
				dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, @StockItemUOMId, t.dblQty)
			) 
	FROM	tblICInventoryTransaction t INNER JOIN tblICItemUOM iUOM
				ON t.intItemUOMId = iUOM.intItemUOMId
			LEFT JOIN tblICCostingMethod c
				ON t.intCostingMethod = c.intCostingMethodId
	WHERE	t.intItemId = @intItemId
			AND t.intItemLocationId = @intItemLocationId
			AND ISNULL(t.ysnIsUnposted, 0) = 0 
			AND (c.strCostingMethod <> 'ACTUAL COST' OR t.strActualCostId IS NULL)

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
			,[intRelatedTransactionDetailId]
			,[intRelatedInventoryTransactionId]
			,[intCreatedUserId] 
			,[intCreatedEntityUserId] 
			,[intOtherChargeItemId] 
		)
		SELECT
			[intInventoryFIFOId] = @CostBucketId
			,[intInventoryTransactionId] = @DummyInventoryTransactionId 
			,[intInventoryCostAdjustmentTypeId] = @COST_ADJ_TYPE_Adjust_Value						
			,[dblQty] = NULL 
			,[dblCost] = NULL 
			,[dblValue] = @CostAdjustment
			,[ysnIsUnposted]  = CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
			,[dtmCreated] = GETDATE()
			,[strRelatedTransactionId] = @t_strTransactionId 
			,[intRelatedTransactionId] = @t_intTransactionId
			,[intRelatedTransactionDetailId] = @t_intTransactionDetailId
			,[intRelatedInventoryTransactionId] = @t_intInventoryTransactionId
			,[intCreatedUserId] = @intEntityUserSecurityId
			,[intCreatedEntityUserId] = @intEntityUserSecurityId
			,[intOtherChargeItemId] = @intOtherChargeItemId 
	END 

	-- Log it as sold if Running Qty is zero.
	IF ISNULL(ROUND(@RunningQty, 2), 0) = 0 
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
			,[intRelatedTransactionDetailId]
			,[intRelatedInventoryTransactionId]
			,[intCreatedUserId] 
			,[intCreatedEntityUserId] 
			,[intOtherChargeItemId] 
		)
		SELECT
			[intInventoryFIFOId] = @CostBucketId
			,[intInventoryTransactionId] = @DummyInventoryTransactionId 
			,[intInventoryCostAdjustmentTypeId] = @COST_ADJ_TYPE_Adjust_Sold						
			,[dblQty] = NULL 
			,[dblCost] = NULL 
			,[dblValue] = -@CostAdjustment
			,[ysnIsUnposted]  = CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
			,[dtmCreated] = GETDATE()
			,[strRelatedTransactionId] = @t_strTransactionId 
			,[intRelatedTransactionId] = @t_intTransactionId
			,[intRelatedTransactionDetailId] = @t_intTransactionDetailId
			,[intRelatedInventoryTransactionId] = @t_intInventoryTransactionId
			,[intCreatedUserId] = @intEntityUserSecurityId
			,[intCreatedEntityUserId] = @intEntityUserSecurityId
			,[intOtherChargeItemId] = @intOtherChargeItemId 
	END 
END 

-- Book the cost adjustment. 
BEGIN 

	SET 	@CurrentCostAdjustment = NULL 
	SELECT	@CurrentCostAdjustment = SUM(ROUND(ISNULL(dblValue, 0), 2)) 
	FROM	tblICInventoryFIFOCostAdjustmentLog	
	WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
			AND intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost

	SET @strNewCost = CONVERT(NVARCHAR, CAST(ISNULL(@CostAdjustment, 0) AS MONEY), 1)

	SELECT	@strDescription = 'A value of ' + @strNewCost + ' is adjusted for ' + i.strItemNo + '. It is posted in ' + @strSourceTransactionId + '.'
	FROM	tblICItem i 
	WHERE	i.intItemId = @intItemId

	-- Create the 'Cost Adjustment' inventory transaction. 
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
			,@intCostingMethod						= @AVERAGECOST -- TODO: Double check the costing method. Make sure it matches with the SP. 
			,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
			,@intFobPointId							= @intFobPointId 
			,@intInTransitSourceLocationId			= @intInTransitSourceLocationId
			,@intForexRateTypeId					= NULL
			,@dblForexRate							= 1
			,@strDescription						= @strDescription	
			,@intSourceEntityId						= @intSourceEntityId

			UPDATE	tblICInventoryTransaction 
			SET		ysnIsUnposted = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END 
					, dtmDateModified = GETUTCDATE()
			WHERE	intInventoryTransactionId = @InventoryTransactionIdentityId

			-- Update the log with correct inventory transaction id
			IF @InventoryTransactionIdentityId IS NOT NULL 
			BEGIN 
				UPDATE	tblICInventoryFIFOCostAdjustmentLog 
				SET		intInventoryTransactionId = @InventoryTransactionIdentityId
				WHERE	intInventoryTransactionId = @DummyInventoryTransactionId
			END 
	END
END 

-- Compute the new average cost
BEGIN 
	SELECT @OriginalAverageCost = dblAverageCost
	FROM 
		tblICItemPricing
	WHERE
		intItemId = @intItemId
		AND intItemLocationId = @intItemLocationId

	SET @NewAverageCost = 
			dbo.fnDivide(
				dbo.fnMultiply(@OriginalAverageCost, @RunningQty) + @CurrentCostAdjustment
				,ROUND(@RunningQty, 2) 
			) 

	UPDATE	p
	SET		p.dblAverageCost = @NewAverageCost
			,p.ysnIsPendingUpdate = 1
	FROM	tblICItemPricing p 
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND @NewAverageCost IS NOT NULL 
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
		FROM	tblICItemPricing p INNER JOIN tblICInventoryFIFO cb
					ON p.intItemId = cb.intItemId
					AND p.intItemLocationId = cb.intItemLocationId
				INNER JOIN tblICItemUOM stockUOM
					ON stockUOM.intItemId = p.intItemId
					AND stockUOM.ysnStockUnit = 1
		WHERE	cb.intInventoryFIFOId = @CostBucketId
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


-- Create the auto-variance. 
IF dbo.fnGetCostingMethod(@intItemId, @intItemLocationId) = @AVERAGECOST 
BEGIN 
	INSERT INTO dbo.tblICInventoryTransaction (
				[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[dtmDate]
				,[dblQty]
				,[dblUOMQty]
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[strTransactionId]
				,[strBatchId]
				,[intTransactionTypeId]
				,[intLotId]
				,[ysnIsUnposted]
				,[intRelatedInventoryTransactionId]
				,[intRelatedTransactionId]
				,[strRelatedTransactionId]
				,[strTransactionForm]
				,[dtmCreated]
				,[intCreatedEntityId]
				,[intConcurrencyId]
				,[intCostingMethod]
				,[strDescription]
				,[intForexRateTypeId]
				,[dblForexRate]
				,[dtmDateCreated]
				,[dblComputedValue]
		)			
	SELECT	
			[intItemId]								= @intItemId
			,[intItemLocationId]					= @intItemLocationId
			,[intItemUOMId]							= NULL 
			,[intSubLocationId]						= NULL 
			,[intStorageLocationId]					= NULL 
			,[dtmDate]								= @dtmDate
			,[dblQty]								= 0
			,[dblUOMQty]							= 0
			,[dblCost]								= 0
			,[dblValue]								= 
					dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) 
					- dbo.fnGetItemTotalValueFromAVGTransactions(@intItemId, @intItemLocationId)
			,[dblSalesPrice]						= 0
			,[intCurrencyId]						= NULL
			,[dblExchangeRate]						= 1 
			,[intTransactionId]						= @intTransactionId
			,[strTransactionId]						= @strTransactionId
			,[strBatchId]							= @strBatchId
			,[intTransactionTypeId]					= @INV_TRANS_TYPE_Inventory_Auto_Variance
			,[intLotId]								= NULL 
			,[ysnIsUnposted]						= 0
			,[intRelatedInventoryTransactionId]		= NULL 
			,[intRelatedTransactionId]				= NULL 
			,[strRelatedTransactionId]				= NULL 
			,[strTransactionForm]					= @strTransactionForm
			,[dtmCreated]							= GETDATE()
			,[intCreatedEntityId]					= @intEntityUserSecurityId
			,[intConcurrencyId]						= 1
			,[intCostingMethod]						= @AVERAGECOST
			,[strDescription]						= -- Inventory variance is created. The current item valuation is %s. The new valuation is (Qty x New Average Cost) %s x %s = %s. 
														dbo.fnFormatMessage(
														dbo.fnICGetErrorMessage(80078)
														,dbo.fnGetItemTotalValueFromAVGTransactions(@intItemId, @intItemLocationId)
														,Stock.dblUnitOnHand
														,ItemPricing.dblAverageCost
														,(Stock.dblUnitOnHand * ItemPricing.dblAverageCost)
														, DEFAULT
														, DEFAULT
														, DEFAULT
														, DEFAULT
														, DEFAULT
														, DEFAULT
													)
			,[intForexRateTypeId]					= NULL 
			,[dblForexRate]							= 1 
			,[dtmDateCreated]						= GETUTCDATE()
			,[dblComputedValue]						= 
					dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) 
					- dbo.fnGetItemTotalValueFromAVGTransactions(@intItemId, @intItemLocationId)
	FROM	dbo.tblICItemPricing AS ItemPricing INNER JOIN dbo.tblICItemStock AS Stock 
				ON ItemPricing.intItemId = Stock.intItemId
				AND ItemPricing.intItemLocationId = Stock.intItemLocationId
			CROSS APPLY (
				SELECT 
					TOP 1
					intItemId = @intItemId
					,intItemLocationId = @intItemLocationId
				FROM 
					#tmpAutoVarianceBatchesForAVGCosting tmp
				WHERE
					1 = 
						CASE 
							WHEN @isStockRebuilding = 0 THEN 
								1
							WHEN 
								@isStockRebuilding = 1 
								AND tmp.intItemId = @intItemId
								AND tmp.intItemLocationId = @intItemLocationId
								AND tmp.strTransactionId = @strTransactionId
								AND tmp.strBatchId = @strBatchId							
							THEN 
								1							
							ELSE 
								0
						END 
			) allowAutoVariance 
	WHERE	ItemPricing.intItemId = @intItemId
			AND ItemPricing.intItemLocationId = @intItemLocationId			
			AND ROUND(dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromAVGTransactions(@intItemId, @intItemLocationId), 2) <> 0

	SET @intInventoryTransactionIdentityId = SCOPE_IDENTITY();

	-----------------------------------------
	-- Log the Daily Stock Quantity
	-----------------------------------------
	IF @intInventoryTransactionIdentityId IS NOT NULL 
	BEGIN 
		EXEC uspICPostStockDailyQuantity 
			@intInventoryTransactionId = @intInventoryTransactionIdentityId
	END 
			
END

