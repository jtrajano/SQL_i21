﻿CREATE PROCEDURE [dbo].[uspICPostInventoryReceiptOtherCharges]
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
			,@strTransactionId AS NVARCHAR(50)
END 

-- Validate 
BEGIN 
	-- Check for invalid location for the Other Charge item. 
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intItemId = Item.intItemId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge OtherCharge
				ON Receipt.intInventoryReceiptId = OtherCharge.intInventoryReceiptId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = OtherCharge.intChargeId
			LEFT JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intLocationId = Receipt.intLocationId
				AND ItemLocation.intItemId = Item.intItemId
	WHERE	ItemLocation.intItemLocationId IS NULL 
			AND Receipt.intInventoryReceiptId = @intInventoryReceiptId

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- 'Item Location is invalid or missing for {Item}.'
		RAISERROR(50028, 11, 1, @strItemNo)
		GOTO _Exit
	END 
END 

-- Validate 
BEGIN 
	-- Check for invalid location for the Receipt Item. 
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intItemId = Item.intItemId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = ReceiptItem.intItemId 
			LEFT JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intLocationId = Receipt.intLocationId
				AND ItemLocation.intItemId = Item.intItemId
	WHERE	ItemLocation.intItemLocationId IS NULL 
			AND Receipt.intInventoryReceiptId = @intInventoryReceiptId

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- 'Item Location is invalid or missing for {Item}.'
		RAISERROR(80002, 11, 1, @strItemNo)
		GOTO _Exit
	END 
END 
	
-- Validate 
BEGIN 
	-- Price cannot be checked if Accrue is checked for Receipt vendor.
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intItemId = Item.intItemId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge OtherCharge
				ON Receipt.intInventoryReceiptId = OtherCharge.intInventoryReceiptId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = OtherCharge.intChargeId
	WHERE	OtherCharge.ysnAccrue = 1
			AND OtherCharge.ysnPrice = 1
			AND OtherCharge.ysnInventoryCost = 1
			AND ISNULL(OtherCharge.intEntityVendorId, Receipt.intEntityVendorId) = Receipt.intEntityVendorId
			AND Receipt.intInventoryReceiptId = @intInventoryReceiptId

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- The {Other Charge} is both a payable and deductible to the bill of the same vendor. Please correct the Accrue or Price checkbox.
		RAISERROR(80064, 11, 1, @strItemNo)
		GOTO _Exit
	END 
END 

-- Validate 
BEGIN 
	-- Price cannot be checked if Accrue is checked for Receipt vendor.
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intItemId = Item.intItemId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge OtherCharge
				ON Receipt.intInventoryReceiptId = OtherCharge.intInventoryReceiptId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = OtherCharge.intChargeId
	WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
			AND (
				-- Do not allow if third party or receipt vendor is going to pay the other charge and cost is passed-on to the item cost. 
				(
					OtherCharge.ysnPrice = 1
					AND OtherCharge.ysnInventoryCost = 1
				)
			)			
			
	IF @intItemId IS NOT NULL 
	BEGIN 
		-- The {Other Charge} is shouldered by the receipt vendor and can''t be added to the item cost. Please correct the Price or Inventory Cost checkbox.
		RAISERROR(80065, 11, 1, @strItemNo)
		GOTO _Exit
	END 
END 

/*
	Check if the transaction is using a foreign currency and it has a missing forex rate. 
*/
SELECT @strItemNo = NULL
		, @intItemId = NULL 
		, @strTransactionId = NULL 

SELECT TOP 1 
		@strTransactionId = Receipt.strReceiptNumber
		,@strItemNo = Item.strItemNo
		,@intItemId = Item.intItemId
FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge OtherCharge
			ON Receipt.intInventoryReceiptId = OtherCharge.intInventoryReceiptId	
		INNER JOIN tblICItem Item
			ON Item.intItemId = OtherCharge.intChargeId
WHERE	ISNULL(OtherCharge.dblForexRate, 0) = 0 
		AND OtherCharge.intCurrencyId IS NOT NULL 
		AND OtherCharge.intCurrencyId <> dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 

IF @intItemId IS NOT NULL 
BEGIN 
	-- '{Transaction Id} is using a foreign currency. Please check if {Item No} has a forex rate.'
	RAISERROR(80162, 11, 1, @strTransactionId, @strItemNo)
	RETURN -1
END 

-- Calculate the other charges. 
BEGIN
	EXEC dbo.uspICCalculateOtherCharges
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

	-------------------------------------------------------------------------------------------
	-- Cost billed by: None
	-- Add cost to inventory: Yes
	-- 
	-- Dr...... A/P Clearing 
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
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription
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
	-- Dr...... Freight Expense
	-- Cr..................... Freight Income 
	-------------------------------------------------------------------------------------------
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
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
			,dblDebitUnit				= 0
			,dblCreditUnit				= 0
			,strDescription				= GLAccount.strDescription
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

END

-- Exit point
_Exit: