CREATE PROCEDURE [dbo].[uspICCreateReturnGLEntries]
	@strBatchId AS NVARCHAR(40)
	,@AccountCategory_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 	
	,@intContraInventory_ItemLocationId AS INT = NULL 
	,@intRebuildItemId AS INT = NULL -- This is only used when rebuilding the stocks. 
	,@strRebuildTransactionId AS NVARCHAR(50) = NULL -- This is only used when rebuilding the stocks. 
	,@intRebuildCategoryId AS INT = NULL -- This is only used when rebuilding the stocks. 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the temp table for the specific items/categories to rebuild
IF OBJECT_ID('tempdb..#tmpRebuildList') IS NULL  
BEGIN 
	CREATE TABLE #tmpRebuildList (
		intItemId INT NULL 
		,intCategoryId INT NULL 
	)	
END 

IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpRebuildList)
BEGIN 
	INSERT INTO #tmpRebuildList VALUES (@intRebuildItemId, @intRebuildCategoryId) 
END 
		
-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
		,@AccountCategory_Auto_Variance AS NVARCHAR(30) = 'Inventory Adjustment' --'Auto-Variance'
		,@AccountCategory_Cost_of_Goods AS NVARCHAR(30) = 'Cost of Goods'

-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the variables for the internal transaction types used by costing. 
DECLARE @InventoryTransactionTypeId_AutoNegative AS INT = 1;
DECLARE @InventoryTransactionTypeId_WriteOffSold AS INT = 2;
DECLARE @InventoryTransactionTypeId_RevalueSold AS INT = 3;
DECLARE @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock AS INT = 35;
DECLARE @InventoryTransactionTypeId_InventoryAdjustmentQtyChange AS INT = 10;

DECLARE @strTransactionForm NVARCHAR(255) = 'Inventory Receipt'

-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';

-- Get the GL Account ids to use
DECLARE @GLAccounts AS dbo.ItemGLAccount; 
INSERT INTO @GLAccounts (
	intItemId 
	,intItemLocationId 
	,intInventoryId 
	,intContraInventoryId 
	,intAutoNegativeId 
	,intCOGSId
	,intTransactionTypeId
)
SELECT	Query.intItemId
		,Query.intItemLocationId
		,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, ISNULL(@intContraInventory_ItemLocationId, Query.intItemLocationId), @AccountCategory_ContraInventory) 		
		,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Auto_Variance) 
		,intCOGSId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Cost_of_Goods) 
		,intTransactionTypeId
FROM	(
			SELECT  DISTINCT 
					t.intItemId
					, t.intItemLocationId
					, t.intTransactionTypeId
			FROM (
				-- regular inventory transactions 
				SELECT	t.intItemId, t.intItemLocationId, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICItem i
							ON t.intItemId = i.intItemId
						INNER JOIN #tmpRebuildList list	
							ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
							AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
				WHERE	t.strBatchId = @strBatchId
						AND t.strTransactionId = ISNULL(@strRebuildTransactionId, t.strTransactionId)
				-- inventory-adj-qty-change transactions involved in the item return. 
				UNION ALL 
				SELECT	DISTINCT t.intItemId, t.intItemLocationId, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryReturned rtn 
							ON t.intInventoryTransactionId = rtn.intInventoryTransactionId
						INNER JOIN tblICItem i
							ON t.intItemId = i.intItemId
						INNER JOIN #tmpRebuildList list	
							ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
							AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
				WHERE	rtn.strBatchId = @strBatchId
						AND rtn.strTransactionId = ISNULL(@strRebuildTransactionId, rtn.strTransactionId)
			) t 			
		) Query

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
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_Inventory;
		RETURN -1;
	END 
END 
;

-- Check for missing Contra-Account Id
IF @AccountCategory_ContraInventory IS NOT NULL 
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	dbo.tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
			--LEFT JOIN dbo.tblICInventoryTransactionWithNoCounterAccountCategory ExemptedList
			--	ON ItemGLAccount.intTransactionTypeId = ExemptedList.intTransactionTypeId
	WHERE	ItemGLAccount.intContraInventoryId IS NULL 			
			--AND ExemptedList.intTransactionTypeId IS NULL 

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
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_ContraInventory;
		RETURN -1;
	END 
END 
;

-- Check for missing COGS Id
IF EXISTS (SELECT TOP 1 1 FROM tblICInventoryReturned rtn WHERE rtn.strBatchId = @strBatchId) 
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	dbo.tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intCOGSId IS NULL
	
	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @GLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intCOGSId IS NULL 				 			
			
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_Cost_of_Goods;
		RETURN -1;
	END 
END 
;

-- Check for missing Auto Variance Account Id
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intAutoNegativeId IS NULL 
			AND EXISTS (
				SELECT	TOP 1 1 
				FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
							ON t.intTransactionTypeId = TransType.intTransactionTypeId
						INNER JOIN tblICItem i 
							ON i.intItemId = t.intItemId
						INNER JOIN #tmpRebuildList list	
							ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
							AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
				WHERE	t.strBatchId = @strBatchId
						AND TransType.intTransactionTypeId IN (@InventoryTransactionTypeId_AutoNegative, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock)
						AND t.intItemId = Item.intItemId
						AND t.dblQty * t.dblCost + t.dblValue <> 0
			)

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @GLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intAutoNegativeId IS NULL 				 			
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_Auto_Variance;
		RETURN -1;
	END 
END 
;

-- Log the g/l account used in this batch. 
INSERT INTO dbo.tblICInventoryGLAccountUsedOnPostLog (
		intItemId
		,intItemLocationId
		,intInventoryId
		,intContraInventoryId
		,intWriteOffSoldId
		,intRevalueSoldId
		,intAutoNegativeId
		,strBatchId
)
SELECT 
		intItemId
		,intItemLocationId
		,intInventoryId
		,intContraInventoryId
		,intWriteOffSoldId
		,intRevalueSoldId
		,intAutoNegativeId
		,@strBatchId
FROM	@GLAccounts
;

-- Get the default transaction form name
SELECT TOP 1 
		@strTransactionForm = TransType.strTransactionForm
FROM	dbo.tblICInventoryTransactionType TransType		
WHERE	TransType.strName = 'Inventory Receipt'
;

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 
;

-- Generate the G/L Entries for Inventory Transactions 
WITH ForGLEntries_CTE (
	dtmDate
	,intItemId
	,intItemLocationId
	,intTransactionId
	,strTransactionId
	,dblQty
	,dblUOMQty
	,dblCost
	,dblValue
	,intTransactionTypeId
	,intCurrencyId
	,dblExchangeRate
	,intInventoryTransactionId
	,strInventoryTransactionTypeName
	,strTransactionForm
	,strDescription
	,dblForexRate
	,strRateType 
	,strItemNo
	,dblReceiptUnitCost
	,dblReturnUnitCostInFunctionalCurrency
	,intSourceEntityId
	,intCommodityId
	,intReference
)
AS 
(
	-- Load the Inventory Returns
	SELECT	dtmDate	= r.dtmReceiptDate
			,t.intItemId
			,t.intItemLocationId
			,intTransactionId = r.intInventoryReceiptId
			,strTransactionId = r.strReceiptNumber
			,dblQty = t.dblQty
			,dblUOMQty = t.dblUOMQty
			,dblCost = t.dblCost
			,dblValue = CAST(0  AS NUMERIC(18, 6)) 
			,t.intTransactionTypeId
			,intCurrencyId = r.intCurrencyId
			,dblExchangeRate = ISNULL(ri.dblForexRate, 1) 
			,intInventoryTransactionId = t.intInventoryTransactionId 
			,ty.strTransactionType
			,ty.strTransactionForm 
			,strDescription = NULL  
			,dblForexRate = ri.dblForexRate
			,strRateType = currencyRateType.strCurrencyExchangeRateType
			,i.strItemNo
			,dblReceiptUnitCost = 
					(
						dbo.fnCalculateReceiptUnitCost(
							ri.intItemId
							,ri.intUnitMeasureId		
							,ri.intCostUOMId
							,ri.intWeightUOMId
							,ri.dblUnitCost
							,ri.dblNet
							,t.intLotId
							,t.intItemUOMId
							,AggregrateItemLots.dblTotalNet
							,ri.ysnSubCurrency
							,r.intSubCurrencyCents
							,t.intItemUOMId
						)
					)
			,dblReturnUnitCostInFunctionalCurrency = 
				CASE 
					WHEN ISNULL(r.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(ri.dblForexRate, 0) <> 0 THEN 
						dbo.fnMultiply(
							(
								dbo.fnCalculateReceiptUnitCost(
									ri.intItemId
									,ri.intUnitMeasureId		
									,ri.intCostUOMId
									,ri.intWeightUOMId
									,ri.dblUnitCost
									,ri.dblNet
									,t.intLotId
									,t.intItemUOMId
									,AggregrateItemLots.dblTotalNet
									,ri.ysnSubCurrency
									,r.intSubCurrencyCents
									,t.intItemUOMId
								)
							)
							,ri.dblForexRate
						)
					ELSE 
						(
							dbo.fnCalculateReceiptUnitCost(
								ri.intItemId
								,ri.intUnitMeasureId		
								,ri.intCostUOMId
								,ri.intWeightUOMId
								,ri.dblUnitCost
								,ri.dblNet
								,t.intLotId
								,t.intItemUOMId
								,AggregrateItemLots.dblTotalNet
								,ri.ysnSubCurrency
								,r.intSubCurrencyCents
								,t.intItemUOMId
							)
						)
				END 
			,intSourceEntityId = t.intSourceEntityId 
			,i.intCommodityId
			,intReference = CAST(1 AS TINYINT)
	FROM	tblICInventoryReceipt r INNER JOIN (
				tblICInventoryReceiptItem ri LEFT JOIN tblICInventoryReceiptItemLot ril
					ON ri.intInventoryReceiptItemId  = ril.intInventoryReceiptItemId
			)
				ON  r.intInventoryReceiptId = ri.intInventoryReceiptId				

			CROSS APPLY (
				SELECT	dblQty = -rtn.dblQtyReturned
						,dblUOMQty = t.dblUOMQty 
						,rtn.dblCost
						,rtn.strBatchId
						,rtn.intTransactionId
						,rtn.intTransactionDetailId
						,rtn.strTransactionId
						,rtn.intTransactionTypeId
						,t.intInventoryTransactionId
						,cb.intLotId
						,cb.intItemId
						,cb.intItemUOMId
						,cb.intItemLocationId
						,t.intSourceEntityId
				FROM	tblICInventoryReturned rtn 
						OUTER APPLY (
							SELECT	cbLot.intItemId
									,cbLot.intItemLocationId
									,cbLot.intLotId
									,cbLot.intItemUOMId
									,dblUOMQty = uom.dblUnitQty
							FROM	tblICInventoryLot cbLot LEFT JOIN tblICItemUOM uom
										ON cbLot.intItemUOMId = uom.intItemUOMId 
							WHERE	cbLot.intInventoryLotId = rtn.intInventoryLotId
									AND rtn.intInventoryLotId IS NOT NULL
							UNION ALL 
							SELECT	cbFifo.intItemId
									,cbFifo.intItemLocationId
									,intLotId = CAST(NULL AS INT) 
									,cbFifo.intItemUOMId
									,dblUOMQty = uom.dblUnitQty
							FROM	tblICInventoryFIFO cbFifo LEFT JOIN tblICItemUOM uom
										ON cbFifo.intItemUOMId = uom.intItemUOMId 
							WHERE	cbFifo.intInventoryFIFOId = rtn.intInventoryFIFOId
									AND rtn.intInventoryFIFOId IS NOT NULL
							UNION ALL 
							SELECT	cbLifo.intItemId
									,cbLifo.intItemLocationId
									,intLotId = CAST(NULL AS INT) 
									,cbLifo.intItemUOMId 
									,dblUOMQty = uom.dblUnitQty
							FROM	tblICInventoryLIFO cbLifo LEFT JOIN tblICItemUOM uom
										ON cbLifo.intItemUOMId = uom.intItemUOMId 
							WHERE	cbLifo.intInventoryLIFOId = rtn.intInventoryLIFOId
									AND rtn.intInventoryLIFOId IS NOT NULL 
							UNION ALL 
							SELECT	cbActualCost.intItemId
									,cbActualCost.intItemLocationId
									,intLotId = CAST(NULL AS INT) 
									,cbActualCost.intItemUOMId
									,dblUOMQty = uom.dblUnitQty
							FROM	tblICInventoryActualCost cbActualCost LEFT JOIN tblICItemUOM uom
										ON cbActualCost.intItemUOMId = uom.intItemUOMId 
							WHERE	cbActualCost.intInventoryActualCostId = rtn.intInventoryActualCostId
									AND rtn.intInventoryActualCostId IS NOT NULL 				
						) cb
						LEFT JOIN tblICInventoryTransaction t
							ON rtn.intInventoryTransactionId = t.intInventoryTransactionId
				WHERE	rtn.intTransactionId = r.intInventoryReceiptId
						AND rtn.strTransactionId = r.strReceiptNumber
						AND rtn.intTransactionDetailId = ri.intInventoryReceiptItemId
						AND ISNULL(cb.intLotId, 0) = COALESCE(ril.intLotId, cb.intLotId, 0) 
			) t
			INNER JOIN tblICItem i
				ON i.intItemId = ri.intItemId
			INNER JOIN #tmpRebuildList list	
				ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
			OUTER APPLY (
				SELECT TOP 1 intItemUOMId FROM tblICItemUOM iu WHERE iu.intItemId = i.intItemId AND iu.ysnStockUnit = 1
			) stockUOM
			OUTER APPLY (
				SELECT  dblTotalNet = SUM(
							CASE	WHEN  ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0) = 0 THEN -- If Lot net weight is zero, convert the 'Pack' Qty to the Volume or Weight. 											
										ISNULL(dbo.fnCalculateQtyBetweenUOM(ReceiptItemLot.intItemUnitMeasureId, ReceiptItem.intWeightUOMId, ReceiptItemLot.dblQuantity), 0) 
									ELSE 
										ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0)
							END 
						)
				FROM	tblICInventoryReceiptItem ReceiptItem INNER JOIN tblICInventoryReceiptItemLot ReceiptItemLot
							ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId
				WHERE	ReceiptItem.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			) AggregrateItemLots
			OUTER APPLY (
				SELECT TOP 1 
						strTransactionType = ty.strName
						,ty.intTransactionTypeId
						,strTransactionForm = 'Inventory Receipt'
				FROM	dbo.tblICInventoryTransactionType ty
				WHERE	ty.strName = 'Inventory Return'
			) ty
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = ri.intForexRateTypeId
	WHERE	t.strBatchId = @strBatchId

	-- Resolve the 0.01 discrepancy between the inventory transaction value and the return line total. 
	UNION ALL
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId 
			--,t.intInTransitSourceLocationId
			,t.intTransactionId
			,t.strTransactionId
			,dblQty = 0
			,dblUOMQty = 0 
			,dblCost = 0 
			,dblValue = ROUND(ri.[dblRecomputeLineTotal] - topRi.dblLineTotal, 2) 
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) intCurrencyId
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = t.strTransactionType
			,t.strTransactionForm 
			,strDescription = 
				dbo.fnFormatMessage(
					'Resolve the decimal discrepancy for %s.'
					,ri.strItemNo
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
					,DEFAULT 
				)
			,dblForexRate = t.dblForexRate
			,strRateType = currencyRateType.strCurrencyExchangeRateType
			,ri.strItemNo
			,dblReceiptUnitCost = NULL 
			,dblReturnUnitCostInFunctionalCurrency = NULL 
			,t.intSourceEntityId
			,i.intCommodityId
			,intReference = CAST(2 AS TINYINT)
	FROM	(
				SELECT 
					i.strItemNo
					,ri.intInventoryReceiptItemId
					,r.strReceiptNumber
					,r.intInventoryReceiptId
					,dblRecomputeLineTotal = SUM(
						     ROUND(
								 -t.dblQty * 
								 dbo.fnCalculateReceiptUnitCost (
									ri.intItemId
									,ri.intUnitMeasureId		
									,ri.intCostUOMId
									,ri.intWeightUOMId
									,ri.dblUnitCost
									,ri.dblNet
									,t.intLotId
									,t.intItemUOMId
									,AggregrateItemLots.dblTotalNet
									,ri.ysnSubCurrency
									,r.intSubCurrencyCents
									,t.intItemUOMId
								)
								,2 
							)
						)			
				FROM 
					tblICInventoryReceiptItem ri INNER JOIN tblICInventoryReceipt r
						ON ri.intInventoryReceiptId = r.intInventoryReceiptId
					INNER JOIN tblICItem i 
						ON ri.intItemId = i.intItemId
					INNER JOIN #tmpRebuildList list	
						ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
						AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
					INNER JOIN tblICInventoryTransaction t 
						ON t.intTransactionId = r.intInventoryReceiptId
						AND t.strTransactionId = r.strReceiptNumber
						AND t.intTransactionDetailId = ri.intInventoryReceiptItemId
					OUTER APPLY (
						SELECT  dblTotalNet = SUM(
									CASE	WHEN  ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0) = 0 THEN -- If Lot net weight is zero, convert the 'Pack' Qty to the Volume or Weight. 											
												ISNULL(dbo.fnCalculateQtyBetweenUOM(ReceiptItemLot.intItemUnitMeasureId, ReceiptItem.intWeightUOMId, ReceiptItemLot.dblQuantity), 0) 
											ELSE 
												ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0)
									END 
								)
						FROM	tblICInventoryReceiptItem ReceiptItem INNER JOIN tblICInventoryReceiptItemLot ReceiptItemLot
									ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId
						WHERE	ReceiptItem.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AggregrateItemLots
				WHERE
					t.strBatchId = @strBatchId
				GROUP BY
					i.strItemNo
					,ri.intInventoryReceiptItemId
					,r.strReceiptNumber
					,r.intInventoryReceiptId
										
			) ri
			CROSS APPLY (
				SELECT 
					TOP 1 
					topRi.* 
				FROM 
					tblICInventoryReceiptItem topRi 
				WHERE
					topRi.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			) topRi 		

			CROSS APPLY (
				SELECT TOP 1 
					t.* 
					,strTransactionType = ty.strName
				FROM 
					tblICInventoryTransaction t INNER JOIN tblICInventoryTransactionType ty
						ON t.intTransactionTypeId = ty.intTransactionTypeId
				WHERE
					t.strTransactionId = ri.strReceiptNumber
					AND t.intTransactionId = ri.intInventoryReceiptId
					AND t.intTransactionDetailId = ri.intInventoryReceiptItemId
					AND ty.strName = 'Inventory Return'
				ORDER BY t.intInventoryTransactionId DESC 
			) t

			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId

			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId

	WHERE	
			ri.[dblRecomputeLineTotal] - topRi.dblLineTotal <> 0 

	-- Load the Inventory-Adjustment
	UNION ALL 
	SELECT	
			t.dtmDate
			,t.intItemId
			,t.intItemLocationId
			,t.intTransactionId 
			,t.strTransactionId 
			,dblQty = t.dblQty 
			,dblUOMQty = t.dblUOMQty
			,dblCost = t.dblCost 
			,dblValue = t.dblValue 
			,t.intTransactionTypeId
			,t.intCurrencyId 
			,t.dblExchangeRate 
			,t.intInventoryTransactionId 
			,ty.strTransactionType
			,ty.strTransactionForm 
			,strDescription = NULL  
			,t.dblForexRate 
			,strRateType = currencyRateType.strCurrencyExchangeRateType
			,i.strItemNo
			,dblReceiptUnitCost = NULL 
			,dblReturnUnitCostInFunctionalCurrency = NULL 
			,intSourceEntityId = t.intSourceEntityId 
			,i.intCommodityId
			,intReference = CAST(3 AS TINYINT)
	FROM	tblICInventoryTransaction t INNER JOIN tblICItem i
				ON t.intItemId = i.intItemId 
			INNER JOIN #tmpRebuildList list	
				ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
			OUTER APPLY (
				SELECT TOP 1 
						strTransactionType = ty.strName
						,ty.intTransactionTypeId
						,strTransactionForm = 'Inventory Receipt'
				FROM	dbo.tblICInventoryTransactionType ty
				WHERE	ty.strName = 'Inventory Return'
			) ty
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
	WHERE	t.strBatchId = @strBatchId
			AND t.intTransactionTypeId IN (
				@InventoryTransactionTypeId_WriteOffSold
				, @InventoryTransactionTypeId_RevalueSold
				, @InventoryTransactionTypeId_AutoNegative
				, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock			
			)


)
-------------------------------------------------------------------------------------------
-- This part is for the usual G/L entries for Inventory Account and its contra account 
-------------------------------------------------------------------------------------------
/*
	
	1. AP clearing needs to be posted against the same cost used in the original receipt. 
	2. Inventory cost needs to posted against the cost from the cost bucket. In case of add-on cost, where charges with 
	Inventory-Cost set to yes, cost will be higher in the return compared to the IR cost. 
	3. The difference between the cost from original IR and cost bucket will be posted against the Inventory Adjustment. 

	Debit  ............ AP Clearing
	Debit  ............ COGS (Do Inventory Adjustment for cost difference) 
	Credit ............................... Inventory 


	4. In case the stock shrinks before it was returned, the GL entries will become like this: 

	Debit  ............ AP Clearing
	Debit  ............ COGS (Do Inventory Adjustment for cost difference) 
	Credit ............................... Inventory 
	Credit ............................... COGS (Do Inventory Adjustment due to shrinkage)

*/

-- AP Clearing: 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= CreditUnit.Value
		,dblCreditUnit				= DebitUnit.Value
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblReceiptUnitCost) 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
FROM	ForGLEntries_CTE  
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount 
			ON tblGLAccount.intAccountId = GLAccounts.intContraInventoryId
		CROSS APPLY dbo.fnGetDebitFunctional(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblReceiptUnitCost, 0)) 
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblReceiptUnitCost, 0)) 
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) Credit
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblReceiptUnitCost, 0)) 
		) DebitForeign
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblReceiptUnitCost, 0)) 
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.intTransactionTypeId NOT IN (
			@InventoryTransactionTypeId_WriteOffSold
			, @InventoryTransactionTypeId_RevalueSold
			, @InventoryTransactionTypeId_AutoNegative
			, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
		)
		AND ForGLEntries_CTE.intReference = 1

-- COGS (Inventory Adjustment) 
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= NULL --CreditUnit.Value
		,dblCreditUnit				= NULL --DebitUnit.Value
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, (ISNULL(dblCost, 0) - ISNULL(dblReceiptUnitCost, 0))) 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
FROM	ForGLEntries_CTE  
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount 
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(
			ROUND(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)), 2)
			- ROUND(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblReturnUnitCostInFunctionalCurrency, 0)), 2)
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			ROUND(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)), 2)
			- ROUND(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblReturnUnitCostInFunctionalCurrency, 0)), 2) 
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			(
				ROUND(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0) ), 2)
				- ROUND(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblReturnUnitCostInFunctionalCurrency, 0)), 2)
			)
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			(
				ROUND(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)),2)
				- ROUND(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblReturnUnitCostInFunctionalCurrency, 0)), 2)
			)
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 


WHERE	ForGLEntries_CTE.intTransactionTypeId NOT IN (
			@InventoryTransactionTypeId_WriteOffSold
			, @InventoryTransactionTypeId_RevalueSold
			, @InventoryTransactionTypeId_AutoNegative
			, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
		)
		AND (
			ROUND(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)), 2)
			- ROUND(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblReturnUnitCostInFunctionalCurrency, 0)), 2) 	
		) <> 0
		AND ForGLEntries_CTE.intReference = 1

-- Inventory 
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= DebitUnit.Value
		,dblCreditUnit				= CreditUnit.Value
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm) 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId

		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)				
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.intTransactionTypeId NOT IN (
			@InventoryTransactionTypeId_WriteOffSold
			, @InventoryTransactionTypeId_RevalueSold
			, @InventoryTransactionTypeId_AutoNegative
			, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
			, @InventoryTransactionTypeId_InventoryAdjustmentQtyChange
		)
		AND ForGLEntries_CTE.intReference = 1

-- Inventory-Adjustment during stock shrinking. 
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= DebitUnit.Value
		,dblCreditUnit				= CreditUnit.Value
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm) 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId

		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)				
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.intTransactionTypeId IN (
			@InventoryTransactionTypeId_InventoryAdjustmentQtyChange			
		)
		AND ForGLEntries_CTE.intReference = 1

-----------------------------------------------------------------------------------
-- This part is for the Auto Variance on Used or Sold Stock
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= DebitUnit.Value
		,dblCreditUnit				= CreditUnit.Value
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IAV'
		,strReference				= ''
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm) 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)				
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
		AND (Debit.Value <> 0 OR Credit.Value <> 0)

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= CreditUnit.Value
		,dblCreditUnit				= DebitUnit.Value
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IAV' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription    = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName 
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)				
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.intTransactionTypeId  = @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
		AND (Debit.Value <> 0 OR Credit.Value <> 0)

-----------------------------------------------------------------------------------
-- This part is for the Auto-Variance 
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= DebitUnit.Value
		,dblCreditUnit				= CreditUnit.Value
		,strDescription				= ISNULL(ForGLEntries_CTE.strDescription, tblGLAccount.strDescription)
		,strCode					= 'IAN' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)				
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_AutoNegative
		AND (Debit.Value <> 0 OR Credit.Value <> 0)

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= CreditUnit.Value 
		,dblCreditUnit				= DebitUnit.Value 
		,strDescription				= ISNULL(ForGLEntries_CTE.strDescription, tblGLAccount.strDescription)
		,strCode					= 'IAN' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)				
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.intTransactionTypeId  = @InventoryTransactionTypeId_AutoNegative
		AND (Debit.Value <> 0 OR Credit.Value <> 0)

-----------------------------------------------------------------------------------
-- This part is to resolve the decimal discrepancy.
-----------------------------------------------------------------------------------
/*
	Debit .............................. AP Clearing
	Credit ........... COGS (Auto Variance)
*/

UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= DebitUnit.Value
		,dblCreditUnit				= CreditUnit.Value
		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) 
										+ ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
										+ ' ' + ForGLEntries_CTE.strDescription 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId 
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intContraInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.intTransactionTypeId NOT IN (
			@InventoryTransactionTypeId_AutoNegative
			,@InventoryTransactionTypeId_WriteOffSold
			,@InventoryTransactionTypeId_RevalueSold
			,@InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
		)
		AND ISNULL(dblValue, 0) <> 0 
		AND ForGLEntries_CTE.intReference = 2

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= CreditUnit.Value
		,dblCreditUnit				= DebitUnit.Value
		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) 
									+ ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
									+ ' ' + ForGLEntries_CTE.strDescription 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId 
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		CROSS APPLY dbo.fnGetDebitForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) DebitForeign
		CROSS APPLY dbo.fnGetCreditForeign(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.intTransactionTypeId NOT IN (
			@InventoryTransactionTypeId_AutoNegative
			,@InventoryTransactionTypeId_WriteOffSold
			,@InventoryTransactionTypeId_RevalueSold
			,@InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
		)
		AND ISNULL(dblValue, 0) <> 0 
		AND ForGLEntries_CTE.intReference = 2
;
