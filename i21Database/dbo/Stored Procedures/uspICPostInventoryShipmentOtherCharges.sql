CREATE PROCEDURE [dbo].[uspICPostInventoryShipmentOtherCharges]
	@intInventoryShipmentId AS INT 
	,@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
	,@intTransactionTypeId AS INT 
AS

-- Constant Variables
BEGIN 
	-- Variables used in the validations. 
	DECLARE @strItemNo AS NVARCHAR(50)
			,@intItemId AS INT 
			,@strTransactionId AS NVARCHAR(50)
			,@strCurrencyId AS NVARCHAR(50)
			,@strFunctionalCurrencyId AS NVARCHAR(50)
END 

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 

-- Validate 
BEGIN 
	-- Check for invalid location for the Other Charge item. 
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intItemId = Item.intItemId
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge OtherCharge
				ON Shipment.intInventoryShipmentId = OtherCharge.intInventoryShipmentId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = OtherCharge.intChargeId
			LEFT JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intLocationId = Shipment.intShipFromLocationId
				AND ItemLocation.intItemId = Item.intItemId
	WHERE	ItemLocation.intItemLocationId IS NULL 
			AND Shipment.intInventoryShipmentId = @intInventoryShipmentId

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- 'Item Location is invalid or missing for {Item}.'
		RAISERROR(50028, 11, 1, @strItemNo)
		GOTO _Exit
	END 
END 

-- Validate 
BEGIN 
	-- Check for invalid location for the Shipment Item. 
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intItemId = Item.intItemId
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
				ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = ShipmentItem.intItemId 
			LEFT JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intLocationId = Shipment.intShipFromLocationId
				AND ItemLocation.intItemId = Item.intItemId
	WHERE	ItemLocation.intItemLocationId IS NULL 
			AND Shipment.intInventoryShipmentId = @intInventoryShipmentId

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- 'Item Location is invalid or missing for {Item}.'
		RAISERROR(80002, 11, 1, @strItemNo)
		GOTO _Exit
	END 
END 
	
-- Validate 
BEGIN 
	-- Other Charges cannot be Accrued to the Same Shipment Customer
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intItemId = Item.intItemId
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge OtherCharge
				ON Shipment.intInventoryShipmentId = OtherCharge.intInventoryShipmentId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = OtherCharge.intChargeId
	WHERE	OtherCharge.ysnAccrue = 1
			AND OtherCharge.intEntityVendorId = Shipment.intEntityCustomerId
			AND Shipment.intInventoryShipmentId = @intInventoryShipmentId

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- The {Other Charge} cannot be accrued to the same Shipment Customer.
		RAISERROR(80095, 11, 1, @strItemNo)
		GOTO _Exit
	END 
END 

-- Validate 
BEGIN 
	-- Third Party is Required to Accrue ('Accrue-Y, Vendor-Null' combination should not be allowed)
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intItemId = Item.intItemId
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge OtherCharge
				ON Shipment.intInventoryShipmentId = OtherCharge.intInventoryShipmentId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = OtherCharge.intChargeId
	WHERE	OtherCharge.ysnAccrue = 1
			AND OtherCharge.intEntityVendorId IS NULL
			AND Shipment.intInventoryShipmentId = @intInventoryShipmentId

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- Vendor for {Other Charge Item} is required to accrue.
		RAISERROR(80088, 11, 1, @strItemNo)
		GOTO _Exit
	END 
END 

-- Validate
BEGIN 
	-- Check if the transaction is using a foreign currency and it has a missing forex rate. 
	SELECT @strItemNo = NULL
			,@intItemId = NULL 
			,@strTransactionId = NULL 
			,@strCurrencyId = NULL 
			,@strFunctionalCurrencyId = NULL 

	SELECT TOP 1 
			@strTransactionId = Shipment.strShipmentNumber 
			,@strItemNo = Item.strItemNo
			,@intItemId = Item.intItemId
			,@strCurrencyId = c.strCurrency
			,@strFunctionalCurrencyId = fc.strCurrency
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge OtherCharge
				ON Shipment.intInventoryShipmentId = OtherCharge.intInventoryShipmentId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = OtherCharge.intChargeId
			LEFT JOIN tblSMCurrency c
				ON c.intCurrencyID =  OtherCharge.intCurrencyId
			LEFT JOIN tblSMCurrency fc
				ON fc.intCurrencyID =  @intFunctionalCurrencyId
	WHERE	ISNULL(OtherCharge.dblForexRate, 0) = 0 
			AND OtherCharge.intCurrencyId IS NOT NULL 
			AND OtherCharge.intCurrencyId <> @intFunctionalCurrencyId
			AND Shipment.intInventoryShipmentId = @intInventoryShipmentId
			AND OtherCharge.intCurrencyId NOT IN (SELECT intCurrencyID FROM tblSMCurrency WHERE ysnSubCurrency = 1 AND intMainCurrencyId = @intFunctionalCurrencyId)

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- '{Transaction Id} is using a foreign currency. Please check if {Other Charge} has a forex rate. You may also need to review the Currency Exchange Rates and check if there is a valid forex rate from {Foreign Currency} to {Functional Currency}.'
		RAISERROR(80162, 11, 1, @strTransactionId, @strItemNo, @strCurrencyId, @strFunctionalCurrencyId)
		RETURN -1
	END 
END 

-- Calculate the other charges. 
BEGIN
	EXEC dbo.uspICCalculateShipmentOtherCharges
		@intInventoryShipmentId
END 

-- Allocate the other charges and surcharges. 
BEGIN 
	EXEC dbo.uspICAllocateInventoryShipmentOtherCharges 
		@intInventoryShipmentId
END 

-- Create the G/L Entries
BEGIN 
	-- Create the variables used by fnGetItemGLAccount
	DECLARE @ACCOUNT_CATEGORY_Inventory AS NVARCHAR(30) = 'Inventory'
			,@ACCOUNT_CATEGORY_APClearing AS NVARCHAR(30) = 'AP Clearing'
			,@ACCOUNT_CATEGORY_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense'
			,@ACCOUNT_CATEGORY_OtherChargeIncome AS NVARCHAR(30) = 'Other Charge Income'
			--,@ACCOUNT_CATEGORY_OtherChargeAsset AS NVARCHAR(30) = 'Other Charge (Asset)'

	-- Initialize the module name
	DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory'
			,@strTransactionForm  AS NVARCHAR(50) = 'Inventory Shipment'
			,@strCode AS NVARCHAR(10) = 'IC'


	DECLARE @ItemGLAccounts AS dbo.ItemGLAccount

	-- Get the GL Account ids to use for AP Clearing. 
	INSERT INTO @ItemGLAccounts (
		intItemId
		,intItemLocationId 
		,intInventoryId
		,intContraInventoryId
		,intTransactionTypeId
	)
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_Inventory) 
			,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_APClearing) 
			,intTransactionTypeId = @intTransactionTypeId
	FROM (
		SELECT	DISTINCT 
				ShipmentItem.intItemId
				,ItemLocation.intItemLocationId
		FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem
				ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
				LEFT JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ShipmentItem.intItemId
					AND ItemLocation.intLocationId = Shipment.intShipFromLocationId
		WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId
	) Query
		

	-- Get the GL Account ids to use for the other charges. 
	DECLARE @OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount; 
	INSERT INTO @OtherChargesGLAccounts (
		intChargeId 
		,intItemLocationId 
		,intOtherChargeExpense 
		,intOtherChargeIncome 
		--,intOtherChargeAsset 
		,intTransactionTypeId
	)
	SELECT	Query.intChargeId
			,Query.intItemLocationId
			,intOtherChargeExpense = dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeExpense) 
			,intOtherChargeIncome = dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeIncome) 
			--,intOtherChargeAsset = dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeAsset) 
			,intTransactionTypeId = @intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						OtherCharges.intChargeId
						,ItemLocation.intItemLocationId
				FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge OtherCharges 
							ON Shipment.intInventoryShipmentId = OtherCharges.intInventoryShipmentId
						LEFT JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = OtherCharges.intChargeId
							AND ItemLocation.intLocationId = Shipment.intShipFromLocationId
				WHERE	OtherCharges.intInventoryShipmentId = @intInventoryShipmentId
			) Query

	-- Check for missing Inventory Account Id
	BEGIN 
		SET @strItemNo = NULL
		SET @intItemId = NULL

		SELECT	TOP 1 
				@intItemId = Item.intItemId 
				,@strItemNo = Item.strItemNo
		FROM	tblICItem Item INNER JOIN @ItemGLAccounts ItemGLAccount
					ON Item.intItemId = ItemGLAccount.intItemId
		WHERE	ItemGLAccount.intInventoryId IS NULL 

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- {Item} is missing a GL account setup for {Account Category} account category.
			RAISERROR(80008, 11, 1, @strItemNo, @ACCOUNT_CATEGORY_Inventory) 	
			RETURN;
		END 
	END 
	;

	-- Check for missing AP Clearing Account Id
	BEGIN 
		SET @strItemNo = NULL
		SET @intItemId = NULL

		SELECT	TOP 1 
				@intItemId = Item.intItemId 
				,@strItemNo = Item.strItemNo
		FROM	tblICItem Item INNER JOIN @ItemGLAccounts ItemGLAccount
					ON Item.intItemId = ItemGLAccount.intItemId
		WHERE	ItemGLAccount.intContraInventoryId IS NULL 

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- {Item} is missing a GL account setup for {Account Category} account category.
			RAISERROR(80008, 11, 1, @strItemNo, @ACCOUNT_CATEGORY_APClearing) 	
			RETURN;
		END 
	END 
	;

	-- Check for missing Other Charge Expense 
	BEGIN 
		SET @strItemNo = NULL
		SET @intItemId = NULL

		SELECT	TOP 1 
				@intItemId = Item.intItemId 
				,@strItemNo = Item.strItemNo
		FROM	dbo.tblICItem Item INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts
					ON Item.intItemId = ChargesGLAccounts.intChargeId
		WHERE	ChargesGLAccounts.intOtherChargeExpense IS NULL 			
			
		IF @intItemId IS NOT NULL 
		BEGIN 
			-- {Item} is missing a GL account setup for {Account Category} account category.
			RAISERROR(80008, 11, 1, @strItemNo, @ACCOUNT_CATEGORY_OtherChargeExpense) 	
			RETURN;
		END 
	END 
	;

	-- Check for missing Other Charge Income 
	BEGIN 
		SET @strItemNo = NULL
		SET @intItemId = NULL

		SELECT	TOP 1 
				@intItemId = Item.intItemId 
				,@strItemNo = Item.strItemNo
		FROM	dbo.tblICItem Item INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts
					ON Item.intItemId = ChargesGLAccounts.intChargeId
		WHERE	ChargesGLAccounts.intOtherChargeIncome IS NULL 			
			
		IF @intItemId IS NOT NULL 
		BEGIN 
			-- {Item} is missing a GL account setup for {Account Category} account category.
			RAISERROR(80008, 11, 1, @strItemNo, @ACCOUNT_CATEGORY_OtherChargeIncome) 	
			RETURN;
		END 
	END 
	;

	-- Log the g/l account used in this batch. 
	INSERT INTO dbo.tblICInventoryGLAccountUsedOnPostLog (
			intItemId
			,intItemLocationId
			,strBatchId
			,intOtherChargeExpense
			,intOtherChargeIncome
			,intOtherChargeAsset
	)
	SELECT	intChargeId
			,intItemLocationId
			,@strBatchId
			,intOtherChargeExpense
			,intOtherChargeIncome
			,intOtherChargeAsset			
	FROM	@OtherChargesGLAccounts
	;

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
	)
	AS 
	(
		SELECT	dtmDate = Shipment.dtmShipDate
				,ShipmentItem.intItemId
				,intChargeId = ShipmentCharges.intChargeId
				,ItemLocation.intItemLocationId
				,intChargeItemLocation = ChargeItemLocation.intItemLocationId
				,intTransactionId = Shipment.intInventoryShipmentId
				,strTransactionId = Shipment.strShipmentNumber
				,dblCost = AllocatedOtherCharges.dblAmount
				,intTransactionTypeId  = @intTransactionTypeId
				,intCurrencyId = ISNULL(ShipmentCharges.intCurrencyId, Shipment.intCurrencyId) 
				,dblExchangeRate = ISNULL(ShipmentCharges.dblForexRate, 1) 
				,ShipmentItem.intInventoryShipmentItemId
				,strInventoryTransactionTypeName = TransType.strName
				,strTransactionForm = @strTransactionForm
				,AllocatedOtherCharges.ysnAccrue
				,AllocatedOtherCharges.ysnPrice
				,dblForexRate = ISNULL(ShipmentCharges.dblForexRate, 1) 
				,strRateType = currencyRateType.strCurrencyExchangeRateType
				,Charge.strItemNo
		FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem 
					ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
				INNER JOIN dbo.tblICInventoryShipmentItemAllocatedCharge AllocatedOtherCharges
					ON AllocatedOtherCharges.intInventoryShipmentId = Shipment.intInventoryShipmentId
					AND AllocatedOtherCharges.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
				INNER JOIN dbo.tblICInventoryShipmentCharge ShipmentCharges
					ON ShipmentCharges.intInventoryShipmentChargeId = AllocatedOtherCharges.intInventoryShipmentChargeId
				INNER JOIN tblICItem Charge	
					ON Charge.intItemId = ShipmentCharges.intChargeId
				LEFT JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ShipmentItem.intItemId
					AND ItemLocation.intLocationId = Shipment.intShipFromLocationId
				LEFT JOIN dbo.tblICItemLocation ChargeItemLocation
					ON ChargeItemLocation.intItemId = ShipmentCharges.intChargeId
					AND ChargeItemLocation.intLocationId = Shipment.intShipFromLocationId
				LEFT JOIN dbo.tblICInventoryTransactionType TransType
					ON TransType.intTransactionTypeId = @intTransactionTypeId
				LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
					ON currencyRateType.intCurrencyExchangeRateTypeId = ShipmentCharges.intForexRateTypeId

		WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId
				
	)

	-------------------------------------------------------------------------------------------
	-- Accrue: No
	-- Vendor: Blank
	-- Price: No
	--
	-- Dr...... Other Charge Expense
	-- Cr..................... Other Charge Income 
	-------------------------------------------------------------------------------------------
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryShipmentItemId
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
	FROM	ForGLEntries_CTE  
			INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense -- Other Charge Expense
			CROSS APPLY dbo.fnGetDebitFunctional(
				ForGLEntries_CTE.dblCost
				,ForGLEntries_CTE.intCurrencyId
				,@intFunctionalCurrencyId
				,ForGLEntries_CTE.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				ForGLEntries_CTE.dblCost
				,ForGLEntries_CTE.intCurrencyId
				,@intFunctionalCurrencyId
				,ForGLEntries_CTE.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) DebitForeign
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) CreditForeign

	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 0 
			AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 0

	UNION ALL 
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryShipmentItemId
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
	FROM	ForGLEntries_CTE INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome -- Other Charge Income
			CROSS APPLY dbo.fnGetDebitFunctional(
				ForGLEntries_CTE.dblCost
				,ForGLEntries_CTE.intCurrencyId
				,@intFunctionalCurrencyId
				,ForGLEntries_CTE.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				ForGLEntries_CTE.dblCost
				,ForGLEntries_CTE.intCurrencyId
				,@intFunctionalCurrencyId
				,ForGLEntries_CTE.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) DebitForeign
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) CreditForeign

	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 0 
			AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 0
END

-- Exit point
_Exit: