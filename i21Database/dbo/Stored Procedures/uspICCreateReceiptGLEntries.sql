CREATE PROCEDURE [dbo].[uspICCreateReceiptGLEntries]
	@strBatchId AS NVARCHAR(40)
	,@AccountCategory_ContraInventory AS NVARCHAR(255) = 'AP Clearing'
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
DECLARE @AccountCategory_Adjustment AS NVARCHAR(30) = 'Inventory Adjustment' --'Auto-Variance' -- Auto-variance will no longer be used. It will now use Inventory Adjustment. 

-- Create the variables for the internal transaction types used by costing. 
DECLARE @InventoryTransactionTypeId_AutoVariance AS INT = 1;
DECLARE @InventoryTransactionTypeId_WriteOffSold AS INT = 2;
DECLARE @InventoryTransactionTypeId_RevalueSold AS INT = 3;
DECLARE @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock AS INT = 35;

DECLARE @strTransactionForm NVARCHAR(255)

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
	,intTransactionTypeId
)
SELECT	Query.intItemId
		,Query.intItemLocationId
		,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, ISNULL(@intContraInventory_ItemLocationId, Query.intItemLocationId), @AccountCategory_ContraInventory) 
		,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Adjustment) 
		,intTransactionTypeId
FROM	(
			SELECT	DISTINCT 
					intItemId
					, intItemLocationId 
					, intTransactionTypeId
			FROM	(
				SELECT	DISTINCT 
						t.intItemId
						, t.intItemLocationId 
						, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICItem i
							ON t.intItemId = i.intItemId
						INNER JOIN #tmpRebuildList list	
							ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
							AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
				WHERE	t.strBatchId = @strBatchId
						AND t.strTransactionId = ISNULL(@strRebuildTransactionId, t.strTransactionId)
						--AND i.strType <> 'Non-Inventory'
				UNION ALL 
				SELECT	DISTINCT 
						t.intItemId
						, t.intInTransitSourceLocationId 
						, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICItem i
							ON t.intItemId = i.intItemId
						INNER JOIN #tmpRebuildList list	
							ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
							AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
				WHERE	t.strBatchId = @strBatchId
						AND t.strTransactionId = ISNULL(@strRebuildTransactionId, t.strTransactionId)
						AND t.intInTransitSourceLocationId IS NOT NULL
						--AND i.strType <> 'Non-Inventory'
				UNION ALL 
				SELECT	DISTINCT 
						t.intItemId
						, t.intItemLocationId 
						, @InventoryTransactionTypeId_AutoVariance
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICItem i
							ON t.intItemId = i.intItemId
						INNER JOIN #tmpRebuildList list	
							ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
							AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
				WHERE	t.strBatchId = @strBatchId
						AND t.strTransactionId = ISNULL(@strRebuildTransactionId, t.strTransactionId)
						AND t.intItemLocationId IS NOT NULL
						AND t.intInTransitSourceLocationId IS NULL
						--AND i.strType <> 'Non-Inventory'
			) InnerQuery
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
						AND TransType.intTransactionTypeId IN (@InventoryTransactionTypeId_AutoVariance, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock)
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
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_Adjustment;
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
FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
			ON t.intTransactionTypeId = TransType.intTransactionTypeId
		INNER JOIN tblICItem i
			ON i.intItemId = t.intItemId 
		INNER JOIN #tmpRebuildList list	
			ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
			AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
		INNER JOIN @GLAccounts GLAccounts
			ON t.intItemId = GLAccounts.intItemId
			AND t.intItemLocationId = GLAccounts.intItemLocationId
			AND t.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
WHERE	t.strBatchId = @strBatchId
;

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 
;

-- Generate the G/L Entries here: 
WITH ForGLEntries_CTE (
	dtmDate
	,intItemId
	,intItemLocationId
	,intInTransitSourceLocationId
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
	,strItemNo
	,strRateType
	,dblLineTotal
	--,dblAddOnCostFromOtherCharge
	,intSourceEntityId
	,intCommodityId
	,intReference
)
AS 
(
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId 
			,t.intInTransitSourceLocationId
			,t.intTransactionId
			,t.strTransactionId
			,t.dblQty
			,t.dblUOMQty
			,t.dblCost
			,dblValue = ROUND(t.dblValue, 2) 
			,t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) intCurrencyId
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,t.strTransactionForm 
			,t.strDescription
			,t.dblForexRate	
			,i.strItemNo
			,strRateType = currencyRateType.strCurrencyExchangeRateType
			,dblLineTotal = 
					dbo.fnMultiply(
						t.dblQty
						,dbo.fnCalculateReceiptUnitCost(
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
							,CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 THEN stockUOM.intItemUOMId ELSE NULL END
						)
					)						
			--,dblAddOnCostFromOtherCharge = t.dblQty * dbo.fnGetOtherChargesFromInventoryReceipt(ri.intInventoryReceiptItemId)		
			,t.intSourceEntityId
			,i.intCommodityId
			,intReference = CAST(1 AS TINYINT)
	FROM	dbo.tblICInventoryTransaction t 
			INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i
				ON i.intItemId = t.intItemId
			INNER JOIN #tmpRebuildList list	
				ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
			INNER JOIN tblICInventoryReceipt r
				ON r.strReceiptNumber = t.strTransactionId
				AND r.intInventoryReceiptId = t.intTransactionId			
			LEFT JOIN tblICInventoryReceiptItem ri
				ON ri.intInventoryReceiptId = r.intInventoryReceiptId
				AND ri.intInventoryReceiptItemId = t.intTransactionDetailId
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
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
	WHERE	t.strBatchId = @strBatchId

	-- Resolve the 0.01 discrepancy between the inventory transaction value and the receipt line total. 
	UNION ALL
	SELECT	t.dtmDate
			,t.intItemId
			,t.intItemLocationId 
			,t.intInTransitSourceLocationId
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
			,t.dblForexRate	
			,ri.strItemNo
			,strRateType = currencyRateType.strCurrencyExchangeRateType
			,dblLineTotal = NULL
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
								 t.dblQty * 
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
									,CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 THEN stockUOM.intItemUOMId ELSE NULL END
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
					OUTER APPLY (
						SELECT TOP 1 intItemUOMId FROM tblICItemUOM iu WHERE iu.intItemId = i.intItemId AND iu.ysnStockUnit = 1
					) stockUOM
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
					AND ty.strName = 'Inventory Receipt'
				ORDER BY t.intInventoryTransactionId DESC 
			) t

			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId

			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId

	WHERE	
			ri.[dblRecomputeLineTotal] - topRi.dblLineTotal <> 0 

	UNION ALL 
	SELECT	
			dtmDate = t.dtmDate
			,intItemId = t.intItemId
			,intItemLocationId  = t.intItemLocationId
			,intInTransitSourceLocationId = NULL 
			,intTransactionId = t.intTransactionId
			,strTransactionId = t.strTransactionId 
			,dblQty = 0
			,dblUOMQty = 0 
			,dblCost = 0 
			,dblValue = 
				-- Cost Bucket Value
				ROUND(
					dbo.fnMultiply(t.dblQty, t.dblCost)
					,2
				)
				- 
				-- Less Return Value
				ROUND(
					dbo.fnMultiply(
						t.dblQty 
						,dbo.fnCalculateReceiptUnitCost(
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
							,CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 THEN stockUOM.intItemUOMId ELSE NULL END
						)
					)
					,2
				)
			,intTransactionTypeId = t.intTransactionTypeId
			,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) intCurrencyId
			,dblExchangeRate = t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = TransType.strTransactionForm
			,strDescription = 
					-- 'Returning {Qty} for {Item No}. Return cost is {IR Cost} and cb cost is at {Cb Cost}. The inventory adjustment value is {Adjustment Value}.'
					dbo.fnFormatMessage(
						'Returning %f %s for %s. Return cost is %f and the costing method is at %f. The inventory adjustment value is %f.'
						, ABS(t.dblQty) 
						, u.strUnitMeasure
						, i.strItemNo
						, dbo.fnCalculateReceiptUnitCost(
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
							,CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 THEN stockUOM.intItemUOMId ELSE NULL END 
						)	
						, t.dblCost
						, (
							-- Cost Bucket Value
							ROUND(
								t.dblQty * t.dblCost 
								,2
							)
							- 
							-- Less Return Value
							ROUND(
								t.dblQty *
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
									,CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 THEN stockUOM.intItemUOMId ELSE NULL END 
								)
								,2
							)
						)
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
					)
			,dblForexRate = t.dblForexRate
			,strItemNo = i.strItemNo 
			,strRateType = currencyRateType.strCurrencyExchangeRateType
			,dblLineTotal = NULL 
			,t.intSourceEntityId
			,i.intCommodityId
			,intReference = CAST(3 AS TINYINT)
	FROM	dbo.tblICInventoryTransaction t 
			INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TransType.intTransactionTypeId = t.intTransactionTypeId
			INNER JOIN tblICItem i
				ON i.intItemId = t.intItemId
			INNER JOIN #tmpRebuildList list	
				ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
			INNER JOIN tblICInventoryReceipt r
				ON  r.strReceiptNumber = t.strTransactionId
				AND r.intInventoryReceiptId = t.intTransactionId
			INNER JOIN (
				tblICItemUOM iu INNER JOIN tblICUnitMeasure u
					ON iu.intUnitMeasureId = u.intUnitMeasureId
			)
				ON iu.intItemUOMId = t.intItemUOMId
			OUTER APPLY (
				SELECT TOP 1 intItemUOMId FROM tblICItemUOM iu WHERE iu.intItemId = i.intItemId AND iu.ysnStockUnit = 1
			) stockUOM
			LEFT JOIN tblICInventoryReceiptItem ri
				ON  ri.intInventoryReceiptId = r.intInventoryReceiptId
				AND ri.intInventoryReceiptItemId = t.intTransactionDetailId
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
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON 
				currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId

	WHERE	t.strBatchId = @strBatchId
			AND t.intInTransitSourceLocationId IS NULL
			AND t.dblQty < 0 
			AND 
				-- Cost Bucket Value
				ROUND(
					t.dblQty * t.dblCost 
					,2
				)
				- 
				-- Less Return Value
				ROUND(
					t.dblQty *
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
						,CASE WHEN ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 THEN stockUOM.intItemUOMId ELSE NULL END 
					)
					,2 
				)
				<> 0 	
)
-------------------------------------------------------------------------------------------
-- This part is for the usual G/L entries for the Receipt Line Total
-------------------------------------------------------------------------------------------
/*
	Debit ........... Inventory
	Credit .............................. AP Clearing
*/
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= DebitUnit.Value 
		,dblCreditUnit				= CreditUnit.Value
		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
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
			ISNULL(dblLineTotal, 0)
		) DebitForeign
		CROSS APPLY dbo.fnGetCredit(
			ISNULL(dblLineTotal, 0) 			
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitFunctional(
			ISNULL(dblLineTotal, 0)	
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
			ISNULL(dblLineTotal, 0) 			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) Credit
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.dblQty <> 0 
		AND ForGLEntries_CTE.intTransactionTypeId NOT IN (
				@InventoryTransactionTypeId_WriteOffSold
				, @InventoryTransactionTypeId_RevalueSold
				, @InventoryTransactionTypeId_AutoVariance
				, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
			)

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= CreditUnit.Value
		,dblCreditUnit				= DebitUnit.Value
		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
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
			AND ISNULL(ForGLEntries_CTE.intInTransitSourceLocationId, ForGLEntries_CTE.intItemLocationId) = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intContraInventoryId
		CROSS APPLY dbo.fnGetDebit(
			ISNULL(dblLineTotal, 0)			
		) DebitForeign
		CROSS APPLY dbo.fnGetCredit(
			ISNULL(dblLineTotal, 0) 			
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitFunctional(
			ISNULL(dblLineTotal, 0)			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
			ISNULL(dblLineTotal, 0) 			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) Credit
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.dblQty <> 0 
		AND GLAccounts.intContraInventoryId IS NOT NULL 
		AND ForGLEntries_CTE.intTransactionTypeId NOT IN (
				@InventoryTransactionTypeId_WriteOffSold
				, @InventoryTransactionTypeId_RevalueSold
				, @InventoryTransactionTypeId_AutoVariance
				, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
			)

-- -------------------------------------------------------------------------------------------
-- -- This part is for the usual G/L entries for the Inventory Cost coming from Other Charges
-- -------------------------------------------------------------------------------------------
-- UNION ALL 
-- SELECT	
-- 		dtmDate						= ForGLEntries_CTE.dtmDate
-- 		,strBatchId					= @strBatchId
-- 		,intAccountId				= tblGLAccount.intAccountId
-- 		,dblDebit					= Debit.Value
-- 		,dblCredit					= Credit.Value
-- 		,dblDebitUnit				= 0
-- 		,dblCreditUnit				= 0
-- 		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ', ' + 'Added Inventory Cost for ' + strItemNo + ' from Other Charges.' 
-- 		,strCode					= 'IC' 
-- 		,strReference				= '' 
-- 		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
-- 		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
-- 		,dtmDateEntered				= GETDATE()
-- 		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
--         ,strJournalLineDescription  = '' 
-- 		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
-- 		,ysnIsUnposted				= 0
-- 		,intUserId					= @intEntityUserSecurityId 
-- 		,intEntityId				= @intEntityUserSecurityId
-- 		,strTransactionId			= ForGLEntries_CTE.strTransactionId
-- 		,intTransactionId			= ForGLEntries_CTE.intTransactionId
-- 		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
-- 		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
-- 		,strModuleName				= @ModuleName
-- 		,intConcurrencyId			= 1
-- 		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END 
-- 		,dblDebitReport				= NULL 
-- 		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END
-- 		,dblCreditReport			= NULL 
-- 		,dblReportingRate			= NULL 
-- 		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
-- 		,strRateType				= ForGLEntries_CTE.strRateType 
--		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
-- FROM	ForGLEntries_CTE  
-- 		INNER JOIN @GLAccounts GLAccounts
-- 			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
-- 			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
-- 			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
-- 		INNER JOIN dbo.tblGLAccount
-- 			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
-- 		CROSS APPLY dbo.fnGetDebit(
-- 			ISNULL(dblAddOnCostFromOtherCharge, 0)
-- 		) Debit
-- 		CROSS APPLY dbo.fnGetCredit(
-- 			ISNULL(dblAddOnCostFromOtherCharge, 0) 			
-- 		) Credit
-- 		CROSS APPLY dbo.fnGetDebitForeign(
-- 			ISNULL(dblAddOnCostFromOtherCharge, 0)	
-- 			,ForGLEntries_CTE.intCurrencyId
-- 			,@intFunctionalCurrencyId
-- 			,ForGLEntries_CTE.dblForexRate
-- 		) DebitForeign
-- 		CROSS APPLY dbo.fnGetCreditForeign(
-- 			ISNULL(dblAddOnCostFromOtherCharge, 0) 			
-- 			,ForGLEntries_CTE.intCurrencyId
-- 			,@intFunctionalCurrencyId
-- 			,ForGLEntries_CTE.dblForexRate
-- 		) CreditForeign

-- WHERE	ForGLEntries_CTE.dblQty <> 0 
-- 		AND ROUND(dblAddOnCostFromOtherCharge, 2) <> 0 
-- 		AND ForGLEntries_CTE.intTransactionTypeId NOT IN (
-- 				@InventoryTransactionTypeId_WriteOffSold
-- 				, @InventoryTransactionTypeId_RevalueSold
-- 				, @InventoryTransactionTypeId_AutoVariance
-- 				, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
-- 			)

--UNION ALL 
--SELECT	
--		dtmDate						= ForGLEntries_CTE.dtmDate
--		,strBatchId					= @strBatchId
--		,intAccountId				= tblGLAccount.intAccountId
--		,dblDebit					= Credit.Value
--		,dblCredit					= Debit.Value
--		,dblDebitUnit				= 0
--		,dblCreditUnit				= 0
--		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
--		,strCode					= 'IC' 
--		,strReference				= '' 
--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
--		,dtmDateEntered				= GETDATE()
--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
--        ,strJournalLineDescription  = '' 
--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
--		,ysnIsUnposted				= 0
-- 		,intUserId					= @intEntityUserSecurityId 
-- 		,intEntityId				= @intEntityUserSecurityId
--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
--		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm) 
--		,strModuleName				= @ModuleName
--		,intConcurrencyId			= 1
--		,dblDebitForeign			= CreditForeign.Value
--		,dblDebitReport				= NULL 
--		,dblCreditForeign			= DebitForeign.Value 
--		,dblCreditReport			= NULL 
--		,dblReportingRate			= NULL 
--		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
--		,strRateType				= ForGLEntries_CTE.strRateType 
--		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
--FROM	ForGLEntries_CTE 
--		INNER JOIN @GLAccounts GLAccounts
--			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
--			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
--			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
--		INNER JOIN dbo.tblGLAccount
--			ON tblGLAccount.intAccountId = GLAccounts.intContraInventoryId
--		CROSS APPLY dbo.fnGetDebit(
--			ISNULL(dblAddOnCostFromOtherCharge, 0)			
--		) Debit
--		CROSS APPLY dbo.fnGetCredit(
--			ISNULL(dblAddOnCostFromOtherCharge, 0) 			
--		) Credit
--		CROSS APPLY dbo.fnGetDebitForeign(
--			ISNULL(dblAddOnCostFromOtherCharge, 0)			
--			,ForGLEntries_CTE.intCurrencyId
--			,@intFunctionalCurrencyId
--			,ForGLEntries_CTE.dblForexRate
--		) DebitForeign
--		CROSS APPLY dbo.fnGetCreditForeign(
--			ISNULL(dblAddOnCostFromOtherCharge, 0) 			
--			,ForGLEntries_CTE.intCurrencyId
--			,@intFunctionalCurrencyId
--			,ForGLEntries_CTE.dblForexRate
--		) CreditForeign

--WHERE	ForGLEntries_CTE.dblQty <> 0 
--		AND ForGLEntries_CTE.intTransactionTypeId NOT IN (
--				@InventoryTransactionTypeId_WriteOffSold
--				, @InventoryTransactionTypeId_RevalueSold
--				, @InventoryTransactionTypeId_AutoVariance
--				, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
--			)

-----------------------------------------------------------------------------------
-- This part is for the Auto Variance on Used or Sold Stock
-----------------------------------------------------------------------------------
/*
	Debit ........... Inventory
	Credit .............................. COGS (Auto Variance)
*/
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= DebitUnit.Value
		,dblCreditUnit				= CreditUnit.Value
		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
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
		AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= CreditUnit.Value
		,dblCreditUnit				= DebitUnit.Value
		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
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
		AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 

-----------------------------------------------------------------------------------
-- This part is for the Auto-Variance 
-----------------------------------------------------------------------------------
/*
	Debit ........... Inventory
	Credit .............................. COGS (Auto Variance)
*/
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= DebitUnit.Value
		,dblCreditUnit				= CreditUnit.Value
		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) 
										+ ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
										+ ' ' + ForGLEntries_CTE.strDescription 
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

WHERE	ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_AutoVariance
		AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= CreditUnit.Value
		,dblCreditUnit				= DebitUnit.Value
		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) 
									+ ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
									+ ' ' + ForGLEntries_CTE.strDescription 
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

WHERE	ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_AutoVariance
		AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 

-----------------------------------------------------------------------------------
-- This part is for variance because of the stock returns. 
-----------------------------------------------------------------------------------
/*
	Debit ........... Inventory
	Credit .............................. COGS (Auto Variance)
*/
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
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
			@InventoryTransactionTypeId_AutoVariance
			,@InventoryTransactionTypeId_WriteOffSold
			,@InventoryTransactionTypeId_RevalueSold
			,@InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
		)
		AND ISNULL(dblValue, 0) <> 0 
		AND ForGLEntries_CTE.intReference = 3

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
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
		,intEntityId				= NULL
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
			@InventoryTransactionTypeId_AutoVariance
			,@InventoryTransactionTypeId_WriteOffSold
			,@InventoryTransactionTypeId_RevalueSold
			,@InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
		)
		AND ISNULL(dblValue, 0) <> 0 
		AND ForGLEntries_CTE.intReference = 3

-----------------------------------------------------------------------------------
-- This part is to resolve the decimal discrepancy.
-----------------------------------------------------------------------------------
/*
	Debit ........... AP Clearing
	Credit .............................. COGS (Auto Variance)
*/

UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
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
		,intEntityId				= NULL
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
			@InventoryTransactionTypeId_AutoVariance
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
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
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
			@InventoryTransactionTypeId_AutoVariance
			,@InventoryTransactionTypeId_WriteOffSold
			,@InventoryTransactionTypeId_RevalueSold
			,@InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
		)
		AND ISNULL(dblValue, 0) <> 0 
		AND ForGLEntries_CTE.intReference = 2
;
