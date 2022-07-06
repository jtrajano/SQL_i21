CREATE PROCEDURE [dbo].[uspGRCreateItemGLEntriesTransfer]
	@strBatchId AS NVARCHAR(40)
	,@GLEntries AS GLForItem READONLY
	,@AccountCategory_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 	
	,@intContraInventory_ItemLocationId AS INT = NULL
	,@intRebuildCategoryId AS INT = NULL -- This is only used when rebuilding the stocks. 
	,@intRebuildItemId AS INT = NULL
	,@ysnUnpostInvAdj AS BIT = 0
	,@ysnDPtoOS AS BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_Inventory AS NVARCHAR(30) = 'Inventory'
DECLARE @AccountCategory_Auto_Variance AS NVARCHAR(30) = 'Inventory Adjustment' --'Auto-Variance' -- Auto-variance will no longer be used. It will now use Inventory Adjustment. 

-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the variables for the internal transaction types used by costing. 
DECLARE @InventoryTransactionTypeId_AutoNegative AS INT = 1;
DECLARE @InventoryTransactionTypeId_WriteOffSold AS INT = 2;
DECLARE @InventoryTransactionTypeId_RevalueSold AS INT = 3;
DECLARE @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock AS INT = 35;

DECLARE @strTransactionForm NVARCHAR(255)

-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Grain';

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
SELECT	
	Query.intItemId
	,Query.intItemLocationId
	,intInventoryId			= dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Inventory) 
	,intContraInventoryId	= dbo.fnGetItemGLAccount(Query.intItemId, ISNULL(@intContraInventory_ItemLocationId, Query.intItemLocationId), @AccountCategory_ContraInventory) 
	,intAutoNegativeId		= dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_Auto_Variance) 
	,intTransactionTypeId
FROM (
	SELECT DISTINCT 
		t.intItemId
		,t.intItemLocationId
		,t.intTransactionTypeId
	FROM dbo.tblICInventoryTransaction t 
	INNER JOIN tblICItem i
		ON t.intItemId = i.intItemId 
	WHERE t.strBatchId = @strBatchId
		AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
		AND ISNULL(i.intCategoryId, 0) = COALESCE(@intRebuildCategoryId, i.intCategoryId, 0) 
		AND i.strType <> 'Non-Inventory'
) Query

-- Validate the GL Accounts
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemId AS INT 
DECLARE @strLocationName AS NVARCHAR(50)

-- Check for missing Inventory Account Id
BEGIN 
	SELECT TOP 1 
		@intItemId	= Item.intItemId 
		,@strItemNo = Item.strItemNo
	FROM tblICItem Item 
	INNER JOIN @GLAccounts ItemGLAccount
		ON Item.intItemId = ItemGLAccount.intItemId
	WHERE ItemGLAccount.intInventoryId IS NULL 

	SELECT TOP 1 
		@strLocationName = c.strLocationName
	FROM tblICItemLocation il 
	INNER JOIN tblSMCompanyLocation c
		ON il.intLocationId = c.intCompanyLocationId
	INNER JOIN @GLAccounts ItemGLAccount
		ON ItemGLAccount.intItemId = il.intItemId
			AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE il.intItemId = @intItemId
		AND ItemGLAccount.intInventoryId IS NULL 

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_Inventory;
		RETURN -1;
	END 
END 
;

-- Check for missing Contra-Account Id
IF @AccountCategory_ContraInventory IS NOT NULL 
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT TOP 1 
		@intItemId = Item.intItemId 
		,@strItemNo = Item.strItemNo
	FROM dbo.tblICItem Item 
	INNER JOIN @GLAccounts ItemGLAccount
		ON Item.intItemId = ItemGLAccount.intItemId
	WHERE ItemGLAccount.intContraInventoryId IS NULL

	SELECT TOP 1 
		@strLocationName = c.strLocationName
	FROM tblICItemLocation il 
	INNER JOIN tblSMCompanyLocation c
		ON il.intLocationId = c.intCompanyLocationId
	INNER JOIN @GLAccounts ItemGLAccount
		ON ItemGLAccount.intItemId = il.intItemId
			AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE il.intItemId = @intItemId
		AND ItemGLAccount.intContraInventoryId IS NULL 
			
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_ContraInventory;
		RETURN -1;
	END 
END 
;

-- Check for missing Auto Variance Account Id
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT TOP 1 
		@intItemId = Item.intItemId 
		,@strItemNo = Item.strItemNo
	FROM tblICItem Item 
	INNER JOIN @GLAccounts ItemGLAccount
		ON Item.intItemId = ItemGLAccount.intItemId
	WHERE ItemGLAccount.intAutoNegativeId IS NULL 
		AND EXISTS (
			SELECT TOP 1 1 
			FROM dbo.tblICInventoryTransaction t 
			INNER JOIN dbo.tblICInventoryTransactionType TransType
				ON t.intTransactionTypeId = TransType.intTransactionTypeId
			INNER JOIN tblICItem i
				ON i.intItemId = t.intItemId
			WHERE t.strBatchId = @strBatchId
				AND TransType.intTransactionTypeId IN (@InventoryTransactionTypeId_AutoNegative, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock)
				AND t.intItemId = Item.intItemId
				AND t.dblQty * t.dblCost + t.dblValue <> 0
		)

	SELECT TOP 1 
		@strLocationName = c.strLocationName
	FROM tblICItemLocation il 
	INNER JOIN tblSMCompanyLocation c
		ON il.intLocationId = c.intCompanyLocationId
	INNER JOIN @GLAccounts ItemGLAccount
		ON ItemGLAccount.intItemId = il.intItemId
			AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE il.intItemId = @intItemId
		AND ItemGLAccount.intAutoNegativeId IS NULL 
	
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_Auto_Variance;
		RETURN -1;
	END 
END 
;

-- Get the default transaction form name
SELECT TOP 1 
	@strTransactionForm = TransType.strTransactionForm
FROM dbo.tblICInventoryTransaction t 
INNER JOIN dbo.tblICInventoryTransactionType TransType
	ON t.intTransactionTypeId = TransType.intTransactionTypeId
INNER JOIN tblICItem i
	ON i.intItemId = t.intItemId 
INNER JOIN @GLAccounts GLAccounts
	ON t.intItemId = GLAccounts.intItemId
		AND t.intItemLocationId = GLAccounts.intItemLocationId
		AND t.intTransactionTypeId = GLAccounts.intTransactionTypeId
INNER JOIN dbo.tblGLAccount
	ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
WHERE 
	t.strBatchId = @strBatchId
	AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
	AND ISNULL(i.intCategoryId, 0) = COALESCE(@intRebuildCategoryId, i.intCategoryId, 0) 
;

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
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
	,dblItemCost
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
	,strTransactionType
	,strLotNumber
)
AS 
(
	--Inventory
	SELECT	
		t.dtmDate
		,t.intItemId
		,t.intItemLocationId
		,t.intTransactionId
		,t.strTransactionId
		,t.dblQty
		,t.dblUOMQty
		,dblCost = CASE WHEN t.dblQty > 0 THEN t.dblCost -dbo.fnDivide(DiscountCost.dblTotalDiscountCost, t.dblQty) ELSE t.dblCost -dbo.fnDivide(DiscountCost.dblTotalDiscountCost, -t.dblQty) END
		,dblItemCost = t.dblCost
		,t.dblValue
		,t.intTransactionTypeId
		,ISNULL(t.intCurrencyId, @DefaultCurrencyId) intCurrencyId
		,t.dblExchangeRate
		,t.intInventoryTransactionId
		,strInventoryTransactionTypeName = TransType.strName
		,t.strTransactionForm 
		,t.strDescription
		,t.dblForexRate
		,i.strItemNo
		,strRateType = currencyRateType.strCurrencyExchangeRateType
		,strTransactionType = 'Inventory'
		,lot.strLotNumber
	FROM dbo.tblICInventoryTransaction t 
	INNER JOIN dbo.tblICInventoryTransactionType TransType
		ON t.intTransactionTypeId = TransType.intTransactionTypeId
	INNER JOIN tblICItem i
		ON i.intItemId = t.intItemId
	LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
	OUTER APPLY (
		SELECT 
			ISNULL(SV.dblCost,0) as dblTotalDiscountCost
		FROM @GLEntries SV
	) DiscountCost
	LEFT JOIN tblICLot lot
		ON lot.intLotId = t.intLotId
	WHERE t.strBatchId = @strBatchId
		AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
		AND ISNULL(i.intCategoryId, 0) = COALESCE(@intRebuildCategoryId, i.intCategoryId, 0) 
		AND t.intInTransitSourceLocationId IS NULL -- If there is a value in intInTransitSourceLocationId, then it is for In-Transit costing. Use uspICCreateGLEntriesForInTransitCosting instead of this sp.
		AND @ysnUnpostInvAdj = 0

	UNION ALL
	--Cost adjustment
	SELECT * FROM (SELECT	
		t.dtmDate
		,t.intItemId
		,t.intItemLocationId
		,t.intTransactionId
		,t.strTransactionId
		,t.dblQty
		,t.dblUOMQty
		,dblCost = (CASE WHEN t.dblQty > 0 THEN (t.dblCost - (CS_FROM.dblBasis + CS_FROM.dblSettlementPrice)) -dbo.fnDivide(ISNULL(DiscountCost.dblTotalDiscountCost,0), t.dblQty) ELSE (t.dblCost - (CS_FROM.dblBasis + CS_FROM.dblSettlementPrice)) -dbo.fnDivide(ISNULL(DiscountCost.dblTotalDiscountCost,0), -t.dblQty) END) * -1
		,dblItemCost = t.dblCost
		,t.dblValue
		,t.intTransactionTypeId
		,ISNULL(t.intCurrencyId, @DefaultCurrencyId) intCurrencyId
		,t.dblExchangeRate
		,intInventoryTransactionId = @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock--t.intInventoryTransactionId
		,strInventoryTransactionTypeName = TransType.strName
		,t.strTransactionForm 
		,t.strDescription
		,t.dblForexRate
		,i.strItemNo
		,strRateType = currencyRateType.strCurrencyExchangeRateType
		,strTransactionType = 'Cost Adjustment'
		,lot.strLotNumber
	FROM tblICInventoryTransaction t
	INNER JOIN tblGRTransferStorageReference TSR
		ON TSR.intTransferStorageReferenceId = t.intTransactionDetailId
	INNER JOIN tblGRTransferStorage TS
		ON TS.intTransferStorageId = t.intTransactionId
			AND TS.strTransferStorageTicket = t.strTransactionId
	INNER JOIN tblGRCustomerStorage CS_FROM
		ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
	INNER JOIN tblGRCustomerStorage CS_TO
		ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
	INNER JOIN tblGRStorageType ST_TO
		ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId	
			AND ST_TO.ysnDPOwnedType = 0
	INNER JOIN dbo.tblICInventoryTransactionType TransType
		ON t.intTransactionTypeId = TransType.intTransactionTypeId
	INNER JOIN tblICItem i
		ON i.intItemId = t.intItemId
	LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
	OUTER APPLY (
		SELECT 
			SV.dblCost as dblTotalDiscountCost
		FROM @GLEntries SV
	) DiscountCost
	LEFT JOIN tblICLot lot
		ON lot.intLotId = t.intLotId
	WHERE t.strBatchId = @strBatchId
		AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
		AND ISNULL(i.intCategoryId, 0) = COALESCE(@intRebuildCategoryId, i.intCategoryId, 0) 
		AND t.intInTransitSourceLocationId IS NULL
		AND (@ysnDPtoOS = 1 OR (@ysnDPtoOS = 0 AND @ysnUnpostInvAdj = 1))
	) A WHERE dblCost <> 0
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
	,dblDebitUnit				= DebitUnit.Value
	,dblCreditUnit				= CreditUnit.Value
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblItemCost, strLotNumber) --+ 'A'
	,strCode					= 'IC' 
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= NULL 
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
FROM ForGLEntries_CTE  
INNER JOIN @GLAccounts GLAccounts
	ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
	AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
	AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
INNER JOIN dbo.tblGLAccount
	ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Credit
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
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) CreditUnit
WHERE ForGLEntries_CTE.intTransactionTypeId NOT IN (
	@InventoryTransactionTypeId_WriteOffSold
	, @InventoryTransactionTypeId_RevalueSold
	, @InventoryTransactionTypeId_AutoNegative
	, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
)
	AND ForGLEntries_CTE.strTransactionType = 'Inventory'

UNION ALL

SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= tblGLAccount.intAccountId
	,dblDebit					= Debit.Value
	,dblCredit					= Credit.Value
	,dblDebitUnit				= CreditUnit.Value
	,dblCreditUnit				= DebitUnit.Value
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost, strLotNumber) --+ 'Z'
	,strCode					= 'ICA' 
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= NULL 
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
FROM ForGLEntries_CTE  
INNER JOIN @GLAccounts GLAccounts
	ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
	AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
	AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
INNER JOIN dbo.tblGLAccount
	ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Credit
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
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) CreditUnit
WHERE ForGLEntries_CTE.intTransactionTypeId NOT IN (
	@InventoryTransactionTypeId_WriteOffSold
	, @InventoryTransactionTypeId_RevalueSold
	, @InventoryTransactionTypeId_AutoNegative
	, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
)
	AND ForGLEntries_CTE.strTransactionType = 'Cost Adjustment'

UNION ALL 

SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= tblGLAccount.intAccountId
	,dblDebit					= Credit.Value
	,dblCredit					= Debit.Value
	,dblDebitUnit				= CASE WHEN strTransactionType = 'Inventory' THEN CreditUnit.Value ELSE DebitUnit.Value END
	,dblCreditUnit				= CASE WHEN strTransactionType = 'Inventory' THEN DebitUnit.Value ELSE CreditUnit.Value END
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, CASE WHEN strTransactionType = 'Inventory' THEN dblItemCost ELSE dblCost END, strLotNumber) --+ 'B'
	,strCode					= 'IC' 
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= NULL 
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
FROM ForGLEntries_CTE 
INNER JOIN @GLAccounts GLAccounts
	ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
		AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
INNER JOIN dbo.tblGLAccount
	ON tblGLAccount.intAccountId = GLAccounts.intContraInventoryId
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Credit
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
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) CreditUnit
WHERE ForGLEntries_CTE.intTransactionTypeId NOT IN (
	@InventoryTransactionTypeId_WriteOffSold
	, @InventoryTransactionTypeId_RevalueSold
	, @InventoryTransactionTypeId_AutoNegative
	, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
)
	AND ForGLEntries_CTE.strTransactionType <> 'Cost Adjustment'

UNION ALL

SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= tblGLAccount.intAccountId
	,dblDebit					= Credit.Value
	,dblCredit					= Debit.Value
	,dblDebitUnit				= CASE WHEN strTransactionType = 'Inventory' THEN CreditUnit.Value ELSE DebitUnit.Value END
	,dblCreditUnit				= CASE WHEN strTransactionType = 'Inventory' THEN DebitUnit.Value ELSE CreditUnit.Value END
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, CASE WHEN strTransactionType = 'Inventory' THEN dblItemCost ELSE dblCost END, strLotNumber) --+ 'B'
	,strCode					= 'ICA' 
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= NULL 
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
FROM ForGLEntries_CTE 
INNER JOIN @GLAccounts GLAccounts
	ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
		AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
INNER JOIN dbo.tblGLAccount
	ON tblGLAccount.intAccountId = GLAccounts.intContraInventoryId
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Credit
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
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) CreditUnit
WHERE ForGLEntries_CTE.intTransactionTypeId NOT IN (
	@InventoryTransactionTypeId_WriteOffSold
	, @InventoryTransactionTypeId_RevalueSold
	, @InventoryTransactionTypeId_AutoNegative
	, @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
)
	AND ForGLEntries_CTE.strTransactionType = 'Cost Adjustment'

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
	,dblDebitUnit				= DebitUnit.Value
	,dblCreditUnit				= CreditUnit.Value
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblItemCost, strLotNumber)-- + 'C'
	,strCode					= 'IAV'
	,strReference				= ''
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= NULL 
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
FROM ForGLEntries_CTE 
INNER JOIN @GLAccounts GLAccounts
	ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
	AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
	AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
INNER JOIN dbo.tblGLAccount
	ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Credit
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
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) CreditUnit
WHERE ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
	AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 
	AND ForGLEntries_CTE.strTransactionType = 'Inventory'

UNION ALL 
SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= tblGLAccount.intAccountId
	,dblDebit					= Credit.Value
	,dblCredit					= Debit.Value
	,dblDebitUnit				= CreditUnit.Value
	,dblCreditUnit				= DebitUnit.Value
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblItemCost, strLotNumber) --+ 'D'
	,strCode					= 'IAV' 
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription    = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= NULL 
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
FROM ForGLEntries_CTE 
INNER JOIN @GLAccounts GLAccounts
	ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
	AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
	AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
INNER JOIN dbo.tblGLAccount
	ON tblGLAccount.intAccountId = GLAccounts.intAutoNegativeId
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Credit
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
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) CreditUnit
WHERE ForGLEntries_CTE.intTransactionTypeId  = @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock
	AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 
	AND ForGLEntries_CTE.strTransactionType = 'Inventory'
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
	,dblDebitUnit				= DebitUnit.Value
	,dblCreditUnit				= CreditUnit.Value
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblItemCost, strLotNumber) --+ 'E'
	,strCode					= 'IAN' 
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= NULL 
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
FROM ForGLEntries_CTE 
INNER JOIN @GLAccounts GLAccounts
	ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
		AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
		AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
INNER JOIN dbo.tblGLAccount
	ON tblGLAccount.intAccountId = GLAccounts.intInventoryId
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Credit
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
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) CreditUnit 

WHERE ForGLEntries_CTE.intTransactionTypeId = @InventoryTransactionTypeId_AutoNegative
	AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 
	AND ForGLEntries_CTE.strTransactionType = 'Inventory'

UNION ALL 
SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= tblGLAccount.intAccountId
	,dblDebit					= Credit.Value
	,dblCredit					= Debit.Value
	,dblDebitUnit				= CreditUnit.Value
	,dblCreditUnit				= DebitUnit.Value
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblItemCost, strLotNumber) --+ 'F'
	,strCode					= 'IAN' 
	,strReference				= '' 
	,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	,dtmDateEntered				= GETDATE()
	,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
    ,strJournalLineDescription  = '' 
	,intJournalLineNo			= ForGLEntries_CTE.intInventoryTransactionId
	,ysnIsUnposted				= 0
	,intUserId					= @intEntityUserSecurityId
	,intEntityId				= NULL 
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
CROSS APPLY dbo.fnGetDebit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Debit
CROSS APPLY dbo.fnGetCredit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblCost, 0)) + ISNULL(dblValue, 0)) Credit
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
CROSS APPLY dbo.fnGetDebitUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) DebitUnit
CROSS APPLY dbo.fnGetCreditUnit(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1))) CreditUnit
WHERE ForGLEntries_CTE.intTransactionTypeId  = @InventoryTransactionTypeId_AutoNegative
	AND ROUND(ISNULL(dblQty, 0) * ISNULL(dblCost, 0) + ISNULL(dblValue, 0), 2) <> 0 
	AND ForGLEntries_CTE.strTransactionType = 'Inventory'
;