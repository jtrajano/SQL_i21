CREATE PROCEDURE [dbo].[uspICUnpostInventoryReceiptOtherCharges]
	@intInventoryReceiptId AS INT 
	,@strBatchId AS NVARCHAR(20)
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
		-- 'Unable to unpost the Inventory Receipt. The {Other Charge} was billed.'
		RAISERROR('Unable to unpost the Inventory Receipt. The %s was billed.', 11, 1, @strItemNo) 	
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
			RAISERROR('%s is missing a GL account setup for %s account category.', 11, 1, @strItemNo, @ACCOUNT_CATEGORY_Inventory) 	
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
			RAISERROR('%s is missing a GL account setup for %s account category.', 11, 1, @strItemNo, @ACCOUNT_CATEGORY_APClearing) 	
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
			RAISERROR('%s is missing a GL account setup for %s account category.', 11, 1, @strItemNo, @ACCOUNT_CATEGORY_OtherChargeExpense) 	
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
			RAISERROR('%s is missing a GL account setup for %s account category.', 11, 1, @strItemNo, @ACCOUNT_CATEGORY_OtherChargeIncome) 	
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
		,ysnAccrue
		,ysnPrice
		,ysnInventoryCost
		,dblForexRate
		,strRateType
		,strItemNo 
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
							THEN -AllocatedOtherCharges.dblAmount 
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
				,Charge.strItemNo
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				INNER JOIN dbo.tblICInventoryReceiptItemAllocatedCharge AllocatedOtherCharges
					ON AllocatedOtherCharges.intInventoryReceiptId = Receipt.intInventoryReceiptId
					AND AllocatedOtherCharges.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
				INNER JOIN dbo.tblICInventoryReceiptCharge ReceiptCharges
					ON ReceiptCharges.intInventoryReceiptChargeId = AllocatedOtherCharges.intInventoryReceiptChargeId
				INNER JOIN tblICItem Charge
					ON Charge.intItemId = ReceiptCharges.intChargeId
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
				
	)

	-------------------------------------------------------------------------------------------
	-- Cost billed by: None
	-- Add cost to inventory: Yes
	-- 
	-- Dr...... Freight Income 
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
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
			,ysnIsUnposted				= 1
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
	FROM	ForGLEntries_CTE  
			INNER JOIN @ItemGLAccounts ItemGLAccounts
				ON ForGLEntries_CTE.intItemId = ItemGLAccounts.intItemId
				AND ForGLEntries_CTE.intItemLocationId = ItemGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = ItemGLAccounts.intContraInventoryId -- AP Clearing 
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
			AND ISNULL(ForGLEntries_CTE.ysnInventoryCost, 0) = 1

	UNION ALL 
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
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
			,ysnIsUnposted				= 1
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
	FROM	ForGLEntries_CTE INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome
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
			AND ISNULL(ForGLEntries_CTE.ysnInventoryCost, 0) = 1

	-------------------------------------------------------------------------------------------
	-- Cost billed by: None
	-- Add cost to inventory: No
	-- 
	-- Dr...... Freight Income 
	-- Cr..................... Freight Expense
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
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblExchangeRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
			,ysnIsUnposted				= 1
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
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
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
	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 0 -- @COST_BILLED_BY_None
			AND ISNULL(ForGLEntries_CTE.ysnInventoryCost, 0) = 0
			AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 0

	UNION ALL 
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
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
			,ysnIsUnposted				= 1
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
	FROM	ForGLEntries_CTE INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome
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
	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 0 -- @COST_BILLED_BY_None
			AND ISNULL(ForGLEntries_CTE.ysnInventoryCost, 0) = 0
			AND ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 0

	-------------------------------------------------------------------------------------------
	-- Accrue Other Charge to Vendor 
	-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
	-- 
	-- Dr...... Freight Expense 
	-- Cr.................... AP Clearing	
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
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
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
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
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
	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1

	UNION ALL 
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
			,dblExchangeRate			= ForGLEntries_CTE.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
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
	FROM	ForGLEntries_CTE INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing 
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

	WHERE	ISNULL(ForGLEntries_CTE.ysnAccrue, 0) = 1

	-------------------------------------------------------------------------------------------
	-- Price Down 
	-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
	-- 
	-- Dr...... AP Clearing
	-- Cr.................... Freight Expense 
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
			,strDescription				= ISNULL(GLAccount.strDescription, '') + ', ' + ForGLEntries_CTE.strItemNo 
			,strCode					= @strCode
			,strReference				= '' 
			,intCurrencyId				= ForGLEntries_CTE.intCurrencyId
			,dblExchangeRate			= ForGLEntries_CTE.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
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
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intAPClearing 
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
	WHERE	ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 1

	UNION ALL 
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
			,dblExchangeRate			= ForGLEntries_CTE.dblForexRate
			,dtmDateEntered				= GETDATE()
			,dtmTransactionDate			= ForGLEntries_CTE.dtmDate
			,strJournalLineDescription  = '' 
			,intJournalLineNo			= ForGLEntries_CTE.intInventoryReceiptItemId
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
	FROM	ForGLEntries_CTE INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts
				ON ForGLEntries_CTE.intChargeId = OtherChargesGLAccounts.intChargeId
				AND ForGLEntries_CTE.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
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

	WHERE	ISNULL(ForGLEntries_CTE.ysnPrice, 0) = 1	
END

-- Exit point
_Exit: