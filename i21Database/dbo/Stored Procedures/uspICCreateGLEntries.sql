CREATE PROCEDURE [dbo].[uspICCreateGLEntries]
	@strBatchId AS NVARCHAR(20)
	,@AccountCategory_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intUserId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory';
DECLARE @AccountCategory_WriteOffSold AS NVARCHAR(30) = 'Write-Off Sold';
DECLARE @AccountCategory_RevalueSold AS NVARCHAR(30) = 'Revalue Sold';
DECLARE @AccountCategory_AutoNegative AS NVARCHAR(30) = 'Auto-Negative';

-- Create the variables for the internal transaction types used by costing. 
DECLARE @InventoryTransactionTypeId_AutoNegative AS INT = 1;
DECLARE @InventoryTransactionTypeId_WriteOffSold AS INT = 2;
DECLARE @InventoryTransactionTypeId_RevalueSold AS INT = 3;

-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';

-- Get the GL Account ids to use
DECLARE @GLAccounts AS dbo.ItemGLAccount; 
INSERT INTO @GLAccounts (
	intItemId 
	,intItemLocationId 
	,intInventoryId 
	,intContraInventoryId 
	,intWriteOffSoldId 
	,intRevalueSoldId 
	,intAutoNegativeId 
)
SELECT	Query.intItemId
		,Query.intItemLocationId
		,intInventoryId = Inventory.intAccountId
		,intContraInventoryId = ContraInventory.intAccountId
		,intWriteOffSoldId = WriteOffSold.intAccountId
		,intRevalueSoldId = RevalueSold.intAccountId
		,intAutoNegativeId = AutoNegative.intAccountId
FROM	(
			SELECT DISTINCT intItemId, intItemLocationId 
			FROM	dbo.tblICInventoryTransaction TRANS 
			WHERE	TRANS.strBatchId = @strBatchId
		) Query
		OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) Inventory
		OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intItemLocationId, @AccountCategory_ContraInventory) ContraInventory
		OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intItemLocationId, @AccountCategory_WriteOffSold) WriteOffSold
		OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intItemLocationId, @AccountCategory_RevalueSold) RevalueSold
		OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intItemLocationId, @AccountCategory_AutoNegative) AutoNegative;

-- Validate the GL Accounts
BEGIN 
	DECLARE @strItemNo AS NVARCHAR(50)
	DECLARE @intItemId AS INT 

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intInventoryId IS NULL 

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- G/L account setup is missing for {Item}
		RAISERROR(51041, 11, 1, @strItemNo) 	
		RETURN;
	END 
END 
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
			,TRANS.intCurrencyId
			,TRANS.dblExchangeRate
			,TRANS.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,TRANS.strTransactionForm
	FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
	WHERE	TRANS.strBatchId = @strBatchId
)
-------------------------------------------------------------------------------------------
-- This part is for the usual G/L entries for Inventory Account and its contra account 
-------------------------------------------------------------------------------------------
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intInventoryId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= tblGLAccount.strDescription
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId 
		,intEntityId				= @intUserId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE  
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty)  + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0)  * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId NOT IN (@InventoryTransactionTypeId_WriteOffSold, @InventoryTransactionTypeId_RevalueSold, @InventoryTransactionTypeId_AutoNegative)

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intContraInventoryId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= tblGLAccount.strDescription
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId 
		,intEntityId				= @intUserId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intContraInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId NOT IN (@InventoryTransactionTypeId_WriteOffSold, @InventoryTransactionTypeId_RevalueSold, @InventoryTransactionTypeId_AutoNegative)

-----------------------------------------------------------------------------------
-- This part is for the Write-Off Sold 
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intInventoryId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= tblGLAccount.strDescription
		,strCode					= 'IWS'
		,strReference				= ''
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId 
		,intEntityId				= @intUserId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId = @InventoryTransactionTypeId_WriteOffSold
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intWriteOffSoldId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= tblGLAccount.strDescription
		,strCode					= 'IWS' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId 
		,intEntityId				= @intUserId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName 
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intWriteOffSoldId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId  = @InventoryTransactionTypeId_WriteOffSold

-----------------------------------------------------------------------------------
-- This part is for the Revalue Sold 
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intInventoryId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= tblGLAccount.strDescription
		,strCode					= 'IRS' -- TODO
		,strReference				= '' -- TODO
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' -- TODO
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId -- TODO
		,intEntityId				= @intUserId -- TODO
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1

FROM	ForGLEntries_CTE
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId 
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId = @InventoryTransactionTypeId_RevalueSold
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intRevalueSoldId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= tblGLAccount.strDescription
		,strCode					= 'IRS' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId 
		,intEntityId				= @intUserId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueSoldId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId  = @InventoryTransactionTypeId_RevalueSold

-----------------------------------------------------------------------------------
-- This part is for the Auto-Negative 
-----------------------------------------------------------------------------------
UNION ALL  
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intInventoryId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= tblGLAccount.strDescription
		,strCode					= 'IAN' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId 
		,intEntityId				= @intUserId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId = @InventoryTransactionTypeId_AutoNegative
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intAutoNegativeId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= tblGLAccount.strDescription
		,strCode					= 'IAN' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' 
		,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId 
		,intEntityId				= @intUserId 
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId  = @InventoryTransactionTypeId_AutoNegative
;