CREATE PROCEDURE [dbo].[uspICCreateGLEntriesOnCostAdjustment]
	@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
	,@ysnPost AS INT = 1
	,@AccountCategory_Cost_Adjustment AS NVARCHAR(50) = 'AP Clearing' 
	,@strTransactionId AS NVARCHAR(50) = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON 
SET ANSI_WARNINGS OFF

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
		,@AccountCategory_WIP AS NVARCHAR(30) = 'Work In Progress' 
		,@AccountCategory_InTransit AS NVARCHAR(30) = 'Inventory In-Transit'
		,@AccountCategory_Sold AS NVARCHAR(30) = 'Cost of Goods'
		,@AccountCategory_Auto_Variance AS NVARCHAR(30) = 'Inventory Adjustment'
		,@AccountCategory_OtherCharge_Expense AS NVARCHAR(30) = 'Other Charge Expense' 
		
-- Create the variables for the internal transaction types used by costing. 
DECLARE @INV_TRANS_TYPE_Auto_Variance AS INT = 1
		,@INV_TRANS_TYPE_Auto_Variance_On_Sold_Or_Used_Stock AS INT = 35

		,@INV_TRANS_TYPE_Cost_Adjustment AS INT = 26
		,@INV_TRANS_TYPE_Revalue_WIP AS INT = 28
		,@INV_TRANS_TYPE_Revalue_Produced AS INT = 29
		,@INV_TRANS_TYPE_Revalue_Transfer AS INT = 30
		,@INV_TRANS_TYPE_Revalue_Build_Assembly AS INT = 31

		,@INV_TRANS_TYPE_Revalue_Sold AS INT = 3
		,@INV_TRANS_TYPE_Revalue_Item_Change AS INT = 36
		,@INV_TRANS_TYPE_Revalue_Split_Lot AS INT = 37
		,@INV_TRANS_TYPE_Revalue_Lot_Merge AS INT = 38
		,@INV_TRANS_TYPE_Revalue_Lot_Move AS INT = 39
		,@INV_TRANS_TYPE_Revalue_Shipment AS INT = 40

		-- Fob Point types: 
		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

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
		,@COST_ADJ_TYPE_Adjust_Auto_Variance AS INT = 10
		,@COST_ADJ_TYPE_Adjust_InTransit_Transfer_Order_Add AS INT = 11
		,@COST_ADJ_TYPE_Adjust_InTransit_Transfer_Order_Reduce AS INT = 12

-- Declare the cost adjustment types
DECLARE @costAdjustmentType_DETAILED AS TINYINT = 1
		,@costAdjustmentType_SUMMARIZED AS TINYINT = 2

-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';

DECLARE @GLEntries AS RecapTableType

-- Get the GL Account ids to use from Item Setup
BEGIN 
	DECLARE @GLAccounts AS dbo.ItemGLAccount; 
	INSERT INTO @GLAccounts (
			intItemId 
			,intItemLocationId 
			,intInventoryId 
			,intContraInventoryId 
			,intRevalueWIP
			,intRevalueInTransit
			,intRevalueSoldId
			,intAutoNegativeId
			,intOtherChargeExpense
			,intTransactionTypeId
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
			,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Cost_Adjustment) 
			,intRevalueWIP = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_WIP) 
			,intRevalueInTransit = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_InTransit) 
			,intRevalueSoldId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Sold) 
			,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Auto_Variance) 
			,intOtherChargeExpense = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_OtherCharge_Expense) 
			,intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						intItemId
						, intItemLocationId = ISNULL(intInTransitSourceLocationId, intItemLocationId)
						, intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction TRANS 
				WHERE	TRANS.strBatchId = @strBatchId
						AND (@strTransactionId IS NULL OR TRANS.strTransactionId = @strTransactionId)
			) Query
	;

	-- Again, get the GL Account ids to use, in case intItemLocationId is not found in intInTransitSourceLocationId.
	INSERT INTO @GLAccounts (
			intItemId 
			,intItemLocationId 
			,intInventoryId 
			,intContraInventoryId 
			,intRevalueWIP
			,intRevalueInTransit
			,intRevalueSoldId
			,intAutoNegativeId
			,intTransactionTypeId
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
			,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Cost_Adjustment) 
			,intRevalueWIP = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_WIP) 
			,intRevalueInTransit = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_InTransit) 
			,intRevalueSoldId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Sold) 
			,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Auto_Variance) 
			,intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						intItemId
						, intItemLocationId = t.intItemLocationId
						, intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t
						OUTER APPLY (
							SELECT	TOP 1 
									intItemLocationId
							FROM	@GLAccounts g
							WHERE	g.intItemLocationId = t.intItemLocationId
									AND g.intTransactionTypeId = t.intTransactionTypeId
									AND g.intItemId = t.intItemId
						) missing_item_location 						
				WHERE	t.strBatchId = @strBatchId
						AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
						AND missing_item_location.intItemLocationId IS NULL 
					
			) Query
	;
END 

-- Get the GL Account ids for the Other Charges 
BEGIN 
	DECLARE @OtherChargeGLAccounts AS dbo.ItemGLAccount; 

	-- FIFO LOG
	INSERT INTO @OtherChargeGLAccounts (
			intItemId 
			,intItemLocationId 
			,intOtherChargeExpense
			,intTransactionTypeId
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intOtherChargeExpense = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_OtherCharge_Expense) 
			,intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						intItemId = cbLog.intOtherChargeItemId
						, intItemLocationId = ocl.intItemLocationId
						, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryFIFOCostAdjustmentLog cbLog
							ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
							AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
						INNER JOIN tblICItemLocation il
							ON il.intItemLocationId = ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId)
						INNER JOIN tblICItemLocation ocl
							ON ocl.intItemId = cbLog.intOtherChargeItemId
							AND ocl.intLocationId = il.intLocationId
				WHERE	t.strBatchId = @strBatchId
						AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
						AND cbLog.intOtherChargeItemId IS NOT NULL 
			) Query

	-- LIFO LOG
	INSERT INTO @OtherChargeGLAccounts (
			intItemId 
			,intItemLocationId 
			,intOtherChargeExpense
			,intTransactionTypeId
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intOtherChargeExpense = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_OtherCharge_Expense) 
			,intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						intItemId = cbLog.intOtherChargeItemId
						, intItemLocationId = ocl.intItemLocationId
						, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryLIFOCostAdjustmentLog cbLog
							ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
							AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
						INNER JOIN tblICItemLocation il
							ON il.intItemLocationId = ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId)
						INNER JOIN tblICItemLocation ocl
							ON ocl.intItemId = cbLog.intOtherChargeItemId
							AND ocl.intLocationId = il.intLocationId
						LEFT JOIN @OtherChargeGLAccounts OtherChargeGLAccounts
							ON OtherChargeGLAccounts.intItemId = cbLog.intOtherChargeItemId
							AND OtherChargeGLAccounts.intItemLocationId = ocl.intItemLocationId
							AND OtherChargeGLAccounts.intTransactionTypeId = t.intTransactionTypeId
				WHERE	t.strBatchId = @strBatchId
						AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)						
						AND cbLog.intOtherChargeItemId IS NOT NULL 
						AND t.intItemLocationId IS NOT NULL 
						AND OtherChargeGLAccounts.intItemId IS NULL 
			) Query
	;

	-- LOT LOG 
	INSERT INTO @OtherChargeGLAccounts (
			intItemId 
			,intItemLocationId 
			,intOtherChargeExpense
			,intTransactionTypeId
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intOtherChargeExpense = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_OtherCharge_Expense) 
			,intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						intItemId = cbLog.intOtherChargeItemId
						, intItemLocationId = ocl.intItemLocationId
						, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryLotCostAdjustmentLog cbLog
							ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
							AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
						INNER JOIN tblICItemLocation il
							ON il.intItemLocationId = ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId)
						INNER JOIN tblICItemLocation ocl
							ON ocl.intItemId = cbLog.intOtherChargeItemId
							AND ocl.intLocationId = il.intLocationId
						LEFT JOIN @OtherChargeGLAccounts OtherChargeGLAccounts
							ON OtherChargeGLAccounts.intItemId = cbLog.intOtherChargeItemId
							AND OtherChargeGLAccounts.intItemLocationId = ocl.intItemLocationId
							AND OtherChargeGLAccounts.intTransactionTypeId = t.intTransactionTypeId
				WHERE	t.strBatchId = @strBatchId
						AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
						AND cbLog.intOtherChargeItemId IS NOT NULL 
						AND t.intItemLocationId IS NOT NULL 
						AND OtherChargeGLAccounts.intItemId IS NULL 
			) Query
	;

	-- ACTUAL COST LOG 
	INSERT INTO @OtherChargeGLAccounts (
			intItemId 
			,intItemLocationId 
			,intOtherChargeExpense
			,intTransactionTypeId
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intOtherChargeExpense = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_OtherCharge_Expense) 
			,intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						intItemId = cbLog.intOtherChargeItemId
						, intItemLocationId = ocl.intItemLocationId
						, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryActualCostAdjustmentLog cbLog
							ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
							AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
						INNER JOIN tblICItemLocation il
							ON il.intItemLocationId = ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId)
						INNER JOIN tblICItemLocation ocl
							ON ocl.intItemId = cbLog.intOtherChargeItemId
							AND ocl.intLocationId = il.intLocationId
						
						LEFT JOIN @OtherChargeGLAccounts OtherChargeGLAccounts
							ON OtherChargeGLAccounts.intItemId = cbLog.intOtherChargeItemId
							AND OtherChargeGLAccounts.intItemLocationId = ocl.intItemLocationId
							AND OtherChargeGLAccounts.intTransactionTypeId = t.intTransactionTypeId

				WHERE	t.strBatchId = @strBatchId
						AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
						AND cbLog.intOtherChargeItemId IS NOT NULL 
						AND t.intItemLocationId IS NOT NULL 
						AND OtherChargeGLAccounts.intItemId IS NULL 
			) Query
	;
END

-- Validate the GL Accounts
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemId AS INT 
DECLARE @strLocationName AS NVARCHAR(50)

-- Check for missing Inventory Account Id
BEGIN 
	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intInventoryId IS NULL 

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @GLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intInventoryId IS NULL 

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in Location is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_Inventory;
		RETURN -1;
	END 
END 
;

-- Check for missing Contra Account Id
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intContraInventoryId IS NULL 
			AND ISNULL(Item.strType, '') IN ('Inventory', 'Finished Good', 'Raw Material')

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @GLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intContraInventoryId IS NULL 
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Cost Adjustment} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_Cost_Adjustment;
		RETURN -1;
	END 
END 
;

-- Check for missing Other Charge Expense
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @OtherChargeGLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intOtherChargeExpense IS NULL 
			AND ISNULL(Item.strType, '') IN ('Other Charge')

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @OtherChargeGLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intOtherChargeExpense IS NULL 
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Other Charge Expense} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_OtherCharge_Expense;
		RETURN -1;
	END 
END 
;

-- Check for missing Work In Progress 
IF EXISTS (
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryFIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_WIP
			AND cbLog.ysnIsUnposted = 0
	UNION ALL 
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryLIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_WIP
			AND cbLog.ysnIsUnposted = 0
	UNION ALL 
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryLotCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_WIP
			AND cbLog.ysnIsUnposted = 0
	UNION ALL 
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryActualCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_WIP
			AND cbLog.ysnIsUnposted = 0
)
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intRevalueWIP IS NULL 

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @GLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intRevalueWIP IS NULL 
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Work In Progress} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_WIP;
		RETURN -1;
	END 
END 
;


-- Check for missing In-Transit 
IF EXISTS (
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryFIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit
			AND cbLog.ysnIsUnposted = 0
	UNION ALL 
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryLIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit
			AND cbLog.ysnIsUnposted = 0
	UNION ALL 
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryLotCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit
			AND cbLog.ysnIsUnposted = 0
	UNION ALL 
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryActualCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit
			AND cbLog.ysnIsUnposted = 0
)
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intRevalueInTransit IS NULL 

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @GLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intRevalueInTransit IS NULL 
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Work In Progress} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_InTransit;
		RETURN -1;
	END 
END 
;

-- Check for missing COGS
IF EXISTS (
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryFIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Sold
			AND cbLog.ysnIsUnposted = 0
	UNION ALL 
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryLIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Sold
			AND cbLog.ysnIsUnposted = 0
	UNION ALL 
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryLotCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Sold
			AND cbLog.ysnIsUnposted = 0
	UNION ALL 
	SELECT	TOP 1 cbLog.intInventoryCostAdjustmentTypeId
	FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryActualCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND cbLog.intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Sold
			AND cbLog.ysnIsUnposted = 0
)
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intRevalueSoldId IS NULL 

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @GLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intRevalueSoldId IS NULL 
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Cost of Goods Sold} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_Sold;
		RETURN -1;
	END 
END 
;

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 
;

-- Log the g/l account used in this batch. 
INSERT INTO dbo.tblICInventoryGLAccountUsedOnPostLog (
		intItemId
		,intItemLocationId
		,intInventoryId
		,intContraInventoryId 
		,intRevalueWIP
		,intRevalueInTransit
		,intRevalueSoldId
		,intAutoNegativeId
		,intOtherChargeExpense
		,strBatchId
)
SELECT 
		intItemId
		,intItemLocationId
		,intInventoryId
		,intContraInventoryId 
		,intRevalueWIP
		,intRevalueInTransit
		,intRevalueSoldId
		,intAutoNegativeId
		,intOtherChargeExpense
		,@strBatchId
FROM	@GLAccounts
;

-- Generate the G/L Entries here: 
WITH ForGLEntries_CTE (
	dtmDate
	,intItemId
	,intItemLocationId
	,intTransactionId
	,strTransactionId
	,dblValue
	,intTransactionTypeId
	,intCurrencyId
	,dblExchangeRate
	,intInventoryTransactionId
	,strInventoryTransactionTypeName
	,strTransactionForm
	,intInTransitSourceLocationId
	,strItemNo 
	,intRelatedTransactionId
	,strRelatedTransactionId
	,strBatchId 
	,intLotId
	,intFOBPointId
	,dblForexRate
	,intInventoryCostAdjustmentTypeId
	,intOtherChargeItemId
	,ysnFixInventoryRoundingDiscrepancy 
)
AS
(
	-- FIFO DETAILED
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId
			,t.intTransactionId
			,t.strTransactionId
			,dblValue = ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2)
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,cbLog.intRelatedTransactionId  -- t.intRelatedTransactionId
			,cbLog.strRelatedTransactionId --t.strRelatedTransactionId
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
			,cbLog.intInventoryCostAdjustmentTypeId
			,charge.intItemId
			,ysnFixInventoryRoundingDiscrepancy = CAST(0 AS BIT)
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			INNER JOIN tblICInventoryFIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost				
			LEFT JOIN tblICItem charge
				ON charge.intItemId = cbLog.intOtherChargeItemId
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND dbo.fnICGetCostAdjustmentSetup(t.intItemId, t.intItemLocationId) = @costAdjustmentType_DETAILED
	UNION ALL 
	-- FIFO SUMMARIZED
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId
			,t.intTransactionId
			,t.strTransactionId
			,dblValue = ISNULL(cbLog.dblValue, 0)
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,t.intRelatedTransactionId --cbLog.intRelatedTransactionId  
			,t.strRelatedTransactionId --cbLog.strRelatedTransactionId 
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
			,cbLog.intInventoryCostAdjustmentTypeId
			,charge.intItemId
			,ysnFixInventoryRoundingDiscrepancy = CAST(0 AS BIT)
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			CROSS APPLY (
				SELECT 
					dblValue = SUM(ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2))
					,cbLog.intInventoryCostAdjustmentTypeId 
					,cbLog.intOtherChargeItemId
				FROM
					tblICInventoryFIFOCostAdjustmentLog cbLog
				WHERE
					cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
				GROUP BY 
					cbLog.intInventoryCostAdjustmentTypeId
					,cbLog.intOtherChargeItemId
			) cbLog
			LEFT JOIN tblICItem charge
				ON charge.intItemId = cbLog.intOtherChargeItemId
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ISNULL(cbLog.dblValue, 0) <> 0 
			AND dbo.fnICGetCostAdjustmentSetup(t.intItemId, t.intItemLocationId) = @costAdjustmentType_SUMMARIZED

	-- LIFO DETAILED
	UNION ALL 
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId
			,t.intTransactionId
			,t.strTransactionId
			,dblValue = ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2)
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,cbLog.intRelatedTransactionId  -- t.intRelatedTransactionId
			,cbLog.strRelatedTransactionId --t.strRelatedTransactionId
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
			,cbLog.intInventoryCostAdjustmentTypeId
			,charge.intItemId
			,ysnFixInventoryRoundingDiscrepancy = CAST(0 AS BIT)
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			INNER JOIN tblICInventoryLIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
			LEFT JOIN tblICItem charge
				ON charge.intItemId = cbLog.intOtherChargeItemId
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND dbo.fnICGetCostAdjustmentSetup(t.intItemId, t.intItemLocationId) = @costAdjustmentType_DETAILED
	-- LIFO SUMMARIZED
	UNION ALL 
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId
			,t.intTransactionId
			,t.strTransactionId
			,dblValue = ISNULL(cbLog.dblValue, 0)
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,t.intRelatedTransactionId --cbLog.intRelatedTransactionId  
			,t.strRelatedTransactionId --cbLog.strRelatedTransactionId 
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
			,cbLog.intInventoryCostAdjustmentTypeId
			,charge.intItemId
			,ysnFixInventoryRoundingDiscrepancy = CAST(0 AS BIT)
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			CROSS APPLY(
				SELECT 
					dblValue = SUM(ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2))
					,cbLog.intInventoryCostAdjustmentTypeId
					,cbLog.intOtherChargeItemId
				FROM 
					tblICInventoryLIFOCostAdjustmentLog cbLog
				WHERE
					cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
				GROUP BY 
					cbLog.intInventoryCostAdjustmentTypeId
					,cbLog.intOtherChargeItemId
			) cbLog
			LEFT JOIN tblICItem charge
				ON charge.intItemId = cbLog.intOtherChargeItemId
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ISNULL(cbLog.dblValue, 0) <> 0 
			AND dbo.fnICGetCostAdjustmentSetup(t.intItemId, t.intItemLocationId) = @costAdjustmentType_SUMMARIZED

	-- LOT DETAILED
	UNION ALL 
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId
			,t.intTransactionId
			,t.strTransactionId
			,dblValue = ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2)
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,cbLog.intRelatedTransactionId  -- t.intRelatedTransactionId
			,cbLog.strRelatedTransactionId --t.strRelatedTransactionId
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
			,cbLog.intInventoryCostAdjustmentTypeId
			,charge.intItemId
			,ysnFixInventoryRoundingDiscrepancy = CAST(0 AS BIT)
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			INNER JOIN tblICInventoryLotCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
			LEFT JOIN tblICItem charge
				ON charge.intItemId = cbLog.intOtherChargeItemId
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND dbo.fnICGetCostAdjustmentSetup(t.intItemId, t.intItemLocationId) = @costAdjustmentType_DETAILED
	-- LOT SUMMARIZED
	UNION ALL 
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId
			,t.intTransactionId
			,t.strTransactionId
			,dblValue = ISNULL(cbLog.dblValue, 0)
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,t.intRelatedTransactionId --cbLog.intRelatedTransactionId  
			,t.strRelatedTransactionId --cbLog.strRelatedTransactionId 
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
			,cbLog.intInventoryCostAdjustmentTypeId
			,charge.intItemId
			,ysnFixInventoryRoundingDiscrepancy = CAST(0 AS BIT)
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			CROSS APPLY(
				SELECT 
					dblValue = SUM(ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2))
					,cbLog.intInventoryCostAdjustmentTypeId
					,cbLog.intOtherChargeItemId
				FROM 
					tblICInventoryLotCostAdjustmentLog cbLog
				WHERE
					cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
				GROUP BY
					cbLog.intInventoryCostAdjustmentTypeId
					,cbLog.intOtherChargeItemId
			) cbLog
			LEFT JOIN tblICItem charge
				ON charge.intItemId = cbLog.intOtherChargeItemId
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ISNULL(cbLog.dblValue, 0) <> 0 
			AND dbo.fnICGetCostAdjustmentSetup(t.intItemId, t.intItemLocationId) = @costAdjustmentType_SUMMARIZED

	-- ACTUAL COST DETAILED
	UNION ALL 
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId
			,t.intTransactionId
			,t.strTransactionId
			,dblValue = ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2)
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,cbLog.intRelatedTransactionId  -- t.intRelatedTransactionId
			,cbLog.strRelatedTransactionId --t.strRelatedTransactionId
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
			,cbLog.intInventoryCostAdjustmentTypeId
			,charge.intItemId
			,ysnFixInventoryRoundingDiscrepancy = CAST(0 AS BIT)
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			INNER JOIN tblICInventoryActualCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
				AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
			LEFT JOIN tblICItem charge
				ON charge.intItemId = cbLog.intOtherChargeItemId
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
			AND dbo.fnICGetCostAdjustmentSetup(t.intItemId, t.intItemLocationId) = @costAdjustmentType_DETAILED
	-- ACTUAL SUMMARIZED
	UNION ALL 
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId
			,t.intTransactionId
			,t.strTransactionId
			,dblValue = ISNULL(cbLog.dblValue, 0)
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,t.intRelatedTransactionId --cbLog.intRelatedTransactionId  
			,t.strRelatedTransactionId --cbLog.strRelatedTransactionId 
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
			,cbLog.intInventoryCostAdjustmentTypeId
			,charge.intItemId
			,ysnFixInventoryRoundingDiscrepancy = CAST(0 AS BIT)
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			CROSS APPLY (
				SELECT 
					dblValue = SUM(ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2))
					,cbLog.intInventoryCostAdjustmentTypeId
					,cbLog.intOtherChargeItemId
				FROM
					tblICInventoryActualCostAdjustmentLog cbLog
				WHERE
					cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					AND cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
				GROUP BY 
					cbLog.intInventoryCostAdjustmentTypeId
					,cbLog.intOtherChargeItemId
			) cbLog 
			LEFT JOIN tblICItem charge
				ON charge.intItemId = cbLog.intOtherChargeItemId
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ISNULL(cbLog.dblValue, 0) <> 0 
			AND dbo.fnICGetCostAdjustmentSetup(t.intItemId, t.intItemLocationId) = @costAdjustmentType_SUMMARIZED

	-- AUTO VARIANCE 
	UNION ALL 
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId
			,t.intTransactionId
			,t.strTransactionId
			,dblValue = ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2)
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,t.intRelatedTransactionId
			,t.strRelatedTransactionId
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
			,intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Auto_Variance
			,intOtherChargeItemId = NULL 
			,ysnFixInventoryRoundingDiscrepancy = CAST(0 AS BIT)
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND t.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Variance
)
INSERT INTO @GLEntries (
	dtmDate
	,strBatchId
	,intAccountId
	,dblDebit
	,dblCredit
	,dblDebitUnit
	,dblCreditUnit
	,strDescription
	,strCode
	,strReference
	,intCurrencyId
	,dblExchangeRate
	,dtmDateEntered
	,dtmTransactionDate
	,strJournalLineDescription
	,intJournalLineNo
	,ysnIsUnposted
	,intUserId
	,intEntityId
	,strTransactionId
	,intTransactionId
	,strTransactionType
	,strTransactionForm
	,strModuleName
	,intConcurrencyId
	,dblDebitForeign
	,dblDebitReport
	,dblCreditForeign
	,dblCreditReport
	,dblReportingRate
	,dblForeignRate
)

/*-----------------------------------------------------------------------------------
  GL Entries for Adjust Value 
  Debit	....... Inventory
  Credit	..................... Cost Adjustment (Item's AP Clearing) 
  -- OR -- 
  Credit	..................... Other Charge Expense 
-----------------------------------------------------------------------------------*/
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									) 
		,strCode					= 'ICA' 
		,strReference				= '1' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId 
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Value

-- Cost Adjustment from Item cost change. 
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'ICA' 
		,strReference				= '2' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 -- CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intContraInventoryId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Value
		AND ForGLEntries_CTE.intOtherChargeItemId IS NULL 

-- Cost Adjustment from Other Charges
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'ICA' 
		,strReference				= '3' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 -- CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @OtherChargeGLAccounts GLAccounts
			ON ForGLEntries_CTE.intOtherChargeItemId = GLAccounts.intItemId		
			--AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId	
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intOtherChargeExpense
		INNER JOIN tblICItemLocation il
			ON il.intItemLocationId =  ForGLEntries_CTE.intItemLocationId
		INNER JOIN tblICItemLocation ocl
			ON ocl.intItemId = ForGLEntries_CTE.intOtherChargeItemId
			AND ocl.intLocationId = il.intLocationId			
		
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Value
		AND ForGLEntries_CTE.intOtherChargeItemId IS NOT NULL 
		AND GLAccounts.intItemLocationId = ocl.intItemLocationId

/*-----------------------------------------------------------------------------------
  GL Entries for Adjust Work In Progress
  Debit	....... Inventory
  Credit	..................... Work In Progress
-----------------------------------------------------------------------------------*/
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									) 
		,strCode					= 'ICA' 
		,strReference				= '4' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId 
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_WIP

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'ICA' 
		,strReference				= '5' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueWIP
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_WIP

/*-----------------------------------------------------------------------------------
  GL Entries for Adjust In-Transit
  Debit	....... In-Transit
  Credit ........................ Inventory
-----------------------------------------------------------------------------------*/
UNION ALL
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'ICA' 
		,strReference				= '6' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueInTransit
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit
UNION ALL
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'ICA' 
		,strReference				= '7' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId 
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit

/*-----------------------------------------------------------------------------------
  GL Entries for Adjust In-Transit from Transfer Order
  Debit		... Inventory   
  Credit	.......................... In-Transit   
-----------------------------------------------------------------------------------*/
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'ICA' 
		,strReference				= '9' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId 
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit_Transfer_Order_Add --@COST_ADJ_TYPE_Adjust_InTransit_Inventory
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'ICA' 
		,strReference				= '8' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueInTransit
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit_Transfer_Order_Reduce --@COST_ADJ_TYPE_Adjust_InTransit_Inventory

/*-----------------------------------------------------------------------------------
  GL Entries for Adjust In-Transit Sold (In Transit reduced from Invoice)
  Debit	....... COGS
  Credit ..................... In-Transit
-----------------------------------------------------------------------------------*/
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'ICA' 
		,strReference				= '10' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueSoldId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit_Sold
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'ICA' 
		,strReference				= '11' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueInTransit
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit_Sold


/*-----------------------------------------------------------------------------------
  GL Entries for Adjust Inventory Adjustment   
  Single GL entry. 
  
  If increasing:
  Debit	....... Inventory Adjustment 

  If decreasing: 
  Credit	..................... Inventory Adjustment 
-----------------------------------------------------------------------------------*/
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									) 
		,strCode					= 'ICA' 
		,strReference				= '12' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId 
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InventoryAdjustment

/*-----------------------------------------------------------------------------------
  GL Entries for Adjust Sold
  Debit	....... Inventory
  Credit	..................... COGS
-----------------------------------------------------------------------------------*/
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									) 
		,strCode					= 'ICA' 
		,strReference				= '13' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId 
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Sold

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'ICA' 
		,strReference				= '14' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueSoldId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Sold

/*-------------------------------------------------------------------------------------------
  GL Entries for Auto Variance 
  Debit	....... Inventory
  Credit	..................... Inventory Adjustment (usually, it is the same as COGS)
-------------------------------------------------------------------------------------------*/
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									) 
		,strCode					= 'ICA' 
		,strReference				= '15' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId 
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Auto_Variance
		AND ysnFixInventoryRoundingDiscrepancy = 0

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'ICA' 
		,strReference				= '16' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= NULL 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Auto_Variance
		AND ysnFixInventoryRoundingDiscrepancy = 0
;

-- Fix the decimal discrepancy. 
IF EXISTS (
	SELECT	1
	FROM	@GLEntries
	HAVING	SUM(dblDebit) - SUM(dblCredit) <> 0 
			AND ABS(SUM(dblDebit) - SUM(dblCredit)) <= 1
			AND SUM(dblDebit) - SUM(dblCredit) % 1 <> 0
)
BEGIN 
	-- Generate the G/L Entries here: 
	WITH DecimalDiscrepancy (
		dtmDate
		,intItemId
		,intItemLocationId
		,intTransactionId
		,strTransactionId
		,dblValue
		,intTransactionTypeId
		,intCurrencyId
		,dblExchangeRate
		,intInventoryTransactionId
		,strInventoryTransactionTypeName
		,strTransactionForm
		,intInTransitSourceLocationId
		,strItemNo 
		,intRelatedTransactionId
		,strRelatedTransactionId
		,strBatchId 
		,intLotId
		,intFOBPointId
		,dblForexRate
		,intInventoryCostAdjustmentTypeId
		,intOtherChargeItemId
		,ysnFixInventoryRoundingDiscrepancy 
	)
	AS
	(
		-- AUTO VARIANCE TO FIX ROUNDING DISCREPANCIES (Lot)
		SELECT	t.dtmDate
				,t.intItemId
				,t.intItemLocationId
				,t.intTransactionId
				,t.strTransactionId
				,dblValue = 
					CASE 
						WHEN isInTransit.intInventoryTransactionId IS NULL THEN -ROUND(lot.[variance], 2) 
						ELSE ROUND(lot.[variance], 2) 
					END
				,t.intTransactionTypeId
				,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
				,t.dblExchangeRate
				,t.intInventoryTransactionId
				,strInventoryTransactionTypeName = TransType.strName
				,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
				,t.intInTransitSourceLocationId
				,t.strItemNo
				,t.intRelatedTransactionId
				,t.strRelatedTransactionId
				,t.strBatchId
				,t.intLotId 
				,t.intFobPointId
				,t.dblForexRate
				,intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Auto_Variance
				,intOtherChargeItemId = NULL 
				,ysnFixInventoryRoundingDiscrepancy = CAST(1 AS BIT)
		FROM	dbo.tblICInventoryTransactionType TransType
				CROSS APPLY (
					SELECT	cbLog.strRelatedTransactionId 
							,cbLog.intRelatedTransactionId
							,cbLog.intRelatedTransactionDetailId
							,[cnt] = COUNT(1)
							,[variance] = SUM(ROUND(ISNULL(cbLog.dblValue, 0), 2))
					FROM	tblICInventoryLotCostAdjustmentLog cbLog INNER JOIN tblICInventoryLot cb
								ON cbLog.intInventoryLotId = cb.intInventoryLotId				
							INNER JOIN dbo.tblICInventoryTransaction t 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
								AND cb.intLotId = t.intLotId
					WHERE	cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
							AND t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
					GROUP BY 
						cbLog.strRelatedTransactionId 
						,cbLog.intRelatedTransactionId
						,cbLog.intRelatedTransactionDetailId
					HAVING 
						COUNT(1) > 1
						AND SUM(ROUND(cbLog.dblValue, 2)) <> 0 							
				) lot
				CROSS APPLY (
					SELECT	TOP 1 
							t.* 
							,i.strItemNo
					FROM	tblICInventoryTransaction t INNER JOIN tblICItem i
								ON i.intItemId = t.intItemId
							INNER JOIN tblICInventoryLotCostAdjustmentLog cbLog 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					WHERE	t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
							AND cbLog.strRelatedTransactionId = lot.strRelatedTransactionId
							AND cbLog.intRelatedTransactionId = lot.intRelatedTransactionId
							AND cbLog.intRelatedTransactionDetailId = lot.intRelatedTransactionDetailId
					ORDER BY 
							t.intInventoryTransactionId DESC 
				) t
				OUTER APPLY (
					SELECT	TOP 1 
							t.* 
					FROM	tblICInventoryTransaction t INNER JOIN tblICItemLocation il
								ON il.intItemLocationId = t.intItemLocationId
							INNER JOIN tblICInventoryLotCostAdjustmentLog cbLog 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					WHERE	t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
							AND cbLog.strRelatedTransactionId = lot.strRelatedTransactionId
							AND cbLog.intRelatedTransactionId = lot.intRelatedTransactionId
							AND cbLog.intRelatedTransactionDetailId = lot.intRelatedTransactionDetailId
							AND il.intLocationId IS NULL 
				) isInTransit
		WHERE	TransType.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Variance
				AND ABS(ROUND(lot.[variance], 2)) <= 1
				AND ROUND(lot.[variance], 2) % 1 <> 0

		-- AUTO VARIANCE TO FIX ROUNDING DISCREPANCIES (FIFO)
		UNION ALL 
		SELECT	t.dtmDate
				,t.intItemId
				,t.intItemLocationId
				,t.intTransactionId
				,t.strTransactionId
				,dblValue = 
					CASE 
						WHEN isInTransit.intInventoryTransactionId IS NULL THEN -ROUND(fifo.[variance], 2) 
						ELSE ROUND(fifo.[variance], 2) 
					END
				,t.intTransactionTypeId
				,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
				,t.dblExchangeRate
				,t.intInventoryTransactionId
				,strInventoryTransactionTypeName = TransType.strName
				,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
				,t.intInTransitSourceLocationId
				,t.strItemNo
				,t.intRelatedTransactionId
				,t.strRelatedTransactionId
				,t.strBatchId
				,t.intLotId 
				,t.intFobPointId
				,t.dblForexRate
				,intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Auto_Variance
				,intOtherChargeItemId = NULL 
				,ysnFixInventoryRoundingDiscrepancy = CAST(1 AS BIT)
		FROM	dbo.tblICInventoryTransactionType TransType
				CROSS APPLY (
					SELECT	cbLog.strRelatedTransactionId 
							,cbLog.intRelatedTransactionId
							,cbLog.intRelatedTransactionDetailId
							,[cnt] = COUNT(1)
							,[variance] = SUM(ROUND(ISNULL(cbLog.dblValue, 0), 2))
					FROM	tblICInventoryFIFOCostAdjustmentLog cbLog INNER JOIN dbo.tblICInventoryTransaction t 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					WHERE	cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
							AND t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
					GROUP BY 
						cbLog.strRelatedTransactionId 
						,cbLog.intRelatedTransactionId
						,cbLog.intRelatedTransactionDetailId
					HAVING 
						COUNT(1) > 1
						AND SUM(ROUND(cbLog.dblValue, 2)) <> 0 							
				) fifo
				CROSS APPLY (
					SELECT	TOP 1 
							t.* 
							,i.strItemNo
					FROM	tblICInventoryTransaction t INNER JOIN tblICItem i
								ON i.intItemId = t.intItemId
							INNER JOIN tblICCostingMethod c
								ON c.intCostingMethodId = t.intCostingMethod
							INNER JOIN tblICInventoryFIFOCostAdjustmentLog cbLog 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					WHERE	t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
							AND cbLog.strRelatedTransactionId = fifo.strRelatedTransactionId
							AND cbLog.intRelatedTransactionId = fifo.intRelatedTransactionId
							AND cbLog.intRelatedTransactionDetailId = fifo.intRelatedTransactionDetailId
							AND c.strCostingMethod = 'FIFO' 
					ORDER BY 
							t.intInventoryTransactionId DESC 
				) t
				OUTER APPLY (
					SELECT	TOP 1 
							t.* 
					FROM	tblICInventoryTransaction t INNER JOIN tblICItemLocation il
								ON il.intItemLocationId = t.intItemLocationId
							INNER JOIN tblICInventoryFIFOCostAdjustmentLog cbLog 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					WHERE	t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
							AND cbLog.strRelatedTransactionId = fifo.strRelatedTransactionId
							AND cbLog.intRelatedTransactionId = fifo.intRelatedTransactionId
							AND cbLog.intRelatedTransactionDetailId = fifo.intRelatedTransactionDetailId
							AND il.intLocationId IS NULL 
				) isInTransit
		WHERE	TransType.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Variance
				AND ABS(ROUND(fifo.[variance], 2)) <= 1
				AND ROUND(fifo.[variance], 2) % 1 <> 0

		-- AUTO VARIANCE TO FIX ROUNDING DISCREPANCIES (LIFO)
		UNION ALL 
		SELECT	t.dtmDate
				,t.intItemId
				,t.intItemLocationId
				,t.intTransactionId
				,t.strTransactionId
				,dblValue = 
					CASE 
						WHEN isInTransit.intInventoryTransactionId IS NULL THEN -ROUND(lifo.[variance], 2) 
						ELSE ROUND(lifo.[variance], 2) 
					END
				,t.intTransactionTypeId
				,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
				,t.dblExchangeRate
				,t.intInventoryTransactionId
				,strInventoryTransactionTypeName = TransType.strName
				,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
				,t.intInTransitSourceLocationId
				,t.strItemNo
				,t.intRelatedTransactionId
				,t.strRelatedTransactionId
				,t.strBatchId
				,t.intLotId 
				,t.intFobPointId
				,t.dblForexRate
				,intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Auto_Variance
				,intOtherChargeItemId = NULL 
				,ysnFixInventoryRoundingDiscrepancy = CAST(1 AS BIT)
		FROM	dbo.tblICInventoryTransactionType TransType
				CROSS APPLY (
					SELECT	cbLog.strRelatedTransactionId 
							,cbLog.intRelatedTransactionId
							,cbLog.intRelatedTransactionDetailId
							,[cnt] = COUNT(1)
							,[variance] = SUM(ROUND(ISNULL(cbLog.dblValue, 0), 2))
					FROM	tblICInventoryLIFOCostAdjustmentLog cbLog INNER JOIN dbo.tblICInventoryTransaction t 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					WHERE	cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
							AND t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
					GROUP BY 
						cbLog.strRelatedTransactionId 
						,cbLog.intRelatedTransactionId
						,cbLog.intRelatedTransactionDetailId
					HAVING 
						COUNT(1) > 1
						AND SUM(ROUND(cbLog.dblValue, 2)) <> 0 							
				) lifo
				CROSS APPLY (
					SELECT	TOP 1 
							t.* 
							,i.strItemNo
					FROM	tblICInventoryTransaction t INNER JOIN tblICItem i
								ON i.intItemId = t.intItemId
							INNER JOIN tblICInventoryLIFOCostAdjustmentLog cbLog 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					WHERE	t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
							AND cbLog.strRelatedTransactionId = lifo.strRelatedTransactionId
							AND cbLog.intRelatedTransactionId = lifo.intRelatedTransactionId
							AND cbLog.intRelatedTransactionDetailId = lifo.intRelatedTransactionDetailId
					ORDER BY 
							t.intInventoryTransactionId DESC 
				) t
				OUTER APPLY (
					SELECT	TOP 1 
							t.* 
					FROM	tblICInventoryTransaction t INNER JOIN tblICItemLocation il
								ON il.intItemLocationId = t.intItemLocationId
							INNER JOIN tblICInventoryLIFOCostAdjustmentLog cbLog 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					WHERE	t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
							AND cbLog.strRelatedTransactionId = lifo.strRelatedTransactionId
							AND cbLog.intRelatedTransactionId = lifo.intRelatedTransactionId
							AND cbLog.intRelatedTransactionDetailId = lifo.intRelatedTransactionDetailId
							AND il.intLocationId IS NULL 
				) isInTransit
		WHERE	TransType.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Variance
				AND ABS(ROUND(lifo.[variance], 2)) <= 1
				AND ROUND(lifo.[variance], 2) % 1 <> 0

		-- AUTO VARIANCE TO FIX ROUNDING DISCREPANCIES (ACTUAL)
		UNION ALL 
		SELECT	t.dtmDate
				,t.intItemId
				,t.intItemLocationId
				,t.intTransactionId
				,t.strTransactionId
				,dblValue = 
					CASE 
						WHEN isInTransit.intInventoryTransactionId IS NULL THEN -ROUND(actual.[variance], 2) 
						ELSE ROUND(actual.[variance], 2) 
					END
				,t.intTransactionTypeId
				,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) 
				,t.dblExchangeRate
				,t.intInventoryTransactionId
				,strInventoryTransactionTypeName = TransType.strName
				,strTransactionForm = ISNULL(TransType.strTransactionForm, t.strTransactionForm) 
				,t.intInTransitSourceLocationId
				,t.strItemNo
				,t.intRelatedTransactionId
				,t.strRelatedTransactionId
				,t.strBatchId
				,t.intLotId 
				,t.intFobPointId
				,t.dblForexRate
				,intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_Auto_Variance
				,intOtherChargeItemId = NULL 
				,ysnFixInventoryRoundingDiscrepancy = CAST(1 AS BIT)
		FROM	dbo.tblICInventoryTransactionType TransType
				CROSS APPLY (
					SELECT	cbLog.strRelatedTransactionId 
							,cbLog.intRelatedTransactionId
							,cbLog.intRelatedTransactionDetailId
							,[cnt] = COUNT(1)
							,[variance] = SUM(ROUND(ISNULL(cbLog.dblValue, 0), 2))
					FROM	tblICInventoryActualCostAdjustmentLog cbLog INNER JOIN dbo.tblICInventoryTransaction t 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					WHERE	cbLog.intInventoryCostAdjustmentTypeId <> @COST_ADJ_TYPE_Original_Cost
							AND t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
					GROUP BY 
						cbLog.strRelatedTransactionId 
						,cbLog.intRelatedTransactionId
						,cbLog.intRelatedTransactionDetailId
					HAVING 
						COUNT(1) > 1
						AND SUM(ROUND(cbLog.dblValue, 2)) <> 0 							
				) actual
				CROSS APPLY (
					SELECT	TOP 1 
							t.* 
							,i.strItemNo
					FROM	tblICInventoryTransaction t INNER JOIN tblICItem i
								ON i.intItemId = t.intItemId
							INNER JOIN tblICInventoryActualCostAdjustmentLog cbLog 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					WHERE	t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
							AND cbLog.strRelatedTransactionId = actual.strRelatedTransactionId
							AND cbLog.intRelatedTransactionId = actual.intRelatedTransactionId
							AND cbLog.intRelatedTransactionDetailId = actual.intRelatedTransactionDetailId
					ORDER BY 
							t.intInventoryTransactionId DESC 
				) t
				OUTER APPLY (
					SELECT	TOP 1 
							t.* 
					FROM	tblICInventoryTransaction t INNER JOIN tblICItemLocation il
								ON il.intItemLocationId = t.intItemLocationId
							INNER JOIN tblICInventoryActualCostAdjustmentLog cbLog 
								ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
					WHERE	t.strBatchId = @strBatchId
							AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
							AND cbLog.strRelatedTransactionId = actual.strRelatedTransactionId
							AND cbLog.intRelatedTransactionId = actual.intRelatedTransactionId
							AND cbLog.intRelatedTransactionDetailId = actual.intRelatedTransactionDetailId
							AND il.intLocationId IS NULL 
				) isInTransit
		WHERE	TransType.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Variance
				AND ABS(ROUND(actual.[variance], 2)) <= 1
				AND ROUND(actual.[variance], 2) % 1 <> 0
	)
	INSERT INTO @GLEntries (
		dtmDate
		,strBatchId
		,intAccountId
		,dblDebit
		,dblCredit
		,dblDebitUnit
		,dblCreditUnit
		,strDescription
		,strCode
		,strReference
		,intCurrencyId
		,dblExchangeRate
		,dtmDateEntered
		,dtmTransactionDate
		,strJournalLineDescription
		,intJournalLineNo
		,ysnIsUnposted
		,intUserId
		,intEntityId
		,strTransactionId
		,intTransactionId
		,strTransactionType
		,strTransactionForm
		,strModuleName
		,intConcurrencyId
		,dblDebitForeign
		,dblDebitReport
		,dblCreditForeign
		,dblCreditReport
		,dblReportingRate
		,dblForeignRate
	)
	SELECT	
			dtmDate						= DecimalDiscrepancy.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= tblGLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= dbo.fnCreateCostAdjGLDescription(
											@strGLDescription
											,tblGLAccount.strDescription
											,DecimalDiscrepancy.strItemNo
											,DecimalDiscrepancy.strRelatedTransactionId
										)
			,strCode					= 'ICA' 
			,strReference				= '17' 
			,intCurrencyId				= DecimalDiscrepancy.intCurrencyId
			,dblExchangeRate			= DecimalDiscrepancy.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= DecimalDiscrepancy.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= DecimalDiscrepancy.intInventoryTransactionId
			,ysnIsUnposted				= 0 --CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= @intEntityUserSecurityId
			,strTransactionId			= DecimalDiscrepancy.strTransactionId
			,intTransactionId			= DecimalDiscrepancy.intTransactionId
			,strTransactionType			= DecimalDiscrepancy.strInventoryTransactionTypeName
			,strTransactionForm			= DecimalDiscrepancy.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= NULL 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= NULL 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= DecimalDiscrepancy.dblForexRate 
	FROM	DecimalDiscrepancy 
			INNER JOIN @GLAccounts GLAccounts
				ON DecimalDiscrepancy.intItemId = GLAccounts.intItemId
				AND DecimalDiscrepancy.intItemLocationId = GLAccounts.intItemLocationId
				AND DecimalDiscrepancy.intTransactionTypeId = GLAccounts.intTransactionTypeId
			INNER JOIN dbo.tblGLAccount
				ON tblGLAccount.intAccountId = GLAccounts.intRevalueInTransit
			CROSS APPLY dbo.fnGetDebit(dblValue) Debit
			CROSS APPLY dbo.fnGetCredit(dblValue) Credit
	WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit_Inventory;

	-- Check if the discrepancy still exists. 
	IF EXISTS (
		SELECT	1
		FROM	@GLEntries
		HAVING	SUM(dblDebit) - SUM(dblCredit) <> 0 
				AND ABS(SUM(dblDebit) - SUM(dblCredit)) <= 1
				AND SUM(dblDebit) - SUM(dblCredit) % 1 <> 0	
	)
	BEGIN 
		DECLARE @discrepancy AS NUMERIC(18, 6)

		SELECT	@discrepancy = -(SUM(dblDebit) - SUM(dblCredit)) 
		FROM	@GLEntries
		HAVING	SUM(dblDebit) - SUM(dblCredit) <> 0 

		INSERT INTO @GLEntries (
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,strReference
			,intCurrencyId
			,dblExchangeRate
			,dtmDateEntered
			,dtmTransactionDate
			,strJournalLineDescription
			,intJournalLineNo
			,ysnIsUnposted
			,intUserId
			,intEntityId
			,strTransactionId
			,intTransactionId
			,strTransactionType
			,strTransactionForm
			,strModuleName
			,intConcurrencyId
			,dblDebitForeign
			,dblDebitReport
			,dblCreditForeign
			,dblCreditReport
			,dblReportingRate
			,dblForeignRate	
		)
		SELECT	TOP 1 
				dtmDate
				,strBatchId
				,glEntries.intAccountId
				,Debit.Value
				,Credit.Value
				,dblDebitUnit
				,dblCreditUnit
				,strDescription = 'Decimal Discrepancy'
				,strCode
				,strReference
				,intCurrencyId
				,dblExchangeRate
				,dtmDateEntered
				,dtmTransactionDate
				,strJournalLineDescription
				,intJournalLineNo
				,ysnIsUnposted
				,intUserId
				,intEntityId
				,strTransactionId
				,intTransactionId
				,strTransactionType
				,strTransactionForm
				,strModuleName
				,glEntries.intConcurrencyId
				,dblDebitForeign
				,dblDebitReport
				,dblCreditForeign
				,dblCreditReport
				,dblReportingRate
				,dblForeignRate					 
		FROM	@GLEntries glEntries
				CROSS APPLY dbo.fnGetDebit(@discrepancy) Debit
				CROSS APPLY dbo.fnGetCredit(@discrepancy) Credit	
				INNER JOIN dbo.tblGLAccount
					ON tblGLAccount.intAccountId = glEntries.intAccountId
				INNER JOIN @GLAccounts GLAccounts
					ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
	END 
END 

-- Return the GL entries back to the caller. 
DECLARE @debug AS BIT = 0
SELECT		
		dtmDate
		,strBatchId
		,intAccountId
		,dblDebit
		,dblCredit
		,dblDebitUnit
		,dblCreditUnit
		,strDescription
		,strCode
		,strReference = CASE WHEN @debug = 0 THEN '' ELSE strReference END 
		,intCurrencyId
		,dblExchangeRate
		,dtmDateEntered
		,dtmTransactionDate
		,strJournalLineDescription
		,intJournalLineNo
		,ysnIsUnposted
		,intUserId
		,intEntityId
		,strTransactionId
		,intTransactionId
		,strTransactionType
		,strTransactionForm
		,strModuleName
		,intConcurrencyId
		,dblDebitForeign
		,dblDebitReport
		,dblCreditForeign
		,dblCreditReport
		,dblReportingRate
		,dblForeignRate 
FROM	@GLEntries

--IF @ysnPost = 0 
--BEGIN 
--	-- Update the ysnPostedFlag 
--	UPDATE	GLEntries
--	SET		ysnIsUnposted = 1
--	FROM	dbo.tblGLDetail GLEntries
--	WHERE	GLEntries.strTransactionId = @strTransactionId
--			AND GLEntries.strCode = 'ICA'
--			AND ysnIsUnposted = 0 
--END 
