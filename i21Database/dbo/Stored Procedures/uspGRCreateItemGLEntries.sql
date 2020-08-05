CREATE PROCEDURE [dbo].[uspGRCreateItemGLEntries]
	@strBatchId AS NVARCHAR(40)
	,@SettleVoucherCreate AS SettleVoucherCreate READONLY
	,@AccountCategory_ContraInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 	
	,@intContraInventory_ItemLocationId AS INT = NULL
	,@ysnForRebuild as BIT = 0 	
	,@intRebuildItemId AS INT = NULL -- This is only used when rebuilding the stocks. 
	,@intRebuildCategoryId AS INT = NULL -- This is only used when rebuilding the stocks. 
	,@dblSelectedUnits AS DECIMAL(24,10) = null
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	declare @debug_awesome_ness bit = 0
	
	--if exists( select top 1 1 from @SettleVoucherCreate where intSettleVoucherKey > 7)
	--begin
	--	set @debug_awesome_ness = 0
	--end
	if @debug_awesome_ness = 1	
	begin
		
		select 'awesomeness begins [uspGRCreateItemGLEntries]'
		--set @dblCashPriceFromCt = 9.55
	end

DECLARE @dblGrossUnits AS DECIMAL(24,10) = null

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
declare @EntityNo nvarchar(100)

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


-- Getting Entity no
	select top 1 @EntityNo = strEntityNo from  
		@SettleVoucherCreate VoucherCreate		
			join tblGRCustomerStorage CustomerStorage
				on CustomerStorage.intCustomerStorageId = VoucherCreate.intCustomerStorageId			
			join tblEMEntity Entity
				on CustomerStorage.intEntityId = Entity.intEntityId
		where VoucherCreate.intItemType = 1

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


if @ysnForRebuild = 0
	exec uspGRHandleSettleVoucherCreateReferenceTable  @strBatchId, @SettleVoucherCreate

;

select @dblGrossUnits = dblUnits from @SettleVoucherCreate where ysnDiscountFromGrossWeight = 1


if @debug_awesome_ness = 1
begin
	select 'voucher create reference table ', * from tblGRSettleVoucherCreateReferenceTable where strBatchId = @strBatchId
	select 'Settle voucher create', * from @SettleVoucherCreate
	SELECT	'this is what the data will be the reference for'		
		,DiscountCost.*
		,@dblSelectedUnits as [selected units]
		,dbo.fnDivide(DiscountCost.dblTotalDiscountCost, isnull(@dblSelectedUnits, t.dblQty) )
		,t.dtmDate
		,t.intItemId
		,t.intItemLocationId
		,t.intTransactionId
		,t.strTransactionId
		,t.dblQty
		,t.dblUOMQty
		,dblCost = t.dblCost - dbo.fnDivide(DiscountCost.dblTotalDiscountCost, t.dblQty ) 
		,DiscountCost.dblTotalDiscountCost
		, t.dblQty
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
	FROM dbo.tblICInventoryTransaction t 
	INNER JOIN dbo.tblICInventoryTransactionType TransType
		ON t.intTransactionTypeId = TransType.intTransactionTypeId
	INNER JOIN tblICItem i
		ON i.intItemId = t.intItemId
	LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
	OUTER APPLY (
		SELECT 
			ISNULL(round(SUM(((SV.dblCashPrice * CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 THEN SV.dblSettleContractUnits ELSE SV.dblUnits END)) ), 2),0)  AS dblTotalDiscountCost
		FROM tblGRSettleVoucherCreateReferenceTable SV	
		WHERE intItemType = 3 and SV.strBatchId = @strBatchId and SV.ysnItemInventoryCost = 1--DISCOUNTS
	) DiscountCost
	WHERE t.strBatchId = @strBatchId
		AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
		AND ISNULL(i.intCategoryId, 0) = COALESCE(@intRebuildCategoryId, i.intCategoryId, 0) 
		AND t.intInTransitSourceLocationId IS NULL -- If there is a value in intInTransitSourceLocationId, then it is for In-Transit costing. Use uspICCreateGLEntriesForInTransitCosting instead of this sp.

end

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
)
AS 
(
	SELECT	
		t.dtmDate
		,t.intItemId
		,t.intItemLocationId
		,t.intTransactionId
		,t.strTransactionId
		,t.dblQty
		,t.dblUOMQty
		,dblCost = t.dblCost 
				- (
					dbo.fnDivide(DiscountCost.dblTotalDiscountCost, isnull(@dblSelectedUnits, t.dblQty) ) 
				  + dbo.fnDivide(DiscountCostGross.dblTotalDiscountCost, isnull(@dblGrossUnits, t.dblQty) ) 
				  )
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
	FROM dbo.tblICInventoryTransaction t 
	INNER JOIN dbo.tblICInventoryTransactionType TransType
		ON t.intTransactionTypeId = TransType.intTransactionTypeId
	INNER JOIN tblICItem i
		ON i.intItemId = t.intItemId
	LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		ON currencyRateType.intCurrencyExchangeRateTypeId = t.intForexRateTypeId
	OUTER APPLY (
		SELECT 
			ISNULL(
				SUM(
					ROUND(
						(SV.dblCashPrice * 
							CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 
								THEN
									SV.dblSettleContractUnits												
								ELSE 									
									SV.dblUnits
							END)									 
					, 2) 
				) 
			,0)  AS  dblTotalDiscountCost
			--ISNULL(round(SUM(((SV.dblCashPrice * CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 THEN SV.dblSettleContractUnits ELSE SV.dblUnits END)) ), 2),0)  AS dblTotalDiscountCost
		FROM tblGRSettleVoucherCreateReferenceTable SV		
		WHERE intItemType = 3 and SV.strBatchId = @strBatchId and SV.ysnItemInventoryCost = 1--DISCOUNTS
			and SV.ysnDiscountFromGrossWeight = 0
	) DiscountCost

	OUTER APPLY (
		SELECT 
			ISNULL(
				SUM(
					ROUND(
						(SV.dblCashPrice * 
							CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 
								THEN
									((SV.dblSettleContractUnits / @dblSelectedUnits) * @dblGrossUnits ) 
								ELSE
									((SV.dblUnits  / @dblSelectedUnits) * @dblGrossUnits) 
									
							END)									 
					, 2) 
				) 
			,0)  AS  dblTotalDiscountCost
			--ISNULL(round(SUM(((SV.dblCashPrice * CASE WHEN ISNULL(SV.dblSettleContractUnits,0) > 0 THEN SV.dblSettleContractUnits ELSE SV.dblUnits END)) ), 2),0)  AS dblTotalDiscountCost
		FROM tblGRSettleVoucherCreateReferenceTable SV		
		WHERE intItemType = 3 and SV.strBatchId = @strBatchId and SV.ysnItemInventoryCost = 1--DISCOUNTS
			and SV.ysnDiscountFromGrossWeight = 1
	) DiscountCostGross


	WHERE t.strBatchId = @strBatchId
		AND t.intItemId = ISNULL(@intRebuildItemId, t.intItemId) 
		AND ISNULL(i.intCategoryId, 0) = COALESCE(@intRebuildCategoryId, i.intCategoryId, 0) 
		AND t.intInTransitSourceLocationId IS NULL -- If there is a value in intInTransitSourceLocationId, then it is for In-Transit costing. Use uspICCreateGLEntriesForInTransitCosting instead of this sp.
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
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblItemCost) 
	,strCode					= 'STR' 
	,strReference				= @EntityNo
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

UNION ALL 
SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= tblGLAccount.intAccountId
	,dblDebit					= Credit.Value
	,dblCredit					= Debit.Value
	,dblDebitUnit				= CreditUnit.Value
	,dblCreditUnit				= DebitUnit.Value
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblItemCost) 
	,strCode					= 'STR' 
	,strReference				= @EntityNo 
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
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblItemCost) 
	,strCode					= 'IAV'
	,strReference				= @EntityNo
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

UNION ALL 
SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= tblGLAccount.intAccountId
	,dblDebit					= Credit.Value
	,dblCredit					= Debit.Value
	,dblDebitUnit				= CreditUnit.Value 
	,dblCreditUnit				= DebitUnit.Value 
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblItemCost) 
	,strCode					= 'IAV' 
	,strReference				= @EntityNo 
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
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblItemCost) 
	,strCode					= 'IAN' 
	,strReference				= @EntityNo 
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

UNION ALL 
SELECT	
	dtmDate						= ForGLEntries_CTE.dtmDate
	,strBatchId					= @strBatchId
	,intAccountId				= tblGLAccount.intAccountId
	,dblDebit					= Credit.Value
	,dblCredit					= Debit.Value
	,dblDebitUnit				= CreditUnit.Value 
	,dblCreditUnit				= DebitUnit.Value 
	,strDescription				= ISNULL(@strGLDescription, ISNULL(tblGLAccount.strDescription, '')) + ' ' + dbo.[fnICDescribeSoldStock](strItemNo, dblQty, dblItemCost) 
	,strCode					= 'IAN' 
	,strReference				= @EntityNo
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
;



	if @debug_awesome_ness = 1	
	begin
		
		select 'awesomeness ends [uspGRCreateItemGLEntries]'
		--set @dblCashPriceFromCt = 9.55
	end
