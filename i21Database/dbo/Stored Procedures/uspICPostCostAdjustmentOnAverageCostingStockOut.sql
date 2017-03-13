/*
	
*/
CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentOnAverageCostingStockOut]
	@intInventoryTransactionId AS INT 
	,@AdjustCost AS NUMERIC(38,20)
	,@AdjustDate AS DATETIME 
	,@strVoucherId AS NVARCHAR(50)
	,@intVoucherId AS INT 
	,@intVoucherDetailId AS INT 
	,@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @intInventoryTransactionId IS NULL OR @AdjustCost IS NULL 
	GOTO _Exit; 
	
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
		,[intLotId] INT NULL									-- Place holder field for average cost
		,[intSubLocationId] INT NULL							-- Place holder field for average cost
		,[intStorageLocationId] INT NULL						-- Place holder field for average cost
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

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4 	
		,@ACTUALCOST AS INT = 5	

		,@FOB_ORIGIN AS TINYINT = 1
		,@FOB_DESTINATION AS TINYINT = 2

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

DECLARE	@tOut_intInventoryTransactionId AS INT
		,@tOut_intItemId AS INT 
		,@tOut_intItemUOMId AS INT 
		,@tOut_intItemLocationId AS INT
		,@tOut_intSubLocationId AS INT
		,@tOut_intStorageLocationId AS INT
		,@tOut_dblQty AS NUMERIC(38, 20)
		,@tOut_dblUOMQty AS NUMERIC(38, 20)
		,@tOut_dblCost AS NUMERIC(38, 20)
		,@tOut_dblValue AS NUMERIC(38, 20)
		,@tOut_intCurrencyId AS INT
		,@tOut_dblExchangeRate AS NUMERIC(38,20)
		,@tOut_strTransactionId AS NVARCHAR(50)
		,@tOut_intTransactionId AS INT 
		,@tOut_intTransactionDetailId AS INT
		,@tOut_strTransactionType AS NVARCHAR(200)
		,@tOut_intTransactionType AS INT
		,@tOut_strBatchId AS NVARCHAR(20)
		,@tOut_strTransactionForm AS NVARCHAR(200) 
		,@tOut_intFobPointId AS INT 
		,@tOut_intInTransitSourceLocationId AS INT 

		,@InvAdjustValue AS NUMERIC(38, 20)
		,@InventoryTransactionIdentityId AS INT 
		,@intInventoryTransactionEscalateId AS INT 

DECLARE @LoopTransactionTypeId AS INT 
		,@CostAdjustmentTransactionType AS INT -- = @intTransactionTypeId		
		,@strNewCost AS NVARCHAR(50) 
		,@strDescription AS NVARCHAR(255) 

SELECT  @tOut_intInventoryTransactionId = t.intInventoryTransactionId
		,@tOut_intItemId = t.intItemId 
		,@tOut_intItemUOMId = t.intItemUOMId 
		,@tOut_intItemLocationId = t.intItemLocationId
		,@tOut_intSubLocationId = t.intSubLocationId
		,@tOut_intStorageLocationId = t.intStorageLocationId 
		,@tOut_dblQty = t.dblQty
		,@tOut_dblUOMQty = t.dblUOMQty
		,@tOut_dblCost = t.dblCost
		,@tOut_dblValue = t.dblValue
		,@tOut_intCurrencyId = t.intCurrencyId
		,@tOut_dblExchangeRate = t.dblExchangeRate
		,@tOut_strTransactionId = t.strTransactionId 
		,@tOut_intTransactionId = t.intTransactionId
		,@tOut_intTransactionDetailId = t.intTransactionDetailId
		,@tOut_strTransactionType = ty.strName 
		,@tOut_intTransactionType = t.intTransactionTypeId  
		,@tOut_strTransactionForm = t.strTransactionForm
		,@tOut_strBatchId = t.strBatchId
		,@tOut_intFobPointId = t.intFobPointId
		,@tOut_intInTransitSourceLocationId = t.intInTransitSourceLocationId
FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
			ON ty.intTransactionTypeId = t.intTransactionTypeId 
WHERE	t.intInventoryTransactionId = @intInventoryTransactionId
		AND ISNULL(t.ysnIsUnposted, 0) = 0 

BEGIN 
	
	-- Calculate the Inv Adjust value.  
	SET @InvAdjustValue = dbo.fnMultiply(@AdjustCost, @tOut_dblQty) 

	SET @strNewCost = CONVERT(NVARCHAR, CAST(@InvAdjustValue AS MONEY), 1)
	SELECT	@strDescription = 'A value of ' + @strNewCost + ' is adjusted for ' + i.strItemNo + '. It is posted in ' + @tOut_strTransactionId + '.'
	FROM	tblICItem i 
	WHERE	i.intItemId = @tOut_intItemId

	---------------------------------------------------------------------------
	-- If stock was shipped or reduced from adj, then do the "Revalue Sold". 
	---------------------------------------------------------------------------
	IF	@tOut_intTransactionType NOT IN (
			@INV_TRANS_TYPE_Consume
			, @INV_TRANS_TYPE_Build_Assembly
			, @INV_TRANS_Inventory_Transfer
			, @INV_TRANS_TYPE_ADJ_Item_Change
			, @INV_TRANS_TYPE_ADJ_Split_Lot
			, @INV_TRANS_TYPE_ADJ_Lot_Merge
			, @INV_TRANS_TYPE_ADJ_Lot_Move
			, @INV_TRANS_TYPE_Inventory_Shipment
		)
		AND @InvAdjustValue <> 0 
	BEGIN 
		EXEC [dbo].[uspICPostInventoryTransaction]
			@intItemId								= @tOut_intItemId 
			,@intItemLocationId						= @tOut_intItemLocationId
			,@intItemUOMId							= @tOut_intItemUOMId
			,@intSubLocationId						= @tOut_intSubLocationId
			,@intStorageLocationId					= @tOut_intStorageLocationId 
			,@dtmDate								= @AdjustDate
			,@dblQty								= 0
			,@dblUOMQty								= 0
			,@dblCost								= 0
			,@dblValue								= @InvAdjustValue
			,@dblSalesPrice							= 0
			,@intCurrencyId							= @tOut_intCurrencyId
			--,@dblExchangeRate						= @tOut_dblExchangeRate
			,@intTransactionId						= @intVoucherId
			,@intTransactionDetailId				= @intVoucherDetailId 
			,@strTransactionId						= @strVoucherId
			,@strBatchId							= @strBatchId
			,@intTransactionTypeId					= @INV_TRANS_TYPE_Revalue_Sold
			,@intLotId								= NULL  
			,@intRelatedInventoryTransactionId		= @tOut_intInventoryTransactionId
			,@intRelatedTransactionId				= @tOut_intTransactionId
			,@strRelatedTransactionId				= @tOut_strTransactionId
			,@strTransactionForm					= @tOut_strTransactionForm
			,@intEntityUserSecurityId				= @intEntityUserSecurityId
			,@intCostingMethod						= @AVERAGECOST
			,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
			,@intFobPointId							= @tOut_intFobPointId 
			,@intInTransitSourceLocationId			= @tOut_intInTransitSourceLocationId 
			,@intForexRateTypeId					= NULL
			,@dblForexRate							= 1
			,@strDescription						= @strDescription		
	END 

	---------------------------------------------------------------------------
	-- 8. If stock was consumed in a production, transfer, or lot adjustment
	---------------------------------------------------------------------------
	ELSE IF @tOut_intTransactionType IN (
				@INV_TRANS_TYPE_Consume
				, @INV_TRANS_TYPE_Build_Assembly
				, @INV_TRANS_Inventory_Transfer
				, @INV_TRANS_TYPE_ADJ_Item_Change
				, @INV_TRANS_TYPE_ADJ_Split_Lot
				, @INV_TRANS_TYPE_ADJ_Lot_Merge
				, @INV_TRANS_TYPE_ADJ_Lot_Move
				, @INV_TRANS_TYPE_Inventory_Shipment						
			)
			AND @InvAdjustValue <> 0 
	BEGIN 
		SELECT	@CostAdjustmentTransactionType 
					= CASE	WHEN @tOut_intTransactionType = @INV_TRANS_Inventory_Transfer	THEN @INV_TRANS_TYPE_Revalue_Transfer
							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_Consume			THEN @INV_TRANS_TYPE_Revalue_WIP
							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_Build_Assembly	THEN @INV_TRANS_TYPE_Revalue_Build_Assembly

							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_ADJ_Item_Change	THEN @INV_TRANS_TYPE_Revalue_Item_Change
							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_ADJ_Lot_Merge	THEN @INV_TRANS_TYPE_Revalue_Lot_Merge
							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_ADJ_Lot_Move	THEN @INV_TRANS_TYPE_Revalue_Lot_Move
							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_ADJ_Split_Lot	THEN @INV_TRANS_TYPE_Revalue_Split_Lot									

							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_Inventory_Shipment THEN @INV_TRANS_TYPE_Revalue_Shipment

					END
				,@LoopTransactionTypeId
					= CASE	WHEN @tOut_intTransactionType = @INV_TRANS_Inventory_Transfer	THEN @INV_TRANS_TYPE_Revalue_Transfer
							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_Consume			THEN @INV_TRANS_TYPE_Revalue_Produced
							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_Build_Assembly	THEN @INV_TRANS_TYPE_Revalue_Build_Assembly

							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_ADJ_Item_Change	THEN @INV_TRANS_TYPE_Revalue_Item_Change
							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_ADJ_Lot_Merge	THEN @INV_TRANS_TYPE_Revalue_Lot_Merge
							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_ADJ_Lot_Move	THEN @INV_TRANS_TYPE_Revalue_Lot_Move
							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_ADJ_Split_Lot	THEN @INV_TRANS_TYPE_Revalue_Split_Lot

							WHEN @tOut_intTransactionType = @INV_TRANS_TYPE_Inventory_Shipment THEN @INV_TRANS_TYPE_Revalue_Shipment
					END

		EXEC [dbo].[uspICPostInventoryTransaction]
			@intItemId								= @tOut_intItemId 
			,@intItemLocationId						= @tOut_intItemLocationId
			,@intItemUOMId							= @tOut_intItemUOMId
			,@intSubLocationId						= @tOut_intSubLocationId
			,@intStorageLocationId					= @tOut_intStorageLocationId 
			,@dtmDate								= @AdjustDate
			,@dblQty								= 0
			,@dblUOMQty								= 0
			,@dblCost								= 0
			,@dblValue								= @InvAdjustValue
			,@dblSalesPrice							= 0
			,@intCurrencyId							= @tOut_intCurrencyId
			--,@dblExchangeRate						= @tOut_dblExchangeRate
			,@intTransactionId						= @intVoucherId
			,@intTransactionDetailId				= @intVoucherDetailId 
			,@strTransactionId						= @strVoucherId
			,@strBatchId							= @strBatchId
			,@intTransactionTypeId					= @CostAdjustmentTransactionType
			,@intLotId								= NULL  
			,@intRelatedInventoryTransactionId		= @tOut_intInventoryTransactionId
			,@intRelatedTransactionId				= @tOut_intTransactionId
			,@strRelatedTransactionId				= @tOut_strTransactionId
			,@strTransactionForm					= @tOut_strTransactionForm
			,@intEntityUserSecurityId				= @intEntityUserSecurityId
			,@intCostingMethod						= @AVERAGECOST
			,@InventoryTransactionIdentityId		= @InventoryTransactionIdentityId OUTPUT
			,@intFobPointId							= @tOut_intFobPointId 
			,@intInTransitSourceLocationId			= @tOut_intInTransitSourceLocationId
			,@intForexRateTypeId					= NULL
			,@dblForexRate							= 1
			,@strDescription						= @strDescription
				
		-----------------------------------------------------------------------------------------------------------
		-- 9. Get the 'produced/transferred/in-transit item'. Insert it in a temporary table for later processing. 
		-----------------------------------------------------------------------------------------------------------
		IF @tOut_intTransactionType IN (
				@INV_TRANS_TYPE_Consume						
			)
		BEGIN 
			SELECT	TOP 1 
					@intInventoryTransactionEscalateId = t.intInventoryTransactionId							
			FROM	dbo.tblICInventoryTransaction t
			WHERE	t.strBatchId = @tOut_strBatchId 
					AND t.intTransactionId = @tOut_intTransactionId
					AND t.strTransactionId = @tOut_strTransactionId
					AND ISNULL(t.ysnIsUnposted, 0) = 0
					AND ISNULL(t.dblQty, 0) > 0 
					AND t.intTransactionTypeId = @INV_TRANS_TYPE_Produce
		END 
		IF	@tOut_intTransactionType = @INV_TRANS_TYPE_Inventory_Shipment	
		BEGIN 
			SELECT	TOP 1 
					@intInventoryTransactionEscalateId = t.intInventoryTransactionId							
			FROM	dbo.tblICInventoryTransaction t
			WHERE	t.strBatchId = @tOut_strBatchId 
					AND t.intTransactionId = @tOut_intTransactionId
					AND t.strTransactionId = @tOut_strTransactionId
					AND ISNULL(t.ysnIsUnposted, 0) = 0
					AND ISNULL(t.dblQty, 0) > 0 
					AND t.intTransactionTypeId = @INV_TRANS_TYPE_Inventory_Shipment
					AND t.intFobPointId = @FOB_DESTINATION

			-- If @intInventoryTransactionEscalateId is null, then the buck stops at the shipment.
			-- Change the type to Revalue Sold. 
			BEGIN 
				UPDATE	t
				SET		t.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Sold
				FROM	tblICInventoryTransaction t
				WHERE	t.intInventoryTransactionId = @InventoryTransactionIdentityId
						AND @intInventoryTransactionEscalateId IS NULL 
			END 
		END 
		ELSE 
		BEGIN 
			SELECT	TOP 1 
					@intInventoryTransactionEscalateId = t.intInventoryTransactionId							
			FROM	dbo.tblICInventoryTransaction t
			WHERE	t.strBatchId = @tOut_strBatchId 
					AND t.intTransactionId = @tOut_intTransactionId
					AND t.strTransactionId = @tOut_strTransactionId
					AND ISNULL(t.ysnIsUnposted, 0) = 0
					AND ISNULL(t.dblQty, 0) > 0 
					AND t.intTransactionTypeId IN (
						@INV_TRANS_TYPE_Build_Assembly
						, @INV_TRANS_Inventory_Transfer
						, @INV_TRANS_TYPE_ADJ_Item_Change
						, @INV_TRANS_TYPE_ADJ_Split_Lot
						, @INV_TRANS_TYPE_ADJ_Lot_Merge
						, @INV_TRANS_TYPE_ADJ_Lot_Move
					)
		END
					
		IF @intInventoryTransactionEscalateId IS NOT NULL 
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
					[intItemId]						= t.intItemId
					,[intItemLocationId]			= t.intItemLocationId
					,[intItemUOMId]					= t.intItemUOMId
					,[dtmDate]						= @AdjustDate
					,[dblQty]						= t.dblQty
					,[dblUOMQty]					= t.dblUOMQty
					,[dblNewValue]					= -@InvAdjustValue
					,[intCurrencyId]				= t.intCurrencyId
					,[dblExchangeRate]				= t.dblExchangeRate
					,[intTransactionId]				= @intVoucherId
					,[intTransactionDetailId]		= @intVoucherDetailId
					,[strTransactionId]				= @strVoucherId 
					,[intTransactionTypeId]			= @LoopTransactionTypeId 
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
			WHERE	intInventoryTransactionId = @intInventoryTransactionEscalateId
		END 
	END 
END 

_Exit: 