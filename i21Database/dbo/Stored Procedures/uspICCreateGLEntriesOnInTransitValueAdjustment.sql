CREATE PROCEDURE [dbo].[uspICCreateGLEntriesOnInTransitValueAdjustment]
	@strBatchId AS NVARCHAR(40)
	,@strTransactionId AS NVARCHAR(50) 
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
	,@AccountCategory_Cost_Adjustment AS NVARCHAR(50) = 'AP Clearing' 	

	,@intRebuildItemId AS INT = NULL -- This is only used when rebuilding the stocks. 
	,@strRebuildTransactionId AS NVARCHAR(50) = NULL -- This is only used when rebuilding the stocks. 
	,@intRebuildCategoryId AS INT = NULL -- This is only used when rebuilding the stocks. 
	,@dtmRebuildDate AS DATETIME = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON 
SET ANSI_WARNINGS ON

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
			,intTransactionTypeId
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_InTransit) 
			,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Cost_Adjustment) 
			,intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						t.intItemId
						, intItemLocationId = ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId)
						, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t 
						INNER JOIN tblICItem i
							ON t.intItemId = i.intItemId 
						INNER JOIN #tmpRebuildList list	
							ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
							AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)							
				WHERE	t.strBatchId = @strBatchId
						AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
						AND (dbo.fnDateEquals(t.dtmDate, @dtmRebuildDate) = 1 OR @dtmRebuildDate IS NULL) 
			) Query
	;

	-- Again, get the GL Account ids to use, in case intItemLocationId is not found in intInTransitSourceLocationId.
	INSERT INTO @GLAccounts (
			intItemId 
			,intItemLocationId 
			,intInventoryId 
			,intContraInventoryId 
			,intTransactionTypeId
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_InTransit) 
			,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Cost_Adjustment) 
			,intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						t.intItemId
						, intItemLocationId = t.intItemLocationId
						, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t
						INNER JOIN tblICItem i
							ON t.intItemId = i.intItemId 
						INNER JOIN #tmpRebuildList list	
							ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
							AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
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
						AND (dbo.fnDateEquals(t.dtmDate, @dtmRebuildDate) = 1 OR @dtmRebuildDate IS NULL) 
					
			) Query
	;
END 

-- Get the GL Account ids to use for the other charges. 
BEGIN 
	DECLARE @OtherChargeGLAccounts AS dbo.ItemGLAccount; 
	INSERT INTO @OtherChargeGLAccounts (
			intItemId 
			,intItemLocationId 
			,intInventoryId 
			,intContraInventoryId 
			,intTransactionTypeId
	)
	SELECT	Query.intOtherChargeItemId
			,Query.intItemLocationId
			,intInventoryId = dbo.fnGetItemGLAccount(Query.intOtherChargeItemId, Query.intItemLocationId, @AccountCategory_InTransit) 
			,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intOtherChargeItemId, Query.intItemLocationId, @AccountCategory_Cost_Adjustment) 
			,intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						adjLog.intOtherChargeItemId
						, intItemLocationId = il.intItemLocationId
						, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t 
						INNER JOIN tblICItem i
							ON t.intItemId = i.intItemId 
						INNER JOIN #tmpRebuildList list	
							ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
							AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)							
						INNER JOIN tblICInventoryValueAdjustmentLog adjLog
							ON adjLog.intInventoryTransactionId = t.intInventoryTransactionId
						INNER JOIN tblICItemLocation il 
							ON il.intItemId = adjLog.intOtherChargeItemId
							AND il.intLocationId = t.intCompanyLocationId
				WHERE	t.strBatchId = @strBatchId
						AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
						AND (dbo.fnDateEquals(t.dtmDate, @dtmRebuildDate) = 1 OR @dtmRebuildDate IS NULL) 
			) Query
	;
END 

-- Validate the GL Accounts
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemId AS INT 
DECLARE @strLocationName AS NVARCHAR(50)

-- Check for missing In-Transit Account Id
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
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_InTransit;
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
	FROM	tblICItem Item INNER JOIN @OtherChargeGLAccounts OtherChargeGLAccount
				ON Item.intItemId = OtherChargeGLAccount.intItemId
	WHERE	OtherChargeGLAccount.intContraInventoryId IS NULL 

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @OtherChargeGLAccounts OtherChargeGLAccount
				ON OtherChargeGLAccount.intItemId = il.intItemId
				AND OtherChargeGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND OtherChargeGLAccount.intContraInventoryId IS NULL 
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {AP Clearing} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_Cost_Adjustment;
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
		,strBatchId
)
SELECT 
		intItemId
		,intItemLocationId
		,intInventoryId
		,intContraInventoryId 
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
	,intSourceEntityId
	,intCommodityId
	,strRateType
	,dblForexValue
	,intOtherChargeItemId
	,intOtherChargeLocationId
	,[other charge]
	,ysnReversal
)
AS
(	
	SELECT	t.dtmDate
			,t.intItemId
			,ISNULL(t.intInTransitSourceLocationId, t.intItemLocationId)
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
			,t.intSourceEntityId
			,i.intCommodityId
			,strRateType = currencyRateType.strCurrencyExchangeRateType
			,dblForexValue = ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblForexCost, 0) + ISNULL(t.dblForexValue, 0), 2)
			,adjLog.intOtherChargeItemId
			,[intOtherChargeLocationId] = otherChargeLocation.intItemLocationId
			,[other charge] = charge.strItemNo
			,ysnReversal = CASE WHEN ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2) < 0 THEN 1 ELSE 0 END 
	FROM	dbo.tblICInventoryTransaction t 
			INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i
				ON t.intItemId = i.intItemId 
			INNER JOIN #tmpRebuildList list	
				ON i.intItemId = COALESCE(list.intItemId, i.intItemId)
				AND i.intCategoryId = COALESCE(list.intCategoryId, i.intCategoryId)
			INNER JOIN tblICInventoryValueAdjustmentLog adjLog
				ON adjLog.intInventoryTransactionId = t.intInventoryTransactionId
			INNER JOIN tblICItem charge
				ON charge.intItemId = adjLog.intOtherChargeItemId
			INNER JOIN tblICItemLocation otherChargeLocation
				ON otherChargeLocation.intItemId = adjLog.intOtherChargeItemId
				AND otherChargeLocation.intLocationId = t.intCompanyLocationId
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId

	WHERE	t.strBatchId = @strBatchId
			AND (@strTransactionId IS NULL OR t.strTransactionId = @strTransactionId)
			AND ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2) <> 0 
			AND TransType.strName = 'In-Transit Adjustment'
			AND (dbo.fnDateEquals(t.dtmDate, @dtmRebuildDate) = 1 OR @dtmRebuildDate IS NULL) 

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
	,intSourceEntityId
	,intCommodityId
	,strRateType
)

/*-----------------------------------------------------------------------------------
  GL Entries for Adjust Value 
  Debit	....... In-Transit
  Credit	..................... AP Clearing
-----------------------------------------------------------------------------------*/
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateInTransitValueAdjDescription (
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.[other charge]
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.ysnReversal
									) 
		,strCode					= 'ITA' -- In-Transit Adjustment
		,strReference				= '' 
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
		,dblDebitForeign			= DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CreditForeign.Value 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId 
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
		,strRateType				= ForGLEntries_CTE.strRateType 
FROM	ForGLEntries_CTE
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId 
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
		OUTER APPLY dbo.fnGetDebit(dblForexValue) DebitForeign
		OUTER APPLY dbo.fnGetCredit(dblForexValue) CreditForeign

-- AP Clearing
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateInTransitValueAdjDescription (
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.[other charge]
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.ysnReversal
									)
		,strCode					= 'ITA' -- In-Transit Adjustment
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0 -- CASE WHEN ISNULL(@ysnPost, 0) = 1 THEN 0 ELSE 1 END 
		,intUserId					= @intEntityUserSecurityId
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CreditForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= DebitForeign.Value 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
		,strRateType				= ForGLEntries_CTE.strRateType 
FROM	ForGLEntries_CTE 
		INNER JOIN @OtherChargeGLAccounts OtherChargeGLAccounts
			ON ForGLEntries_CTE.intOtherChargeItemId = OtherChargeGLAccounts.intItemId
			AND ForGLEntries_CTE.intOtherChargeLocationId = OtherChargeGLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = OtherChargeGLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = OtherChargeGLAccounts.intContraInventoryId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
		OUTER APPLY dbo.fnGetDebit(dblForexValue) DebitForeign
		OUTER APPLY dbo.fnGetCredit(dblForexValue) CreditForeign
;

-- Return the GL entries back to the caller. 
SELECT 
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
	,[intSourceEntityId]
	,[intCommodityId]
	,[strRateType]
FROM 
	@GLEntries