CREATE PROCEDURE uspICFixReceiptAPClearingDiscrepancy
	@strReceiptNumber AS NVARCHAR(50) 
	,@dtmTargeDate AS DATETIME = NULL 
AS

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 
;

DECLARE 
	@GLEntries AS RecapTableType
	,@intEntityUserSecurityId AS INT 
	,@ModuleName AS NVARCHAR(50) = 'Inventory'
	,@dtmDate AS DATETIME 
	,@glDescription AS NVARCHAR(100) 

-- Create the variables for the internal transaction types used by costing. 
DECLARE @InventoryTransactionTypeId_AutoVariance AS INT = 1;
DECLARE @InventoryTransactionTypeId_WriteOffSold AS INT = 2;
DECLARE @InventoryTransactionTypeId_RevalueSold AS INT = 3;
DECLARE @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock AS INT = 35;

SELECT 
	@intEntityUserSecurityId = r.intEntityId
	,@dtmDate = r.dtmReceiptDate
FROM 
	tblICInventoryReceipt r
WHERE
	r.strReceiptNumber = @strReceiptNumber
	and r.ysnPosted = 1

IF dbo.isOpenAccountingDate(@dtmDate) = 0
BEGIN 
	SET @dtmDate = dbo.fnRemoveTimeOnDate(ISNULL(@dtmTargeDate, GETDATE()))
	SET @glDescription = 'Previous year AP Clearing account out of balance correction'
END 

-- Get the GL Account ids to use
DECLARE @GLAccounts AS dbo.ItemGLAccount; 

-- Create the variables used by fnGetItemGLAccount
DECLARE 
	@AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
	,@AccountCategory_Adjustment AS NVARCHAR(30) = 'Inventory Adjustment' --'Auto-Variance' -- Auto-variance will no longer be used. It will now use Inventory Adjustment. 
	,@AccountCategory_ContraInventory AS NVARCHAR(50) = 'AP Clearing'

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
		,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_ContraInventory) 
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
				WHERE	t.strTransactionId = @strReceiptNumber
						AND t.ysnIsUnposted = 0 
						--AND i.strType <> 'Non-Inventory'
				UNION ALL 
				SELECT	DISTINCT 
						t.intItemId
						, t.intInTransitSourceLocationId 
						, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICItem i
							ON t.intItemId = i.intItemId
				WHERE	t.strTransactionId = @strReceiptNumber
						AND t.intInTransitSourceLocationId IS NOT NULL
						AND t.ysnIsUnposted = 0 
						--AND i.strType <> 'Non-Inventory'
				UNION ALL 
				SELECT	DISTINCT 
						t.intItemId
						, t.intItemLocationId 
						, @InventoryTransactionTypeId_AutoVariance
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICItem i
							ON t.intItemId = i.intItemId
				WHERE	t.strTransactionId = @strReceiptNumber
						AND t.intItemLocationId IS NOT NULL
						AND t.intInTransitSourceLocationId IS NULL
						AND t.ysnIsUnposted = 0 
						--AND i.strType <> 'Non-Inventory'
			) InnerQuery
		) Query;

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
	,intReference
	,strBatchId
)
AS (
	-- Resolve the 0.01 discrepancy between the inventory transaction value and the receipt line total. 	
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
			,intReference = CAST(2 AS TINYINT)
			,t.strBatchId
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
									,t.intItemUOMId								)
								,2 
							)
						)					
				FROM 
					tblICInventoryReceiptItem ri INNER JOIN tblICInventoryReceipt r
						ON ri.intInventoryReceiptId = r.intInventoryReceiptId
					INNER JOIN tblICItem i 
						ON ri.intItemId = i.intItemId
					INNER JOIN tblICInventoryTransaction t 
						ON t.intTransactionId = r.intInventoryReceiptId
						AND t.strTransactionId = r.strReceiptNumber
						AND t.intTransactionDetailId = ri.intInventoryReceiptItemId
						AND t.ysnIsUnposted = 0 
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
					r.strReceiptNumber = @strReceiptNumber
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

			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId

	WHERE	
			ri.[dblRecomputeLineTotal] - topRi.dblLineTotal <> 0 
)
INSERT INTO @GLEntries (
	[dtmDate]
	,[strBatchId]
	,[intAccountId]
	,[dblDebit]
	,[dblCredit]
	,[dblDebitUnit]
	,[dblCreditUnit]
	,[strDescription]
	,[strCode]
	,[strReference]
	,[intCurrencyId]
	,[dblExchangeRate]
	,[dtmDateEntered]
	,[dtmTransactionDate]
	,[strJournalLineDescription]
	,[intJournalLineNo]
	,[ysnIsUnposted]
	,[intUserId]
	,[intEntityId]
	,[strTransactionId]
	,[intTransactionId]
	,[strTransactionType]
	,[strTransactionForm]
	,[strModuleName]
	,[intConcurrencyId]
	,[dblDebitForeign]
	,[dblDebitReport]
	,[dblCreditForeign]
	,[dblCreditReport]
	,[dblReportingRate]
	,[dblForeignRate]
	,[strRateType]
)
-----------------------------------------------------------------------------------
-- This part is to resolve the decimal discrepancy.
-----------------------------------------------------------------------------------
/*
	Debit ........... AP Clearing
	Credit .............................. COGS (Auto Variance)
*/
SELECT	
		dtmDate						= @dtmDate
		,strBatchId					= strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= DebitUnit.Value
		,dblCreditUnit				= CreditUnit.Value
		,strDescription				= ISNULL(tblGLAccount.strDescription, '')
										+ ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
										+ ' ' + ForGLEntries_CTE.strDescription 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = COALESCE(@glDescription, '')
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId 
		,intEntityId				= NULL
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
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
		dtmDate						= @dtmDate
		,strBatchId					= strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= CreditUnit.Value
		,dblCreditUnit				= DebitUnit.Value
		,strDescription				= ISNULL(tblGLAccount.strDescription, '')
									+ ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
									+ ' ' + ForGLEntries_CTE.strDescription 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = COALESCE(@glDescription, '') 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId 
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		--,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		--,intCommodityId				= ForGLEntries_CTE.intCommodityId 
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

IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
BEGIN
	--PRINT 'Last GL Book Entries'
	EXEC dbo.uspGLBookEntries @GLEntries, 1
END