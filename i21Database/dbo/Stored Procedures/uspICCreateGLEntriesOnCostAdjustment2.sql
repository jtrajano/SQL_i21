CREATE PROCEDURE [dbo].[uspICCreateGLEntriesOnCostAdjustment2]
	@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
	,@AccountCategory_Cost_Adjustment AS NVARCHAR(50) = 'AP Clearing' 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'

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
		
-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';

DECLARE @ysnIsUnposted AS BIT = 0

-- Get the GL Account ids to use
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
		,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Cost_Adjustment) 
		,intTransactionTypeId
FROM	(
			SELECT	DISTINCT 
					intItemId
					, intItemLocationId = ISNULL(intInTransitSourceLocationId, intItemLocationId)
					, intTransactionTypeId
			FROM	dbo.tblICInventoryTransaction TRANS 
			WHERE	TRANS.strBatchId = @strBatchId
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
		,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Cost_Adjustment) 
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
					AND missing_item_location.intItemLocationId IS NULL 
					
		) Query
;

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
)
AS 
(
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
			,TransType.strTransactionForm
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,t.intRelatedTransactionId
			,t.strRelatedTransactionId
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			INNER JOIN tblICInventoryFIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
	WHERE	t.strBatchId = @strBatchId
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
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
			,TransType.strTransactionForm
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,t.intRelatedTransactionId
			,t.strRelatedTransactionId
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			INNER JOIN tblICInventoryLIFOCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
	WHERE	t.strBatchId = @strBatchId
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
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
			,TransType.strTransactionForm
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,t.intRelatedTransactionId
			,t.strRelatedTransactionId
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			INNER JOIN tblICInventoryLotCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
	WHERE	t.strBatchId = @strBatchId
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 
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
			,TransType.strTransactionForm
			,t.intInTransitSourceLocationId
			,i.strItemNo
			,t.intRelatedTransactionId
			,t.strRelatedTransactionId
			,t.strBatchId
			,t.intLotId 
			,t.intFobPointId
			,t.dblForexRate
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i 
				ON i.intItemId = t.intItemId
			INNER JOIN tblICInventoryActualCostAdjustmentLog cbLog
				ON cbLog.intInventoryTransactionId = t.intInventoryTransactionId
	WHERE	t.strBatchId = @strBatchId
			AND ROUND(ISNULL(cbLog.dblQty, 0) * ISNULL(cbLog.dblCost, 0) + ISNULL(cbLog.dblValue, 0), 2) <> 0 

)

/*-----------------------------------------------------------------------------------
  GL Entries for Cost Adjustment
  Debit	....... Inventory
  Credit	..................... Cost Adjustment 
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
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnIsUnposted, 0) = 1 THEN 0 ELSE 1 END 
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
		,ysnIsUnposted				= CASE WHEN ISNULL(@ysnIsUnposted, 0) = 1 THEN 0 ELSE 1 END 
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
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(dblValue) Debit
		CROSS APPLY dbo.fnGetCredit(dblValue) Credit
