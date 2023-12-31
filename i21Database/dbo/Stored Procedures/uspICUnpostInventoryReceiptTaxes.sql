﻿CREATE PROCEDURE [dbo].[uspICUnpostInventoryReceiptTaxes]
	@intInventoryReceiptId AS INT 
	,@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
	,@intTransactionTypeId AS INT 
AS

-- Get the A/P Clearing account 
BEGIN 
	DECLARE @AccountCategory_APClearing AS NVARCHAR(30) = 'AP Clearing';
	DECLARE @GLAccounts AS dbo.ItemGLAccount;

	INSERT INTO @GLAccounts (
		intItemId 
		,intItemLocationId 
		,intContraInventoryId
		,intTransactionTypeId 
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @AccountCategory_APClearing) 
			,@intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						ReceiptItem.intItemId
						,ItemLocation.intItemLocationId
				FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
							ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = ReceiptItem.intItemId
							AND ItemLocation.intLocationId = Receipt.intLocationId
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
			,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @AccountCategory_APClearing) 
			,@intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						ReceiptCharge.intChargeId
						,ItemLocation.intItemLocationId
				FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharge
							ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = ReceiptCharge.intChargeId
							AND ItemLocation.intLocationId = Receipt.intLocationId
				WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
			) Query
END

-- Log the g/l account used in this batch. 
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
	;

END 

---- Get Total Value of Other Charges Taxes
--BEGIN
--	DECLARE @OtherChargeTaxes AS NUMERIC(18, 6);

--	SELECT @OtherChargeTaxes = SUM(CASE 
--										WHEN ReceiptCharge.ysnPrice = 1
--											THEN ISNULL(ReceiptCharge.dblTax,0) * -1
--										ELSE ISNULL(ReceiptCharge.dblTax,0) 
--									END )
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
				,dblExchangeRate					= ISNULL(ReceiptItem.dblForexRate, 0)
				,strInventoryTransactionTypeName	= TransType.strName
				,strTransactionForm					= @strTransactionForm
				,intPurchaseTaxAccountId			= TaxCode.intPurchaseTaxAccountId
				,dblForexRate						= ISNULL(ReceiptItem.dblForexRate, 0)
				,strRateType						= currencyRateType.strCurrencyExchangeRateType
				,strItemNo							= item.strItemNo
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
		
		-- Charge taxes
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
				,dblExchangeRate					= ISNULL(ReceiptCharge.dblForexRate, 0)
				,strInventoryTransactionTypeName	= TransType.strName
				,strTransactionForm					= @strTransactionForm
				,intPurchaseTaxAccountId			= TaxCode.intPurchaseTaxAccountId
				,dblForexRate						= ISNULL(ReceiptCharge.dblForexRate, 0)
				,strRateType						= currencyRateType.strCurrencyExchangeRateType
				,strItemNo							= item.strItemNo
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
				--AND ReceiptCharge.ysnAccrue = 1 -- Note: Tax is only available if there is a vendor entity (receipt vendor or 3rd party vendor). 
		
		---- Price Down Other Charge taxes
		--UNION ALL 
		--SELECT	dtmDate								= Receipt.dtmReceiptDate
		--		,intItemId							= ReceiptCharge.intChargeId 
		--		,intItemLocationId					= ItemLocation.intItemLocationId
		--		,intTransactionId					= Receipt.intInventoryReceiptId				
		--		,strTransactionId					= Receipt.strReceiptNumber
		--		,intReceiptChargeTaxId				= ChargeTaxes.intInventoryReceiptChargeTaxId
		--		,dblTax								= 
		--											-- Negate the tax if it is an Inventory Return 
		--											CASE WHEN Receipt.strReceiptType = 'Inventory Return' THEN
		--													-(-ChargeTaxes.dblTax)
		--												ELSE
		--													-ChargeTaxes.dblTax 
		--											END 
		--		,intTransactionTypeId				= TransType.intTransactionTypeId
		--		,intCurrencyId						= ReceiptCharge.intCurrencyId
		--		,dblExchangeRate					= ISNULL(ReceiptCharge.dblForexRate, 0)
		--		,strInventoryTransactionTypeName	= TransType.strName
		--		,strTransactionForm					= @strTransactionForm
		--		,intPurchaseTaxAccountId			= TaxCode.intPurchaseTaxAccountId
		--		,dblForexRate						= ISNULL(ReceiptCharge.dblForexRate, 0)
		--		,strRateType						= currencyRateType.strCurrencyExchangeRateType
		--		,strItemNo							= item.strItemNo
		--FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharge
		--			ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
		--		INNER JOIN dbo.tblICItemLocation ItemLocation
		--			ON ItemLocation.intItemId = ReceiptCharge.intChargeId
		--			AND ItemLocation.intLocationId = Receipt.intLocationId		
		--		INNER JOIN tblICItem item
		--			ON item.intItemId = ReceiptCharge.intChargeId 				
		--		INNER JOIN dbo.tblICInventoryReceiptChargeTax ChargeTaxes
		--			ON ReceiptCharge.intInventoryReceiptChargeId = ChargeTaxes.intInventoryReceiptChargeId
		--		INNER JOIN dbo.tblSMTaxCode TaxCode
		--			ON TaxCode.intTaxCodeId = ChargeTaxes.intTaxCodeId
		--		LEFT JOIN dbo.tblICInventoryTransactionType TransType
		--			ON TransType.intTransactionTypeId = @intTransactionTypeId
		--		LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
		--			ON currencyRateType.intCurrencyExchangeRateTypeId = ReceiptCharge.intForexRateTypeId
		--WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
		--		AND ReceiptCharge.ysnAccrue = 1 -- Note: Tax is only available if there is a vendor entity (receipt vendor or 3rd party vendor). 
		--		AND ReceiptCharge.ysnPrice = 1 						
	)
	
	-------------------------------------------------------------------------------------------
	-- Dr...... Purchase Tax Id 
	-- Cr..................... A/P Clearing 
	-------------------------------------------------------------------------------------------
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
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
			,intUserId					= NULL 
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
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
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
			,intUserId					= NULL 
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