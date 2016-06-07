CREATE PROCEDURE [dbo].[uspICCreateGLEntries]
	@strBatchId AS NVARCHAR(20)
	,@AccountCategory_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 	
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
DECLARE @AccountCategory_AutoNegative AS NVARCHAR(30) = 'Auto-Variance';

-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the variables for the internal transaction types used by costing. 
DECLARE @InventoryTransactionTypeId_AutoNegative AS INT = 1;
DECLARE @InventoryTransactionTypeId_WriteOffSold AS INT = 2;
DECLARE @InventoryTransactionTypeId_RevalueSold AS INT = 3;

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
	,intWriteOffSoldId 
	,intRevalueSoldId 
	,intAutoNegativeId 
	,intTransactionTypeId
)
SELECT	Query.intItemId
		,Query.intItemLocationId
		,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_ContraInventory) 
		,intWriteOffSoldId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_WriteOffSold) 
		,intRevalueSoldId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_RevalueSold) 
		,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_AutoNegative) 
		,intTransactionTypeId
FROM	(
			SELECT	DISTINCT 
					intItemId, intItemLocationId, intTransactionTypeId
			FROM	dbo.tblICInventoryTransaction TRANS 
			WHERE	TRANS.strBatchId = @strBatchId
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

-- Check for missing Write-Off Sold Account Id
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intWriteOffSoldId IS NULL 
			AND EXISTS (
				SELECT	TOP 1 1 
				FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
							ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
				WHERE	TRANS.strBatchId = @strBatchId
						AND TransType.intTransactionTypeId = @InventoryTransactionTypeId_WriteOffSold 
						AND TRANS.intItemId = Item.intItemId
			)
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_WriteOffSold) 	
		RETURN -1;
	END 
END 
;

-- Check for missing Revalue Sold Account id
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intRevalueSoldId IS NULL 
			AND EXISTS (
				SELECT	TOP 1 1 
				FROM	dbo.tblICInventoryTransaction TRANS INNER JOIN dbo.tblICInventoryTransactionType TransType
							ON TRANS.intTransactionTypeId = TransType.intTransactionTypeId
				WHERE	TRANS.strBatchId = @strBatchId
						AND TransType.intTransactionTypeId = @InventoryTransactionTypeId_RevalueSold  
						AND TRANS.intItemId = Item.intItemId
			)
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_RevalueSold) 	
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
						AND TransType.intTransactionTypeId = @InventoryTransactionTypeId_AutoNegative 
						AND TRANS.intItemId = Item.intItemId
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
WHERE	ForGLEntries_CTE.intTransactionTypeId NOT IN (@InventoryTransactionTypeId_WriteOffSold, @InventoryTransactionTypeId_RevalueSold, @InventoryTransactionTypeId_AutoNegative)

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intContraInventoryId
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
WHERE	ForGLEntries_CTE.intTransactionTypeId NOT IN (@InventoryTransactionTypeId_WriteOffSold, @InventoryTransactionTypeId_RevalueSold, @InventoryTransactionTypeId_AutoNegative)

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
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IWS'
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
WHERE	ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_WriteOffSold
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intWriteOffSoldId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IWS' 
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
			ON tblGLAccount.intAccountId = GLAccounts.intWriteOffSoldId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId  = @InventoryTransactionTypeId_WriteOffSold

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
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IRS' -- TODO
		,strReference				= '' -- TODO
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
WHERE	ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_RevalueSold
UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= GLAccounts.intRevalueSoldId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, tblGLAccount.strDescription)
		,strCode					= 'IRS' 
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
			ON tblGLAccount.intAccountId = GLAccounts.intRevalueSoldId
		CROSS APPLY dbo.fnGetDebit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty) + ISNULL(dblValue, 0)) Credit
WHERE	ForGLEntries_CTE.intTransactionTypeId  = @InventoryTransactionTypeId_RevalueSold

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
		,intAccountId				= GLAccounts.intAutoNegativeId
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