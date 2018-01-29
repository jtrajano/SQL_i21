CREATE PROCEDURE [dbo].[uspICPostInventoryShipmentTaxes]
	@intInventoryShipmentId AS INT 
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@intTransactionTypeId AS INT 
	,@ysnPost AS BIT = 1
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
	SELECT	Query.intChargeId
			,Query.intItemLocationId
			,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @AccountCategory_APClearing) 
			,@intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						ShipmentCharge.intChargeId
						,ItemLocation.intItemLocationId
				FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge ShipmentCharge
							ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
						INNER JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = ShipmentCharge.intChargeId
							AND ItemLocation.intLocationId = Shipment.intShipFromLocationId
				WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId
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
			ShipmentCharge.intChargeId
			,ItemLocation.intItemLocationId
			,NULL
			,TaxCode.intPurchaseTaxAccountId
			,@strBatchId
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge ShipmentCharge
				ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
			INNER JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intItemId = ShipmentCharge.intChargeId
				AND ItemLocation.intLocationId = Shipment.intShipFromLocationId							
			INNER JOIN dbo.tblICInventoryShipmentChargeTax ChargeTaxes
				ON ShipmentCharge.intInventoryShipmentChargeId = ChargeTaxes.intInventoryShipmentChargeId
			INNER JOIN dbo.tblSMTaxCode TaxCode
				ON TaxCode.intTaxCodeId = ChargeTaxes.intTaxCodeId
			LEFT JOIN dbo.tblICInventoryTransactionType TransType
				ON TransType.intTransactionTypeId = @intTransactionTypeId
	WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId
	;

END 


-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 
;

DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory'
		,@strTransactionForm  AS NVARCHAR(50) = 'Inventory Shipment'
		,@strCode AS NVARCHAR(10) = 'IC';

-- Generate the G/L Entries for the item taxes. 
BEGIN 
	WITH ForGLEntries_CTE (
		dtmDate
		,intItemId
		,intItemLocationId
		,intTransactionId		
		,strTransactionId
		,intShipmentItemTaxId
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
		SELECT	dtmDate								= Shipment.dtmShipDate
				,intItemId							= ShipmentCharge.intChargeId 
				,intItemLocationId					= ItemLocation.intItemLocationId
				,intTransactionId					= Shipment.intInventoryShipmentId				
				,strTransactionId					= Shipment.strShipmentNumber
				,intShipmentChargeTaxId				= ChargeTaxes.intInventoryShipmentChargeTaxId
				,dblTax								= CASE WHEN ShipmentCharge.ysnPrice = 1 THEN -ChargeTaxes.dblTax ELSE ChargeTaxes.dblTax END
				,intTransactionTypeId				= TransType.intTransactionTypeId
				,intCurrencyId						= ShipmentCharge.intCurrencyId
				,dblExchangeRate					= ISNULL(ShipmentCharge.dblForexRate, 0)
				,strInventoryTransactionTypeName	= TransType.strName
				,strTransactionForm					= @strTransactionForm
				,intPurchaseTaxAccountId			= TaxCode.intPurchaseTaxAccountId
				,dblForexRate						= ISNULL(ShipmentCharge.dblForexRate, 0)
				,strRateType						= currencyRateType.strCurrencyExchangeRateType
				,strItemNo							= item.strItemNo
		FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge ShipmentCharge
					ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ShipmentCharge.intChargeId
					AND ItemLocation.intLocationId = Shipment.intShipFromLocationId		
				INNER JOIN tblICItem item
					ON item.intItemId = ShipmentCharge.intChargeId 				
				INNER JOIN dbo.tblICInventoryShipmentChargeTax ChargeTaxes
					ON ShipmentCharge.intInventoryShipmentChargeId = ChargeTaxes.intInventoryShipmentChargeId
				INNER JOIN dbo.tblSMTaxCode TaxCode
					ON TaxCode.intTaxCodeId = ChargeTaxes.intTaxCodeId
				LEFT JOIN dbo.tblICInventoryTransactionType TransType
					ON TransType.intTransactionTypeId = @intTransactionTypeId
				LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
					ON currencyRateType.intCurrencyExchangeRateTypeId = ShipmentCharge.intForexRateTypeId
		WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId	
				AND (ShipmentCharge.ysnAccrue = 1 OR ShipmentCharge.ysnPrice = 1) -- Note: Tax is only computed if ysnAccrue is Y or ysnPrice is Y. 
		
		-- Price Down - Other Charge taxes. This tax is for the 3rd party vendor. 
		UNION ALL 
		SELECT	dtmDate								= Shipment.dtmShipDate
				,intItemId							= ShipmentCharge.intChargeId 
				,intItemLocationId					= ItemLocation.intItemLocationId
				,intTransactionId					= Shipment.intInventoryShipmentId				
				,strTransactionId					= Shipment.strShipmentNumber
				,intShipmentChargeTaxId				= ChargeTaxes.intInventoryShipmentChargeTaxId
				,dblTax								= ChargeTaxes.dblTax 
				,intTransactionTypeId				= TransType.intTransactionTypeId
				,intCurrencyId						= ShipmentCharge.intCurrencyId
				,dblExchangeRate					= ISNULL(ShipmentCharge.dblForexRate, 0)
				,strInventoryTransactionTypeName	= TransType.strName
				,strTransactionForm					= @strTransactionForm
				,intPurchaseTaxAccountId			= TaxCode.intPurchaseTaxAccountId
				,dblForexRate						= ISNULL(ShipmentCharge.dblForexRate, 0)
				,strRateType						= currencyRateType.strCurrencyExchangeRateType
				,strItemNo							= item.strItemNo
		FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge ShipmentCharge
					ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ShipmentCharge.intChargeId
					AND ItemLocation.intLocationId = Shipment.intShipFromLocationId		
				INNER JOIN tblICItem item
					ON item.intItemId = ShipmentCharge.intChargeId 				
				INNER JOIN dbo.tblICInventoryShipmentChargeTax ChargeTaxes
					ON ShipmentCharge.intInventoryShipmentChargeId = ChargeTaxes.intInventoryShipmentChargeId
				INNER JOIN dbo.tblSMTaxCode TaxCode
					ON TaxCode.intTaxCodeId = ChargeTaxes.intTaxCodeId
				LEFT JOIN dbo.tblICInventoryTransactionType TransType
					ON TransType.intTransactionTypeId = @intTransactionTypeId
				LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
					ON currencyRateType.intCurrencyExchangeRateTypeId = ShipmentCharge.intForexRateTypeId
		WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId
				AND ShipmentCharge.ysnAccrue = 1 
				AND ShipmentCharge.ysnPrice = 1 
	)
	
	-------------------------------------------------------------------------------------------
	-- Dr...... Purchase Tax Id 
	-- Cr..................... A/P Clearing 
	-------------------------------------------------------------------------------------------
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= CASE WHEN @ysnPost = 1 THEN Debit.Value ELSE Credit.Value END 
			,dblCredit					= CASE WHEN @ysnPost = 1 THEN Credit.Value ELSE Debit.Value END 
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
			,intJournalLineNo			= ForGLEntries_CTE.intShipmentItemTaxId
			,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END 
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN 
												CASE WHEN @ysnPost = 1 THEN DebitForeign.Value ELSE CreditForeign.Value END 
											ELSE 0 
										END 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN 
												CASE WHEN @ysnPost = 1 THEN CreditForeign.Value ELSE DebitForeign.Value END 
											ELSE 0 
										END 
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
			,dblDebit					= CASE WHEN @ysnPost = 1 THEN Credit.Value ELSE Debit.Value END 
			,dblCredit					= CASE WHEN @ysnPost = 1 THEN Debit.Value ELSE Credit.Value END 
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
			,intJournalLineNo			= ForGLEntries_CTE.intShipmentItemTaxId
			,ysnIsUnposted				= CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END 
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN 
												CASE WHEN @ysnPost = 1 THEN CreditForeign.Value ELSE DebitForeign.Value END 
											ELSE 0 
										END
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE 
											WHEN intCurrencyId <> @intFunctionalCurrencyId THEN 
												CASE WHEN @ysnPost = 1 THEN DebitForeign.Value ELSE CreditForeign.Value END 
											ELSE 0 
										END
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