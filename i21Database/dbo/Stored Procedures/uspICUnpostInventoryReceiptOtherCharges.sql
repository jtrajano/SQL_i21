CREATE PROCEDURE [dbo].[uspICUnpostInventoryReceiptOtherCharges]

	@intInventoryReceiptId AS INT 
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@intTransactionTypeId AS INT 
AS

-- Constant Variables
BEGIN 
	DECLARE @COST_BILLED_BY_Vendor AS NVARCHAR(50) = 'Vendor'
			,@COST_BILLED_BY_ThirdParty AS NVARCHAR(50) = 'Third Party'
			,@COST_BILLED_BY_None AS NVARCHAR(50) = 'None'

	-- Variables used in the validations. 
	DECLARE @strItemNo AS NVARCHAR(50)
			,@intItemId AS INT 
			,@strLocationName AS NVARCHAR(50)
END 

BEGIN 
	-- Validate if other charge was billed. If billed, do not allow the unpost of the inventory receipt. 
	SET @strItemNo = NULL
	SET @intItemId = NULL 
	
	SELECT	@strItemNo = Item.strItemNo
			,@intItemId = Item.intItemId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharge
				ON Receipt.intInventoryReceiptId = ReceiptCharge.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = ReceiptCharge.intChargeId
	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId 
			AND Receipt.ysnPosted = 1
			AND ISNULL(ReceiptCharge.dblAmountBilled, 0) > 0

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- 'Unable to unpost the {Inventory Receipt or Shipment}. The {Other Charge} was {voucher or invoiced}.'
		EXEC uspICRaiseError 80054, 'Inventory Receipt', @strItemNo, 'vouchered';
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
	DECLARE @ModuleName AS NVARCHAR(50) = 'Inventory'
			,@strTransactionForm  AS NVARCHAR(50) = 'Inventory Receipt'
			,@strCode AS NVARCHAR(10) = 'IC'

	-- Get the GL Account ids to use for the other charges. 
	DECLARE @ItemGLAccounts AS dbo.ItemGLAccount; 

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
	FROM	(
				SELECT	DISTINCT 
						ReceiptItem.intItemId
						,ItemLocation.intItemLocationId
				FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
							ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
						LEFT JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = ReceiptItem.intItemId
							AND ItemLocation.intLocationId = Receipt.intLocationId
				WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
						AND ISNULL(ReceiptItem.intOwnershipType, 0) = 1 -- Only "Own" items will have GL entries. 
			) Query

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
	SELECT	Query.intChargeId
			,Query.intItemLocationId
			,intOtherChargeExpense = dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeExpense) 
			,intOtherChargeIncome = dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeIncome) 
			,intAPClearing = dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @ACCOUNT_CATEGORY_APClearing)  
			,intTransactionTypeId = @intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						OtherCharges.intChargeId
						,ItemLocation.intItemLocationId
				FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge OtherCharges 
							ON Receipt.intInventoryReceiptId = OtherCharges.intInventoryReceiptId
						LEFT JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = OtherCharges.intChargeId
							AND ItemLocation.intLocationId = Receipt.intLocationId
				WHERE	OtherCharges.intInventoryReceiptId = @intInventoryReceiptId
			) Query

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

		SELECT	TOP 1 
				@strLocationName = c.strLocationName
		FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
					ON il.intLocationId = c.intCompanyLocationId
				INNER JOIN @ItemGLAccounts ItemGLAccount
					ON ItemGLAccount.intItemId = il.intItemId
					AND ItemGLAccount.intItemLocationId = il.intItemLocationId
		WHERE	il.intItemId = @intItemId
				AND ItemGLAccount.intContraInventoryId IS NULL 

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- {Item} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_APClearing;
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
		
		SELECT	TOP 1 
				@strLocationName = c.strLocationName
		FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
					ON il.intLocationId = c.intCompanyLocationId
				INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts
					ON ChargesGLAccounts.intChargeId = il.intItemId
					AND ChargesGLAccounts.intItemLocationId = il.intItemLocationId
		WHERE	il.intItemId = @intItemId
				AND ChargesGLAccounts.intOtherChargeExpense IS NULL 			
			
		IF @intItemId IS NOT NULL 
		BEGIN 
			-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_OtherChargeExpense;
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
		
		SELECT	TOP 1 
				@strLocationName = c.strLocationName
		FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
					ON il.intLocationId = c.intCompanyLocationId
				INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts
					ON ChargesGLAccounts.intChargeId = il.intItemId
					AND ChargesGLAccounts.intItemLocationId = il.intItemLocationId
		WHERE	il.intItemId = @intItemId
				AND ChargesGLAccounts.intOtherChargeIncome IS NULL
			
		IF @intItemId IS NOT NULL 
		BEGIN 
			-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_OtherChargeIncome;
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
			,intContraInventoryId
	)
	SELECT	intChargeId
			,intItemLocationId
			,@strBatchId
			,intOtherChargeExpense
			,intOtherChargeIncome
			,intAPClearing			
	FROM	@OtherChargesGLAccounts
	;

	-- Get the functional currency
	BEGIN 
		DECLARE @intFunctionalCurrencyId AS INT
		SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
	END 
	;
	
	DECLARE @ChargesGLEntries AS RecapTableType;

	-- Generate the G/L Entries here: 
	WITH InventoryCostCharges (
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
		,intInventoryReceiptItemId
		,strInventoryTransactionTypeName
		,strTransactionForm
		,ysnAccrue
		,ysnPrice
		,ysnInventoryCost
		,dblForexRate
		,strRateType
		,strCharge
		,strItem
	)
	AS 
	(
		SELECT	dtmDate = Receipt.dtmReceiptDate
				,ReceiptItem.intItemId
				,intChargeId = ReceiptCharges.intChargeId
				,ItemLocation.intItemLocationId
				,intChargeItemLocation = ChargeItemLocation.intItemLocationId
				,intTransactionId = Receipt.intInventoryReceiptId
				,strTransactionId = Receipt.strReceiptNumber
				,dblCost = 
					CASE 
						WHEN Receipt.strReceiptType = 'Inventory Return' 
							THEN -AllocatedOtherCharges.dblAmount /*Negate the other charge if it is an Inventory Return*/
						ELSE 
							AllocatedOtherCharges.dblAmount 
					END					
				,intTransactionTypeId  = @intTransactionTypeId
				,intCurrencyId = ISNULL(ReceiptCharges.intCurrencyId, Receipt.intCurrencyId) 
				,dblExchangeRate = ISNULL(ReceiptCharges.dblForexRate, 1)
				,ReceiptItem.intInventoryReceiptItemId
				,strInventoryTransactionTypeName = TransType.strName
				,strTransactionForm = @strTransactionForm
				,AllocatedOtherCharges.ysnAccrue
				,AllocatedOtherCharges.ysnPrice
				,AllocatedOtherCharges.ysnInventoryCost
				,dblForexRate = ISNULL(ReceiptCharges.dblForexRate, 1) 
				,strRateType = currencyRateType.strCurrencyExchangeRateType
				,strCharge = Charge.strItemNo
				,strItem = Item.strItemNo
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				INNER JOIN dbo.tblICInventoryReceiptItemAllocatedCharge AllocatedOtherCharges
					ON AllocatedOtherCharges.intInventoryReceiptId = Receipt.intInventoryReceiptId
					AND AllocatedOtherCharges.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
				INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharges
					ON ReceiptCharges.intInventoryReceiptChargeId = AllocatedOtherCharges.intInventoryReceiptChargeId
				LEFT JOIN tblICItem Charge
					ON Charge.intItemId = ReceiptCharges.intChargeId
				LEFT JOIN tblICItem Item 
					ON Item.intItemId = ReceiptItem.intItemId 
				LEFT JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ReceiptItem.intItemId
					AND ItemLocation.intLocationId = Receipt.intLocationId
				LEFT JOIN dbo.tblICItemLocation ChargeItemLocation
					ON ChargeItemLocation.intItemId = ReceiptCharges.intChargeId
					AND ChargeItemLocation.intLocationId = Receipt.intLocationId
				LEFT JOIN dbo.tblICInventoryTransactionType TransType
					ON TransType.intTransactionTypeId = @intTransactionTypeId
				LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
					ON currencyRateType.intCurrencyExchangeRateTypeId = ReceiptCharges.intForexRateTypeId
		WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
				AND ReceiptItem.intItemId = ISNULL(@intItemId, ReceiptItem.intItemId)
				
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
	-- Cost billed by: None
	-- Add cost to inventory: Yes
	-- 
	-- Dr...... Item's Inventory Account
	-- Cr..................... Freight Expense 
	-------------------------------------------------------------------------------------------
	SELECT	
			dtmDate						= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge + ' for ' + InventoryCostCharges.strItem
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= InventoryCostCharges.strTransactionId
			,intTransactionId			= InventoryCostCharges.intTransactionId
			,strTransactionType			= InventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= InventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END  
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= InventoryCostCharges.dblForexRate 
			,strRateType				= InventoryCostCharges.strRateType
	FROM	InventoryCostCharges  
			INNER JOIN @ItemGLAccounts ItemGLAccounts
				ON InventoryCostCharges.intItemId = ItemGLAccounts.intItemId
				AND InventoryCostCharges.intItemLocationId = ItemGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = ItemGLAccounts.intInventoryId
			CROSS APPLY dbo.fnGetDebitFunctional(				
				CASE WHEN InventoryCostCharges.ysnPrice = 1 THEN -InventoryCostCharges.dblCost ELSE InventoryCostCharges.dblCost END 
				,InventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,InventoryCostCharges.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				CASE WHEN InventoryCostCharges.ysnPrice = 1 THEN -InventoryCostCharges.dblCost ELSE InventoryCostCharges.dblCost END 
				,InventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,InventoryCostCharges.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(CASE WHEN InventoryCostCharges.ysnPrice = 1 THEN -InventoryCostCharges.dblCost ELSE InventoryCostCharges.dblCost END) DebitForeign
			CROSS APPLY dbo.fnGetCredit(CASE WHEN InventoryCostCharges.ysnPrice = 1 THEN -InventoryCostCharges.dblCost ELSE InventoryCostCharges.dblCost END) CreditForeign

	WHERE	ISNULL(InventoryCostCharges.ysnAccrue, 0) = 0 
			AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1

	UNION ALL 
	SELECT	
			dtmDate						= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= InventoryCostCharges.strTransactionId
			,intTransactionId			= InventoryCostCharges.intTransactionId
			,strTransactionType			= InventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= InventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END   
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= InventoryCostCharges.dblForexRate 
			,strRateType				= InventoryCostCharges.strRateType
	FROM	InventoryCostCharges INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON InventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND InventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
			CROSS APPLY dbo.fnGetDebitFunctional(
				CASE WHEN InventoryCostCharges.ysnPrice = 1 THEN -InventoryCostCharges.dblCost ELSE InventoryCostCharges.dblCost END 
				,InventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,InventoryCostCharges.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				CASE WHEN InventoryCostCharges.ysnPrice = 1 THEN -InventoryCostCharges.dblCost ELSE InventoryCostCharges.dblCost END 
				,InventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,InventoryCostCharges.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(CASE WHEN InventoryCostCharges.ysnPrice = 1 THEN -InventoryCostCharges.dblCost ELSE InventoryCostCharges.dblCost END) DebitForeign
			CROSS APPLY dbo.fnGetCredit(CASE WHEN InventoryCostCharges.ysnPrice = 1 THEN -InventoryCostCharges.dblCost ELSE InventoryCostCharges.dblCost END) CreditForeign

	WHERE	ISNULL(InventoryCostCharges.ysnAccrue, 0) = 0 
			AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1

	-------------------------------------------------------------------------------------------
	-- Accrue Other Charge to Vendor and Add Cost to Inventory 
	-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
	-- 
	-- (X) Dr...... Item's Inventory Acccount 
	-- Cr.................... AP Clearing	
	-------------------------------------------------------------------------------------------
	UNION ALL 
	SELECT	
			dtmDate						= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge + ' for ' + InventoryCostCharges.strItem
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= InventoryCostCharges.strTransactionId
			,intTransactionId			= InventoryCostCharges.intTransactionId
			,strTransactionType			= InventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= InventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END  
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= InventoryCostCharges.dblForexRate 
			,strRateType				= InventoryCostCharges.strRateType
	FROM	InventoryCostCharges INNER JOIN @ItemGLAccounts ItemGLAccounts
				ON InventoryCostCharges.intItemId = ItemGLAccounts.intItemId
				AND InventoryCostCharges.intItemLocationId = ItemGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = ItemGLAccounts.intInventoryId 
			CROSS APPLY dbo.fnGetDebitFunctional(
				InventoryCostCharges.dblCost
				,InventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,InventoryCostCharges.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				InventoryCostCharges.dblCost
				,InventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,InventoryCostCharges.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(InventoryCostCharges.dblCost) DebitForeign
			CROSS APPLY dbo.fnGetCredit(InventoryCostCharges.dblCost) CreditForeign
	WHERE	ISNULL(InventoryCostCharges.ysnAccrue, 0) = 1
			AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1	
	UNION ALL 
	SELECT	
			dtmDate						= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + InventoryCostCharges.strCharge 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= InventoryCostCharges.intCurrencyId
			,dblExchangeRate			= InventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= InventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= InventoryCostCharges.strTransactionId
			,intTransactionId			= InventoryCostCharges.intTransactionId
			,strTransactionType			= InventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= InventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END  
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= InventoryCostCharges.dblForexRate 
			,strRateType				= InventoryCostCharges.strRateType
	FROM	InventoryCostCharges INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON InventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND InventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing 
			CROSS APPLY dbo.fnGetDebitFunctional(
				InventoryCostCharges.dblCost
				,InventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,InventoryCostCharges.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				InventoryCostCharges.dblCost
				,InventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,InventoryCostCharges.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(InventoryCostCharges.dblCost) DebitForeign
			CROSS APPLY dbo.fnGetCredit(InventoryCostCharges.dblCost) CreditForeign

	WHERE	ISNULL(InventoryCostCharges.ysnAccrue, 0) = 1
			AND ISNULL(InventoryCostCharges.ysnInventoryCost, 0) = 1
	;
	-- Generate the G/L Entries here: 
	WITH NonInventoryCostCharges (
		dtmDate
		,intChargeId
		,intChargeItemLocation
		,intTransactionId
		,strTransactionId
		,dblCost 				
		,intTransactionTypeId  
		,intCurrencyId
		,dblExchangeRate 
		,intInventoryReceiptChargeId
		,strInventoryTransactionTypeName 
		,strTransactionForm 
		,ysnAccrue
		,ysnPrice
		,ysnInventoryCost
		,dblForexRate 
		,strRateType 
		,strCharge 
	)
	AS 
	(
		SELECT	dtmDate = Receipt.dtmReceiptDate
				,intChargeId = Charge.intItemId
				,intChargeItemLocation = ChargeItemLocation.intItemLocationId
				,intTransactionId = Receipt.intInventoryReceiptId
				,strTransactionId = Receipt.strReceiptNumber
				,dblCost = 
					CASE 
						WHEN Receipt.strReceiptType = 'Inventory Return' 
							THEN -ReceiptCharges.dblAmount /*Negate the other charge if it is an Inventory Return*/
						ELSE 
							ReceiptCharges.dblAmount 
					END					
				,intTransactionTypeId  = @intTransactionTypeId
				,intCurrencyId = ISNULL(ReceiptCharges.intCurrencyId, Receipt.intCurrencyId) 
				,dblExchangeRate = ISNULL(ReceiptCharges.dblForexRate, 1)
				,ReceiptCharges.intInventoryReceiptChargeId
				,strInventoryTransactionTypeName = TransType.strName
				,strTransactionForm = @strTransactionForm
				,ReceiptCharges.ysnAccrue
				,ReceiptCharges.ysnPrice
				,ReceiptCharges.ysnInventoryCost
				,dblForexRate = ISNULL(ReceiptCharges.dblForexRate, 1) 
				,strRateType = currencyRateType.strCurrencyExchangeRateType
				,strCharge = Charge.strItemNo
		FROM	dbo.tblICInventoryReceipt Receipt 
				INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharges
					ON ReceiptCharges.intInventoryReceiptId = Receipt.intInventoryReceiptId
				LEFT JOIN tblICItem Charge
					ON Charge.intItemId = ReceiptCharges.intChargeId
				LEFT JOIN dbo.tblICItemLocation ChargeItemLocation
					ON ChargeItemLocation.intItemId = ReceiptCharges.intChargeId
					AND ChargeItemLocation.intLocationId = Receipt.intLocationId
				LEFT JOIN dbo.tblICInventoryTransactionType TransType
					ON TransType.intTransactionTypeId = @intTransactionTypeId
				LEFT JOIN tblSMCurrencyExchangeRateType currencyRateType
					ON currencyRateType.intCurrencyExchangeRateTypeId = ReceiptCharges.intForexRateTypeId
		WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
				
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
	-- Cost billed by: None
	-- Add cost to inventory: No
	-- 
	-- Dr...... Freight Expense
	-- Cr..................... Freight Income 
	-------------------------------------------------------------------------------------------
	SELECT	
			dtmDate						= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NonInventoryCostCharges.intInventoryReceiptChargeId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= NonInventoryCostCharges.strTransactionId
			,intTransactionId			= NonInventoryCostCharges.intTransactionId
			,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END  
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
			,strRateType				= NonInventoryCostCharges.strRateType
	FROM	NonInventoryCostCharges INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
			CROSS APPLY dbo.fnGetDebitFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
			CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign


	WHERE	ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 0 -- @COST_BILLED_BY_None 
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0
			AND ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 0

	UNION ALL 
	SELECT	
			dtmDate						= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NonInventoryCostCharges.intInventoryReceiptChargeId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= NonInventoryCostCharges.strTransactionId
			,intTransactionId			= NonInventoryCostCharges.intTransactionId
			,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END  
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
			,strRateType				= NonInventoryCostCharges.strRateType
	FROM	NonInventoryCostCharges INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome
			CROSS APPLY dbo.fnGetDebitFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
			CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign

	WHERE	ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 0 -- @COST_BILLED_BY_None 
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0
			AND ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 0

	-------------------------------------------------------------------------------------------
	-- Accrue Other Charge to Vendor 
	-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
	-- 
	-- Dr...... Freight Expense 
	-- Cr.................... AP Clearing	
	-------------------------------------------------------------------------------------------
	UNION ALL 
	SELECT	
			dtmDate						= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NonInventoryCostCharges.intInventoryReceiptChargeId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= NonInventoryCostCharges.strTransactionId
			,intTransactionId			= NonInventoryCostCharges.intTransactionId
			,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END  
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
			,strRateType				= NonInventoryCostCharges.strRateType
	FROM	NonInventoryCostCharges INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
			CROSS APPLY dbo.fnGetDebitFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
			CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
	WHERE	ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 1
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0

	UNION ALL 
	SELECT	
			dtmDate						= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NonInventoryCostCharges.intInventoryReceiptChargeId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= NonInventoryCostCharges.strTransactionId
			,intTransactionId			= NonInventoryCostCharges.intTransactionId
			,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END  
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
			,strRateType				= NonInventoryCostCharges.strRateType
	FROM	NonInventoryCostCharges INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing 
			CROSS APPLY dbo.fnGetDebitFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
			CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign

	WHERE	ISNULL(NonInventoryCostCharges.ysnAccrue, 0) = 1
			AND ISNULL(NonInventoryCostCharges.ysnInventoryCost, 0) = 0

	-------------------------------------------------------------------------------------------
	-- Price Down 
	-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
	-- 
	-- Dr...... AP Clearing
	-- Cr.................... Freight Expense 
	-------------------------------------------------------------------------------------------
	UNION ALL 
	SELECT	
			dtmDate						= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NonInventoryCostCharges.intInventoryReceiptChargeId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= NonInventoryCostCharges.strTransactionId
			,intTransactionId			= NonInventoryCostCharges.intTransactionId
			,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END 
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END  
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
			,strRateType				= NonInventoryCostCharges.strRateType
	FROM	NonInventoryCostCharges INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing 
			CROSS APPLY dbo.fnGetDebitFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
			CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign
	WHERE	ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 1

	UNION ALL 
	SELECT	
			dtmDate						= NonInventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', Charges from ' + NonInventoryCostCharges.strCharge 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= NonInventoryCostCharges.intCurrencyId
			,dblExchangeRate			= NonInventoryCostCharges.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= NonInventoryCostCharges.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= NonInventoryCostCharges.intInventoryReceiptChargeId
			,ysnIsUnposted				= 1
			,intUserId					= NULL 
			,intEntityId				= @intEntityUserSecurityId 
			,strTransactionId			= NonInventoryCostCharges.strTransactionId
			,intTransactionId			= NonInventoryCostCharges.intTransactionId
			,strTransactionType			= NonInventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= NonInventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN CreditForeign.Value ELSE 0 END  
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN DebitForeign.Value ELSE 0 END 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= NonInventoryCostCharges.dblForexRate 
			,strRateType				= NonInventoryCostCharges.strRateType
	FROM	NonInventoryCostCharges INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON NonInventoryCostCharges.intChargeId = OtherChargesGLAccounts.intChargeId
				AND NonInventoryCostCharges.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
			CROSS APPLY dbo.fnGetDebitFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Debit
			CROSS APPLY dbo.fnGetCreditFunctional(
				NonInventoryCostCharges.dblCost
				,NonInventoryCostCharges.intCurrencyId
				,@intFunctionalCurrencyId
				,NonInventoryCostCharges.dblForexRate
			) Credit
			CROSS APPLY dbo.fnGetDebit(NonInventoryCostCharges.dblCost) DebitForeign
			CROSS APPLY dbo.fnGetCredit(NonInventoryCostCharges.dblCost) CreditForeign

	WHERE	ISNULL(NonInventoryCostCharges.ysnPrice, 0) = 1	

	SELECT	[dtmDate] 
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
	FROM	@ChargesGLEntries
END

-- Exit point
_Exit: