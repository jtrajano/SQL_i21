CREATE PROCEDURE [dbo].[uspICCreateGLEntriesOnCostAdjustment]
	@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
		,@AccountCategory_Auto_Variance AS NVARCHAR(30) = 'Inventory Adjustment' --'Auto-Variance' -- Auto-variance will no longer be used. It will not use Inventory Adjustment. 

		,@AccountCategory_Cost_Adjustment AS NVARCHAR(30) = 'AP Clearing' 
		,@AccountCategory_Revalue_WIP AS NVARCHAR(30) = 'Work In Progress' 

		,@AccountCategory_Revalue_Sold AS NVARCHAR(30) = 'Cost of Goods'
		,@AccountCategory_Revalue_Shipment AS NVARCHAR(30) = 'Inventory In-Transit'

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

-- Get the GL Account ids to use
DECLARE @GLAccounts AS dbo.ItemGLAccount; 
INSERT INTO @GLAccounts (
		intItemId 
		,intItemLocationId 
		,intInventoryId 
		,intAutoNegativeId 
		,intCostAdjustment 
		,intRevalueTransfer 
		,intRevalueBuildAssembly 
		,intRevalueInTransit
		,intRevalueSoldId
		,intTransactionTypeId
)
SELECT	Query.intItemId
		,Query.intItemLocationId
		,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Auto_Variance) 
		,intCostAdjustment = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Cost_Adjustment) 
		,intRevalueTransfer = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intRevalueBuildAssembly = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intRevalueInTransit = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Revalue_Shipment) 
		,intRevalueSoldId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Revalue_Sold) 
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
		,intAutoNegativeId 
		,intCostAdjustment 
		,intRevalueTransfer 
		,intRevalueBuildAssembly 
		,intRevalueInTransit
		,intRevalueSoldId
		,intTransactionTypeId
)
SELECT	Query.intItemId
		,Query.intItemLocationId
		,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Auto_Variance) 
		,intCostAdjustment = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Cost_Adjustment) 
		,intRevalueTransfer = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intRevalueBuildAssembly = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intRevalueInTransit = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Revalue_Shipment) 
		,intRevalueSoldId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Revalue_Sold) 
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

-- Check for missing Inventory Account Id
BEGIN 
	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intInventoryId IS NULL 

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @AccountCategory_Inventory;
		RETURN -1;
	END 
END 
;
-- Check for missing Auto Variance Account Id
IF EXISTS (
	SELECT	TOP 1 1 
	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	TRANS.strBatchId = @strBatchId
			AND TransType.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Variance 
)
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
			INNER JOIN dbo.tblICInventoryTransaction TRANS 
				ON TRANS.intItemId = Item.intItemId			
			INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
				AND TRANS.intItemId = Item.intItemId
	WHERE	ItemGLAccount.intAutoNegativeId IS NULL 
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @AccountCategory_Auto_Variance;
		RETURN -1;
	END 
END 
;

-- Check for missing Cost Adjustment Account Id
IF EXISTS (
	SELECT	TOP 1 1 
	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	TRANS.strBatchId = @strBatchId
			AND TransType.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
)
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
			INNER JOIN dbo.tblICInventoryTransaction TRANS 
				ON TRANS.intItemId = Item.intItemId			
			INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
				AND TRANS.intItemId = Item.intItemId
	WHERE	ItemGLAccount.intCostAdjustment IS NULL 
			AND TransType.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Cost Adjustment} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @AccountCategory_Cost_Adjustment;
		RETURN -1;
	END 
END 
;

-- Check for missing COGS
IF EXISTS (
	SELECT	TOP 1 1 
	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	TRANS.strBatchId = @strBatchId
			AND TransType.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Sold
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
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Cost Adjustment} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @AccountCategory_Revalue_Sold;
		RETURN -1;
	END 
END 
;
-- Check for missing Revalue Shipment 
IF EXISTS (
	SELECT	TOP 1 1 
	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	TRANS.strBatchId = @strBatchId
			AND TransType.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Shipment
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
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Cost Adjustment} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @AccountCategory_Revalue_Shipment;
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
		,intWriteOffSoldId
		,intRevalueSoldId
		,intAutoNegativeId
		,intCostAdjustment 
		,intRevalueWIP 
		,intRevalueProduced 
		,intRevalueTransfer 
		,intRevalueBuildAssembly 
		,intRevalueInTransit 
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
		,intCostAdjustment 
		,intRevalueWIP 
		,intRevalueProduced 
		,intRevalueTransfer 
		,intRevalueBuildAssembly 
		,intRevalueInTransit
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
			,t.dblQty
			,t.dblUOMQty
			,t.dblCost
			,t.dblValue
			,t.intTransactionTypeId
			,t.intCurrencyId
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,'Bill' 
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
	WHERE	t.strBatchId = @strBatchId
			AND ISNULL(t.ysnNoGLPosting, 0) = 0
			AND ROUND(t.dblQty * t.dblCost + t.dblValue, 2) <> 0 
)

-----------------------------------------------------------------------------------
-- This part is for Auto Variance on Sold or Used Stock
-----------------------------------------------------------------------------------
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
		,strCode					= 'IAV' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL 
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

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Variance_On_Sold_Or_Used_Stock
		AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 
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
		,strCode					= 'IAV' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL 
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

WHERE	ForGLEntries_CTE.intTransactionTypeId  = @INV_TRANS_TYPE_Auto_Variance_On_Sold_Or_Used_Stock
		AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 

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
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= dbo.fnCreateCostAdjGLDescription(
										@strGLDescription
										,tblGLAccount.strDescription
										,ForGLEntries_CTE.strItemNo
										,ForGLEntries_CTE.strRelatedTransactionId
									)
		,strCode					= 'IAN' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
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

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Auto_Variance
		AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 
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
		,strCode					= 'IAN' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
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

WHERE	ForGLEntries_CTE.intTransactionTypeId  = @INV_TRANS_TYPE_Auto_Variance
		AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 

-----------------------------------------------------------------------------------
-- This part is for the Cost Adjustment
-- Inventory (Asset) .............. Debit
-- Cost Adjustment (Expense) ................. Credit
-----------------------------------------------------------------------------------
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
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL -- DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL -- CreditForeign.Value
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
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)	
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
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
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL -- CreditForeign.Value
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL -- DebitForeign.Value 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intCostAdjustment
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)	
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId  = @INV_TRANS_TYPE_Cost_Adjustment

/*----------------------------------------------------------------------------------
	This part is for Revalue Consume

	If value is negative: 
	Inventory (Asset/Inventory) ................. Credit
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
		,strCode					= 'RCON' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
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
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)	
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_WIP

/*----------------------------------------------------------------------------------
	This part is for Revalue Produce

	If value is positive: 
	Inventory (Asset/Inventory) ........ Debit

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
		,strCode					= 'RPRD' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
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
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)	
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Produced


-----------------------------------------------------------------------------------
-- This part is for Revalue Transfer
-----------------------------------------------------------------------------------
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
		,strCode					= 'RTRF' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND GLAccounts.intItemLocationId = ForGLEntries_CTE.intItemLocationId 
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)	
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign
		CROSS APPLY (
			SELECT	TOP 1 
					ysnGLEntriesRequired = CAST(1 AS BIT) 
			FROM	tblICInventoryTransfer it
			WHERE	it.intInventoryTransferId = ForGLEntries_CTE.intRelatedTransactionId 
					AND it.strTransferNo = ForGLEntries_CTE.strRelatedTransactionId 
					AND it.intFromLocationId <> intToLocationId
		) it

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Transfer
		AND it.ysnGLEntriesRequired = 1

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
		,strCode					= 'RTRF' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		OUTER APPLY (
			SELECT	TOP 1 
					* 
			FROM	tblICInventoryTransaction t 
			WHERE	t.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
					AND t.strBatchId = ForGLEntries_CTE.strBatchId
					AND t.strTransactionId = ForGLEntries_CTE.strTransactionId
		) CostAdjustment 
		INNER JOIN @GLAccounts GLAccounts
			ON GLAccounts.intItemId = CostAdjustment.intItemId
			AND GLAccounts.intItemLocationId = CostAdjustment.intItemLocationId
			AND GLAccounts.intTransactionTypeId = CostAdjustment.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign
		CROSS APPLY (
			SELECT	TOP 1 
					ysnGLEntriesRequired = CAST(1 AS BIT) 
			FROM	tblICInventoryTransfer it
			WHERE	it.intInventoryTransferId = ForGLEntries_CTE.intRelatedTransactionId 
					AND it.strTransferNo = ForGLEntries_CTE.strRelatedTransactionId 
					AND it.intFromLocationId <> intToLocationId
		) it

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Transfer
		AND CostAdjustment.intInventoryTransactionId IS NOT NULL 
		AND it.ysnGLEntriesRequired = 1

-----------------------------------------------------------------------------------
-- This part is for Revalue Build Assembly. 
-----------------------------------------------------------------------------------
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
		,strCode					= 'RBLD' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
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
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Build_Assembly
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
		,strCode					= 'RBLD' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		OUTER APPLY (
			SELECT	TOP 1 
					* 
			FROM	tblICInventoryTransaction t 
			WHERE	t.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
					AND t.strBatchId = ForGLEntries_CTE.strBatchId
					AND t.strTransactionId = ForGLEntries_CTE.strTransactionId
		) CostAdjustment 
		INNER JOIN @GLAccounts GLAccounts
			ON GLAccounts.intItemId = CostAdjustment.intItemId
			AND GLAccounts.intItemLocationId = CostAdjustment.intItemLocationId
			AND GLAccounts.intTransactionTypeId = CostAdjustment.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Build_Assembly
		AND CostAdjustment.intInventoryTransactionId IS NOT NULL 

-----------------------------------------------------------------------------------
-- This part is for Revalue Item Change. 
-----------------------------------------------------------------------------------
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
		,strCode					= 'RIC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
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
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Item_Change
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
		,strCode					= 'RIC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		OUTER APPLY (
			SELECT	TOP 1 
					* 
			FROM	tblICInventoryTransaction t 
			WHERE	t.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
					AND t.strBatchId = ForGLEntries_CTE.strBatchId
					AND t.strTransactionId = ForGLEntries_CTE.strTransactionId
		) CostAdjustment 
		INNER JOIN @GLAccounts GLAccounts
			ON GLAccounts.intItemId = CostAdjustment.intItemId
			AND GLAccounts.intItemLocationId = CostAdjustment.intItemLocationId
			AND GLAccounts.intTransactionTypeId = CostAdjustment.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Item_Change
		AND CostAdjustment.intInventoryTransactionId IS NOT NULL 

-----------------------------------------------------------------------------------
-- This part is for Revalue Split Lot. 
-----------------------------------------------------------------------------------
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
		,strCode					= 'RSL' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
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
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Split_Lot
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
		,strCode					= 'RSL' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		OUTER APPLY (
			SELECT	TOP 1 
					* 
			FROM	tblICInventoryTransaction t 
			WHERE	t.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
					AND t.strBatchId = ForGLEntries_CTE.strBatchId
					AND t.strTransactionId = ForGLEntries_CTE.strTransactionId
		) CostAdjustment 
		INNER JOIN @GLAccounts GLAccounts
			ON GLAccounts.intItemId = CostAdjustment.intItemId
			AND GLAccounts.intItemLocationId = CostAdjustment.intItemLocationId
			AND GLAccounts.intTransactionTypeId = CostAdjustment.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Split_Lot
		AND CostAdjustment.intInventoryTransactionId IS NOT NULL 

-----------------------------------------------------------------------------------
-- This part is for Revalue Lot Merge. 
-----------------------------------------------------------------------------------
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
		,strCode					= 'RLMG' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
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
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Lot_Merge
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
		,strCode					= 'RLMG' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		OUTER APPLY (
			SELECT	TOP 1 
					* 
			FROM	tblICInventoryTransaction t 
			WHERE	t.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
					AND t.strBatchId = ForGLEntries_CTE.strBatchId
					AND t.strTransactionId = ForGLEntries_CTE.strTransactionId
		) CostAdjustment 
		INNER JOIN @GLAccounts GLAccounts
			ON GLAccounts.intItemId = CostAdjustment.intItemId
			AND GLAccounts.intItemLocationId = CostAdjustment.intItemLocationId
			AND GLAccounts.intTransactionTypeId = CostAdjustment.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Lot_Merge
		AND CostAdjustment.intInventoryTransactionId IS NOT NULL 

-----------------------------------------------------------------------------------
-- This part is for Revalue Lot Move. 
-----------------------------------------------------------------------------------
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
		,strCode					= 'RLMV' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND GLAccounts.intItemLocationId = ForGLEntries_CTE.intItemLocationId 
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Lot_Move
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
		,strCode					= 'RLMV' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		OUTER APPLY (
			SELECT	TOP 1 
					* 
			FROM	tblICInventoryTransaction t 
			WHERE	t.intTransactionTypeId = @INV_TRANS_TYPE_Cost_Adjustment
					AND t.strBatchId = ForGLEntries_CTE.strBatchId
					AND t.strTransactionId = ForGLEntries_CTE.strTransactionId
		) CostAdjustment 
		INNER JOIN @GLAccounts GLAccounts
			ON GLAccounts.intItemId = CostAdjustment.intItemId
			AND GLAccounts.intItemLocationId = CostAdjustment.intItemLocationId
			AND GLAccounts.intTransactionTypeId = CostAdjustment.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Lot_Move
		AND CostAdjustment.intInventoryTransactionId IS NOT NULL 

-----------------------------------------------------------------------------------
-- This part is for Revalue Sold. 
-- Debit: Inventory
-- Credit: COGS
-----------------------------------------------------------------------------------
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
		,strCode					= 'RCOGS' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON GLAccounts.intItemId = ForGLEntries_CTE.intItemId
			AND GLAccounts.intItemLocationId = ForGLEntries_CTE.intItemLocationId
			AND GLAccounts.intTransactionTypeId = ForGLEntries_CTE.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount			
			ON tblGLAccount.intAccountId = 
				CASE	WHEN ForGLEntries_CTE.intFOBPointId = @FOB_DESTINATION THEN 
							GLAccounts.intRevalueInTransit 
						ELSE 
							GLAccounts.intInventoryId 
				END 
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Sold

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
		,strCode					= 'RCOGS' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND GLAccounts.intItemLocationId = ISNULL(ForGLEntries_CTE.intInTransitSourceLocationId, ForGLEntries_CTE.intItemLocationId)
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueSoldId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)	
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Sold

/*-----------------------------------------------------------------------------------
Generate the GL entries for the Revalue Shipment 
FOB Point must be set to 'Destination' for it to have the gl entries. 
 
Debit:	In-Transit 
Credit: Inventory

----------------------------------------------------------------------------------*/
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
		,strCode					= 'RSHP' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL 
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON GLAccounts.intItemId = ForGLEntries_CTE.intItemId
			AND GLAccounts.intItemLocationId = ISNULL(ForGLEntries_CTE.intInTransitSourceLocationId, ForGLEntries_CTE.intItemLocationId)
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueInTransit
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)	
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0) 			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId  = @INV_TRANS_TYPE_Revalue_Shipment
		AND ForGLEntries_CTE.intFOBPointId = @FOB_DESTINATION
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
		,strCode					= 'RSHP' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= NULL  
		,intEntityId				= @intEntityUserSecurityId
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL --DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL --CreditForeign.Value
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON GLAccounts.intItemId = ForGLEntries_CTE.intItemId
			AND GLAccounts.intItemLocationId = ForGLEntries_CTE.intItemLocationId
			AND GLAccounts.intTransactionTypeId = ForGLEntries_CTE.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		) Debit
		CROSS APPLY dbo.fnGetCredit(
			dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0) 			
		) Credit
		--CROSS APPLY dbo.fnGetDebitForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) DebitForeign
		--CROSS APPLY dbo.fnGetCreditForeign(
		--	dbo.fnMultiply(ISNULL(ForGLEntries_CTE.dblQty, 0), ISNULL(ForGLEntries_CTE.dblCost, 0)) + ISNULL(ForGLEntries_CTE.dblValue, 0)			
		--	,ForGLEntries_CTE.intCurrencyId
		--	,@intFunctionalCurrencyId
		--	,ForGLEntries_CTE.dblForexRate
		--) CreditForeign

WHERE	ForGLEntries_CTE.intTransactionTypeId = @INV_TRANS_TYPE_Revalue_Shipment
		AND ForGLEntries_CTE.intFOBPointId = @FOB_DESTINATION
;