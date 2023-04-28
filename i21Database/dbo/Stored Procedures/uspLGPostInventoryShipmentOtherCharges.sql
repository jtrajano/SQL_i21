CREATE PROCEDURE [dbo].[uspLGPostInventoryShipmentOtherCharges]
	@intLoadId AS INT
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@intTransactionTypeId AS INT
	,@ysnPost AS BIT = 1
AS
-- Constant Variables
BEGIN
	-- Variables used in the validations. 
	DECLARE @strItemNo AS NVARCHAR(50)
		,@intItemId AS INT
		,@strTransactionId AS NVARCHAR(50)
		,@strCurrencyId AS NVARCHAR(50)
		,@strFunctionalCurrencyId AS NVARCHAR(50)
		,@strLocationName AS NVARCHAR(50)
		,@intPurchaseSale AS INT
		,@DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
		,@intInvoiceCurrency AS INT
END

SELECT @intPurchaseSale = intPurchaseSale FROM tblLGLoad WHERE intLoadId = @intLoadId

-- Get the invoice currency
SELECT @intInvoiceCurrency =
	CASE WHEN AD.ysnValidFX = 1
		THEN CD.intInvoiceCurrencyId
		ELSE ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)
	END
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = CD.intCurrencyId
WHERE L.intLoadId = @intLoadId

-- Get the functional currency
BEGIN
	DECLARE @intFunctionalCurrencyId AS INT

	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
END

--Check if Cancelled
BEGIN
	DECLARE @ysnCancel AS BIT
	SELECT @ysnCancel = ISNULL(ysnCancelled, 0) FROM tblLGLoad WHERE intLoadId = @intLoadId
END

-- Validate 
BEGIN
	-- Check for invalid location for the Other Charge item. 
	SELECT TOP 1 @strItemNo = CASE 
			WHEN ISNULL(Item.strItemNo, '') = ''
				THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')'
			ELSE Item.strItemNo
			END
		,@intItemId = Item.intItemId
	FROM dbo.tblLGLoad LOAD
	INNER JOIN dbo.tblLGLoadDetail LoadDetail ON LoadDetail.intLoadId = LOAD.intLoadId
	INNER JOIN dbo.tblLGLoadCost OtherCharge ON LOAD.intLoadId = OtherCharge.intLoadId AND OtherCharge.strEntityType = 'Vendor'
	INNER JOIN tblICItem Item ON Item.intItemId = OtherCharge.intItemId
	LEFT JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intLocationId = 
		CASE 
			WHEN @intPurchaseSale IN (2,3) THEN LoadDetail.intSCompanyLocationId
			WHEN @intPurchaseSale = 1 THEN LoadDetail.intPCompanyLocationId
		END
		AND ItemLocation.intItemId = Item.intItemId
	WHERE ItemLocation.intItemLocationId IS NULL
		AND LOAD.intLoadId = @intLoadId

	IF @intItemId IS NOT NULL
	BEGIN
		-- 'Item Location is invalid or missing for {Item}.'
		EXEC uspICRaiseError 80002
			,@strItemNo;

		GOTO _Exit
	END
END

BEGIN
	-- Third Party is Required to Accrue ('Accrue-Y, Vendor-Null' combination should not be allowed)
	SELECT TOP 1 @strItemNo = CASE 
			WHEN ISNULL(Item.strItemNo, '') = ''
				THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')'
			ELSE Item.strItemNo
			END
		,@intItemId = Item.intItemId
	FROM dbo.tblLGLoad LOAD
	INNER JOIN dbo.tblLGLoadDetail LoadDetail ON LoadDetail.intLoadId = LOAD.intLoadId
	INNER JOIN dbo.tblLGLoadCost OtherCharge ON LOAD.intLoadId = OtherCharge.intLoadId AND OtherCharge.strEntityType = 'Vendor'
	INNER JOIN tblICItem Item ON Item.intItemId = OtherCharge.intItemId
	WHERE OtherCharge.ysnAccrue = 1
		AND OtherCharge.intVendorId IS NULL
		AND LOAD.intLoadId = @intLoadId

	IF @intItemId IS NOT NULL
	BEGIN
		-- Vendor for {Other Charge Item} is required to accrue.
		EXEC uspICRaiseError 80088
			,@strItemNo

		GOTO _Exit
	END
END

-- Create the G/L Entries
BEGIN
	-- Create the variables used by fnGetItemGLAccount
	DECLARE @ACCOUNT_CATEGORY_InventoryInTransit AS NVARCHAR(30) = 'Inventory In-transit'
		,@ACCOUNT_CATEGORY_APClearing AS NVARCHAR(30) = 'AP Clearing'
		,@ACCOUNT_CATEGORY_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense'
		,@ACCOUNT_CATEGORY_OtherChargeIncome AS NVARCHAR(30) = 'Other Charge Income'
	-- Initialize the module name
	DECLARE @ModuleName AS NVARCHAR(50) = 'Logistics'
		,@strTransactionForm AS NVARCHAR(50) =  
			CASE WHEN @intPurchaseSale IN (2,3) THEN 'Outbound Shipment'
			WHEN @intPurchaseSale = 1 THEN 'Inbound Shipment' END
		,@strCode AS NVARCHAR(10) = 'LG'
	-- Get the GL Account ids to use for the other charges. 
	DECLARE @OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount;

	INSERT INTO @OtherChargesGLAccounts (
		intChargeId
		,intItemLocationId
		,intOtherChargeExpense
		,intOtherChargeIncome
		,intAPClearing
		,intTransactionTypeId
		)
	SELECT Query.intItemId
		,Query.intItemLocationId
		,intOtherChargeExpense = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeExpense)
		,intOtherChargeIncome = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeIncome)
		,intAPClearing = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_APClearing)
		,intTransactionTypeId = @intTransactionTypeId
	FROM (
		SELECT DISTINCT OtherCharges.intItemId
			,ItemLocation.intItemLocationId
		FROM dbo.tblLGLoad LOAD
		INNER JOIN tblLGLoadDetail LoadDetail ON LoadDetail.intLoadId = LOAD.intLoadId
		INNER JOIN dbo.tblLGLoadCost OtherCharges ON LOAD.intLoadId = OtherCharges.intLoadId AND OtherCharges.strEntityType = 'Vendor'
		LEFT JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intItemId = OtherCharges.intItemId
			AND ItemLocation.intLocationId = 		
			CASE 
				WHEN @intPurchaseSale IN (2,3) THEN LoadDetail.intSCompanyLocationId
				WHEN @intPurchaseSale = 1 THEN LoadDetail.intPCompanyLocationId
			END
		WHERE OtherCharges.intLoadId = @intLoadId
		) Query

	-- Check for missing AP Clearing Account Id
	BEGIN
		SET @strItemNo = NULL
		SET @intItemId = NULL

		SELECT TOP 1 @intItemId = Item.intItemId
			,@strItemNo = Item.strItemNo
		FROM dbo.tblICItem Item
		INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts ON Item.intItemId = ChargesGLAccounts.intChargeId
		WHERE ChargesGLAccounts.intAPClearing IS NULL

		SELECT TOP 1 @strLocationName = c.strLocationName
		FROM tblICItemLocation il
		INNER JOIN tblSMCompanyLocation c ON il.intLocationId = c.intCompanyLocationId
		INNER JOIN @OtherChargesGLAccounts ItemGLAccount ON ItemGLAccount.intChargeId = il.intItemId
			AND ItemGLAccount.intItemLocationId = il.intItemLocationId
		WHERE il.intItemId = @intItemId
			AND ItemGLAccount.intAPClearing IS NULL

		IF @intItemId IS NOT NULL
		BEGIN
			-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008
				,@strItemNo
				,@strLocationName
				,@ACCOUNT_CATEGORY_APClearing;

			RETURN;
		END
	END;

	-- Check for missing Other Charge Expense 
	BEGIN
		SET @strItemNo = NULL
		SET @intItemId = NULL

		SELECT TOP 1 @intItemId = Item.intItemId
			,@strItemNo = Item.strItemNo
		FROM dbo.tblICItem Item
		INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts ON Item.intItemId = ChargesGLAccounts.intChargeId
		WHERE ChargesGLAccounts.intOtherChargeExpense IS NULL

		SELECT TOP 1 @strLocationName = c.strLocationName
		FROM tblICItemLocation il
		INNER JOIN tblSMCompanyLocation c ON il.intLocationId = c.intCompanyLocationId
		INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts ON ChargesGLAccounts.intChargeId = il.intItemId
			AND ChargesGLAccounts.intItemLocationId = il.intItemLocationId
		WHERE il.intItemId = @intItemId
			AND ChargesGLAccounts.intOtherChargeExpense IS NULL

		IF @intItemId IS NOT NULL
		BEGIN
			-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008
				,@strItemNo
				,@strLocationName
				,@ACCOUNT_CATEGORY_OtherChargeExpense;

			RETURN;
		END
	END;

	-- Check for missing Other Charge Income 
	BEGIN
		SET @strItemNo = NULL
		SET @intItemId = NULL

		SELECT TOP 1 @intItemId = Item.intItemId
			,@strItemNo = Item.strItemNo
		FROM dbo.tblICItem Item
		INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts ON Item.intItemId = ChargesGLAccounts.intChargeId
		WHERE ChargesGLAccounts.intOtherChargeIncome IS NULL

		SELECT TOP 1 @strLocationName = c.strLocationName
		FROM tblICItemLocation il
		INNER JOIN tblSMCompanyLocation c ON il.intLocationId = c.intCompanyLocationId
		INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts ON ChargesGLAccounts.intChargeId = il.intItemId
			AND ChargesGLAccounts.intItemLocationId = il.intItemLocationId
		WHERE il.intItemId = @intItemId
			AND ChargesGLAccounts.intOtherChargeIncome IS NULL

		IF @intItemId IS NOT NULL
		BEGIN
			-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008
				,@strItemNo
				,@strLocationName
				,@ACCOUNT_CATEGORY_OtherChargeIncome;

			RETURN;
		END
	END;

	-- Log the g/l account used in this batch. 
	INSERT INTO dbo.tblICInventoryGLAccountUsedOnPostLog (
		intItemId
		,intItemLocationId
		,strBatchId
		,intOtherChargeExpense
		,intOtherChargeIncome
		,intOtherChargeAsset
		,intContraInventoryId
		)
	SELECT intChargeId
		,intItemLocationId
		,@strBatchId
		,intOtherChargeExpense
		,intOtherChargeIncome
		,intOtherChargeAsset
		,intAPClearing
	FROM @OtherChargesGLAccounts;

	DECLARE @ChargesGLEntries AS RecapTableType;

	-- Generate the G/L Entries here: 
	WITH ForGLEntries_CTE (
		dtmDate
		,intItemId
		,intChargeId
		,intItemLocationId
		,intChargeItemLocation
		,intTransactionId
		,strTransactionId
		,dblCost
		,intTransactionTypeId
		,intCurrencyId
		,intShipmentCurrencyId
		,dblExchangeRate
		,intShipmentItemId
		,strTransactionTypeName
		,strTransactionForm
		,ysnAccrue
		,ysnPrice
		,dblForexRate
		,strRateType
		,strItemNo
		,intEntityId
		,ysnInventoryCost
		,intShipmentExchangeRateTypeId
		)
	AS (
		SELECT dtmDate = GETDATE()
			,ShipmentItem.intItemId
			,intChargeId = ShipmentCharges.intItemId
			,ItemLocation.intItemLocationId
			,intChargeItemLocation = ChargeItemLocation.intItemLocationId
			,intTransactionId = Shipment.intLoadId
			,strTransactionId = Shipment.strLoadNumber
			,dblCost = ShipmentCharges.dblAmount * CASE WHEN (@ysnCancel = 1) THEN -1 ELSE 1 END
			,intTransactionTypeId = @intTransactionTypeId
			,intCurrencyId = ISNULL(ShipmentCharges.intCurrencyId, Shipment.intCurrencyId)
			,intShipmentCurrencyId = @intInvoiceCurrency
			,dblExchangeRate = ISNULL(1, 1)
			,ShipmentItem.intLoadDetailId
			,strTransactionTypeName = TransType.strName
			,strTransactionForm = 'Logistics'
			,ShipmentCharges.ysnAccrue
			,ShipmentCharges.ysnPrice
			,dblForexRate = CASE WHEN (ISNULL(ShipmentCharges.intCurrencyId, Shipment.intCurrencyId) = @DefaultCurrencyId) THEN 1 ELSE ISNULL(ShipmentCharges.dblFX,1) END
			,strRateType = CRT.strCurrencyExchangeRateType --1
			,Charge.strItemNo
			,intEntityId = 1
			,ShipmentCharges.ysnInventoryCost
			-- This is used for inventoried other charge that is converted to shipment currency
			,intShipmentExchangeRateTypeId = CASE --if contract FX tab is setup
									 WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN CD.intRateTypeId --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN NULL --foreign price to functional FX, use NULL
											WHEN (ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN NULL --foreign price to foreign FX, use master FX rate
											ELSE ShipmentItem.intForexRateTypeId END
									 ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)) 
											THEN NULL
											ELSE ShipmentItem.intForexRateTypeId END
									 END
		FROM dbo.tblLGLoad Shipment
		INNER JOIN dbo.tblLGLoadDetail ShipmentItem ON Shipment.intLoadId = ShipmentItem.intLoadId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = 
				CASE 
					WHEN @intPurchaseSale IN (2,3) THEN ShipmentItem.intSContractDetailId
					WHEN @intPurchaseSale = 1 THEN ShipmentItem.intPContractDetailId
				END
		JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
		LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = CD.intCurrencyId
		INNER JOIN dbo.tblLGLoadCost ShipmentCharges ON ShipmentCharges.intLoadId = Shipment.intLoadId AND ShipmentCharges.strEntityType = 'Vendor'
		INNER JOIN tblICItem Charge ON Charge.intItemId = ShipmentCharges.intItemId
		LEFT JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intItemId = ShipmentItem.intItemId
			AND ItemLocation.intLocationId = 
				CASE 
					WHEN @intPurchaseSale IN (2,3) THEN ShipmentItem.intSCompanyLocationId
					WHEN @intPurchaseSale = 1 THEN ShipmentItem.intPCompanyLocationId
				END
		LEFT JOIN dbo.tblICItemLocation ChargeItemLocation ON ChargeItemLocation.intItemId = ShipmentCharges.intItemId
			AND ChargeItemLocation.intLocationId = 
				CASE 
					WHEN @intPurchaseSale IN (2,3) THEN ShipmentItem.intSCompanyLocationId
					WHEN @intPurchaseSale = 1 THEN ShipmentItem.intPCompanyLocationId
				END
		LEFT JOIN dbo.tblICInventoryTransactionType TransType ON TransType.intTransactionTypeId = @intTransactionTypeId
		LEFT JOIN tblCTContractCost CC ON CC.intContractDetailId = CD.intContractDetailId AND CC.intItemId = ShipmentCharges.intItemId
		LEFT JOIN tblSMCurrencyExchangeRateType CRT ON CRT.intCurrencyExchangeRateTypeId = CC.intRateTypeId
		-- OUTER APPLY (SELECT TOP 1 dblForexRate = ISNULL(dblRate,0) FROM vyuGLExchangeRate
		-- 			OUTER APPLY(SELECT intDefaultCurrencyId FROM dbo.tblSMCompanyPreference) tsp
		-- 			WHERE intFromCurrencyId = ShipmentCharges.intCurrencyId AND intToCurrencyId = tsp.intDefaultCurrencyId
		-- 			ORDER BY dtmValidFromDate DESC) FX
		WHERE Shipment.intLoadId = @intLoadId
		)

	INSERT INTO @ChargesGLEntries (
		[dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[ysnIsUnposted]
		,[intUserId]
		,[intEntityId]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblDebitForeign]
		,[dblDebitReport]
		,[dblCreditForeign]
		,[dblCreditReport]
		,[dblReportingRate]
		,[dblForeignRate]
		,[strRateType]
		)
	-- Inventoried Other Charge Wash Over
	SELECT dtmDate = ForGLEntries_CTE.dtmDate
		,strBatchId = @strBatchId
		,intAccountId = GLAccount.intAccountId
		,dblDebit = ROUND(CreditForeign.Value * ForGLEntries_CTE.dblForexRate, 2) --Credit.Value
		,dblCredit = ROUND(DebitForeign.Value * ForGLEntries_CTE.dblForexRate, 2) --Debit.Value
		,dblDebitUnit = 0
		,dblCreditUnit = 0
		,strDescription = ISNULL(GLAccount.strDescription, '') + ' (' + ForGLEntries_CTE.strItemNo + ')'
		,strCode = @strCode
		,strReference = ''
		,intCurrencyId = ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate = ForGLEntries_CTE.dblForexRate
		,dtmDateEntered = GETDATE()
		,dtmTransactionDate = ForGLEntries_CTE.dtmDate
		,strJournalLineDescription = ''
		,intJournalLineNo = ForGLEntries_CTE.intShipmentItemId
		,ysnIsUnposted = 0
		,intUserId = @intEntityUserSecurityId
		,intEntityId = ForGLEntries_CTE.intEntityId
		,strTransactionId = ForGLEntries_CTE.strTransactionId
		,intTransactionId = ForGLEntries_CTE.intTransactionId
		,strTransactionType = ForGLEntries_CTE.strTransactionTypeName
		,strTransactionForm = ForGLEntries_CTE.strTransactionForm
		,strModuleName = @ModuleName
		,intConcurrencyId = 1
		,dblDebitForeign = CASE 
			WHEN ForGLEntries_CTE.intCurrencyId <> @intFunctionalCurrencyId
				THEN CreditForeign.Value
			ELSE ROUND(CreditForeign.Value * ForGLEntries_CTE.dblForexRate, 2)
			END
		,dblDebitReport = NULL
		,dblCreditForeign = CASE 
			WHEN ForGLEntries_CTE.intCurrencyId <> @intFunctionalCurrencyId
				THEN DebitForeign.Value
			ELSE ROUND(DebitForeign.Value * ForGLEntries_CTE.dblForexRate, 2)
			END
		,dblCreditReport = NULL
		,dblReportingRate = NULL
		,dblForeignRate = ForGLEntries_CTE.dblForexRate
		,strRateType = ForGLEntries_CTE.strRateType
	FROM ForGLEntries_CTE
	CROSS APPLY dbo.fnGetItemGLAccountAsTable(ForGLEntries_CTE.intItemId, ForGLEntries_CTE.intItemLocationId, @ACCOUNT_CATEGORY_InventoryInTransit) Account
	INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
		AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
	INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = Account.intAccountId
	-- CROSS APPLY dbo.fnGetDebitFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Debit
	-- CROSS APPLY dbo.fnGetCreditFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Credit
	CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) DebitForeign
	CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) CreditForeign
	WHERE ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1 AND ISNULL(ForGLEntries_CTE.ysnInventoryCost, 0) = 1 AND ForGLEntries_CTE.intCurrencyId <> @intInvoiceCurrency

	UNION ALL

	-- Inventoried Other Charge CConvert to Shipment Currency
	SELECT dtmDate = ForGLEntries_CTE.dtmDate
		,strBatchId = @strBatchId
		,intAccountId = GLAccount.intAccountId
		,dblDebit = ROUND(DebitForeign.Value * ItemCurrencyToFunctional.dblForexRate, 2)
		,dblCredit = ROUND(CreditForeign.Value * ItemCurrencyToFunctional.dblForexRate, 2)
		,dblDebitUnit = 0
		,dblCreditUnit = 0
		,strDescription = ISNULL(GLAccount.strDescription, '') + ' (' + ForGLEntries_CTE.strItemNo + ')'
		,strCode = @strCode
		,strReference = ''
		,intCurrencyId = ForGLEntries_CTE.intShipmentCurrencyId
		,dblExchangeRate = ISNULL(ItemCurrencyToFunctional.dblForexRate,1)
		,dtmDateEntered = GETDATE()
		,dtmTransactionDate = ForGLEntries_CTE.dtmDate
		,strJournalLineDescription = ''
		,intJournalLineNo = ForGLEntries_CTE.intShipmentItemId
		,ysnIsUnposted = 0
		,intUserId = @intEntityUserSecurityId
		,intEntityId = ForGLEntries_CTE.intEntityId
		,strTransactionId = ForGLEntries_CTE.strTransactionId
		,intTransactionId = ForGLEntries_CTE.intTransactionId
		,strTransactionType = ForGLEntries_CTE.strTransactionTypeName
		,strTransactionForm = ForGLEntries_CTE.strTransactionForm
		,strModuleName = @ModuleName
		,intConcurrencyId = 1
		,dblDebitForeign = CASE 
			WHEN ForGLEntries_CTE.intShipmentCurrencyId <> @intFunctionalCurrencyId
				THEN DebitForeign.Value
			ELSE ROUND(DebitForeign.Value * ItemCurrencyToFunctional.dblForexRate, 2)
			END
		,dblDebitReport = NULL
		,dblCreditForeign = CASE 
			WHEN ForGLEntries_CTE.intShipmentCurrencyId <> @intFunctionalCurrencyId
				THEN CreditForeign.Value
			ELSE ROUND(CreditForeign.Value * ItemCurrencyToFunctional.dblForexRate, 2)
			END
		,dblCreditReport = NULL
		,dblReportingRate = NULL
		,dblForeignRate = ISNULL(ItemCurrencyToFunctional.dblForexRate,1)
		,strRateType = ItemCurrencyToFunctional.strCurrencyExchangeRateType
	FROM ForGLEntries_CTE
	CROSS APPLY dbo.fnGetItemGLAccountAsTable(ForGLEntries_CTE.intItemId, ForGLEntries_CTE.intItemLocationId, @ACCOUNT_CATEGORY_InventoryInTransit) Account
	INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
		AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
	INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = Account.intAccountId
	OUTER APPLY (SELECT TOP 1 
					dblForexRate = ISNULL(dblRate,0),
					strCurrencyExchangeRateType
				FROM vyuGLExchangeRate
				WHERE intFromCurrencyId = ForGLEntries_CTE.intCurrencyId
					AND intToCurrencyId = @intFunctionalCurrencyId
					AND intCurrencyExchangeRateTypeId = ISNULL(ForGLEntries_CTE.intShipmentExchangeRateTypeId, intCurrencyExchangeRateTypeId)
				ORDER BY dtmValidFromDate DESC) ChargeCurrencyToFunctional
	OUTER APPLY (SELECT TOP 1 
					dblForexRate = ISNULL(dblRate,0),
					strCurrencyExchangeRateType
				FROM vyuGLExchangeRate
				WHERE intFromCurrencyId = ForGLEntries_CTE.intShipmentCurrencyId
				AND intToCurrencyId = @intFunctionalCurrencyId
				ORDER BY dtmValidFromDate DESC) ItemCurrencyToFunctional
	-- CROSS APPLY dbo.fnGetDebitFunctional(dbo.fnMultiply(ForGLEntries_CTE.dblCost, ISNULL(ItemCurrencyToFunctional.dblForexRate,1)), ForGLEntries_CTE.intShipmentCurrencyId, @intFunctionalCurrencyId, FX.dblForexRate) Debit
	-- CROSS APPLY dbo.fnGetCreditFunctional(dbo.fnMultiply(ForGLEntries_CTE.dblCost, ISNULL(ItemCurrencyToFunctional.dblForexRate,1)), ForGLEntries_CTE.intShipmentCurrencyId, @intFunctionalCurrencyId, FX.dblForexRate) Credit
	CROSS APPLY dbo.fnGetDebit(dbo.fnDivide(dbo.fnMultiply(ForGLEntries_CTE.dblCost, ISNULL(ChargeCurrencyToFunctional.dblForexRate,1)),ItemCurrencyToFunctional.dblForexRate)) DebitForeign
	CROSS APPLY dbo.fnGetCredit(dbo.fnDivide(dbo.fnMultiply(ForGLEntries_CTE.dblCost, ISNULL(ChargeCurrencyToFunctional.dblForexRate,1)),ItemCurrencyToFunctional.dblForexRate)) CreditForeign
	WHERE ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1 AND ISNULL(ForGLEntries_CTE.ysnInventoryCost, 0) = 1 AND ForGLEntries_CTE.intCurrencyId <> @intInvoiceCurrency

	UNION ALL

	-------------------------------------------------------------------------------------------
	-- Accrue Other Charge to Vendor 
	-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
	-- Dr...... Freight Expense 
	-- Cr.................... AP Clearing	
	-------------------------------------------------------------------------------------------
	SELECT dtmDate = ForGLEntries_CTE.dtmDate
		,strBatchId = @strBatchId
		,intAccountId = GLAccount.intAccountId
		,dblDebit = ROUND(DebitForeign.Value * ForGLEntries_CTE.dblForexRate, 2) --Debit.Value
		,dblCredit = ROUND(CreditForeign.Value * ForGLEntries_CTE.dblForexRate, 2) --Credit.Value
		,dblDebitUnit = 0
		,dblCreditUnit = 0
		,strDescription = ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo
		,strCode = @strCode
		,strReference = ''
		,intCurrencyId = ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate = ForGLEntries_CTE.dblForexRate
		,dtmDateEntered = GETDATE()
		,dtmTransactionDate = ForGLEntries_CTE.dtmDate
		,strJournalLineDescription = ''
		,intJournalLineNo = ForGLEntries_CTE.intShipmentItemId
		,ysnIsUnposted = 0
		,intUserId = @intEntityUserSecurityId
		,intEntityId = ForGLEntries_CTE.intEntityId
		,strTransactionId = ForGLEntries_CTE.strTransactionId
		,intTransactionId = ForGLEntries_CTE.intTransactionId
		,strTransactionType = ForGLEntries_CTE.strTransactionTypeName
		,strTransactionForm = ForGLEntries_CTE.strTransactionForm
		,strModuleName = @ModuleName
		,intConcurrencyId = 1
		,dblDebitForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN DebitForeign.Value
			ELSE ROUND(DebitForeign.Value * ForGLEntries_CTE.dblForexRate, 2)
			END
		,dblDebitReport = NULL
		,dblCreditForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN CreditForeign.Value
			ELSE ROUND(CreditForeign.Value * ForGLEntries_CTE.dblForexRate, 2)
			END
		,dblCreditReport = NULL
		,dblReportingRate = NULL
		,dblForeignRate = ForGLEntries_CTE.dblForexRate
		,strRateType = ForGLEntries_CTE.strRateType
	FROM ForGLEntries_CTE
	INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
		AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
	INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
	-- CROSS APPLY dbo.fnGetDebitFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Debit
	-- CROSS APPLY dbo.fnGetCreditFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Credit
	CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) DebitForeign
	CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) CreditForeign
	WHERE ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1 AND ISNULL(ForGLEntries_CTE.ysnInventoryCost, 0) = 0
	
	UNION ALL
	
	SELECT dtmDate = ForGLEntries_CTE.dtmDate
		,strBatchId = @strBatchId
		,intAccountId = GLAccount.intAccountId
		,dblDebit = ROUND(CreditForeign.Value * ForGLEntries_CTE.dblForexRate, 2) --Credit.Value
		,dblCredit = ROUND(DebitForeign.Value * ForGLEntries_CTE.dblForexRate, 2) --Debit.Value
		,dblDebitUnit = 0
		,dblCreditUnit = 0
		,strDescription = ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo
		,strCode = @strCode
		,strReference = ''
		,intCurrencyId = ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate = ForGLEntries_CTE.dblForexRate
		,dtmDateEntered = GETDATE()
		,dtmTransactionDate = ForGLEntries_CTE.dtmDate
		,strJournalLineDescription = ''
		,intJournalLineNo = ForGLEntries_CTE.intShipmentItemId
		,ysnIsUnposted = 0
		,intUserId = @intEntityUserSecurityId
		,intEntityId = ForGLEntries_CTE.intEntityId
		,strTransactionId = ForGLEntries_CTE.strTransactionId
		,intTransactionId = ForGLEntries_CTE.intTransactionId
		,strTransactionType = ForGLEntries_CTE.strTransactionTypeName
		,strTransactionForm = ForGLEntries_CTE.strTransactionForm
		,strModuleName = @ModuleName
		,intConcurrencyId = 1
		,dblDebitForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN CreditForeign.Value
			ELSE ROUND(CreditForeign.Value * ForGLEntries_CTE.dblForexRate, 2)
			END
		,dblDebitReport = NULL
		,dblCreditForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN DebitForeign.Value
			ELSE ROUND(DebitForeign.Value * ForGLEntries_CTE.dblForexRate, 2)
			END
		,dblCreditReport = NULL
		,dblReportingRate = NULL
		,dblForeignRate = ForGLEntries_CTE.dblForexRate
		,strRateType = ForGLEntries_CTE.strRateType
	FROM ForGLEntries_CTE
	INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
		AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
	INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing
	-- CROSS APPLY dbo.fnGetDebitFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Debit
	-- CROSS APPLY dbo.fnGetCreditFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Credit
	CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) DebitForeign
	CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) CreditForeign
	WHERE ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1 AND ISNULL(ForGLEntries_CTE.ysnInventoryCost, 0) = 0

	SELECT [dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit] = CASE 
			WHEN @ysnPost = 1 AND @ysnCancel = 0
				THEN [dblDebit]
			ELSE [dblCredit]
			END
		,[dblCredit] = CASE 
			WHEN @ysnPost = 1 AND @ysnCancel = 0
				THEN [dblCredit]
			ELSE [dblDebit]
			END
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[ysnIsUnposted] = CAST(CASE 
				WHEN @ysnPost = 1
					THEN 0
				ELSE 1
				END AS BIT)
		,[intUserId]
		,[intEntityId]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblDebitForeign] = CASE 
			WHEN @ysnPost = 1 AND @ysnCancel = 0
				THEN [dblDebitForeign]
			ELSE [dblCreditForeign]
			END
		,[dblDebitReport]
		,[dblCreditForeign] = CASE 
			WHEN @ysnPost = 1 AND @ysnCancel = 0
				THEN [dblCreditForeign]
			ELSE [dblDebitForeign]
			END
		,[dblCreditReport]
		,[dblReportingRate]
		,[dblForeignRate]
		,[strRateType]
	FROM @ChargesGLEntries
END

-- Exit point
_Exit: