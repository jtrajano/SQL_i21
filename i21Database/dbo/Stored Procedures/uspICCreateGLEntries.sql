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

DECLARE @GLAccounts AS dbo.ItemGLAccount; 
DECLARE @GLEntries AS dbo.RecapTableType; 

-- Get the GL Account ids to use
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
		,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @UseGLAccount_Inventory)
		,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @UseGLAccount_ContraInventory)
		,intWriteOffSoldId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @UseGLAccount_WriteOffSold)
		,intRevalueSoldId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @UseGLAccount_RevalueSold)
		,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @UseGLAccount_AutoNegative)
FROM (
	SELECT DISTINCT intItemId, intItemLocationId 
	FROM	dbo.tblICInventoryTransaction TRANS 
	WHERE	TRANS.strBatchId = @strBatchId
) Query;

-- Generate the G/L Entries here: 
WITH ForGLEntries_CTE (
	dtmDate
	,intItemId
	,intItemLocationId
	,intTransactionId
	,strTransactionId
	,dblUnitQty
	,dblCost
	,dblValue
	,intTransactionTypeId
	,intCurrencyId
	,dblExchangeRate
)
AS 
(
	SELECT	TRANS.dtmDate
			,TRANS.intItemId
			,TRANS.intItemLocationId
			,TRANS.intTransactionId
			,TRANS.strTransactionId
			,TRANS.dblUnitQty
			,TRANS.dblCost
			,TRANS.dblValue
			,TRANS.intTransactionTypeId
			,TRANS.intCurrencyId
			,TRANS.dblExchangeRate
	FROM	dbo.tblICInventoryTransaction TRANS 
	WHERE	TRANS.strBatchId = @strBatchId
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
)
-------------------------------------------------------------------------------------------
-- This part if for the usual G/L entries for Inventory Account and its contra account 
-------------------------------------------------------------------------------------------
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intInventoryId
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= '' -- TODO 
		,strCode					= '' -- TODO
		,strReference				= '' -- TODO
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' -- TODO
		,intJournalLineNo			= NULL -- TODO
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId -- TODO
		,intEntityId				= @intUserId -- TODO
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= '' -- TODO 
		,strTransactionForm			= '' -- TODO
		,strModuleName				= '' -- TODO
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE  
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
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
		,strDescription				= '' -- TODO 
		,strCode					= '' -- TODO
		,strReference				= '' -- TODO
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' -- TODO
		,intJournalLineNo			= NULL -- TODO
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId -- TODO
		,intEntityId				= @intUserId -- TODO
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= '' -- TODO 
		,strTransactionForm			= '' -- TODO
		,strModuleName				= '' -- TODO
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId NOT IN (@WRITE_OFF_SOLD, @REVALUE_SOLD, @AUTO_NEGATIVE)

-----------------------------------------------------------------------------------
-- This part for the Write-Off Sold 
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
		,strDescription				= '' -- TODO 
		,strCode					= '' -- TODO
		,strReference				= '' -- TODO
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' -- TODO
		,intJournalLineNo			= NULL -- TODO
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId -- TODO
		,intEntityId				= @intUserId -- TODO
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= '' -- TODO 
		,strTransactionForm			= '' -- TODO
		,strModuleName				= '' -- TODO
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
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
		,strDescription				= '' -- TODO 
		,strCode					= '' -- TODO
		,strReference				= '' -- TODO
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' -- TODO
		,intJournalLineNo			= NULL -- TODO
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId -- TODO
		,intEntityId				= @intUserId -- TODO
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= '' -- TODO 
		,strTransactionForm			= '' -- TODO
		,strModuleName				= '' -- TODO
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
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
		,strDescription				= '' -- TODO 
		,strCode					= '' -- TODO
		,strReference				= '' -- TODO
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' -- TODO
		,intJournalLineNo			= NULL -- TODO
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId -- TODO
		,intEntityId				= @intUserId -- TODO
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= '' -- TODO 
		,strTransactionForm			= '' -- TODO
		,strModuleName				= '' -- TODO
		,intConcurrencyId			= 1

FROM	ForGLEntries_CTE
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId 
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
		,strDescription				= '' -- TODO 
		,strCode					= '' -- TODO
		,strReference				= '' -- TODO
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' -- TODO
		,intJournalLineNo			= NULL -- TODO
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId -- TODO
		,intEntityId				= @intUserId -- TODO
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= '' -- TODO 
		,strTransactionForm			= '' -- TODO
		,strModuleName				= '' -- TODO
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
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
		,strDescription				= '' -- TODO 
		,strCode					= '' -- TODO
		,strReference				= '' -- TODO
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' -- TODO
		,intJournalLineNo			= NULL -- TODO
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId -- TODO
		,intEntityId				= @intUserId -- TODO
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= '' -- TODO 
		,strTransactionForm			= '' -- TODO
		,strModuleName				= '' -- TODO
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
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
		,strDescription				= '' -- TODO 
		,strCode					= '' -- TODO
		,strReference				= '' -- TODO
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
		,strJournalLineDescription	= '' -- TODO
		,intJournalLineNo			= NULL -- TODO
		,ysnIsUnposted				= 0
		,intUserId					= @intUserId -- TODO
		,intEntityId				= @intUserId -- TODO
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= '' -- TODO 
		,strTransactionForm			= '' -- TODO
		,strModuleName				= '' -- TODO
		,intConcurrencyId			= 1
FROM	ForGLEntries_CTE 
		INNER JOIN @GLAccounts GLAccounts
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblUnitQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0)) Credit
WHERE	intTransactionTypeId  = @AUTO_NEGATIVE
;

-- Query the GL Entries table
SELECT * FROM @GLEntries;