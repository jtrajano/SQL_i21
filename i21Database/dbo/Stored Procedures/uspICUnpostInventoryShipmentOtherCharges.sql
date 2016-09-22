CREATE PROCEDURE [dbo].[uspICUnpostInventoryShipmentOtherCharges]
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
END 

-- Validate if other charge was billed. If billed, do not allow the unpost of the inventory shipment. 
BEGIN 
	SET @strItemNo = NULL
	SET @intItemId = NULL 
	
	SELECT	@strItemNo = Item.strItemNo
			,@intItemId = Item.intItemId
	FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentCharge ShipmentCharge
				ON Shipment.intInventoryShipmentId = ShipmentCharge.intInventoryShipmentId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = ShipmentCharge.intChargeId
	WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId 
			AND Shipment.ysnPosted = 1
			AND ISNULL(ShipmentCharge.dblAmountBilled, 0) > 0

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- 'Unable to unpost the Inventory Shipment. The {Other Charge} was billed.'
		RAISERROR(80054, 11, 1, @strItemNo) 	
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
			--,@ACCOUNT_CATEGORY_OtherChargeAsset AS NVARCHAR(30) = 'Other Charge (Asset)'

	-- Initialize the module name
	DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory'
			,@strTransactionForm  AS NVARCHAR(50) = 'Inventory Shipment'
			,@strCode AS NVARCHAR(10) = 'IC'

	-- Get the GL Account ids to use for the other charges. 
	DECLARE @ItemGLAccounts AS dbo.ItemGLAccount

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

	---- Check for missing Other Charge Asset 
	--BEGIN 
	--	SET @strItemNo = NULL
	--	SET @intItemId = NULL

	--	SELECT	TOP 1 
	--			@intItemId = Item.intItemId 
	--			,@strItemNo = Item.strItemNo
	--	FROM	dbo.tblICItem Item INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts
	--				ON Item.intItemId = ChargesGLAccounts.intChargeId
	--	WHERE	ChargesGLAccounts.intOtherChargeAsset IS NULL 			
			
	--	IF @intItemId IS NOT NULL 
	--	BEGIN 
	--		-- {Item} is missing a GL account setup for {Account Category} account category.
	--		RAISERROR(80008, 11, 1, @strItemNo, @ACCOUNT_CATEGORY_OtherChargeAsset) 	
	--		RETURN;
	--	END 
	--END 
	--;

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
				,ShipmentCharges.intCurrencyId
				,dblExchangeRate = 1
				,ShipmentItem.intInventoryShipmentItemId
				,strInventoryTransactionTypeName = TransType.strName
				,strTransactionForm = @strTransactionForm
				,AllocatedOtherCharges.ysnAccrue
				,AllocatedOtherCharges.ysnPrice
		FROM	dbo.tblICInventoryShipment Shipment INNER JOIN dbo.tblICInventoryShipmentItem ShipmentItem 
					ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
				INNER JOIN dbo.tblICInventoryShipmentItemAllocatedCharge AllocatedOtherCharges
					ON AllocatedOtherCharges.intInventoryShipmentId = Shipment.intInventoryShipmentId
					AND AllocatedOtherCharges.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId
				INNER JOIN dbo.tblICInventoryShipmentCharge ShipmentCharges
					ON ShipmentCharges.intInventoryShipmentChargeId = AllocatedOtherCharges.intInventoryShipmentChargeId
				LEFT JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ShipmentItem.intItemId
					AND ItemLocation.intLocationId = Shipment.intShipFromLocationId
				LEFT JOIN dbo.tblICItemLocation ChargeItemLocation
					ON ChargeItemLocation.intItemId = ShipmentCharges.intChargeId
					AND ChargeItemLocation.intLocationId = Shipment.intShipFromLocationId
				LEFT JOIN dbo.tblICInventoryTransactionType TransType
					ON TransType.intTransactionTypeId = @intTransactionTypeId
		WHERE	Shipment.intInventoryShipmentId = @intInventoryShipmentId
				
	)

	-------------------------------------------------------------------------------------------
	-- Accrue: No
	-- Vendor: Blank
	-- Price: No
	--
	-- Dr...... Other Charge Income
	-- Cr..................... Other Charge Expense
	-------------------------------------------------------------------------------------------
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryShipmentItemId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= NULL 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= NULL 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NULL
	FROM	ForGLEntries_CTE  
			INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense -- Other Charge Expense
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 0 
			AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 0
			AND (SELECT OtherCharge.intEntityVendorId 
				 FROM tblICInventoryShipment Shipment 
					  INNER JOIN tblICInventoryShipmentCharge OtherCharge ON OtherCharge.intInventoryShipmentId = Shipment.intInventoryShipmentId
				  WHERE Shipment.intInventoryShipmentId = @intInventoryShipmentId) IS NULL
	
	UNION ALL 
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryShipmentItemId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= NULL 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= NULL 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NULL
	FROM	ForGLEntries_CTE INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome -- Other Charge Income
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 0 
			AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 0
			AND (SELECT OtherCharge.intEntityVendorId 
				 FROM tblICInventoryShipment Shipment 
					  INNER JOIN tblICInventoryShipmentCharge OtherCharge ON OtherCharge.intInventoryShipmentId = Shipment.intInventoryShipmentId
				  WHERE Shipment.intInventoryShipmentId = @intInventoryShipmentId) IS NULL

	-------------------------------------------------------------------------------------------
	-- Accrue: Yes
	-- Vendor: Specified
	-- Price: No
	--
	-- Dr...... AP Clearing
	-- Cr..................... Other Charge Expense
	-------------------------------------------------------------------------------------------
	UNION ALL
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryShipmentItemId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= NULL 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= NULL 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NULL
	FROM	ForGLEntries_CTE  
			INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense -- Other Charge Expense
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1 
			AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 0
			AND (SELECT OtherCharge.intEntityVendorId 
				 FROM tblICInventoryShipment Shipment 
					  INNER JOIN tblICInventoryShipmentCharge OtherCharge ON OtherCharge.intInventoryShipmentId = Shipment.intInventoryShipmentId
				  WHERE Shipment.intInventoryShipmentId = @intInventoryShipmentId) IS NOT NULL

	UNION ALL 
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryShipmentItemId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= NULL 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= NULL 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NULL
	FROM	ForGLEntries_CTE INNER JOIN @ItemGLAccounts ItemGLAccounts
				ON ForGLEntries_CTE.intItemId = ItemGLAccounts.intItemId
				AND ForGLEntries_CTE.intItemLocationId = ItemGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = ItemGLAccounts.intContraInventoryId -- AP Clearing
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1
			AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 0
			AND (SELECT OtherCharge.intEntityVendorId 
				 FROM tblICInventoryShipment Shipment 
					  INNER JOIN tblICInventoryShipmentCharge OtherCharge ON OtherCharge.intInventoryShipmentId = Shipment.intInventoryShipmentId
				  WHERE Shipment.intInventoryShipmentId = @intInventoryShipmentId) IS NOT NULL
	-------------------------------------------------------------------------------------------
	-- Accrue: Yes
	-- Vendor: Specified
	-- Price: Yes
	--
	-- Dr...... AP Clearing
	-- Cr..................... Other Charge Expense
	-------------------------------------------------------------------------------------------
	UNION ALL 
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryShipmentItemId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= NULL 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= NULL 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NULL
	FROM	ForGLEntries_CTE INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense -- Other Charge Expense
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1 
			AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 1
			AND (SELECT OtherCharge.intEntityVendorId 
				 FROM tblICInventoryShipment Shipment 
					  INNER JOIN tblICInventoryShipmentCharge OtherCharge ON OtherCharge.intInventoryShipmentId = Shipment.intInventoryShipmentId
				  WHERE Shipment.intInventoryShipmentId = @intInventoryShipmentId) IS NOT NULL

	UNION ALL 
	SELECT	
			dtmDate						= ForGLEntries_CTE.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryShipmentItemId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= NULL 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= NULL 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NULL
   FROM	ForGLEntries_CTE INNER JOIN @ItemGLAccounts ItemGLAccounts
				ON ForGLEntries_CTE.intItemId = ItemGLAccounts.intItemId
				AND ForGLEntries_CTE.intItemLocationId = ItemGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = ItemGLAccounts.intContraInventoryId -- AP Clearing
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1 
			AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 1
			AND (SELECT OtherCharge.intEntityVendorId 
				 FROM tblICInventoryShipment Shipment 
					  INNER JOIN tblICInventoryShipmentCharge OtherCharge ON OtherCharge.intInventoryShipmentId = Shipment.intInventoryShipmentId
				  WHERE Shipment.intInventoryShipmentId = @intInventoryShipmentId) IS NOT NULL
END

-- Exit point
_Exit: