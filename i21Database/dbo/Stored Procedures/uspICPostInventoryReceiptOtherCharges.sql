CREATE PROCEDURE [dbo].[uspICPostInventoryReceiptOtherCharges]
	@intInventoryReceiptId AS INT 
	,@strBatchId AS NVARCHAR(20)
	,@intUserId AS INT
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
END 
	
-- Calculate the other charges. 
BEGIN 
	-- Calculate the other charges. 
	EXEC dbo.uspICCalculateInventoryReceiptOtherCharges
		@intInventoryReceiptId
END 

-- Calculate the surcharges
BEGIN 
	EXEC dbo.uspICCalculateInventoryReceiptSurchargeOnOtherCharges
		@intInventoryReceiptId
END

-- Allocate the other charges and surcharges. 
BEGIN 
	EXEC dbo.uspICAllocateInventoryReceiptOtherCharges 
		@intInventoryReceiptId
END 

-- Create the G/L Entries
BEGIN 
	-- Create the variables used by fnGetItemGLAccount
	DECLARE @ACCOUNT_CATEGORY_Inventory AS NVARCHAR(30) = 'Inventory'
			,@ACCOUNT_CATEGORY_APClearing AS NVARCHAR(30) = 'AP Clearing'
			,@ACCOUNT_CATEGORY_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense'
			,@ACCOUNT_CATEGORY_OtherChargeIncome AS NVARCHAR(30) = 'Other Charge Income'
			,@ACCOUNT_CATEGORY_OtherChargeAsset AS NVARCHAR(30) = 'Other Charge (Asset)'

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
			) Query

	-- Get the GL Account ids to use for the other charges. 
	DECLARE @OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount; 
	INSERT INTO @OtherChargesGLAccounts (
		intChargeId 
		,intItemLocationId 
		,intOtherChargeExpense 
		,intOtherChargeIncome 
		,intOtherChargeAsset 
		,intTransactionTypeId
	)
	SELECT	Query.intChargeId
			,Query.intItemLocationId
			,intOtherChargeExpense = dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeExpense) 
			,intOtherChargeIncome = dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeIncome) 
			,intOtherChargeAsset = dbo.fnGetItemGLAccount(Query.intChargeId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeAsset) 
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
			RAISERROR(51041, 11, 1, @strItemNo, @ACCOUNT_CATEGORY_Inventory) 	
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
			RAISERROR(51041, 11, 1, @strItemNo, @ACCOUNT_CATEGORY_APClearing) 	
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
			RAISERROR(51041, 11, 1, @strItemNo, @ACCOUNT_CATEGORY_OtherChargeExpense) 	
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
			RAISERROR(51041, 11, 1, @strItemNo, @ACCOUNT_CATEGORY_OtherChargeIncome) 	
			RETURN;
		END 
	END 
	;

	-- Check for missing Other Charge Asset 
	BEGIN 
		SET @strItemNo = NULL
		SET @intItemId = NULL

		SELECT	TOP 1 
				@intItemId = Item.intItemId 
				,@strItemNo = Item.strItemNo
		FROM	dbo.tblICItem Item INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts
					ON Item.intItemId = ChargesGLAccounts.intChargeId
		WHERE	ChargesGLAccounts.intOtherChargeAsset IS NULL 			
			
		IF @intItemId IS NOT NULL 
		BEGIN 
			-- {Item} is missing a GL account setup for {Account Category} account category.
			RAISERROR(51041, 11, 1, @strItemNo, @ACCOUNT_CATEGORY_OtherChargeAsset) 	
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
		,intInventoryReceiptItemId
		,strInventoryTransactionTypeName
		,strTransactionForm
		,strCostBilledBy
		,ysnInventoryCost
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
				,dblCost = AllocatedOtherCharges.dblAmount
				,intTransactionTypeId  = @intTransactionTypeId
				,Receipt.intCurrencyId
				,dblExchangeRate = 1
				,ReceiptItem.intInventoryReceiptItemId
				,strInventoryTransactionTypeName = TransType.strName
				,strTransactionForm = @strTransactionForm
				,AllocatedOtherCharges.strCostBilledBy
				,AllocatedOtherCharges.ysnInventoryCost
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				INNER JOIN dbo.tblICInventoryReceiptItemAllocatedCharge AllocatedOtherCharges
					ON AllocatedOtherCharges.intInventoryReceiptId = Receipt.intInventoryReceiptId
					AND AllocatedOtherCharges.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
				INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharges
					ON ReceiptCharges.intInventoryReceiptChargeId = AllocatedOtherCharges.intInventoryReceiptChargeId
				LEFT JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = ReceiptItem.intItemId
					AND ItemLocation.intLocationId = Receipt.intLocationId
				LEFT JOIN dbo.tblICItemLocation ChargeItemLocation
					ON ChargeItemLocation.intItemId = ReceiptCharges.intChargeId
					AND ChargeItemLocation.intLocationId = Receipt.intLocationId
				LEFT JOIN dbo.tblICInventoryTransactionType TransType
					ON TransType.intTransactionTypeId = @intTransactionTypeId
		WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
				
	)
	---------------------------------------------------------------------------------------------
	---- Cost billed by: Vendor
	---- Add cost to inventory: Yes
	---- 
	---- Dr...... Inventory
	---- Cr..................... AP Clearing
	---------------------------------------------------------------------------------------------
	--SELECT	
	--		dtmDate						= ForGLEntries_CTE.dtmDate
	--		,strBatchId					= @strBatchId
	--		,intAccountId				= GLAccount.intAccountId
	--		,dblDebit					= Debit.Value
	--		,dblCredit					= Credit.Value
	--		,dblDebitUnit				= 0
	--		,dblCreditUnit				= 0
	--		,strDescription				= GLAccount.strDescription
	--		,strCode					= @strCode
	--		,strReference				= '' 
	--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	--		,dtmDateEntered				= GETDATE()
	--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
	--		,strJournalLineDescription  = '' 
	--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
	--		,ysnIsUnposted				= 0
	--		,intUserId					= @intUserId 
	--		,intEntityId				= @intUserId 
	--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
	--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
	--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
	--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
	--		,strModuleName				= @ModuleName
	--		,intConcurrencyId			= 1
	--FROM	ForGLEntries_CTE  
	--		INNER JOIN @ItemGLAccounts ItemGLAccounts
	--			ON ForGLEntries_CTE.intItemId = ItemGLAccounts.intItemId
	--			AND ForGLEntries_CTE.intItemLocationId = ItemGLAccounts.intItemLocationId
	--		INNER JOIN dbo.tblGLAccount GLAccount
	--			ON GLAccount.intAccountId = ItemGLAccounts.intInventoryId
	--		CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
	--		CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	--WHERE	ForGLEntries_CTE.strCostBilledBy = @COST_BILLED_BY_Vendor
	--		AND ForGLEntries_CTE.ysnInventoryCost = 1

	--UNION ALL 
	--SELECT	
	--		dtmDate						= ForGLEntries_CTE.dtmDate
	--		,strBatchId					= @strBatchId
	--		,intAccountId				= GLAccount.intAccountId
	--		,dblDebit					= Credit.Value
	--		,dblCredit					= Debit.Value
	--		,dblDebitUnit				= 0
	--		,dblCreditUnit				= 0
	--		,strDescription				= GLAccount.strDescription
	--		,strCode					= @strCode
	--		,strReference				= '' 
	--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	--		,dtmDateEntered				= GETDATE()
	--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
	--		,strJournalLineDescription  = '' 
	--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
	--		,ysnIsUnposted				= 0
	--		,intUserId					= @intUserId 
	--		,intEntityId				= @intUserId 
	--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
	--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
	--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
	--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
	--		,strModuleName				= @ModuleName
	--		,intConcurrencyId			= 1
	--FROM	ForGLEntries_CTE INNER JOIN @ItemGLAccounts ItemGLAccounts
	--			ON ForGLEntries_CTE.intItemId = ItemGLAccounts.intItemId
	--			AND ForGLEntries_CTE.intItemLocationId = ItemGLAccounts.intItemLocationId
	--		INNER JOIN dbo.tblGLAccount GLAccount
	--			ON GLAccount.intAccountId = ItemGLAccounts.intContraInventoryId
	--		CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
	--		CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	--WHERE	ForGLEntries_CTE.strCostBilledBy = @COST_BILLED_BY_Vendor
	--		AND ForGLEntries_CTE.ysnInventoryCost = 1

	---------------------------------------------------------------------------------------------
	---- Cost billed by: Third Party
	---- Add cost to inventory: Yes
	---- 
	---- Dr...... Inventory
	---- Cr..................... AP Clearing
	---------------------------------------------------------------------------------------------
	--UNION ALL 
	--SELECT	
	--		dtmDate						= ForGLEntries_CTE.dtmDate
	--		,strBatchId					= @strBatchId
	--		,intAccountId				= GLAccount.intAccountId
	--		,dblDebit					= Debit.Value
	--		,dblCredit					= Credit.Value
	--		,dblDebitUnit				= 0
	--		,dblCreditUnit				= 0
	--		,strDescription				= GLAccount.strDescription
	--		,strCode					= @strCode
	--		,strReference				= '' 
	--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	--		,dtmDateEntered				= GETDATE()
	--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
	--		,strJournalLineDescription  = '' 
	--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
	--		,ysnIsUnposted				= 0
	--		,intUserId					= @intUserId 
	--		,intEntityId				= @intUserId 
	--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
	--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
	--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
	--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
	--		,strModuleName				= @ModuleName
	--		,intConcurrencyId			= 1
	--FROM	ForGLEntries_CTE  
	--		INNER JOIN @ItemGLAccounts ItemGLAccounts
	--			ON ForGLEntries_CTE.intItemId = ItemGLAccounts.intItemId
	--			AND ForGLEntries_CTE.intItemLocationId = ItemGLAccounts.intItemLocationId
	--		INNER JOIN dbo.tblGLAccount GLAccount
	--			ON GLAccount.intAccountId = ItemGLAccounts.intInventoryId
	--		CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
	--		CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	--WHERE	ForGLEntries_CTE.strCostBilledBy = @COST_BILLED_BY_ThirdParty
	--		AND ForGLEntries_CTE.ysnInventoryCost = 1

	--UNION ALL 
	--SELECT	
	--		dtmDate						= ForGLEntries_CTE.dtmDate
	--		,strBatchId					= @strBatchId
	--		,intAccountId				= GLAccount.intAccountId
	--		,dblDebit					= Credit.Value
	--		,dblCredit					= Debit.Value
	--		,dblDebitUnit				= 0
	--		,dblCreditUnit				= 0
	--		,strDescription				= GLAccount.strDescription
	--		,strCode					= @strCode
	--		,strReference				= '' 
	--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	--		,dtmDateEntered				= GETDATE()
	--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
	--		,strJournalLineDescription  = '' 
	--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
	--		,ysnIsUnposted				= 0
	--		,intUserId					= @intUserId 
	--		,intEntityId				= @intUserId 
	--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
	--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
	--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
	--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
	--		,strModuleName				= @ModuleName
	--		,intConcurrencyId			= 1
	--FROM	ForGLEntries_CTE INNER JOIN @ItemGLAccounts ItemGLAccounts
	--			ON ForGLEntries_CTE.intItemId = ItemGLAccounts.intItemId
	--			AND ForGLEntries_CTE.intItemLocationId = ItemGLAccounts.intItemLocationId
	--		INNER JOIN dbo.tblGLAccount GLAccount
	--			ON GLAccount.intAccountId = ItemGLAccounts.intContraInventoryId
	--		CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
	--		CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	--WHERE	ForGLEntries_CTE.strCostBilledBy = @COST_BILLED_BY_ThirdParty
	--		AND ForGLEntries_CTE.ysnInventoryCost = 1

	---------------------------------------------------------------------------------------------
	---- Cost billed by: None
	---- Add cost to inventory: Yes
	---- 
	---- Dr...... Inventory
	---- Cr..................... Freight Income 
	---------------------------------------------------------------------------------------------
	--UNION ALL 
	--SELECT	
	--		dtmDate						= ForGLEntries_CTE.dtmDate
	--		,strBatchId					= @strBatchId
	--		,intAccountId				= GLAccount.intAccountId
	--		,dblDebit					= Debit.Value
	--		,dblCredit					= Credit.Value
	--		,dblDebitUnit				= 0
	--		,dblCreditUnit				= 0
	--		,strDescription				= GLAccount.strDescription
	--		,strCode					= @strCode
	--		,strReference				= '' 
	--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	--		,dtmDateEntered				= GETDATE()
	--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
	--		,strJournalLineDescription  = '' 
	--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
	--		,ysnIsUnposted				= 0
	--		,intUserId					= @intUserId 
	--		,intEntityId				= @intUserId 
	--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
	--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
	--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
	--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
	--		,strModuleName				= @ModuleName
	--		,intConcurrencyId			= 1
	--FROM	ForGLEntries_CTE  
	--		INNER JOIN @ItemGLAccounts ItemGLAccounts
	--			ON ForGLEntries_CTE.intItemId = ItemGLAccounts.intItemId
	--			AND ForGLEntries_CTE.intItemLocationId = ItemGLAccounts.intItemLocationId
	--		INNER JOIN dbo.tblGLAccount GLAccount
	--			ON GLAccount.intAccountId = ItemGLAccounts.intInventoryId
	--		CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
	--		CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	--WHERE	ForGLEntries_CTE.strCostBilledBy = @COST_BILLED_BY_None
	--		AND ForGLEntries_CTE.ysnInventoryCost = 1

	--UNION ALL 
	--SELECT	
	--		dtmDate						= ForGLEntries_CTE.dtmDate
	--		,strBatchId					= @strBatchId
	--		,intAccountId				= GLAccount.intAccountId
	--		,dblDebit					= Credit.Value
	--		,dblCredit					= Debit.Value
	--		,dblDebitUnit				= 0
	--		,dblCreditUnit				= 0
	--		,strDescription				= GLAccount.strDescription
	--		,strCode					= @strCode
	--		,strReference				= '' 
	--		,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
	--		,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
	--		,dtmDateEntered				= GETDATE()
	--		,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
	--		,strJournalLineDescription  = '' 
	--		,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
	--		,ysnIsUnposted				= 0
	--		,intUserId					= @intUserId 
	--		,intEntityId				= @intUserId 
	--		,strTransactionId			= ForGLEntries_CTE.strTransactionId
	--		,intTransactionId			= ForGLEntries_CTE.intTransactionId
	--		,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
	--		,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
	--		,strModuleName				= @ModuleName
	--		,intConcurrencyId			= 1
	--FROM	ForGLEntries_CTE INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
	--			ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
	--			AND ForGLEntries_CTE.intItemLocationId = OtherChargesGLAccounts.intItemLocationId
	--		INNER JOIN dbo.tblGLAccount GLAccount
	--			ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome
	--		CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
	--		CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	--WHERE	ForGLEntries_CTE.strCostBilledBy = @COST_BILLED_BY_None
	--		AND ForGLEntries_CTE.ysnInventoryCost = 1

	-------------------------------------------------------------------------------------------
	-- Cost billed by: None
	-- Add cost to inventory: No
	-- 
	-- Dr...... Freight Expense
	-- Cr..................... Freight Income 
	-------------------------------------------------------------------------------------------
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
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
			,ysnIsUnposted				= 0
			,intUserId					= @intUserId 
			,intEntityId				= @intUserId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
	FROM	ForGLEntries_CTE INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	WHERE	ForGLEntries_CTE.strCostBilledBy = @COST_BILLED_BY_None
			AND ForGLEntries_CTE.ysnInventoryCost = 0

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
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
			,ysnIsUnposted				= 0
			,intUserId					= @intUserId 
			,intEntityId				= @intUserId 
			,strTransactionId			= ForGLEntries_CTE.strTransactionId
			,intTransactionId			= ForGLEntries_CTE.intTransactionId
			,strTransactionType			= ForGLEntries_CTE.strInventoryTransactionTypeName
			,strTransactionForm			= ForGLEntries_CTE.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
	FROM	ForGLEntries_CTE INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome
			CROSS APPLY dbo.fnGetDebit(ForGLEntries_CTE.dblCost) Debit
			CROSS APPLY dbo.fnGetCredit(ForGLEntries_CTE.dblCost) Credit
	WHERE	ForGLEntries_CTE.strCostBilledBy = @COST_BILLED_BY_None
			AND ForGLEntries_CTE.ysnInventoryCost = 0
END

-- Exit point
_Exit: