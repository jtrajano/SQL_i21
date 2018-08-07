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
					
-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';

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
							AND OtherChargeGLAccounts.intItemLocationId = t.intItemLocationId
				WHERE	t.strBatchId = @strBatchId
						AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
						AND OtherChargeGLAccounts.intItemId IS NULL 
						AND OtherChargeGLAccounts.intItemLocationId IS NULL 
						AND cbLog.intOtherChargeItemId IS NOT NULL 
						AND t.intItemLocationId IS NOT NULL 
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
							AND OtherChargeGLAccounts.intItemLocationId = t.intItemLocationId
				WHERE	t.strBatchId = @strBatchId
						AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
						AND OtherChargeGLAccounts.intItemId IS NULL 
						AND OtherChargeGLAccounts.intItemLocationId IS NULL 
						AND cbLog.intOtherChargeItemId IS NOT NULL 
						AND t.intItemLocationId IS NOT NULL 
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
							AND OtherChargeGLAccounts.intItemLocationId = t.intItemLocationId
				WHERE	t.strBatchId = @strBatchId
						AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
						AND OtherChargeGLAccounts.intItemId IS NULL 
						AND OtherChargeGLAccounts.intItemLocationId IS NULL 
						AND cbLog.intOtherChargeItemId IS NOT NULL 
						AND t.intItemLocationId IS NOT NULL 
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
)
AS 
(
	-- FIFO 
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
	-- LIFO 
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
	-- LOT 
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
	-- ACTUAL COST 
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
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND t.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Variance

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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= NULL 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= NULL 
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
  GL Entries for Adjust In-Transit Inventory (Reduce Inventory from Shipment)
  Debit		... In-Transit 
  Credit	..................... Inventory   
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit_Inventory
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= NULL 
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
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueInTransit
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit_Inventory
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= NULL 
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
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueInTransit
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
WHERE	intInventoryCostAdjustmentTypeId = @COST_ADJ_TYPE_Adjust_InTransit_Inventory

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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
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