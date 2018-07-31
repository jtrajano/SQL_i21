CREATE PROCEDURE [dbo].[uspLGPostInventoryShipmentOtherCharges]
	@intInventoryShipmentId AS INT
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
END

-- Get the functional currency
BEGIN
	DECLARE @intFunctionalCurrencyId AS INT

	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
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
	INNER JOIN dbo.tblLGLoadCost OtherCharge ON LOAD.intLoadId = OtherCharge.intLoadId
	INNER JOIN tblICItem Item ON Item.intItemId = OtherCharge.intItemId
	LEFT JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intLocationId = LoadDetail.intSCompanyLocationId
		AND ItemLocation.intItemId = Item.intItemId
	WHERE ItemLocation.intItemLocationId IS NULL
		AND LOAD.intLoadId = @intInventoryShipmentId

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
	INNER JOIN dbo.tblLGLoadCost OtherCharge ON LOAD.intLoadId = OtherCharge.intLoadId
	INNER JOIN tblICItem Item ON Item.intItemId = OtherCharge.intItemId
	WHERE OtherCharge.ysnAccrue = 1
		AND OtherCharge.intVendorId IS NULL
		AND LOAD.intLoadId = @intInventoryShipmentId

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
	DECLARE @ACCOUNT_CATEGORY_Inventory AS NVARCHAR(30) = 'Inventory'
		,@ACCOUNT_CATEGORY_APClearing AS NVARCHAR(30) = 'AP Clearing'
		,@ACCOUNT_CATEGORY_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense'
		,@ACCOUNT_CATEGORY_OtherChargeIncome AS NVARCHAR(30) = 'Other Charge Income'
	-- Initialize the module name
	DECLARE @ModuleName AS NVARCHAR(50) = 'Logistics'
		,@strTransactionForm AS NVARCHAR(50) = 'Outbound Shipment'
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
		INNER JOIN dbo.tblLGLoadCost OtherCharges ON LOAD.intLoadId = OtherCharges.intLoadId
		LEFT JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intItemId = OtherCharges.intItemId
			AND ItemLocation.intLocationId = LoadDetail.intSCompanyLocationId
		WHERE OtherCharges.intLoadId = @intInventoryShipmentId
		) Query

	-- Check for missing AP Clearing Account Id
	BEGIN
		SET @strItemNo = NULL
		SET @intItemId = NULL

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
		,dblExchangeRate
		,intInventoryShipmentItemId
		,strInventoryTransactionTypeName
		,strTransactionForm
		,ysnAccrue
		,ysnPrice
		,dblForexRate
		,strRateType
		,strItemNo
		,intEntityId
		)
	AS (
		SELECT dtmDate = GETDATE()
			,ShipmentItem.intItemId
			,intChargeId = ShipmentCharges.intItemId
			,ItemLocation.intItemLocationId
			,intChargeItemLocation = ChargeItemLocation.intItemLocationId
			,intTransactionId = Shipment.intLoadId
			,strTransactionId = Shipment.strLoadNumber
			,dblCost = ShipmentCharges.dblAmount
			,intTransactionTypeId = @intTransactionTypeId
			,intCurrencyId = ISNULL(ShipmentCharges.intCurrencyId, Shipment.intCurrencyId)
			,dblExchangeRate = ISNULL(1, 1)
			,ShipmentItem.intLoadDetailId
			,strInventoryTransactionTypeName = TransType.strName
			,strTransactionForm = 'Logistics'
			,ShipmentCharges.ysnAccrue
			,ShipmentCharges.ysnPrice
			,dblForexRate = ISNULL(1, 1)
			,strRateType = 1
			,Charge.strItemNo
			,intEntityId = 1
		FROM dbo.tblLGLoad Shipment
		INNER JOIN dbo.tblLGLoadDetail ShipmentItem ON Shipment.intLoadId = ShipmentItem.intLoadId
		INNER JOIN dbo.tblLGLoadCost ShipmentCharges ON ShipmentCharges.intLoadId = Shipment.intLoadId
		INNER JOIN tblICItem Charge ON Charge.intItemId = ShipmentCharges.intItemId
		LEFT JOIN dbo.tblICItemLocation ItemLocation ON ItemLocation.intItemId = ShipmentItem.intItemId
			AND ItemLocation.intLocationId = ShipmentItem.intSCompanyLocationId
		LEFT JOIN dbo.tblICItemLocation ChargeItemLocation ON ChargeItemLocation.intItemId = ShipmentCharges.intItemId
			AND ChargeItemLocation.intLocationId = ShipmentItem.intSCompanyLocationId
		LEFT JOIN dbo.tblICInventoryTransactionType TransType ON TransType.intTransactionTypeId = @intTransactionTypeId
		WHERE Shipment.intLoadId = @intInventoryShipmentId
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
	-------------------------------------------------------------------------------------------
	-- Accrue: No
	-- Vendor: Blank
	-- Price: No
	--
	-- Dr...... Other Charge Expense
	-- Cr..................... Other Charge Income 
	-------------------------------------------------------------------------------------------
	SELECT dtmDate = ForGLEntries_CTE.dtmDate
		,strBatchId = @strBatchId
		,intAccountId = GLAccount.intAccountId
		,dblDebit = Debit.Value
		,dblCredit = Credit.Value
		,dblDebitUnit = 0
		,dblCreditUnit = 0
		,strDescription = ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo
		,strCode = @strCode
		,strReference = ''
		,intCurrencyId = ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate = ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered = GETDATE()
		,dtmTransactionDate = ForGLEntries_CTE.dtmDate
		,strJournalLineDescription = ''
		,intJournalLineNo = ForGLEntries_CTE.intInventoryShipmentItemId
		,ysnIsUnposted = 0
		,intUserId = @intEntityUserSecurityId
		,intEntityId = ForGLEntries_CTE.intEntityId
		,strTransactionId = ForGLEntries_CTE.strTransactionId
		,intTransactionId = ForGLEntries_CTE.intTransactionId
		,strTransactionType = ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm = ForGLEntries_CTE.strTransactionForm
		,strModuleName = @ModuleName
		,intConcurrencyId = 1
		,dblDebitForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN DebitForeign.Value
			ELSE 0
			END
		,dblDebitReport = NULL
		,dblCreditForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN CreditForeign.Value
			ELSE 0
			END
		,dblCreditReport = NULL
		,dblReportingRate = NULL
		,dblForeignRate = ForGLEntries_CTE.dblForexRate
		,strRateType = ForGLEntries_CTE.strRateType
	FROM ForGLEntries_CTE
	INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
		AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
	INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense -- Other Charge Expense
	CROSS APPLY dbo.fnGetDebitFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Debit
	CROSS APPLY dbo.fnGetCreditFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Credit
	CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) DebitForeign
	CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) CreditForeign
	WHERE ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 0
		AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 0
	
	UNION ALL
	
	SELECT dtmDate = ForGLEntries_CTE.dtmDate
		,strBatchId = @strBatchId
		,intAccountId = GLAccount.intAccountId
		,dblDebit = Credit.Value
		,dblCredit = Debit.Value
		,dblDebitUnit = 0
		,dblCreditUnit = 0
		,strDescription = ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo
		,strCode = @strCode
		,strReference = ''
		,intCurrencyId = ForGLEntries_CTE.intCurrencyId
		,dblExchangeRate = ForGLEntries_CTE.dblExchangeRate
		,dtmDateEntered = GETDATE()
		,dtmTransactionDate = ForGLEntries_CTE.dtmDate
		,strJournalLineDescription = ''
		,intJournalLineNo = ForGLEntries_CTE.intInventoryShipmentItemId
		,ysnIsUnposted = 0
		,intUserId = @intEntityUserSecurityId
		,intEntityId = ForGLEntries_CTE.intEntityId
		,strTransactionId = ForGLEntries_CTE.strTransactionId
		,intTransactionId = ForGLEntries_CTE.intTransactionId
		,strTransactionType = ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm = ForGLEntries_CTE.strTransactionForm
		,strModuleName = @ModuleName
		,intConcurrencyId = 1
		,dblDebitForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN CreditForeign.Value
			ELSE 0
			END
		,dblDebitReport = NULL
		,dblCreditForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN DebitForeign.Value
			ELSE 0
			END
		,dblCreditReport = NULL
		,dblReportingRate = NULL
		,dblForeignRate = ForGLEntries_CTE.dblForexRate
		,strRateType = ForGLEntries_CTE.strRateType
	FROM ForGLEntries_CTE
	INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
		AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
	INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome -- Other Charge Income
	CROSS APPLY dbo.fnGetDebitFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Debit
	CROSS APPLY dbo.fnGetCreditFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Credit
	CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) DebitForeign
	CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) CreditForeign
	WHERE ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 0
		AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 0
	-------------------------------------------------------------------------------------------
	-- Accrue Other Charge to Vendor 
	-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
	-- Dr...... Freight Expense 
	-- Cr.................... AP Clearing	
	-------------------------------------------------------------------------------------------
	
	UNION ALL
	
	SELECT dtmDate = ForGLEntries_CTE.dtmDate
		,strBatchId = @strBatchId
		,intAccountId = GLAccount.intAccountId
		,dblDebit = Debit.Value
		,dblCredit = Credit.Value
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
		,intJournalLineNo = ForGLEntries_CTE.intInventoryShipmentItemId
		,ysnIsUnposted = 0
		,intUserId = @intEntityUserSecurityId
		,intEntityId = ForGLEntries_CTE.intEntityId
		,strTransactionId = ForGLEntries_CTE.strTransactionId
		,intTransactionId = ForGLEntries_CTE.intTransactionId
		,strTransactionType = ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm = ForGLEntries_CTE.strTransactionForm
		,strModuleName = @ModuleName
		,intConcurrencyId = 1
		,dblDebitForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN DebitForeign.Value
			ELSE 0
			END
		,dblDebitReport = NULL
		,dblCreditForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN CreditForeign.Value
			ELSE 0
			END
		,dblCreditReport = NULL
		,dblReportingRate = NULL
		,dblForeignRate = ForGLEntries_CTE.dblForexRate
		,strRateType = ForGLEntries_CTE.strRateType
	FROM ForGLEntries_CTE
	INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
		AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
	INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
	CROSS APPLY dbo.fnGetDebitFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Debit
	CROSS APPLY dbo.fnGetCreditFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Credit
	CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) DebitForeign
	CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) CreditForeign
	WHERE ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1
	
	UNION ALL
	
	SELECT dtmDate = ForGLEntries_CTE.dtmDate
		,strBatchId = @strBatchId
		,intAccountId = GLAccount.intAccountId
		,dblDebit = Credit.Value
		,dblCredit = Debit.Value
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
		,intJournalLineNo = ForGLEntries_CTE.intInventoryShipmentItemId
		,ysnIsUnposted = 0
		,intUserId = @intEntityUserSecurityId
		,intEntityId = ForGLEntries_CTE.intEntityId
		,strTransactionId = ForGLEntries_CTE.strTransactionId
		,intTransactionId = ForGLEntries_CTE.intTransactionId
		,strTransactionType = ForGLEntries_CTE.strInventoryTransactionTypeName
		,strTransactionForm = ForGLEntries_CTE.strTransactionForm
		,strModuleName = @ModuleName
		,intConcurrencyId = 1
		,dblDebitForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN CreditForeign.Value
			ELSE 0
			END
		,dblDebitReport = NULL
		,dblCreditForeign = CASE 
			WHEN intCurrencyId <> @intFunctionalCurrencyId
				THEN DebitForeign.Value
			ELSE 0
			END
		,dblCreditReport = NULL
		,dblReportingRate = NULL
		,dblForeignRate = ForGLEntries_CTE.dblForexRate
		,strRateType = ForGLEntries_CTE.strRateType
	FROM ForGLEntries_CTE
	INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
		AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
	INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing
	CROSS APPLY dbo.fnGetDebitFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Debit
	CROSS APPLY dbo.fnGetCreditFunctional(ForGLEntries_CTE.dblCost, ForGLEntries_CTE.intCurrencyId, @intFunctionalCurrencyId, ForGLEntries_CTE.dblForexRate) Credit
	CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) DebitForeign
	CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) CreditForeign
	WHERE ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1

	SELECT [dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit] = CASE 
			WHEN @ysnPost = 1
				THEN [dblDebit]
			ELSE [dblCredit]
			END
		,[dblCredit] = CASE 
			WHEN @ysnPost = 1
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
			WHEN @ysnPost = 1
				THEN [dblDebitForeign]
			ELSE [dblCreditForeign]
			END
		,[dblDebitReport]
		,[dblCreditForeign] = CASE 
			WHEN @ysnPost = 1
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