CREATE PROCEDURE [dbo].[uspICCreateReturnGLEntries]
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
DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
		,@AccountCategory_Auto_Variance AS NVARCHAR(30) = 'Auto-Variance'
		,@AccountCategory_Cost_of_Goods AS NVARCHAR(30) = 'Cost of Goods'

-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the variables for the internal transaction types used by costing. 
DECLARE @InventoryTransactionTypeId_AutoNegative AS INT = 1;
DECLARE @InventoryTransactionTypeId_WriteOffSold AS INT = 2;
DECLARE @InventoryTransactionTypeId_RevalueSold AS INT = 3;
DECLARE @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock AS INT = 35;
DECLARE @InventoryTransactionTypeId_InventoryAdjustmentQtyChange AS INT = 10;

DECLARE @strTransactionForm NVARCHAR(255) = 'Inventory Receipt'

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
	,intCOGSId
	,intTransactionTypeId
)
SELECT	Query.intItemId
		,Query.intItemLocationId
		,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
		,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, ISNULL(@intContraInventory_ItemLocationId, Query.intItemLocationId), @AccountCategory_ContraInventory) 		
		,intAutoNegativeId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Auto_Variance) 
		,intCOGSId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Cost_of_Goods) 
		,intTransactionTypeId
FROM	(
			SELECT  DISTINCT 
					t.intItemId
					, t.intItemLocationId
					, t.intTransactionTypeId
			FROM (
				-- regular inventory transactions 
				SELECT	intItemId, intItemLocationId, intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t 
				WHERE	t.strBatchId = @strBatchId
						AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
				-- inventory-adj-qty-change transactions involved in the item return. 
				UNION ALL 
				SELECT	DISTINCT t.intItemId, t.intItemLocationId, t.intTransactionTypeId
				FROM	dbo.tblICInventoryTransaction t INNER JOIN tblICInventoryReturned rtn 
							ON t.intInventoryTransactionId = rtn.intInventoryTransactionId
				WHERE	rtn.strBatchId = @strBatchId
						AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId)
			) t 			
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

-- Check for missing COGS Id
IF EXISTS (SELECT TOP 1 1 FROM tblICInventoryReturned rtn WHERE rtn.strBatchId = @strBatchId) 
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	dbo.tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intCOGSId IS NULL 			
			
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_Cost_of_Goods) 	
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
				FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
							ON t.intTransactionTypeId = TransType.intTransactionTypeId
				WHERE	t.strBatchId = @strBatchId
						AND TransType.intTransactionTypeId IN (@InventoryTransactionTypeId_AutoNegative, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock)
						AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
						AND t.intItemId = Item.intItemId
						AND t.dblQty * t.dblCost + t.dblValue <> 0
			)
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} is missing a GL account setup for {Account Category} account category.
		RAISERROR(80008, 11, 1, @strItemNo, @AccountCategory_Auto_Variance) 	
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
FROM	dbo.tblICInventoryTransactionType TransType		
WHERE	TransType.strName = 'Inventory Receipt'
;

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 
;

-- Generate the G/L Entries for Inventory Transactions 
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
	,dblForexRate
	,strRateType 
)
AS 
(
	-- regular inventory transaction 
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
			,ISNULL(t.intCurrencyId, @DefaultCurrencyId) intCurrencyId
			,t.dblExchangeRate
			,t.intInventoryTransactionId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = @strTransactionForm
			,t.strDescription
			,t.dblForexRate
			,strRateType = currencyRateType.strCurrencyExchangeRateType
	FROM	dbo.tblICInventoryTransaction t INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
	WHERE	t.strBatchId = @strBatchId
			AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
	-- inventory return 
	UNION ALL 
	SELECT	dtmDate	= r.dtmReceiptDate
			,t.intItemId
			,t.intItemLocationId
			,intTransactionId = r.intInventoryReceiptId
			,strTransactionId = r.strReceiptNumber
			,-rtn.dblQtyReturned
			,dblUOMQty = NULL 
			,rtn.dblCost
			,dblValue = 0 
			,rtn.intTransactionTypeId
			,intCurrencyId = @DefaultCurrencyId
			,dblExchangeRate = 1
			,intInventoryTransactionId = t.intInventoryTransactionId 
			,ty.strTransactionType
			,ty.strTransactionForm 
			,strDescription = NULL  
			,t.dblForexRate
			,strRateType = currencyRateType.strCurrencyExchangeRateType
	FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryReturned rtn
				ON rtn.intInventoryTransactionId = t.intInventoryTransactionId
			INNER JOIN tblICInventoryReceipt r
				ON r.intInventoryReceiptId = rtn.intTransactionId 
				AND r.strReceiptNumber = rtn.strTransactionId
			OUTER APPLY (
				SELECT TOP 1 
						strTransactionType = ty.strName
						,ty.intTransactionTypeId
						,strTransactionForm = 'Inventory Receipt'
				FROM	dbo.tblICInventoryTransactionType ty
				WHERE	ty.strName = 'Inventory Return'
			) ty
			LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
				ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId


	WHERE	rtn.strBatchId = @strBatchId
			AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
			AND rtn.intTransactionTypeId = @InventoryTransactionTypeId_InventoryAdjustmentQtyChange
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
		,dblDebitForeign			= DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CreditForeign.Value
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
			ON tblGLAccount.intAccountId = 
				CASE 
					WHEN ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_InventoryAdjustmentQtyChange
						THEN GLAccounts.intCOGSId
					ELSE 
						GLAccounts.intInventoryId
				END 
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
		,dblDebitForeign			= CreditForeign.Value
		,dblDebitReport				= NULL 
		,dblCreditForeign			= DebitForeign.Value 
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
		,dblDebitForeign			= DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CreditForeign.Value
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
WHERE	ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
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
		,dblDebitForeign			= CreditForeign.Value
		,dblDebitReport				= NULL 
		,dblCreditForeign			= DebitForeign.Value 
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
WHERE	ForGLEntries_CTE.intTransactionTypeId  = @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
		AND (Debit.Value <> 0 OR Credit.Value <> 0)

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
		,dblDebitForeign			= DebitForeign.Value 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CreditForeign.Value
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
		,dblDebitForeign			= CreditForeign.Value
		,dblDebitReport				= NULL 
		,dblCreditForeign			= DebitForeign.Value 
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
WHERE	ForGLEntries_CTE.intTransactionTypeId  = @InventoryTransactionTypeId_AutoNegative
		AND (Debit.Value <> 0 OR Credit.Value <> 0)
;