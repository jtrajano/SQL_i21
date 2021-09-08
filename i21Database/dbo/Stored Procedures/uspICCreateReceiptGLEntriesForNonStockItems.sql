CREATE PROCEDURE [dbo].[uspICCreateReceiptGLEntriesForNonStockItems]
	@NonInventoryItem AS ItemCostingTableType READONLY 
	,@strBatchId AS NVARCHAR(40)
	,@intTransactionId AS INT 	
	,@intEntityUserSecurityId AS INT	
	,@strGLDescription AS NVARCHAR(255) = NULL

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Create the variables used by fnGetItemGLAccount
DECLARE @AccountCategory_APClearing AS NVARCHAR(255) = 'AP Clearing'
DECLARE @AccountCategory_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense'
DECLARE @AccountCategory_General AS NVARCHAR(30) = 'General'
DECLARE @strTransactionForm NVARCHAR(255)

DECLARE @InventoryTransactionTypeId_AutoVariance AS INT = 1;
DECLARE @InventoryTransactionTypeId_WriteOffSold AS INT = 2;
DECLARE @InventoryTransactionTypeId_RevalueSold AS INT = 3;
DECLARE @InventoryTransactionTypeId_Auto_Variance_On_Sold_Or_Used_Stock AS INT = 35;

-- Initialize the module name
DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory';
DECLARE @GLAccounts AS TABLE
(
	intItemId INT NOT NULL 
	,intItemLocationId INT NOT NULL 
	,intPOId INT
	,intTransactionTypeId INT 
	,intNonInventoryId INT
	,intContraNonInventoryId INT
	,strNonInventoryAccountCategory NVARCHAR(30)
	,strContraNonInventoryAccountCategory NVARCHAR(30)
	,intOrder INT
)

DECLARE @UnitTrans TABLE (intItemId INT, intItemLocationId INT, intTransactionTypeId INT)
INSERT INTO @UnitTrans
SELECT	DISTINCT 
		intItemId
		, intItemLocationId 
		, intTransactionTypeId
FROM	(
	SELECT	DISTINCT 
			t.intItemId
			, t.intItemLocationId 
			, t.intTransactionTypeId
	FROM	@NonInventoryItem t
) InnerQuery


-- Get the GL Account Other Charge Expense ids to use
INSERT INTO @GLAccounts (
	intItemId 
	,intItemLocationId 
	,intNonInventoryId 
	,intContraNonInventoryId 
	,intPOId
	,intTransactionTypeId
	,strNonInventoryAccountCategory
	,strContraNonInventoryAccountCategory
	,intOrder
)
SELECT	Query.intItemId
		,Query.intItemLocationId
		,intNonInventory = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_OtherChargeExpense)
		,intContraNonInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_APClearing) 
		,NULL
		,intTransactionTypeId
		,@AccountCategory_OtherChargeExpense
		,@AccountCategory_APClearing
		,1
FROM @UnitTrans Query


-- Get Fallback General account ids
INSERT INTO @GLAccounts (
	intItemId 
	,intItemLocationId 
	,intNonInventoryId 
	,intContraNonInventoryId 
	,intPOId
	,intTransactionTypeId
	,strNonInventoryAccountCategory
	,strContraNonInventoryAccountCategory
	,intOrder
)
SELECT	Query.intItemId
		,Query.intItemLocationId
		,intNonInventory = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_General)
		,intContraNonInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_APClearing) 
		,NULL
		,intTransactionTypeId
		,@AccountCategory_General
		,@AccountCategory_APClearing
		,2
FROM @UnitTrans Query

-- Get Accounts from PO
MERGE INTO @GLAccounts AS [target]
USING
(
	SELECT
		DISTINCT 
		  t.intItemId
		, t.intItemLocationId
		, intAccountId = dbo.fnGetLocationAwareItemGLAccount(ap.intAccountId, t.intItemLocationId, @AccountCategory_OtherChargeExpense)
		, intContraNonInventoryId = dbo.fnGetItemGLAccount(i.intItemId, t.intItemLocationId, @AccountCategory_APClearing) 
		, intTransactionTypeId = t.intTransactionTypeId
		,strNonInventoryAccountCategory = @AccountCategory_OtherChargeExpense
		,strContraNonInventoryAccountCategory = @AccountCategory_APClearing
		,intOrder = 0
	FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri 
			ON ri.intInventoryReceiptId = r.intInventoryReceiptId
		INNER JOIN tblICItem i 
			ON i.intItemId = ri.intItemId
		INNER JOIN vyuPODetails ap 
			ON ap.intItemId = ri.intItemId
			AND ap.intPurchaseId = ri.intOrderId	
			AND ap.intPurchaseDetailId = ri.intLineNo
		INNER JOIN @NonInventoryItem t 
			ON t.intTransactionId = r.intInventoryReceiptId
			AND ri.intInventoryReceiptItemId = t.intTransactionDetailId
	WHERE 
		ap.intAccountId IS NOT NULL
) AS [source] (
	intItemId
	, intItemLocationId
	, intAccountId
	, intContraNonInventoryId
	, intTransactionTypeId
	, strNonInventoryAccountCategory
	, strContraNonInventoryAccountCategory
	, intOrder
)
	ON [target].intItemId = [source].intItemId 
	AND [target].intItemLocationId = [source].intItemLocationId 
	AND [target].intNonInventoryId = [source].intAccountId 
	AND [target].intTransactionTypeId = [source].intTransactionTypeId

WHEN MATCHED THEN 
	UPDATE SET intNonInventoryId = [source].intAccountId
	, intTransactionTypeId = [source].intTransactionTypeId
	, intOrder = 0
WHEN NOT MATCHED BY target THEN
INSERT (
	intPOId
	, intNonInventoryId
	, intItemId
	, intItemLocationId
	, intTransactionTypeId
	, intContraNonInventoryId
	, strNonInventoryAccountCategory
	, strContraNonInventoryAccountCategory
	, intOrder
)
VALUES(
	[source].intAccountId
	, [source].intAccountId
	, [source].intItemId
	, [source].intItemLocationId
	, [source].intTransactionTypeId
	, [source].intContraNonInventoryId
	, [source].strNonInventoryAccountCategory
	, [source].strContraNonInventoryAccountCategory
	, [source].intOrder
);

DECLARE @NonStockGLAccounts AS TABLE
(
	intItemId INT NOT NULL 
	,intItemLocationId INT NOT NULL 
	,intPOId INT
	,intTransactionTypeId INT 
	,intNonInventoryId INT
	,intContraNonInventoryId INT
	,strNonInventoryAccountCategory NVARCHAR(30)
	,strContraNonInventoryAccountCategory NVARCHAR(30)
	,intOrder INT
)

;WITH cte AS
(
   SELECT *,
         ROW_NUMBER() OVER (PARTITION BY a.intItemId, a.intItemLocationId ORDER BY intOrder ASC) AS rn
   FROM @GLAccounts a
   WHERE a.intNonInventoryId IS NOT NULL
)
INSERT INTO @NonStockGLAccounts (
	intItemId
	, intItemLocationId
	, intPOId
	, intTransactionTypeId
	, intNonInventoryId
	, intContraNonInventoryId
	, strNonInventoryAccountCategory
	, strContraNonInventoryAccountCategory
	, intOrder
)
SELECT 
	intItemId
	, intItemLocationId
	, intPOId
	, intTransactionTypeId
	, intNonInventoryId
	, intContraNonInventoryId
	, strNonInventoryAccountCategory
	, strContraNonInventoryAccountCategory
	, intOrder
FROM cte
WHERE rn = 1

-- Validate the GL Accounts
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemId AS INT 
DECLARE @strLocationName AS NVARCHAR(50)

-- Check for missing Non-Inventory Account Id
BEGIN 	
	SELECT TOP 1 
		@intItemId = i.intItemId
		,@strItemNo = i.strItemNo
		,@strLocationName = c.strLocationName
	FROM 
		@UnitTrans A INNER JOIN tblICItem i 
			ON A.intItemId = i.intItemId
		INNER JOIN tblICItemLocation il 
			ON il.intItemLocationId = A.intItemLocationId
		INNER JOIN tblSMCompanyLocation c
			ON il.intLocationId = c.intCompanyLocationId
		LEFT JOIN @NonStockGLAccounts B
			ON A.intItemId = B.intItemId
			AND A.intItemLocationId = B.intItemLocationId
	WHERE
		B.intNonInventoryId IS NULL 

	IF @intItemId IS NOT NULL
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		DECLARE @msg NVARCHAR(800) = 'The non-inventory item <b>' + @strItemNo + '</b> at location <b>' + @strLocationName + '</b> is missing a setup for <b>' + @AccountCategory_OtherChargeExpense + '</b> or <b>' + @AccountCategory_General + '</b> GL accounts. (1) Verify if these accounts are properly set up in the <i>item</i> or <i>category</i> screen. (2) Make sure these accounts exist in the GL chart of accounts.'
		--EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_OtherChargeExpense;
		RAISERROR(@msg, 11, 1)
		RETURN -1;
	END
END 
;

-- Check for missing Contra-Account Id
IF @AccountCategory_APClearing IS NOT NULL 
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL

	SELECT TOP 1 
		@intItemId = i.intItemId
		,@strItemNo = i.strItemNo
		,@strLocationName = c.strLocationName
	FROM 
		@UnitTrans A INNER JOIN tblICItem i 
			ON A.intItemId = i.intItemId
		INNER JOIN tblICItemLocation il 
			ON il.intItemLocationId = A.intItemLocationId
		INNER JOIN tblSMCompanyLocation c
			ON il.intLocationId = c.intCompanyLocationId
		LEFT JOIN @NonStockGLAccounts B
			ON A.intItemId = B.intItemId
			AND A.intItemLocationId = B.intItemLocationId
	WHERE
		B.intContraNonInventoryId IS NULL 

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_APClearing;
		RETURN -1;
	END 
END 
;
-- Log the g/l account used in this batch. 
INSERT INTO dbo.tblICInventoryGLAccountUsedOnPostLog (
		intItemId
		,intItemLocationId
		,intNonInventoryId
		,intContraNonInventoryId
		,strBatchId
)
SELECT 
		intItemId
		,intItemLocationId
		,intNonInventoryId
		,intContraNonInventoryId
		,@strBatchId
FROM	@NonStockGLAccounts
;

-- Get the default transaction form name
SELECT TOP 1 
		@strTransactionForm = TransType.strTransactionForm
FROM	@NonInventoryItem t INNER JOIN dbo.tblICInventoryTransactionType TransType
			ON t.intTransactionTypeId = TransType.intTransactionTypeId
		INNER JOIN @GLAccounts GLAccounts
			ON t.intItemId = GLAccounts.intItemId
			AND t.intItemLocationId = GLAccounts.intItemLocationId
			AND t.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount
			ON tblGLAccount.intAccountId = GLAccounts.intNonInventoryId
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
	,intTransactionDetailId
	,strTransactionId
	,dblQty
	,dblUOMQty
	,dblCost
	,dblValue
	,intTransactionTypeId
	,intCurrencyId
	,dblExchangeRate
	,strTransactionName
	,strTransactionForm
	,dblForexRate
	,strItemNo
	,strRateType
	,dblLineTotal
	,intSourceEntityId
	,intCommodityId
)
AS 
(
	SELECT	
		t.dtmDate
		,t.intItemId
		,t.intItemLocationId 
		,t.intTransactionId
		,t.intTransactionDetailId
		,t.strTransactionId
		,t.dblQty
		,t.dblUOMQty
		,t.dblCost
		,t.dblValue
		,t.intTransactionTypeId
		,ISNULL(t.intCurrencyId, @intFunctionalCurrencyId) intCurrencyId
		,t.dblExchangeRate
		,strTransactionName = TransType.strName
		,TransType.strTransactionForm
		,t.dblForexRate	
		,i.strItemNo
		,strRateType = currencyRateType.strCurrencyExchangeRateType
		,dblLineTotal = 
				t.dblQty *
				dbo.fnCalculateReceiptUnitCost(
					ri.intItemId
					,ri.intUnitMeasureId		
					,ri.intCostUOMId
					,ri.intWeightUOMId
					,ri.dblUnitCost
					,ri.dblNet
					,t.intLotId
					,t.intItemUOMId
					,NULL --AggregrateItemLots.dblTotalNet
					,ri.ysnSubCurrency
					,r.intSubCurrencyCents
					,DEFAULT 
				)
		,intSourceEntityId = r.intEntityVendorId
		,intCommodityId = i.intCommodityId
	FROM 
		@NonInventoryItem t INNER JOIN tblICInventoryTransactionType TransType 
			ON t.intTransactionTypeId = TransType.intTransactionTypeId
		INNER JOIN tblICItem i 
			ON i.intItemId = t.intItemId
		INNER JOIN tblICInventoryReceipt r 
			ON r.strReceiptNumber = t.strTransactionId
			AND r.intInventoryReceiptId = t.intTransactionId			
		LEFT JOIN tblICInventoryReceiptItem ri 
			ON ri.intInventoryReceiptId = r.intInventoryReceiptId
			AND ri.intInventoryReceiptItemId = t.intTransactionDetailId
		LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType 
			ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
)

-------------------------------------------------------------------------------------------
-- G/L entries for Non-Inventory items received in the IR screen.
-------------------------------------------------------------------------------------------
/*
	Debit	......... Expense
	Credit	.......................... A/P Clearing
*/

SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId 
		,dblDebit					= Debit.Value
		,dblCredit					= Credit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intTransactionDetailId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId 
		,intEntityId				= NULL
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strTransactionName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm)
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
FROM	ForGLEntries_CTE INNER JOIN @NonStockGLAccounts GLAccounts 
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND (ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId)
		INNER JOIN dbo.tblGLAccount 
			ON tblGLAccount.intAccountId = GLAccounts.intNonInventoryId
		CROSS APPLY dbo.fnGetDebit(
			ISNULL(dblLineTotal, 0)
		) DebitForeign
		CROSS APPLY dbo.fnGetCredit(
			ISNULL(dblLineTotal, 0) 			
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitFunctional(
			ISNULL(dblLineTotal, 0)	
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
			ISNULL(dblLineTotal, 0) 			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) Credit
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 
WHERE	ForGLEntries_CTE.dblLineTotal <> 0 

UNION ALL 
SELECT	
		dtmDate						= ForGLEntries_CTE.dtmDate
		,strBatchId					= @strBatchId
		,intAccountId				= tblGLAccount.intAccountId
		,dblDebit					= Credit.Value
		,dblCredit					= Debit.Value
		,dblDebitUnit				= 0
		,dblCreditUnit				= 0
		,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblCost) 
		,strCode					= 'IC' 
		,strReference				= '' 
		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered				= GETDATE()
		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
        ,strJournalLineDescription  = '' 
		,intJournalLineNo			= ForGLEntries_CTE.intTransactionDetailId
		,ysnIsUnposted				= 0
		,intUserId					= @intEntityUserSecurityId 
		,intEntityId				= NULL
		,strTransactionId			= ForGLEntries_CTE.strTransactionId
		,intTransactionId			= ForGLEntries_CTE.intTransactionId
		,strTransactionType			= ForGLEntries_CTE.strTransactionName
		,strTransactionForm			= ISNULL(ForGLEntries_CTE.strTransactionForm, @strTransactionForm) 
		,strModuleName				= @ModuleName
		,intConcurrencyId			= 1
		,dblDebitForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE CreditForeign.Value END 
		,dblDebitReport				= NULL 
		,dblCreditForeign			= CASE WHEN intCurrencyId = @intFunctionalCurrencyId THEN 0 ELSE DebitForeign.Value END 
		,dblCreditReport			= NULL 
		,dblReportingRate			= NULL 
		,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
		,strRateType				= ForGLEntries_CTE.strRateType 
		,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
		,intCommodityId				= ForGLEntries_CTE.intCommodityId
FROM	ForGLEntries_CTE INNER JOIN @NonStockGLAccounts GLAccounts 
			ON ForGLEntries_CTE.intItemId = GLAccounts.intItemId
			AND ForGLEntries_CTE.intItemLocationId = GLAccounts.intItemLocationId
			AND ForGLEntries_CTE.intTransactionTypeId = GLAccounts.intTransactionTypeId
		INNER JOIN dbo.tblGLAccount 
			ON tblGLAccount.intAccountId = GLAccounts.intContraNonInventoryId
		CROSS APPLY dbo.fnGetDebit(
			ISNULL(dblLineTotal, 0)			
		) DebitForeign
		CROSS APPLY dbo.fnGetCredit(
			ISNULL(dblLineTotal, 0) 			
		) CreditForeign
		CROSS APPLY dbo.fnGetDebitFunctional(
			ISNULL(dblLineTotal, 0)			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) Debit
		CROSS APPLY dbo.fnGetCreditFunctional(
			ISNULL(dblLineTotal, 0) 			
			,ForGLEntries_CTE.intCurrencyId
			,@intFunctionalCurrencyId
			,ForGLEntries_CTE.dblForexRate
		) Credit
		CROSS APPLY dbo.fnGetDebitUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) DebitUnit
		CROSS APPLY dbo.fnGetCreditUnit(
			dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(dblUOMQty, 1)) 
		) CreditUnit 

WHERE	ForGLEntries_CTE.dblLineTotal <> 0 
