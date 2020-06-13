CREATE PROCEDURE [dbo].[uspICPostInventoryReceiptOtherCharges]
	@intInventoryReceiptId AS INT 
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@intTransactionTypeId AS INT 
	,@ysnPost AS BIT = 1 	
	,@intRebuildItemId AS INT = NULL -- Used when rebuilding the stocks. 
AS

-- Constant Variables
BEGIN 
	DECLARE @COST_BILLED_BY_Vendor AS NVARCHAR(50) = 'Vendor'
			,@COST_BILLED_BY_ThirdParty AS NVARCHAR(50) = 'Third Party'
			,@COST_BILLED_BY_None AS NVARCHAR(50) = 'None'

	-- Variables used in the validations. 
	DECLARE @strItemNo AS NVARCHAR(50)
			,@intChargeItemId AS INT 
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
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intChargeItemId = Item.intItemId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge OtherCharge
				ON Receipt.intInventoryReceiptId = OtherCharge.intInventoryReceiptId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = OtherCharge.intChargeId
			LEFT JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intLocationId = Receipt.intLocationId
				AND ItemLocation.intItemId = Item.intItemId
	WHERE	ItemLocation.intItemLocationId IS NULL 
			AND Receipt.intInventoryReceiptId = @intInventoryReceiptId

	IF @intChargeItemId IS NOT NULL 
	BEGIN 
		-- 'Item Location is invalid or missing for {Item}.'
		EXEC uspICRaiseError 80002, @strItemNo;
		GOTO _Exit
	END 
END 

-- Validate 
BEGIN 
	-- Check for invalid location for the Receipt Item. 
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intChargeItemId = Item.intItemId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = ReceiptItem.intItemId 
			LEFT JOIN dbo.tblICItemLocation ItemLocation
				ON ItemLocation.intLocationId = Receipt.intLocationId
				AND ItemLocation.intItemId = Item.intItemId
	WHERE	ItemLocation.intItemLocationId IS NULL 
			AND Receipt.intInventoryReceiptId = @intInventoryReceiptId
			AND ReceiptItem.intItemId = ISNULL(@intRebuildItemId, ReceiptItem.intItemId)

	IF @intChargeItemId IS NOT NULL 
	BEGIN 
		-- 'Item Location is invalid or missing for {Item}.'
		EXEC uspICRaiseError 80002, @strItemNo;
		GOTO _Exit
	END 
END 
	
-- Validate 
BEGIN 
	-- Price cannot be checked if Accrue is checked for Receipt vendor.
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intChargeItemId = Item.intItemId
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge OtherCharge
				ON Receipt.intInventoryReceiptId = OtherCharge.intInventoryReceiptId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = OtherCharge.intChargeId
	WHERE	OtherCharge.ysnAccrue = 1
			AND OtherCharge.ysnPrice = 1
			AND OtherCharge.ysnInventoryCost = 1
			AND ISNULL(OtherCharge.intEntityVendorId, Receipt.intEntityVendorId) = Receipt.intEntityVendorId
			AND Receipt.intInventoryReceiptId = @intInventoryReceiptId

	IF @intChargeItemId IS NOT NULL 
	BEGIN 
		-- The {Other Charge} is both a payable and deductible to the bill of the same vendor. Please correct the Accrue or Price checkbox.
		EXEC uspICRaiseError 80064, @strItemNo;
		GOTO _Exit
	END 
END 

-- Validate 
BEGIN 
	-- Price cannot be checked if Accrue is checked for Receipt vendor.
	SELECT TOP 1 
			@strItemNo = CASE WHEN ISNULL(Item.strItemNo, '') = '' THEN '(Item id: ' + CAST(Item.intItemId AS NVARCHAR(10)) + ')' ELSE Item.strItemNo END 
			,@intChargeItemId = Item.intItemId
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
					AND ISNULL(Item.strCostType, '') <> 'Discount' 
				)
			)			
			
	IF @intChargeItemId IS NOT NULL 
	BEGIN 
		-- The {Other Charge} is shouldered by the receipt vendor and can''t be added to the item cost. Please correct the Price or Inventory Cost checkbox.
		EXEC uspICRaiseError 80065, @strItemNo;
		GOTO _Exit
	END 
END 

-- Validate
BEGIN 
	-- Check if the transaction is using a foreign currency and it has a missing forex rate. 
	SELECT @strItemNo = NULL
			,@intChargeItemId = NULL 
			,@strTransactionId = NULL 
			,@strCurrencyId = NULL 
			,@strFunctionalCurrencyId = NULL 

	SELECT TOP 1 
			@strTransactionId = Receipt.strReceiptNumber
			,@strItemNo = Item.strItemNo
			,@intChargeItemId = Item.intItemId
			,@strCurrencyId = c.strCurrency
			,@strFunctionalCurrencyId = fc.strCurrency
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge OtherCharge
				ON Receipt.intInventoryReceiptId = OtherCharge.intInventoryReceiptId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = OtherCharge.intChargeId
			LEFT JOIN tblSMCurrency c
				ON c.intCurrencyID =  OtherCharge.intCurrencyId
			LEFT JOIN tblSMCurrency fc
				ON fc.intCurrencyID =  @intFunctionalCurrencyId
	WHERE	ISNULL(OtherCharge.dblForexRate, 0) = 0 
			AND OtherCharge.intCurrencyId IS NOT NULL 
			AND OtherCharge.intCurrencyId <> @intFunctionalCurrencyId
			AND Receipt.intInventoryReceiptId = @intInventoryReceiptId
			AND OtherCharge.intCurrencyId NOT IN (SELECT intCurrencyID FROM tblSMCurrency WHERE ysnSubCurrency = 1 AND intMainCurrencyId = @intFunctionalCurrencyId)

	IF @intChargeItemId IS NOT NULL 
	BEGIN 
		-- '{Transaction Id} is using a foreign currency. Please check if {Other Charge} has a forex rate. You may also need to review the Currency Exchange Rates and check if there is a valid forex rate from {Foreign Currency} to {Functional Currency}.'	
		EXEC uspICRaiseError 80162, @strTransactionId, @strItemNo, @strCurrencyId, @strFunctionalCurrencyId
		RETURN -1
	END 
END 

-- Validate
BEGIN 
	-- Check if Other charge is a price down. If yes, then Receipt currency and Other Charge currency must be the same. 
	SELECT @strItemNo = NULL
			,@intChargeItemId = NULL 
			,@strTransactionId = NULL 
			,@strCurrencyId = NULL 
			,@strFunctionalCurrencyId = NULL 

	SELECT TOP 1 
			@strTransactionId = Receipt.strReceiptNumber
			,@strItemNo = Item.strItemNo
			,@intChargeItemId = Item.intItemId
			,@strCurrencyId = cc.strCurrency
			,@strFunctionalCurrencyId = rc.strCurrency
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge OtherCharge
				ON Receipt.intInventoryReceiptId = OtherCharge.intInventoryReceiptId	
			INNER JOIN tblICItem Item
				ON Item.intItemId = OtherCharge.intChargeId
			LEFT JOIN tblSMCurrency cc
				ON cc.intCurrencyID =  OtherCharge.intCurrencyId
			LEFT JOIN tblSMCurrency rc
				ON rc.intCurrencyID =  Receipt.intCurrencyId
	WHERE	ISNULL(OtherCharge.ysnPrice, 0) = 1 
			AND OtherCharge.intCurrencyId IS NOT NULL 
			AND OtherCharge.intCurrencyId <> Receipt.intCurrencyId
			AND Receipt.intInventoryReceiptId = @intInventoryReceiptId

	IF @intChargeItemId IS NOT NULL 
	BEGIN 
		-- '{Other Charge} is using {Other Charge currency}. Price down is only allowed for {Receipt Currency} currency. Please change the currency or uncheck the Price Down.'
		EXEC uspICRaiseError 80191, @strItemNo, @strCurrencyId, @strFunctionalCurrencyId
		RETURN -1
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
						INNER JOIN tblICItem Item 
							ON Item.intItemId = ReceiptItem.intItemId
						INNER JOIN tblICInventoryReceiptItemAllocatedCharge AllocatedCharges
							ON  AllocatedCharges.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND AllocatedCharges.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
						LEFT JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = ReceiptItem.intItemId
							AND ItemLocation.intLocationId = Receipt.intLocationId
				WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
						AND ReceiptItem.intItemId = 
								CASE WHEN @intRebuildItemId < 0 THEN ReceiptItem.intItemId
									 ELSE ISNULL(@intRebuildItemId, ReceiptItem.intItemId)
								END 
						AND ISNULL(ReceiptItem.intOwnershipType, 0) = 1 -- Only "Own" items will have GL entries. 
						AND AllocatedCharges.ysnInventoryCost = 1 -- And allocated charge is part of the item cost. 						
						AND ISNULL(Item.strBundleType,'') != 'Kit' -- Don't include 'Kit' items
			) Query
	
	-- Get Other Expense & AP Clearing Account if item is a 'Kit' type
	UNION ALL
	SELECT	Query.intItemId
			,Query.intItemLocationId
			,intInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeExpense) 
			,intContraInventoryId = dbo.fnGetItemGLAccount(Query.intItemId, Query.intItemLocationId, @ACCOUNT_CATEGORY_APClearing) 
			,intTransactionTypeId = @intTransactionTypeId
	FROM	(
				SELECT	DISTINCT 
						ReceiptItem.intItemId
						,ItemLocation.intItemLocationId
				FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
							ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
						INNER JOIN tblICItem Item 
							ON Item.intItemId = ReceiptItem.intItemId
						INNER JOIN tblICInventoryReceiptItemAllocatedCharge AllocatedCharges
							ON  AllocatedCharges.intInventoryReceiptId = Receipt.intInventoryReceiptId
							AND AllocatedCharges.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
						LEFT JOIN dbo.tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = ReceiptItem.intItemId
							AND ItemLocation.intLocationId = Receipt.intLocationId
				WHERE	Receipt.intInventoryReceiptId = @intInventoryReceiptId
						AND ReceiptItem.intItemId = 
								CASE WHEN @intRebuildItemId < 0 THEN ReceiptItem.intItemId
									 ELSE ISNULL(@intRebuildItemId, ReceiptItem.intItemId)
								END 
						AND ISNULL(ReceiptItem.intOwnershipType, 0) = 1 -- Only "Own" items will have GL entries. 
						AND AllocatedCharges.ysnInventoryCost = 1 -- And allocated charge is part of the item cost. 						
						AND Item.strBundleType = 'Kit' -- Include 'Kit' items						
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
				FROM	tblICInventoryReceipt Receipt INNER JOIN tblICInventoryReceiptCharge OtherCharges 
							ON Receipt.intInventoryReceiptId = OtherCharges.intInventoryReceiptId
						LEFT JOIN tblICItemLocation ItemLocation
							ON ItemLocation.intItemId = OtherCharges.intChargeId
							AND ItemLocation.intLocationId = Receipt.intLocationId
				WHERE	OtherCharges.intInventoryReceiptId = @intInventoryReceiptId
			) Query

	-- -- Check for missing AP Clearing Account Id
	-- BEGIN 
	-- 	SET @strItemNo = NULL
	-- 	SET @intChargeItemId = NULL

	-- 	SELECT	TOP 1 
	-- 			@intChargeItemId = Item.intItemId 
	-- 			,@strItemNo = Item.strItemNo
	-- 	FROM	tblICItem Item INNER JOIN @ItemGLAccounts ItemGLAccount
	-- 				ON Item.intItemId = ItemGLAccount.intItemId
	-- 	WHERE	ItemGLAccount.intContraInventoryId IS NULL 

	-- 	SELECT	TOP 1 
	-- 			@strLocationName = c.strLocationName
	-- 	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
	-- 				ON il.intLocationId = c.intCompanyLocationId
	-- 			INNER JOIN @ItemGLAccounts ItemGLAccount
	-- 				ON ItemGLAccount.intItemId = il.intItemId
	-- 				AND ItemGLAccount.intItemLocationId = il.intItemLocationId
	-- 	WHERE	il.intItemId = @intChargeItemId
	-- 			AND ItemGLAccount.intContraInventoryId IS NULL 				 			

	-- 	IF @intChargeItemId IS NOT NULL 
	-- 	BEGIN 
	-- 		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
	-- 		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_APClearing;
	-- 		RETURN;
	-- 	END 
	-- END 
	-- ;

	-- Check Other Expense Account if Charged item is Inventory Cost = true and Linked item is a Kit item
	BEGIN
		SET @strItemNo = NULL;
		SET @intChargeItemId = NULL;

		SELECT	TOP 1 
				@intChargeItemId = Item.intItemId 
				,@strItemNo = Item.strItemNo
				,@strLocationName = c.strLocationName
		FROM	tblICItem Item INNER JOIN @ItemGLAccounts ItemGLAccount
					ON Item.intItemId = ItemGLAccount.intItemId
				INNER JOIN (tblICItemLocation il INNER JOIN tblSMCompanyLocation c ON il.intLocationId = c.intCompanyLocationId)
					ON il.intItemLocationId = ItemGLAccount.intItemLocationId
		WHERE	ItemGLAccount.intInventoryId IS NULL 
				AND Item.strType = 'Bundle'

 		IF @intChargeItemId IS NOT NULL 
	 	BEGIN 
	 		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
	 		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_OtherChargeExpense;
	 		RETURN;
	 	END 
	END

	-- Check AP Clearing Account if Charged item is Inventory Cost = true and Linked item is a Kit item
	BEGIN
		SET @strItemNo = NULL;
		SET @intChargeItemId = NULL;

		SELECT	TOP 1 
				@intChargeItemId = Item.intItemId 
				,@strItemNo = Item.strItemNo
				,@strLocationName = c.strLocationName
		FROM	tblICItem Item INNER JOIN @ItemGLAccounts ItemGLAccount
					ON Item.intItemId = ItemGLAccount.intItemId
				INNER JOIN (tblICItemLocation il INNER JOIN tblSMCompanyLocation c ON il.intLocationId = c.intCompanyLocationId)
					ON il.intItemLocationId = ItemGLAccount.intItemLocationId
		WHERE	ItemGLAccount.intContraInventoryId IS NULL 
				AND Item.strType = 'Bundle'

 		IF @intChargeItemId IS NOT NULL 
	 	BEGIN 
	 		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
	 		EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_APClearing;
	 		RETURN;
	 	END 
	END

	-- Check for missing Inventory Account Id
	BEGIN 
		SET @strItemNo = NULL
		SET @intChargeItemId = NULL

		SELECT	TOP 1 
				@intChargeItemId = Item.intItemId 
				,@strItemNo = Item.strItemNo
		FROM	tblICItem Item INNER JOIN @ItemGLAccounts ItemGLAccount
					ON Item.intItemId = ItemGLAccount.intItemId
		WHERE	ItemGLAccount.intInventoryId IS NULL 

		SELECT	TOP 1 
				@strLocationName = c.strLocationName
		FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
					ON il.intLocationId = c.intCompanyLocationId
				INNER JOIN @ItemGLAccounts ItemGLAccount
					ON ItemGLAccount.intItemId = il.intItemId
					AND ItemGLAccount.intItemLocationId = il.intItemLocationId
		WHERE	il.intItemId = --ISNULL(@intRebuildItemId, ItemGLAccount.intItemId)
					CASE 
						WHEN @intRebuildItemId < 0 THEN ItemGLAccount.intItemId
						ELSE ISNULL(@intRebuildItemId, ItemGLAccount.intItemId)
					END 

				AND ItemGLAccount.intContraInventoryId IS NULL 				 			

		IF @intChargeItemId IS NOT NULL 
		BEGIN 
			-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_Inventory;
			RETURN;
		END 
	END 
	;	

	-- Check for missing Other Charge Expense 
	BEGIN 
		SET @strItemNo = NULL
		SET @intChargeItemId = NULL

		SELECT	TOP 1 
				@intChargeItemId = Item.intItemId 
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
		WHERE	il.intItemId = @intChargeItemId
				AND ChargesGLAccounts.intOtherChargeExpense IS NULL 	
			
		IF @intChargeItemId IS NOT NULL 
		BEGIN 
			-- {Other Charge} in {Location} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_OtherChargeExpense;				
			RETURN;
		END 
	END 
	;

	-- Check for missing Other Charge Income 
	BEGIN 
		SET @strItemNo = NULL
		SET @intChargeItemId = NULL

		SELECT	TOP 1 
				@intChargeItemId = Item.intItemId 
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
		WHERE	il.intItemId = @intChargeItemId
				AND ChargesGLAccounts.intOtherChargeIncome IS NULL 	
			
		IF @intChargeItemId IS NOT NULL 
		BEGIN 
			-- {Other Charge} in {Location} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_OtherChargeIncome;
			RETURN;
		END 
	END 
	;

	-- Check for missing AP Clearing on Other Charge item. 
	BEGIN 
		SET @strItemNo = NULL
		SET @intChargeItemId = NULL

		SELECT	TOP 1 
				@intChargeItemId = Item.intItemId 
				,@strItemNo = Item.strItemNo
		FROM	dbo.tblICItem Item INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts
					ON Item.intItemId = ChargesGLAccounts.intChargeId
		WHERE	ChargesGLAccounts.intAPClearing IS NULL

		SELECT	TOP 1 
				@strLocationName = c.strLocationName
		FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
					ON il.intLocationId = c.intCompanyLocationId
				INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts
					ON ChargesGLAccounts.intChargeId = il.intItemId
					AND ChargesGLAccounts.intItemLocationId = il.intItemLocationId
		WHERE	il.intItemId = @intChargeItemId
				AND ChargesGLAccounts.intAPClearing IS NULL 
			
		IF @intChargeItemId IS NOT NULL 
		BEGIN 
			-- {Other Charge} in {Location} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008, @strItemNo, @strLocationName, @ACCOUNT_CATEGORY_APClearing;
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
		,intInventoryReceiptChargeId
		,strInventoryTransactionTypeName
		,strTransactionForm
		,ysnAccrue
		,ysnPrice
		,ysnInventoryCost
		,dblForexRate
		,strRateType
		,strCharge
		,strItem
		,strBundleType
		,intEntityVendorId
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
				,AllocatedOtherCharges.intInventoryReceiptChargeId
				,strInventoryTransactionTypeName = TransType.strName
				,strTransactionForm = @strTransactionForm
				,AllocatedOtherCharges.ysnAccrue
				,AllocatedOtherCharges.ysnPrice
				,AllocatedOtherCharges.ysnInventoryCost
				,dblForexRate = ISNULL(ReceiptCharges.dblForexRate, 1) 
				,strRateType = currencyRateType.strCurrencyExchangeRateType
				,strCharge = Charge.strItemNo
				,strItem = Item.strItemNo
				,strBundleType = ISNULL(Item.strBundleType,'')
				,intEntityVendorId = ReceiptCharges.intEntityVendorId 
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
				AND ReceiptItem.intItemId = --ISNULL(@intRebuildItemId, ReceiptItem.intItemId)
						CASE 
							WHEN @intRebuildItemId < 0 THEN ReceiptItem.intItemId
							ELSE ISNULL(@intRebuildItemId, ReceiptItem.intItemId)
						END						
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
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
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
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= InventoryCostCharges.intEntityVendorId
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
			AND InventoryCostCharges.strBundleType != 'Kit'

	UNION ALL 
	SELECT	
			dtmDate						= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Credit.Value
			,dblCredit					= Debit.Value
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
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= InventoryCostCharges.intEntityVendorId
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
			AND InventoryCostCharges.strBundleType != 'Kit'

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
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
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
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= InventoryCostCharges.intEntityVendorId
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
			AND InventoryCostCharges.strBundleType != 'Kit'
	UNION ALL 
	SELECT	
			dtmDate						= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= SUM(Credit.Value)
			,dblCredit					= SUM(Debit.Value)
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
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptChargeId--InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= InventoryCostCharges.intEntityVendorId
			,strTransactionId			= InventoryCostCharges.strTransactionId
			,intTransactionId			= InventoryCostCharges.intTransactionId
			,strTransactionType			= InventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= InventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN SUM(CreditForeign.Value) ELSE 0 END  
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN SUM(DebitForeign.Value) ELSE 0 END 
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
			AND InventoryCostCharges.strBundleType != 'Kit'	
	GROUP BY	InventoryCostCharges.dtmDate,
				GLAccount.intAccountId,
				InventoryCostCharges.strCharge,
				GLAccount.strDescription,
				InventoryCostCharges.intCurrencyId,
				InventoryCostCharges.dblForexRate,
				InventoryCostCharges.intEntityVendorId,
				InventoryCostCharges.intInventoryReceiptChargeId,
				InventoryCostCharges.strTransactionId,
				InventoryCostCharges.intTransactionId,
				InventoryCostCharges.strInventoryTransactionTypeName,
				InventoryCostCharges.strTransactionForm,
				InventoryCostCharges.strRateType

	-------------------------------------------------------------------------------------------
	-- If linked item is a 'Kit' and Inventory Cost = true
	-- It applies to both the Receipt/Return vendor and 3rd party vendor. 
	-- 
	-- Dr...... Item's Other Charge Expense
	-- Cr.................... Item's AP Clearing	
	-------------------------------------------------------------------------------------------
	UNION ALL 
	SELECT	
			dtmDate						= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= Debit.Value
			,dblCredit					= Credit.Value
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
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= InventoryCostCharges.intEntityVendorId
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
			AND InventoryCostCharges.strBundleType = 'Kit'	
	UNION ALL 
	SELECT	
			dtmDate						= InventoryCostCharges.dtmDate
			,strBatchId					= @strBatchId
			,intAccountId				= GLAccount.intAccountId
			,dblDebit					= SUM(Credit.Value)
			,dblCredit					= SUM(Debit.Value)
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
			,intJournalLineNo			= InventoryCostCharges.intInventoryReceiptChargeId--InventoryCostCharges.intInventoryReceiptItemId
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= InventoryCostCharges.intEntityVendorId
			,strTransactionId			= InventoryCostCharges.strTransactionId
			,intTransactionId			= InventoryCostCharges.intTransactionId
			,strTransactionType			= InventoryCostCharges.strInventoryTransactionTypeName
			,strTransactionForm			= InventoryCostCharges.strTransactionForm
			,strModuleName				= @ModuleName
			,intConcurrencyId			= 1
			,dblDebitForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN SUM(CreditForeign.Value) ELSE 0 END  
			,dblDebitReport				= NULL 
			,dblCreditForeign			= CASE WHEN intCurrencyId <> @intFunctionalCurrencyId THEN SUM(DebitForeign.Value) ELSE 0 END 
			,dblCreditReport			= NULL 
			,dblReportingRate			= NULL 
			,dblForeignRate				= InventoryCostCharges.dblForexRate 
			,strRateType				= InventoryCostCharges.strRateType
	FROM	InventoryCostCharges INNER JOIN @ItemGLAccounts ItemGLAccounts
				ON InventoryCostCharges.intItemId = ItemGLAccounts.intItemId
				AND InventoryCostCharges.intItemLocationId = ItemGLAccounts.intItemLocationId
			INNER JOIN dbo.tblGLAccount GLAccount
				ON GLAccount.intAccountId = ItemGLAccounts.intContraInventoryId 
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
			AND InventoryCostCharges.strBundleType = 'Kit'	
	GROUP BY	InventoryCostCharges.dtmDate,
				GLAccount.intAccountId,
				InventoryCostCharges.strCharge,
				GLAccount.strDescription,
				InventoryCostCharges.intCurrencyId,
				InventoryCostCharges.dblForexRate,
				InventoryCostCharges.intEntityVendorId,
				InventoryCostCharges.intInventoryReceiptChargeId,
				InventoryCostCharges.strTransactionId,
				InventoryCostCharges.intTransactionId,
				InventoryCostCharges.strInventoryTransactionTypeName,
				InventoryCostCharges.strTransactionForm,
				InventoryCostCharges.strRateType

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
		,intEntityVendorId
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
				,intEntityVendorId = ReceiptCharges.intEntityVendorId
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
				AND @intRebuildItemId IS NULL 				
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
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= NonInventoryCostCharges.intEntityVendorId
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
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= NonInventoryCostCharges.intEntityVendorId
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
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= NonInventoryCostCharges.intEntityVendorId
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
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= NonInventoryCostCharges.intEntityVendorId
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
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= NonInventoryCostCharges.intEntityVendorId
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
			,ysnIsUnposted				= 0
			,intUserId					= @intEntityUserSecurityId 
			,intEntityId				= NonInventoryCostCharges.intEntityVendorId
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
			,[dblDebit] = CASE WHEN @ysnPost = 1 THEN [dblDebit] ELSE [dblCredit] END 
			,[dblCredit] = CASE WHEN @ysnPost = 1 THEN [dblCredit] ELSE [dblDebit] END 
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
			,[ysnIsUnposted] = CAST(CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END AS BIT) 
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign] = CASE WHEN @ysnPost = 1 THEN [dblDebitForeign] ELSE [dblCreditForeign] END 
			,[dblDebitReport] 
			,[dblCreditForeign]	= CASE WHEN @ysnPost = 1 THEN [dblCreditForeign] ELSE [dblDebitForeign] END 	
			,[dblCreditReport]	
			,[dblReportingRate]	
			,[dblForeignRate]
			,[strRateType]
	FROM	@ChargesGLEntries
END

-- Exit point
_Exit: