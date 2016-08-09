CREATE PROCEDURE [dbo].[uspICCreateGLEntries]
	@strBatchId AS NVARCHAR(20)
	,@AccountCategory_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 	
	,@intContraInventory_ItemLocationId AS INT = NULL 
	,@intRebuildItemId AS INT = NULL -- This is only used when rebuilding the stocks. 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory';
DECLARE @AccountCategory_AutoNegative AS NVARCHAR(30) = 'Auto-Variance';

-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the variables for the internal transaction types used by costing. 
DECLARE @InventoryTransactionTypeId_AutoNegative AS INT = 1;
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
		,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_AutoNegative) 
		,intTransactionTypeId
FROM	(
			SELECT	DISTINCT 
					intItemId, intItemLocationId, intTransactionTypeId
			FROM	dbo.tblICInventoryTransaction TRANS 
			WHERE	TRANS.strBatchId = @strBatchId
					AND TRANS.intItemId = ISNULL(@intRebuildItemId, TRANS.intItemId) 
		) Query

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
		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_Inventory) 	
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
			LEFT JOIN dbo.tblICInventoryTransactionWithNoCounterAccountCategory ExemptedList
				ON ItemGLAccount.intTransactionTypeId = ExemptedList.intTransactionTypeId
	WHERE	ItemGLAccount.intContraInventoryId IS NULL 			
			AND ExemptedList.intTransactionTypeId IS NULL 
			
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_ContraInventory) 	
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
				FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
							ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
				WHERE	TRANS.strBatchId = @strBatchId
						AND TransType.intTransactionTypeId IN (@InventoryTransactionTypeId_AutoNegative, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock)
						AND TRANS.intItemId = ISNULL(@intRebuildItemId, TRANS.intItemId) 
						AND TRANS.intItemId = Item.intItemId
						AND TRANS.dblQty * TRANS.dblCost + TRANS.dblValue <> 0
			)
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_AutoNegative) 	
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
FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
			ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
		INNER JOIN @GLAccounts GLAccounts
			ON TRANS.intItemId = GLAccounts.intItemId
			AND TRANS.intItemLocationId = GLAccounts.intItemLocationId
			AND TRANS.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
WHERE	TRANS.strBatchId = @strBatchId
		AND TRANS.intItemId = ISNULL(@intRebuildItemId, TRANS.intItemId) 
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
	,strDescription
)
AS 
(
	SELECT	TRANS.dtmDate
			,TRANS.intItemId
			,TRANS.intItemLocationId
			,TRANS.intTransactionId
			,TRANS.strTransactionId
			,TRANS.dblQty
			,TRANS.dblUOMQty
			,TRANS.dblCost
			,TRANS.dblValue
			,TRANS.intTransactionTypeId
			,ISNULL(TRANS.intCurrencyId, @DefaultCurrencyId) intCurrencyId
			,TRANS.dblExchangeRate
			,TRANS.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,TRANS.strTransactionForm 
			,TRANS.strDescription

	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	TRANS.strBatchId = @strBatchId
			AND TRANS.intItemId = ISNULL(@intRebuildItemId, TRANS.intItemId) 
)
-------------------------------------------------------------------------------------------
-- This part is for the usual G/L entries for Inventory Account and its contra account 
-------------------------------------------------------------------------------------------
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IC' 
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
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= NULL 
FROM	ForGLEntries_CTE  
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty)  + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0)  * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId NOT IN (
				@InventoryTransactionTypeId_WriteOffSold
				, @InventoryTransactionTypeId_RevalueSold
				, @InventoryTransactionTypeId_AutoNegative
				, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
			)

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IC' 
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
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm) 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= NULL 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intContraInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId NOT IN (
				@InventoryTransactionTypeId_WriteOffSold
				, @InventoryTransactionTypeId_RevalueSold
				, @InventoryTransactionTypeId_AutoNegative
				, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
			)

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
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
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
		,intUserId					= NULL 
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm) 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= NULL 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
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
		,intUserId					= NULL 
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName 
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= NULL 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId  = @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock

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
		,intUserId					= NULL 
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= NULL 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_AutoNegative
		AND (Debit.Value <> 0 OR Credit.Value <> 0)
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
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
		,intUserId					= NULL 
		,intEntityId				= @intEntityUserSecurityId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= NULL 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= NULL 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= NULL 
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId  = @InventoryTransactionTypeId_AutoNegative
		AND (Debit.Value <> 0 OR Credit.Value <> 0)
;