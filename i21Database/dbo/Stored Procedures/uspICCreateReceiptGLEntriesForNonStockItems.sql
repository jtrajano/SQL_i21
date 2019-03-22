CREATE PROCEDURE [dbo].[uspICCreateReceiptGLEntriesForNonStockItems]
	@strBatchId AS NVARCHAR(40)
	,@AccountCategory_ContraNonInventory AS NVARCHAR(255) = 'AP Clearing'
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 	
	,@intContraNonInventory_ItemLocationId AS INT = NULL 
	,@intRebuildItemId AS INT = NULL -- This is only used when rebuilding the stocks. 
	,@strRebuildTransactionId AS NVARCHAR(50) = NULL -- This is only used when rebuilding the stocks. 
	,@intRebuildCategoryId AS INT = NULL -- This is only used when rebuilding the stocks. 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_NonInventory AS NVARCHAR(30) = 'General'
DECLARE @strTransactionForm NVARCHAR(255)
DECLARE @InventoryTransactionTypeId_AutoVariance AS INT = 1;
DECLARE @InventoryTransactionTypeId_WriteOffSold AS INT = 2;
DECLARE @InventoryTransactionTypeId_RevalueSold AS INT = 3;
DECLARE @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock AS INT = 35;

-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';

-- Get the GL Account ids to use
DECLARE @GLAccounts AS dbo.ItemGLAccount; 
INSERT INTO @GLAccounts (
	intItemId 
	,intItemLocationId 
	,intNonInventoryId 
	,intContraNonInventoryId 
	,intTransactionTypeId
)
SELECT	Query.intItemId
		,Query.intItemLocationId
		,intNonInventory = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_NonInventory) 
		,intContraNonInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, ISNULL(@intContraNonInventory_ItemLocationId, Query.intItemLocationId), @AccountCategory_ContraNonInventory) 
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
				WHERE	t.strBatchId = @strBatchId
						AND t.strTransactionId = ISNULL(@strRebuildTransactionId, t.strTransactionId)
						AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
						AND ISNULL(i.intCategoryId, 0) = COALESCE(@intRebuildCategoryId, i.intCategoryId, 0) 
						AND i.strType IN ('Non-Inventory', 'Service', 'Software')
			) InnerQuery
		) Query

-- Validate the GL Accounts
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemId AS INT 
DECLARE @strLocationName AS NVARCHAR(50)

-- Check for missing Non-Inventory Account Id
BEGIN 
	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intNonInventoryId IS NULL

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @GLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intNonInventoryId IS NULL 

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_NonInventory;
		RETURN -1;
	END 
END 
;

-- Check for missing Contra-Account Id
IF @AccountCategory_ContraNonInventory IS NOT NULL 
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
	WHERE	ItemGLAccount.intContraNonInventoryId IS NULL 			
			--AND ExemptedList.intTransactionTypeId IS NULL 

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @GLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intContraNonInventoryId IS NULL 			

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_ContraNonInventory;
		RETURN -1;
	END 
END 
;

-- Log the g/l account used in this batch. 
INSERT INTO dbo.tblICInventoryGLAccountUsedOnPostLog (
		intItemId
		,intItemLocationId
		,intNonInventoryId
		,intContraNonInventoryId
		,strBatchId
)
SELECT 
		intItemId
		,intItemLocationId
		,intNonInventoryId
		,intContraNonInventoryId
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
		INNER JOIN @GLAccounts GLAccounts
			ON t.intItemId = GLAccounts.intItemId
			AND t.intItemLocationId = GLAccounts.intItemLocationId
			AND t.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intNonInventoryId
WHERE	t.strBatchId = @strBatchId
		AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
		AND ISNULL(i.intCategoryId, 0) = COALESCE(@intRebuildCategoryId, i.intCategoryId, 0) 
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
			,t.dblValue
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
					)						
			--,dblAddOnCostFromOtherCharge = t.dblQty * dbo.fnGetOtherChargesFromInventoryReceipt(ri.intInventoryReceiptItemId)		
	FROM	dbo.tblICInventoryTransaction t 
			INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON 
				t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i
				ON 
				i.intItemId = t.intItemId
			INNER JOIN tblICInventoryReceipt r
				ON 
				r.strReceiptNumber = t.strTransactionId
				AND r.intInventoryReceiptId = t.intTransactionId			
			LEFT JOIN tblICInventoryReceiptItem ri
				ON 
				ri.intInventoryReceiptId = r.intInventoryReceiptId
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
			AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intRebuildCategoryId, i.intCategoryId, 0) 
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
					t.dblQty * t.dblCost 
					, 2
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
	FROM	dbo.tblICInventoryTransaction t 
			INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TransType.intTransactionTypeId = t.intTransactionTypeId
			INNER JOIN tblICItem i
				ON i.intItemId = t.intItemId
			INNER JOIN tblICInventoryReceipt r
				ON  r.strReceiptNumber = t.strTransactionId
				AND r.intInventoryReceiptId = t.intTransactionId
			INNER JOIN (
				tblICItemUOM iu INNER JOIN tblICUnitMeasure u
					ON iu.intUnitMeasureId = u.intUnitMeasureId
			)
				ON iu.intItemUOMId = t.intItemUOMId
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
			AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
			AND ISNULL(i.intCategoryId, 0) = COALESCE(@intRebuildCategoryId, i.intCategoryId, 0) 
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
					)
					,2 
				)
				<> 0 	
)
-------------------------------------------------------------------------------------------
-- This part is for the usual G/L entries for the Receipt Line Total
-------------------------------------------------------------------------------------------
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0--DebitUnit.Value 
		,dblCreditUnit				= 0--CreditUnit.Value
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
FROM	ForGLEntries_CTE  
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intNonInventoryId
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
		,dblDebitUnit				= 0--CreditUnit.Value
		,dblCreditUnit				= 0 --DebitUnit.Value
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
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ISNULL(ForGLEntries_CTE.intInTransitSourceLocationId, ForGLEntries_CTE.intItemLocationId) = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intContraNonInventoryId
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