CREATE PROCEDURE [dbo].[uspICPostInventoryReceiptTaxes]
	@intInventoryReceiptId AS INT 
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@intTransactionTypeId AS INT 
AS

-- Get the A/P Clearing account 
BEGIN 
	DECLARE @AccountCategory_APClearing AS NVARCHAR(30) = 'AP Clearing';
	DECLARE @AccountCategory_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense';
	DECLARE @GLAccounts AS dbo.ItemGLAccount;

	DECLARE 
		@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

	-- Get Vendor Tax Exemptions
	DECLARE @TaxExemptions TABLE(strTaxCode NVARCHAR(200), ysnAddToCost BIT, 
		intPurchaseTaxExemptionAccountId INT, intPurchaseAccountId INT,
		intItemId INT, intReceiptId INT, intReceiptItemId INT)
	INSERT INTO @TaxExemptions
	SELECT tc.strTaxCode, tc.ysnAddToCost,
		tc.intPurchaseTaxExemptionAccountId, tc.intPurchaseTaxAccountId,
		i.intItemId, r.intInventoryReceiptId, ri.intInventoryReceiptItemId
	FROM tblICInventoryReceipt r
	INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
	INNER JOIN tblICItem i ON i.intItemId = ri.intItemId
	INNER JOIN tblSMTaxGroupCode tgc ON tgc.intTaxGroupId = ri.intTaxGroupId
	INNER JOIN tblSMTaxCode tc ON tc.intTaxCodeId = tgc.intTaxCodeId
	CROSS APPLY (
		SELECT *
		FROM dbo.fnGetVendorTaxCodeExemption(
			r.intEntityVendorId, 
			r.dtmReceiptDate, 
			tgc.intTaxGroupId, 
			tc.intTaxCodeId,
			tc.intTaxClassId,
			tc.strState,
			i.intItemId,
			i.intCategoryId,
			r.intShipFromId)
	) ex
	WHERE r.intInventoryReceiptId = @intInventoryReceiptId
		AND ex.ysnTaxExempt = 1
		AND tc.intPurchaseTaxExemptionAccountId IS NOT NULL

	INSERT INTO @GLAccounts (
		intItemId 
		,intItemLocationId 
		,intContraInventoryId
		,intTransactionTypeId 
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intContraInventoryId = 
			CASE WHEN Query.intPurchaseTaxExemptionAccountId IS NOT NULL THEN Query.intPurchaseTaxExemptionAccountId
			ELSE dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_APClearing) END
			,@intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						ReceiptItem.intItemId
						,ItemLocation.intItemLocationId
						,ex.intPurchaseTaxExemptionAccountId
						,ex.intPurchaseAccountId
						,ex.ysnAddToCost
				FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
							ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = ReceiptItem.intItemId
							AND ItemLocation.intLocationId = Receipt.intLocationId
						OUTER APPLY (
							SELECT TOP 1 * 
							FROM @TaxExemptions e
							WHERE Receipt.intInventoryReceiptId = e.intReceiptId
								AND ReceiptItem.intInventoryReceiptItemId = e.intReceiptItemId
								AND ReceiptItem.intItemId = e.intItemId
						) ex
				WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
			) Query

	INSERT INTO @GLAccounts (
		intItemId 
		,intItemLocationId 
		,intContraInventoryId
		,intTransactionTypeId 
	)
	SELECT	Query.intChargeId
			,Query.intItemLocationId
			,intContraInventoryId = 
			CASE WHEN Query.intPurchaseTaxExemptionAccountId IS NOT NULL THEN Query.intPurchaseTaxExemptionAccountId
			ELSE dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @AccountCategory_APClearing) END
			,@intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						ReceiptCharge.intChargeId
						,ItemLocation.intItemLocationId
						,ex.intPurchaseTaxExemptionAccountId
						,ex.intPurchaseAccountId
						,ex.ysnAddToCost
				FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharge
							ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = ReceiptCharge.intChargeId
							AND ItemLocation.intLocationId = Receipt.intLocationId
				OUTER APPLY (
					SELECT TOP 1 * 
					FROM @TaxExemptions e
					WHERE Receipt.intInventoryReceiptId = e.intReceiptId
						AND ReceiptCharge.intChargeId = e.intItemId
				) ex
				WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
			) Query
END

BEGIN 
	INSERT INTO dbo.tblICInventoryGLAccountUsedOnPostLog (
			intItemId
			,intItemLocationId
			,intContraInventoryId
			,intPurchaseTaxCodeId
			,strBatchId
	)
	SELECT	DISTINCT 
			intItemId
			,intItemLocationId
			,intContraInventoryId
			,NULL 
			,@strBatchId
	FROM	@GLAccounts
	UNION ALL 
	SELECT	DISTINCT 
			ReceiptItem.intItemId
			,ItemLocation.intItemLocationId
			,NULL
			,TaxCode.intPurchaseTaxAccountId
			,@strBatchId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = ReceiptItem.intItemId
				AND ItemLocation.intLocationId = Receipt.intLocationId							
			INNER JOIN dbo.tblICInventoryReceiptItemTax ReceiptTaxes
				ON ReceiptItem.intInventoryReceiptItemId = ReceiptTaxes.intInventoryReceiptItemId
			INNER JOIN dbo.tblSMTaxCode TaxCode
				ON TaxCode.intTaxCodeId = ReceiptTaxes.intTaxCodeId
			LEFT JOIN dbo.tblICInventoryTransactionType TransType
				ON TransType.intTransactionTypeId = @intTransactionTypeId
	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
	UNION ALL 
	SELECT	DISTINCT 
			ChargeItem.intChargeId
			,ItemLocation.intItemLocationId
			,NULL
			,CASE 
				WHEN TaxCode.ysnExpenseAccountOverride = 1 THEN 
					dbo.fnGetItemGLAccount(ChargeItem.intChargeId, ItemLocation.intItemLocationId, @AccountCategory_OtherChargeExpense) 
				ELSE 
					TaxCode.intPurchaseTaxAccountId 
			END
			,@strBatchId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge ChargeItem
				ON Receipt.intInventoryReceiptId = ChargeItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = ChargeItem.intChargeId
				AND ItemLocation.intLocationId = Receipt.intLocationId							
			INNER JOIN dbo.tblICInventoryReceiptChargeTax ChargeTaxes
				ON ChargeItem.intInventoryReceiptChargeId = ChargeTaxes.intInventoryReceiptChargeId
			INNER JOIN dbo.tblSMTaxCode TaxCode
				ON TaxCode.intTaxCodeId = ChargeTaxes.intTaxCodeId
			LEFT JOIN dbo.tblICInventoryTransactionType TransType
				ON TransType.intTransactionTypeId = @intTransactionTypeId
	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId

	;

END 


--- Validate Override Expense Account
DECLARE @OverrideAccountId INT
DECLARE @OverrideTaxCodeId INT
SELECT @OverrideAccountId = dbo.fnGetItemGLAccount(ReceiptItem.intItemId, ItemLocation.intItemLocationId, @AccountCategory_OtherChargeExpense), 
	@OverrideTaxCodeId = TaxCode.intTaxCodeId
FROM dbo.tblICInventoryReceipt Receipt 
INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
INNER JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intItemId = ReceiptItem.intItemId
	AND ItemLocation.intLocationId = Receipt.intLocationId		
INNER JOIN tblICItem item ON item.intItemId = ReceiptItem.intItemId 
INNER JOIN dbo.tblICInventoryReceiptItemTax ReceiptTaxes ON ReceiptItem.intInventoryReceiptItemId = ReceiptTaxes.intInventoryReceiptItemId
INNER JOIN dbo.tblSMTaxCode TaxCode ON TaxCode.intTaxCodeId = ReceiptTaxes.intTaxCodeId
LEFT JOIN dbo.tblICInventoryTransactionType TransType ON TransType.intTransactionTypeId = @intTransactionTypeId
LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType ON currencyRateType.intCurrencyExchangeRateTypeId = ReceiptItem.intForexRateTypeId
WHERE Receipt.intInventoryReceiptId = @intInventoryReceiptId
	AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
	AND TaxCode.ysnExpenseAccountOverride = 1
				
IF (@OverrideAccountId IS NULL AND @OverrideTaxCodeId IS NOT NULL)
BEGIN
	-- Validate the GL Accounts
DECLARE @strItemNo AS NVARCHAR(50)
DECLARE @intItemId AS INT 
DECLARE @strLocationName AS NVARCHAR(50)

-- Check for missing Inventory Account Id
BEGIN 
	SELECT	TOP 1 
			@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	tblICItem Item INNER JOIN @GLAccounts ItemGLAccount
				ON Item.intItemId = ItemGLAccount.intItemId
	WHERE	ItemGLAccount.intInventoryId IS NULL 

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @GLAccounts ItemGLAccount
				ON ItemGLAccount.intItemId = il.intItemId
				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId
			AND ItemGLAccount.intInventoryId IS NULL 

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @AccountCategory_OtherChargeExpense;
		RETURN -1;
	END 
END 
;
END
		


---- Get Total Value of Other Charges Taxes
--BEGIN
--	DECLARE @OtherChargeTaxes AS NUMERIC(18, 6);

--	SELECT @OtherChargeTaxes = SUM(ISNULL(ReceiptCharge.dblTax,0))
--	FROM dbo.tblICInventoryReceiptCharge ReceiptCharge
--	WHERE ReceiptCharge.intInventoryReceiptId =  @intInventoryReceiptId
--END

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 
;


DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory'
		,@strTransactionForm  AS NVARCHAR(50) = 'Inventory Receipt'
		,@strCode AS NVARCHAR(10) = 'IC';

-- Generate the G/L Entries for the item taxes. 
BEGIN 
	WITH ForGLEntries_CTE (
		dtmDate
		,intItemId
		,intItemLocationId
		,intTransactionId		
		,strTransactionId
		,intReceiptItemTaxId
		,dblTax
		,intTransactionTypeId
		,intCurrencyId
		,dblExchangeRate
		,strInventoryTransactionTypeName
		,strTransactionForm
		,intPurchaseTaxAccountId
		,dblForexRate 
		,strRateType
		,strItemNo
		,intSourceEntityId
		,intCommodityId
	)
	AS 
	(
		-- Item Taxes
		SELECT	dtmDate								= Receipt.dtmReceiptDate
				,intItemId							= ReceiptItem.intItemId
				,intItemLocationId					= ItemLocation.intItemLocationId
				,intTransactionId					= Receipt.intInventoryReceiptId				
				,strTransactionId					= Receipt.strReceiptNumber
				,intReceiptItemTaxId				= ReceiptTaxes.intInventoryReceiptItemTaxId
				,dblTax								= 
													-- Negate the tax if it is an Inventory Return 
													CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN
															-(ReceiptTaxes.dblTax)
														ELSE
															ReceiptTaxes.dblTax 
													END 
				,intTransactionTypeId				= TransType.intTransactionTypeId
				,intCurrencyId						= Receipt.intCurrencyId
				,dblExchangeRate					= ISNULL(ReceiptItem.dblForexRate, 1)
				,strInventoryTransactionTypeName	= TransType.strName
				,strTransactionForm					= @strTransactionForm
				,intPurchaseTaxAccountId			= CASE WHEN TaxCode.ysnAddToCost = 1 THEN dbo.fnGetItemGLAccount(item.intItemId, ItemLocation.intItemLocationId, 'Inventory') ELSE TaxCode.intPurchaseTaxAccountId END
				,dblForexRate						= ISNULL(ReceiptItem.dblForexRate, 1)
				,strRateType						= currencyRateType.strCurrencyExchangeRateType
				,strItemNo							= item.strItemNo
				,intSourceEntityId					= Receipt.intEntityVendorId 
				,intCommodityId						= item.intCommodityId
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ReceiptItem.intItemId
					AND ItemLocation.intLocationId = Receipt.intLocationId		
				INNER JOIN tblICItem item
					ON item.intItemId = ReceiptItem.intItemId 
				INNER JOIN dbo.tblICInventoryReceiptItemTax ReceiptTaxes
					ON ReceiptItem.intInventoryReceiptItemId = ReceiptTaxes.intInventoryReceiptItemId
				INNER JOIN dbo.tblSMTaxCode TaxCode
					ON TaxCode.intTaxCodeId = ReceiptTaxes.intTaxCodeId
				LEFT JOIN dbo.tblICInventoryTransactionType TransType
					ON TransType.intTransactionTypeId = @intTransactionTypeId
				LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
					ON currencyRateType.intCurrencyExchangeRateTypeId = ReceiptItem.intForexRateTypeId
		WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
				AND ISNULL(ReceiptItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
				
		
		-- Other Charge taxes for the Receipt Vendor. 
		UNION ALL 
		SELECT	dtmDate								= Receipt.dtmReceiptDate
				,intItemId							= ReceiptCharge.intChargeId 
				,intItemLocationId					= ItemLocation.intItemLocationId
				,intTransactionId					= Receipt.intInventoryReceiptId				
				,strTransactionId					= Receipt.strReceiptNumber
				,intReceiptChargeTaxId				= ChargeTaxes.intInventoryReceiptChargeTaxId
				,dblTax								= 
													-- Negate the tax if it is an Inventory Return 
													CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN
															-(CASE WHEN ReceiptCharge.ysnPrice = 1 THEN -ChargeTaxes.dblTax ELSE ChargeTaxes.dblTax END )
														ELSE
															-- Negate the tax if Charge is ysnPrice = 1 (Price Down)
															CASE WHEN ReceiptCharge.ysnPrice = 1 THEN -ChargeTaxes.dblTax ELSE ChargeTaxes.dblTax END 															
													END 
				,intTransactionTypeId				= TransType.intTransactionTypeId
				,intCurrencyId						= ReceiptCharge.intCurrencyId
				,dblExchangeRate					= ISNULL(ReceiptCharge.dblForexRate, 1)
				,strInventoryTransactionTypeName	= TransType.strName
				,strTransactionForm					= @strTransactionForm
				,intPurchaseTaxAccountId			= 
														CASE 
															WHEN TaxCode.ysnExpenseAccountOverride = 1 THEN 
																dbo.fnGetItemGLAccount(
																	ReceiptCharge.intChargeId
																	, ItemLocation.intItemLocationId
																	, @AccountCategory_OtherChargeExpense
																) 
															ELSE 
																TaxCode.intPurchaseTaxAccountId 
														END
				,dblForexRate						= ISNULL(ReceiptCharge.dblForexRate, 1)
				,strRateType						= currencyRateType.strCurrencyExchangeRateType
				,strItemNo							= item.strItemNo
				,intSourceEntityId					= Receipt.intEntityVendorId
				,intCommodityId						= item.intCommodityId
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharge
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ReceiptCharge.intChargeId
					AND ItemLocation.intLocationId = Receipt.intLocationId		
				INNER JOIN tblICItem item
					ON item.intItemId = ReceiptCharge.intChargeId 				
				INNER JOIN dbo.tblICInventoryReceiptChargeTax ChargeTaxes
					ON ReceiptCharge.intInventoryReceiptChargeId = ChargeTaxes.intInventoryReceiptChargeId
				INNER JOIN dbo.tblSMTaxCode TaxCode
					ON TaxCode.intTaxCodeId = ChargeTaxes.intTaxCodeId
				LEFT JOIN dbo.tblICInventoryTransactionType TransType
					ON TransType.intTransactionTypeId = @intTransactionTypeId
				LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
					ON currencyRateType.intCurrencyExchangeRateTypeId = ReceiptCharge.intForexRateTypeId
		WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId	
				AND (ReceiptCharge.ysnAccrue = 1 OR ReceiptCharge.ysnPrice = 1) -- Note: Tax is only computed if ysnAccrue is Y or ysnPrice is Y. 
		
		-- Price Down - Other Charge taxes. This tax is for the 3rd party vendor. 
		UNION ALL 
		SELECT	dtmDate								= Receipt.dtmReceiptDate
				,intItemId							= ReceiptCharge.intChargeId 
				,intItemLocationId					= ItemLocation.intItemLocationId
				,intTransactionId					= Receipt.intInventoryReceiptId				
				,strTransactionId					= Receipt.strReceiptNumber
				,intReceiptChargeTaxId				= ChargeTaxes.intInventoryReceiptChargeTaxId
				,dblTax								= 
													-- Negate the tax if it is an Inventory Return 
													CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN
															-ChargeTaxes.dblTax
														ELSE
															ChargeTaxes.dblTax 
													END 
				,intTransactionTypeId				= TransType.intTransactionTypeId
				,intCurrencyId						= ReceiptCharge.intCurrencyId
				,dblExchangeRate					= ISNULL(ReceiptCharge.dblForexRate, 1)
				,strInventoryTransactionTypeName	= TransType.strName
				,strTransactionForm					= @strTransactionForm
				,intPurchaseTaxAccountId			= 
														CASE 
															WHEN TaxCode.ysnExpenseAccountOverride = 1 THEN 
																dbo.fnGetItemGLAccount(
																	ReceiptCharge.intChargeId
																	, ItemLocation.intItemLocationId
																	, @AccountCategory_OtherChargeExpense
																) 
															ELSE 
																TaxCode.intPurchaseTaxAccountId 
														END
				,dblForexRate						= ISNULL(ReceiptCharge.dblForexRate, 1)
				,strRateType						= currencyRateType.strCurrencyExchangeRateType
				,strItemNo							= item.strItemNo
				,intSourceEntityId					= ReceiptCharge.intEntityVendorId
				,intCommodityId						= item.intCommodityId
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharge
					ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ReceiptCharge.intChargeId
					AND ItemLocation.intLocationId = Receipt.intLocationId		
				INNER JOIN tblICItem item
					ON item.intItemId = ReceiptCharge.intChargeId 				
				INNER JOIN dbo.tblICInventoryReceiptChargeTax ChargeTaxes
					ON ReceiptCharge.intInventoryReceiptChargeId = ChargeTaxes.intInventoryReceiptChargeId
				INNER JOIN dbo.tblSMTaxCode TaxCode
					ON TaxCode.intTaxCodeId = ChargeTaxes.intTaxCodeId
				LEFT JOIN dbo.tblICInventoryTransactionType TransType
					ON TransType.intTransactionTypeId = @intTransactionTypeId
				LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
					ON currencyRateType.intCurrencyExchangeRateTypeId = ReceiptCharge.intForexRateTypeId
		WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
				AND ReceiptCharge.ysnAccrue = 1 
				AND ReceiptCharge.ysnPrice = 1 
	)
	
	-------------------------------------------------------------------------------------------
	-- Dr...... Purchase Tax Id 
	-- Cr..................... A/P Clearing 
	-------------------------------------------------------------------------------------------
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription + ', ' +  ISNULL(strItemNo, '') 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intReceiptItemTaxId
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
			,strRateType				= ForGLEntries_CTE.strRateType 
			,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
			,intCommodityId				= ForGLEntries_CTE.intCommodityId
	FROM	ForGLEntries_CTE LEFT JOIN dbo.tblGLAccount GLAccount 
				ON GLAccount.intAccountId = ForGLEntries_CTE.intPurchaseTaxAccountId
			CROSS APPLY dbo.fnGetDebitFunctional(
				ForGLEntries_CTE.dblTax
				,ForGLEntries_CTE.intCurrencyId
				,@intFunctionalCurrencyId
				,ForGLEntries_CTE.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				ForGLEntries_CTE.dblTax
				,ForGLEntries_CTE.intCurrencyId
				,@intFunctionalCurrencyId
				,ForGLEntries_CTE.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblTax) DebitForeign
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblTax) CreditForeign

	UNION ALL 
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription + ', ' + ISNULL(strItemNo, '') 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intReceiptItemTaxId
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= @intEntityUserSecurityId
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= ForGLEntries_CTE.dblForexRate 
			,strRateType				= ForGLEntries_CTE.strRateType 
			,intSourceEntityId			= ForGLEntries_CTE.intSourceEntityId
			,intCommodityId				= ForGLEntries_CTE.intCommodityId
	FROM	ForGLEntries_CTE INNER JOIN @GLAccounts InventoryAccounts
				ON ForGLEntries_CTE.intItemId = InventoryAccounts.intItemId
				AND ForGLEntries_CTE.intItemLocationId = InventoryAccounts.intItemLocationId
			LEFT JOIN dbo.tblGLAccount GLAccount 
				ON GLAccount.intAccountId = InventoryAccounts.intContraInventoryId
			CROSS APPLY dbo.fnGetDebitFunctional(
				ForGLEntries_CTE.dblTax
				,ForGLEntries_CTE.intCurrencyId
				,@intFunctionalCurrencyId
				,ForGLEntries_CTE.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				ForGLEntries_CTE.dblTax
				,ForGLEntries_CTE.intCurrencyId
				,@intFunctionalCurrencyId
				,ForGLEntries_CTE.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblTax) DebitForeign
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblTax) CreditForeign
	;
END

-- Exit point
_Exit: