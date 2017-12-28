/*

*/
CREATE PROCEDURE [dbo].[uspICPostCostAdjustmentEscalate]
	@dtmDate AS DATETIME 
	,@t_intItemId AS INT 
	,@t_intItemLocationId AS INT 
	,@t_dblQty AS NUMERIC(38, 20)
	,@t_strBatchId AS NVARCHAR(50)
	,@t_intTransactionId AS INT 
	,@t_intTransactionDetailId AS INT 
	,@t_strTransactionId AS NVARCHAR(50)
	,@t_intInventoryTransactionId AS INT 
	,@dblEscalateValue AS NUMERIC(38, 20)
	,@intTransactionId AS INT 
	,@intTransactionDetailId AS INT
	,@strTransactionId AS NVARCHAR(50) 
	,@EscalateInventoryTransactionTypeId AS INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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

BEGIN 
	DECLARE @AVERAGECOST AS INT = 1
			,@FIFO AS INT = 2
			,@LIFO AS INT = 3
			,@LOTCOST AS INT = 4 	
			,@ACTUALCOST AS INT = 5	

	-- Create the variables for the internal transaction types used by costing. 
	DECLARE
			@INV_TRANS_TYPE_Inventory_Auto_Variance AS INT = 1
			,@INV_TRANS_TYPE_Inventory_Receipt AS INT = 4
			,@INV_TRANS_TYPE_Inventory_Shipment AS INT = 5

			,@INV_TRANS_TYPE_Consume AS INT = 8
			,@INV_TRANS_TYPE_Produce AS INT = 9
			,@INV_TRANS_Inventory_Transfer AS INT = 12
			,@INV_TRANS_TYPE_ADJ_Item_Change AS INT = 15
			,@INV_TRANS_TYPE_ADJ_Split_Lot AS INT = 17
			,@INV_TRANS_TYPE_ADJ_Lot_Merge AS INT = 19
			,@INV_TRANS_TYPE_ADJ_Lot_Move AS INT = 20
			,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
			,@INV_TRANS_TYPE_Invoice AS INT = 33

	DECLARE @EscalateInventoryTransactionId AS INT 

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
			CASE WHEN t.intTransactionTypeId = @INV_TRANS_TYPE_Inventory_Receipt THEN 0 
					WHEN t.intTransactionTypeId = @INV_TRANS_TYPE_Produce THEN 1 
					WHEN t.intItemId = @t_intItemId AND t.intTransactionDetailId = @t_intTransactionDetailId THEN 1 
					ELSE 0 
			END 

-- If it was an offset from the negative stock scenario, the query below will do more digging. 
IF @EscalateInventoryTransactionId IS NULL 
BEGIN 

	DECLARE @intInventoryTransactionId_NegativeStock AS INT 
			,@strBatchId_NegativeStock AS NVARCHAR(50)
			,@strTransactionId_NegativeStock AS NVARCHAR(50)
			,@intTransactionId_NegativeStock AS INT
			,@intTransactionDetailId_NegativeStock AS INT

	-- FIFO
	SELECT	TOP 1 
			@intInventoryTransactionId_NegativeStock = tNegativeStock.intInventoryTransactionId
			,@strBatchId_NegativeStock = tNegativeStock.strBatchId
			,@strTransactionId_NegativeStock = tNegativeStock.strTransactionId
			,@intTransactionId_NegativeStock = tNegativeStock.intTransactionId
			,@intTransactionDetailId_NegativeStock = tNegativeStock.intTransactionDetailId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryFIFOOut cbOut
				ON t.intInventoryTransactionId = cbOut.intInventoryTransactionId
			INNER JOIN tblICInventoryFIFO cbNegativeStock 
				ON cbNegativeStock.intInventoryFIFOId = cbOut.intRevalueFifoId
				AND cbNegativeStock.ysnIsUnposted = 0 
			INNER JOIN tblICInventoryTransaction tNegativeStock
				ON tNegativeStock.intItemId = cbNegativeStock.intItemId
				AND tNegativeStock.intItemLocationId = cbNegativeStock.intItemLocationId
				AND tNegativeStock.strTransactionId = cbNegativeStock.strTransactionId
				AND tNegativeStock.intTransactionId = cbNegativeStock.intTransactionId
				AND ISNULL(tNegativeStock.intTransactionDetailId, 0) = COALESCE(cbNegativeStock.intTransactionDetailId, tNegativeStock.intTransactionDetailId, 0) 
				AND ISNULL(tNegativeStock.dblQty, 0) < 0 						 
				AND ISNULL(tNegativeStock.ysnIsUnposted, 0) = 0					
	WHERE	t.intInventoryTransactionId = @t_intInventoryTransactionId			
			AND cbOut.intRevalueFifoId IS NOT NULL 
			AND @EscalateInventoryTransactionId IS NULL 
			AND @intInventoryTransactionId_NegativeStock IS NULL 

	-- LIFO
	SELECT	TOP 1 
			@intInventoryTransactionId_NegativeStock = tNegativeStock.intInventoryTransactionId
			,@strBatchId_NegativeStock = tNegativeStock.strBatchId
			,@strTransactionId_NegativeStock = tNegativeStock.strTransactionId
			,@intTransactionId_NegativeStock = tNegativeStock.intTransactionId
			,@intTransactionDetailId_NegativeStock = tNegativeStock.intTransactionDetailId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryLIFOOut cbOut
				ON t.intInventoryTransactionId = cbOut.intInventoryTransactionId
			INNER JOIN tblICInventoryLIFO cbNegativeStock 
				ON cbNegativeStock.intInventoryLIFOId = cbOut.intRevalueLifoId
				AND cbNegativeStock.ysnIsUnposted = 0 
			INNER JOIN tblICInventoryTransaction tNegativeStock
				ON tNegativeStock.intItemId = cbNegativeStock.intItemId
				AND tNegativeStock.intItemLocationId = cbNegativeStock.intItemLocationId
				AND tNegativeStock.strTransactionId = cbNegativeStock.strTransactionId
				AND tNegativeStock.intTransactionId = cbNegativeStock.intTransactionId
				AND ISNULL(tNegativeStock.intTransactionDetailId, 0) = COALESCE(cbNegativeStock.intTransactionDetailId, tNegativeStock.intTransactionDetailId, 0) 
				AND ISNULL(tNegativeStock.dblQty, 0) < 0 						 
				AND ISNULL(tNegativeStock.ysnIsUnposted, 0) = 0					
				
	WHERE	t.intInventoryTransactionId = @t_intInventoryTransactionId			
			AND cbOut.intRevalueLifoId IS NOT NULL 
			AND @EscalateInventoryTransactionId IS NULL 
			AND @intInventoryTransactionId_NegativeStock IS NULL 

	-- Actual Cost 
	SELECT	TOP 1 
			@intInventoryTransactionId_NegativeStock = tNegativeStock.intInventoryTransactionId
			,@strBatchId_NegativeStock = tNegativeStock.strBatchId
			,@strTransactionId_NegativeStock = tNegativeStock.strTransactionId
			,@intTransactionId_NegativeStock = tNegativeStock.intTransactionId
			,@intTransactionDetailId_NegativeStock = tNegativeStock.intTransactionDetailId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryActualCostOut cbOut
				ON t.intInventoryTransactionId = cbOut.intInventoryTransactionId
			INNER JOIN tblICInventoryActualCost cbNegativeStock 
				ON cbNegativeStock.intInventoryActualCostId = cbOut.intRevalueActualCostId
				AND cbNegativeStock.ysnIsUnposted = 0 
			INNER JOIN tblICInventoryTransaction tNegativeStock
				ON tNegativeStock.intItemId = cbNegativeStock.intItemId
				AND tNegativeStock.intItemLocationId = cbNegativeStock.intItemLocationId
				AND tNegativeStock.strTransactionId = cbNegativeStock.strTransactionId
				AND tNegativeStock.intTransactionId = cbNegativeStock.intTransactionId
				AND ISNULL(tNegativeStock.intTransactionDetailId, 0) = COALESCE(cbNegativeStock.intTransactionDetailId, tNegativeStock.intTransactionDetailId, 0) 
				AND ISNULL(tNegativeStock.dblQty, 0) < 0 						 
				AND ISNULL(tNegativeStock.ysnIsUnposted, 0) = 0					
				
	WHERE	t.intInventoryTransactionId = @t_intInventoryTransactionId			
			AND cbOut.intRevalueActualCostId IS NOT NULL 
			AND @EscalateInventoryTransactionId IS NULL 
			AND @intInventoryTransactionId_NegativeStock IS NULL 

	-- Lot Cost 
	SELECT	TOP 1 
			@intInventoryTransactionId_NegativeStock = tNegativeStock.intInventoryTransactionId
			,@strBatchId_NegativeStock = tNegativeStock.strBatchId
			,@strTransactionId_NegativeStock = tNegativeStock.strTransactionId
			,@intTransactionId_NegativeStock = tNegativeStock.intTransactionId
			,@intTransactionDetailId_NegativeStock = tNegativeStock.intTransactionDetailId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryLotOut cbOut
				ON t.intInventoryTransactionId = cbOut.intInventoryTransactionId
			INNER JOIN tblICInventoryLot cbNegativeStock 
				ON cbNegativeStock.intInventoryLotId = cbOut.intRevalueLotId
				AND cbNegativeStock.ysnIsUnposted = 0 
			INNER JOIN tblICInventoryTransaction tNegativeStock			
				ON tNegativeStock.intItemId = cbNegativeStock.intItemId
				AND tNegativeStock.intItemLocationId = cbNegativeStock.intItemLocationId
				AND tNegativeStock.intLotId = cbNegativeStock.intLotId
				AND tNegativeStock.strTransactionId = cbNegativeStock.strTransactionId
				AND tNegativeStock.intTransactionId = cbNegativeStock.intTransactionId
				AND ISNULL(tNegativeStock.intTransactionDetailId, 0) = COALESCE(cbNegativeStock.intTransactionDetailId, tNegativeStock.intTransactionDetailId, 0) 
				AND ISNULL(tNegativeStock.dblQty, 0) < 0 						 
				AND ISNULL(tNegativeStock.ysnIsUnposted, 0) = 0
	WHERE	t.intInventoryTransactionId = @t_intInventoryTransactionId			
			AND cbOut.intRevalueLotId IS NOT NULL 
			AND @EscalateInventoryTransactionId IS NULL 
			AND @intInventoryTransactionId_NegativeStock IS NULL 

	-- Get the transaction to escalate. 
	SELECT	TOP 1 
			@EscalateInventoryTransactionId = t.intInventoryTransactionId							
			,@EscalateInventoryTransactionTypeId = t.intTransactionTypeId
	FROM	dbo.tblICInventoryTransaction t
	WHERE	@t_dblQty < 0 
			AND t.strBatchId = @strBatchId_NegativeStock 
			AND t.intTransactionId = @intTransactionId_NegativeStock
			AND t.strTransactionId = @strTransactionId_NegativeStock
			AND ISNULL(t.ysnIsUnposted, 0) = 0
			AND ISNULL(t.dblQty, 0) > 0 				
			AND 1 = 
				CASE WHEN t.intTransactionTypeId = @INV_TRANS_TYPE_Inventory_Receipt THEN 0 
						WHEN t.intTransactionTypeId = @INV_TRANS_TYPE_Produce THEN 1 
						WHEN t.intItemId = @t_intItemId AND t.intTransactionDetailId = @intTransactionDetailId_NegativeStock THEN 1 
						ELSE 0 
				END 	
			AND @EscalateInventoryTransactionId IS NULL 
			AND @intInventoryTransactionId_NegativeStock IS NOT NULL 
END 

IF @EscalateInventoryTransactionId IS NOT NULL 
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
			,[dblNewValue]					= @dblEscalateValue
			,[intCurrencyId]				= t.intCurrencyId
			,[intTransactionId]				= @intTransactionId
			,[intTransactionDetailId]		= @intTransactionDetailId
			,[strTransactionId]				= @strTransactionId
			,[intTransactionTypeId]			= @EscalateInventoryTransactionTypeId
			,[intLotId]						= t.intLotId
			,[intSubLocationId]				= t.intSubLocationId
			,[intStorageLocationId]			= t.intStorageLocationId
			,[ysnIsStorage]					= NULL 
			,[strActualCostId]				= t.strActualCostId 
			,[intSourceTransactionId]		= t.intTransactionId
			,[intSourceTransactionDetailId]	= t.intTransactionDetailId
			,[strSourceTransactionId]		= t.strTransactionId
			,[intRelatedInventoryTransactionId] = t.intInventoryTransactionId	
			,[intFobPointId]				= t.intFobPointId
			,[intInTransitSourceLocationId]	= t.intInTransitSourceLocationId
	FROM	dbo.tblICInventoryTransaction t 
			--LEFT JOIN tblICInventoryActualCost actualCostCb
			--	ON actualCostCb.strTransactionId = t.strTransactionId
			--	AND actualCostCb.intTransactionId = t.intTransactionId
			--	AND actualCostCb.intTransactionDetailId = t.intTransactionDetailId
			--	AND actualCostCb.intItemId = t.intItemId
			--	AND actualCostCb.intItemLocationId = t.intItemLocationId
			--	AND t.intCostingMethod = @ACTUALCOST
			--	AND actualCostCb.ysnIsUnposted = 0 
	WHERE	intInventoryTransactionId = @EscalateInventoryTransactionId
END 