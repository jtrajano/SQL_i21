CREATE PROCEDURE [dbo].[uspICCreateGLEntries]
	@strBatchId AS NVARCHAR(20)
	,@UseGLAccount_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intUserId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables for the internal transaction types used by costing. 
DECLARE @WRITE_OFF_SOLD AS INT = -1;
DECLARE @REVALUE_SOLD AS INT = -2;
DECLARE @AUTO_NEGATIVE AS INT = -3;

-- Create the variables used by fnGetItemGLAccount
DECLARE @UseGLAccount_Inventory AS NVARCHAR(30) = 'Inventory';
DECLARE @UseGLAccount_WriteOffSold AS NVARCHAR(30) = 'Write-Off Sold';
DECLARE @UseGLAccount_RevalueSold AS NVARCHAR(30) = 'Revalue Sold';
DECLARE @UseGLAccount_AutoNegative AS NVARCHAR(30) = 'Auto Negative';

DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';
DECLARE @AUTO_NEGATIVE_TransactionType AS NVARCHAR(50) = 'Inventory Auto Negative';
DECLARE @WRITEOFF_SOLD_TransactionType AS NVARCHAR(50) = 'Inventory Write-Off Sold';
DECLARE @REVALUE_SOLD_TransactionType AS NVARCHAR(50) = 'Inventory Revalue Sold';
DECLARE @ITEM_COSTING_TransactionType AS NVARCHAR(50) = 'Inventory Costing';

DECLARE @GLAccounts AS dbo.ItemGLAccount; 


-- Get the GL Account ids to use
INSERT INTO @GLAccounts (
	intItemId 
	,intLocationId 
	,intInventoryId 
	,intContraInventoryId 
	,intWriteOffSoldId 
	,intRevalueSoldId 
	,intAutoNegativeId 
)
SELECT	Query.intItemId
		,Query.intLocationId
		,intInventoryId = Inventory.intAccountId
		,intContraInventoryId = ContraInventory.intAccountId
		,intWriteOffSoldId = WriteOffSold.intAccountId
		,intRevalueSoldId = RevalueSold.intAccountId
		,intAutoNegativeId = AutoNegative.intAccountId
FROM	(
			SELECT DISTINCT intItemId, intLocationId 
			FROM	dbo.tblICInventoryTransaction TRANS 
			WHERE	TRANS.strBatchId = @strBatchId
		) Query
		OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intLocationId, @UseGLAccount_Inventory) Inventory
		OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intLocationId, @UseGLAccount_ContraInventory) ContraInventory
		OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intLocationId, @UseGLAccount_WriteOffSold) WriteOffSold
		OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intLocationId, @UseGLAccount_RevalueSold) RevalueSold
		OUTER APPLY dbo.fnGetItemGLAccountAsTable (Query.intItemId, Query.intLocationId, @UseGLAccount_AutoNegative) AutoNegative;

-- Generate the G/L Entries here: 
WITH ForGLEntries_CTE (
	dtmDate
	,intItemId
	,intLocationId
	,intTransactionId
	,strTransactionId
	,dblUnitQty
	,dblCost
	,dblValue
	,intTransactionTypeId
	,intCurrencyId
	,dblExchangeRate
	,intInventoryTransactionId
)
AS 
(
	SELECT	TRANS.dtmDate
			,TRANS.intItemId
			,TRANS.intLocationId
			,TRANS.intTransactionId
			,TRANS.strTransactionId
			,TRANS.dblUnitQty
			,TRANS.dblCost
			,TRANS.dblValue
			,TRANS.intTransactionTypeId
			,TRANS.intCurrencyId
			,TRANS.dblExchangeRate
			,TRANS.intInventoryTransactionId
	FROM	dbo.tblICInventoryTransaction TRANS 
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
		,strCode					= '' 
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
		,strTransactionType			= @ITEM_COSTING_TransactionType
		,strTransactionForm			= '' 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE  
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intLocationId = GLAccounts.intLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE)

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
		,strCode					= '' 
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
		,strTransactionType			= @ITEM_COSTING_TransactionType
		,strTransactionForm			= '' 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intLocationId = GLAccounts.intLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intContraInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE)

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
		,strCode					= ''
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
		,strTransactionType			= @WRITEOFF_SOLD_TransactionType
		,strTransactionForm			= '' 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intLocationId = GLAccounts.intLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId = @WRITE_OFF_SOLD
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
		,strCode					= '' 
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
		,strTransactionType			= @WRITEOFF_SOLD_TransactionType 
		,strTransactionForm			= '' 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intLocationId = GLAccounts.intLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intWriteOffSoldId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId  = @WRITE_OFF_SOLD

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
		,strCode					= '' -- TODO
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
		,strTransactionType			= @REVALUE_SOLD_TransactionType
		,strTransactionForm			= '' -- TODO
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1

FROM	ForGLEntries_CTE
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intLocationId = GLAccounts.intLocationId 
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId = @REVALUE_SOLD
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
		,strCode					= '' 
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
		,strTransactionType			= @REVALUE_SOLD_TransactionType
		,strTransactionForm			= '' 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intLocationId = GLAccounts.intLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueSoldId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId  = @REVALUE_SOLD

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
		,strCode					= '' 
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
		,strTransactionType			= @AUTO_NEGATIVE_TransactionType
		,strTransactionForm			= '' 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intLocationId = GLAccounts.intLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId = @AUTO_NEGATIVE
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
		,strCode					= '' 
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
		,strTransactionType			= @AUTO_NEGATIVE_TransactionType
		,strTransactionForm			= '' 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intLocationId = GLAccounts.intLocationId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId  = @AUTO_NEGATIVE
;