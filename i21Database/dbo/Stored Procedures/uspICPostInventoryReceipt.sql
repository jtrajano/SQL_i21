CREATE PROCEDURE uspICPostInventoryReceipt  
	@ysnPost BIT  = 0  
	,@ysnRecap BIT  = 0  
	,@strTransactionId NVARCHAR(40) = NULL   
	,@intEntityUserSecurityId AS INT = NULL 
	,@strBatchId NVARCHAR(40) = NULL OUTPUT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------    
-- Create a unique transaction name. 
DECLARE @TransactionName AS VARCHAR(500) = 'Inventory Receipt Transaction' + CAST(NEWID() AS NVARCHAR(100));

-- Constants  
DECLARE @INVENTORY_RECEIPT_TYPE AS INT = 4
		,@STARTING_NUMBER_BATCH AS INT = 3  
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'AP Clearing'
		,@TRANSFER_ORDER_ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory In-Transit'
		
		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

		-- Receipt Types
		,@RECEIPT_TYPE_PURCHASE_CONTRACT AS NVARCHAR(50) = 'Purchase Contract'
		,@RECEIPT_TYPE_PURCHASE_ORDER AS NVARCHAR(50) = 'Purchase Order'
		,@RECEIPT_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
		,@RECEIPT_TYPE_DIRECT AS NVARCHAR(50) = 'Direct'

-- Posting variables
DECLARE @strItemNo AS NVARCHAR(50)
		,@intItemId AS INT
		,@ysnAllowBlankGLEntries AS BIT = 1
		,@strCurrencyId AS NVARCHAR(50)
		,@strFunctionalCurrencyId AS NVARCHAR(50)

-- Get the default currency ID
DECLARE @intFunctionalCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType 

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)  
 
-- Create the type of lot numbers
DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

DECLARE @intReturnValue AS INT 

-- Read the transaction info   
BEGIN   
	DECLARE @dtmDate AS DATETIME   
			,@intTransactionId AS INT  
			,@intCreatedEntityId AS INT  
			,@ysnAllowUserSelfPost AS BIT   
			,@ysnTransactionPostedFlag AS BIT  
			,@receiptType AS NVARCHAR(50) 
			,@intTransferorId AS INT
			,@intLocationId AS INT 
  
	SELECT TOP 1   
			@intTransactionId = intInventoryReceiptId  
			,@ysnTransactionPostedFlag = ysnPosted  
			,@dtmDate = dtmReceiptDate  
			,@intCreatedEntityId = intEntityId  
			,@receiptType = strReceiptType
			,@intTransferorId = intTransferorId
			,@intLocationId = intLocationId
	FROM	dbo.tblICInventoryReceipt   
	WHERE	strReceiptNumber = @strTransactionId  
END  
  
--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
BEGIN 
	DECLARE @strBillNumber AS NVARCHAR(50)
	DECLARE @strChargeItem AS NVARCHAR(50)


	-- Validate if the Inventory Receipt exists   
	IF @intTransactionId IS NULL  
	BEGIN   
		-- Cannot find the transaction.  
		RAISERROR(50004, 11, 1)  
		GOTO Post_Exit  
	END   
  
	-- Validate the date against the FY Periods  
	IF @ysnRecap = 0 AND EXISTS (SELECT 1 WHERE dbo.isOpenAccountingDate(@dtmDate) = 0) 
	BEGIN   
		-- Unable to find an open fiscal year period to match the transaction date.  
		RAISERROR(50005, 11, 1)  
		GOTO Post_Exit  
	END  
  
	-- Check if the transaction is already posted  
	IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1  
	BEGIN   
		-- The transaction is already posted.  
		RAISERROR(50007, 11, 1)  
		GOTO Post_Exit  
	END   
  
	-- Check if the transaction is already posted  
	IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
	BEGIN   
		-- The transaction is already unposted.  
		RAISERROR(50008, 11, 1)  
		GOTO Post_Exit  
	END   

	-- Check Company preference: Allow User Self Post  
	IF	dbo.fnIsAllowUserSelfPost(@intEntityUserSecurityId) = 1 
		AND @intEntityUserSecurityId <> @intCreatedEntityId 
		AND @ysnRecap = 0   
	BEGIN   
		-- 'You cannot %s transactions you did not create. Please contact your local administrator.'  
		IF @ysnPost = 1   
		BEGIN   
			RAISERROR(50013, 11, 1, 'Post')  
			GOTO Post_Exit  
		END   

		IF @ysnPost = 0  
		BEGIN  
			RAISERROR(50013, 11, 1, 'Unpost')  
			GOTO Post_Exit    
		END  
	END   

	-- Do not allow unpost if Bill has been created for the inventory receipt
	IF @ysnPost = 0 AND @ysnRecap = 0 
	BEGIN 

		SELECT	TOP 1 
				@strBillNumber = Bill.strBillId
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				LEFT JOIN dbo.tblAPBillDetail BillItems
					ON BillItems.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
				INNER JOIN dbo.tblAPBill Bill
					ON Bill.intBillId = BillItems.intBillId
		WHERE	Receipt.intInventoryReceiptId = @intTransactionId
				AND BillItems.intBillDetailId IS NOT NULL

		IF ISNULL(@strBillNumber, '') <> ''
		BEGIN 
			-- 'Unable to Unreceive. The inventory receipt is already billed in {Bill Id}.'
			RAISERROR(80056, 11, 1, @strBillNumber)  
			GOTO Post_Exit    
		END 

	END 

	-- Do not allow unpost if other charge is already billed. 
	IF @ysnPost = 0 AND @ysnRecap = 0 
	BEGIN 
		SET @strBillNumber = NULL 
		SELECT	TOP 1 
				@strBillNumber = Bill.strBillId
				,@strChargeItem = Item.strItemNo
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptCharge Charge
					ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = Charge.intChargeId				
				LEFT JOIN dbo.tblAPBillDetail BillItems
					ON BillItems.intInventoryReceiptChargeId = Charge.intInventoryReceiptChargeId
				INNER JOIN dbo.tblAPBill Bill
					ON Bill.intBillId = BillItems.intBillId
		WHERE	Receipt.intInventoryReceiptId = @intTransactionId
				AND BillItems.intBillDetailId IS NOT NULL

		IF ISNULL(@strBillNumber, '') <> ''
		BEGIN 
			-- 'Unable to unpost. Charge {Other Charge Id} has a voucher in {Voucher Id}.'
			RAISERROR(80099, 11, 1, @strChargeItem, @strBillNumber)  
			GOTO Post_Exit    
		END 

	END 

	-- Do not allow post if there is Gross/Net UOM and net qty is zero. 
	IF @ysnPost = 1 AND @ysnRecap = 0 
	BEGIN 
		SET @intItemId = NULL 
		SET @strItemNo = NULL 

		SELECT	TOP 1 
				@intItemId = Item.intItemId
				,@strItemNo = Item.strItemNo
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId				
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = ReceiptItem.intItemId
		WHERE	Receipt.intInventoryReceiptId = @intTransactionId
				AND ReceiptItem.intWeightUOMId IS NOT NULL 
				AND ISNULL(ReceiptItem.dblNet, 0) = 0 

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- 'The net quantity for item {Item Name} is missing.'
			RAISERROR(80082, 11, 1, @strItemNo)  
			GOTO Post_Exit    
		END 
	END 

	-- Do not allow post if no lot entry in a lotted item
	SET @strItemNo = NULL
	SELECT TOP 1 @strItemNo = item.strItemNo
	FROM tblICInventoryReceipt receipt
		INNER JOIN tblICInventoryReceiptItem receiptItem ON receiptItem.intInventoryReceiptId = receipt.intInventoryReceiptId
		INNER JOIN tblICItem item ON item.intItemId = receiptItem.intItemId
		LEFT JOIN tblICInventoryReceiptItemLot itemLot ON itemLot.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
	WHERE dbo.fnGetItemLotType(item.intItemId) <> 0
		AND itemLot.intInventoryReceiptItemLotId IS NULL
		AND receipt.intInventoryReceiptId = @intTransactionId

	IF @strItemNo IS NOT NULL
	BEGIN
		-- 'Lotted item {Item No} should should have lot(s) specified.'
		RAISERROR(80090, 11, 1, @strItemNo)  
		GOTO Post_Exit  
	END

	-- Do not allow unpost if it has an Inventory Return transaction 
	IF @ysnPost = 0 AND @ysnRecap = 0 
	BEGIN 
		DECLARE @strReturnId AS NVARCHAR(50) 

		SELECT	TOP 1 
				@strReturnId = strReceiptNumber
		FROM	tblICInventoryReceipt r
		WHERE	r.intSourceInventoryReceiptId = @intTransactionId 

		IF @strReturnId IS NOT NULL 
		BEGIN 
			-- Unable to unpost the Inventory Receipt. It has an Inventory Return in {return id}.
			RAISERROR(80112, 11, 1, @strReturnId)  
			GOTO Post_Exit  
		END 
	END 

	-- Check if the transaction is using a foreign currency and it has a missing forex rate. 
	BEGIN 		
		SELECT @strItemNo = NULL
				,@intItemId = NULL 
				,@strCurrencyId = NULL 
				,@strFunctionalCurrencyId = NULL 

		SELECT TOP 1 
				@strTransactionId = Receipt.strReceiptNumber 
				,@strItemNo = Item.strItemNo
				,@intItemId = Item.intItemId
				,@strCurrencyId = c.strCurrency
				,@strFunctionalCurrencyId = fc.strCurrency
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId				
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = ReceiptItem.intItemId
				LEFT JOIN tblSMCurrency c
					ON c.intCurrencyID =  Receipt.intCurrencyId
				LEFT JOIN tblSMCurrency fc
					ON fc.intCurrencyID = @intFunctionalCurrencyId
		WHERE	Receipt.intInventoryReceiptId = @intTransactionId
				AND ISNULL(ReceiptItem.dblForexRate, 0) = 0 
				AND Receipt.intCurrencyId IS NOT NULL 
				AND Receipt.intCurrencyId <> @intFunctionalCurrencyId

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- '{Transaction Id} is using a foreign currency. Please check if {Item No} has a forex rate. You may also need to review the Currency Exchange Rates and check if there is a valid forex rate from {Foreign Currency} to {Functional Currency}.'
			RAISERROR(80162, 11, 1, @strTransactionId, @strItemNo, @strCurrencyId, @strFunctionalCurrencyId)
			RETURN -1; 
		END 
	END 
END

-- Check if sub location and storage locations are valid. 
BEGIN
	DECLARE @ysnValidLocation BIT
	EXEC dbo.uspICValidateReceiptItemLocations @intTransactionId, @ysnValidLocation OUTPUT, @strItemNo OUTPUT 

	IF @ysnValidLocation = 0
	BEGIN 
		-- The sub location and storage location in {Item No} does not match.
		RAISERROR(80087, 11, 1, @strItemNo)  
		GOTO Post_Exit
	END 
END

-- Get the next batch number
BEGIN 
	SET @strBatchId = NULL 
	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT  
	IF @@ERROR <> 0 GOTO Post_Exit;
END

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

-- Create and validate the lot numbers
IF @ysnPost = 1
BEGIN 	
	DECLARE @intCreateUpdateLotError AS INT 

	EXEC @intCreateUpdateLotError = dbo.uspICCreateLotNumberOnInventoryReceipt 
			@strTransactionId
			,@intEntityUserSecurityId
			,@ysnPost

	IF @intCreateUpdateLotError <> 0
	BEGIN 
		ROLLBACK TRAN @TransactionName
		COMMIT TRAN @TransactionName
		GOTO Post_Exit;
	END
END

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1  
BEGIN  
	-- Get the items to post  
	DECLARE @ItemsForPost AS ItemCostingTableType  
	DECLARE @CompanyOwnedItemsForPost AS ItemCostingTableType  
	DECLARE @ReturnItemsForPost AS ItemCostingTableType  

	DECLARE @StorageItemsForPost AS ItemCostingTableType  

	-- Process the Other Charges
	BEGIN 
		INSERT INTO @GLEntries (
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
		EXEC @intReturnValue = dbo.uspICPostInventoryReceiptOtherCharges 
			@intTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INVENTORY_RECEIPT_TYPE

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
			
	END 

	-- Get company owned items to post. 
	BEGIN 
		INSERT INTO @ItemsForPost (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost  
				,dblSalesPrice  
				,intCurrencyId  
				,dblExchangeRate  
				,intTransactionId  
				,intTransactionDetailId   
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
				,strActualCostId
				,intInTransitSourceLocationId
				,intForexRateTypeId
				,dblForexRate
		)  
		SELECT	intItemId = DetailItem.intItemId  
				,intItemLocationId = ItemLocation.intItemLocationId
				,intItemUOMId = 
							-- New Hierarchy:
							-- 1. Use the Gross/Net UOM (intWeightUOMId) 
							-- 2. If there is no Gross/Net UOM, then check the lot. 
								-- 2.1. If it is a Lot, use the Lot UOM. 
								-- 2.2. If it is not a Lot, use the Item UOM. 
							ISNULL( 
								DetailItem.intWeightUOMId, 
								CASE	WHEN ISNULL(DetailItemLot.intLotId, 0) <> 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) <> 0 THEN 
											DetailItemLot.intItemUnitMeasureId
										ELSE 
											DetailItem.intUnitMeasureId
								END 
							)

				,dtmDate = Header.dtmReceiptDate  
				,dblQty =						
							-- New Hierarchy:
							-- 1. If there is a Gross/Net UOM, use the Net Qty. 
								-- 2.1. If it is not a Lot, use the item's Net Qty. 
								-- 2.2. If it is a Lot, use the Lot's Net Qty. 
							-- 2. If there is no Gross/Net UOM, use the item or lot qty. 
								-- 2.1. If it is not a Lot, use the item Qty. 
								-- 2.2. If it is a Lot, use the lot qty. 
							CASE		-- Use the Gross/Net Qty if there is a Gross/Net UOM. 
										WHEN DetailItem.intWeightUOMId IS NOT NULL THEN 									
											CASE	-- When item is NOT a Lot, receive it by the item's net qty. 
													WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 
														ISNULL(DetailItem.dblNet, 0)
													
													-- When item is a LOT, get the net qty from the Lot record. 
													-- 1. If Net Qty is not provided, convert the Lot Qty into Gross/Net UOM. 
													-- 2. Else, get the Net Qty by using this formula: Gross Weight - Tare Weight. 
													ELSE 
																-- When Net Qty is missing, then convert the Lot Qty to Gross/Net UOM. 
														CASE	WHEN  ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0) = 0 THEN 
																	dbo.fnCalculateQtyBetweenUOM(DetailItemLot.intItemUnitMeasureId, DetailItem.intWeightUOMId, DetailItemLot.dblQuantity)
																-- Calculate the Net Qty
																ELSE 
																	ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0)
														END 
											END 

									-- If Gross/Net UOM is missing, then get the item/lot qty. 
									ELSE 
										CASE	-- When item is NOT a Lot, receive it by the item qty.
												WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 
													DetailItem.dblOpenReceive
												
												-- When item is a LOT, receive it by the Lot Qty. 
												ELSE 
													ISNULL(DetailItemLot.dblQuantity, 0)
										END 								

							END 

				,dblUOMQty = 
							-- New Hierarchy:
							-- 1. Use the Gross/Net UOM (intWeightUOMId) 
							-- 2. If there is no Gross/Net UOM, then check the lot. 
								-- 2.1. If it is a Lot, use the Lot UOM. 
								-- 2.2. If it is not a Lot, use the Item UOM. 
							ISNULL( 
								WeightUOM.dblUnitQty, 
								CASE	WHEN ISNULL(DetailItemLot.intLotId, 0) <> 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) <> 0 THEN 
											LotItemUOM.dblUnitQty
										ELSE 
											ItemUOM.dblUnitQty
								END 
							)
							
				,dblCost =	
							-- New Hierarchy:
							-- 1. If there is a Gross/Net UOM, convert the cost from Cost UOM to Gross/Net UOM. 
							-- 2. If Gross/Net UOM is not specified, then: 
								-- 2.1. If it is not a Lot, convert the cost from Cost UOM to Receive UOM. 
								-- 2.2. If it is a Lot, convert the cost from Cost UOM to Lot UOM. 
							-- 3. If sub-currency exists, then convert it to sub-currency. 
							-- (A + B) / C 
							(
								-- (A) Item Cost
								CASE	
										WHEN DetailItem.intWeightUOMId IS NOT NULL THEN 
											-- Convert the Cost UOM to Gross/Net UOM. 

											CASE	-- When item is NOT a Lot, use the cost line item. 
													WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 

														dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItem.intWeightUOMId, DetailItem.dblUnitCost) 
													
													--------------------------------------------------------------------------------------------------------
													-- Cleaned weight scenario. 
													--------------------------------------------------------------------------------------------------------
													-- When item is a LOT, recalculate the cost. 
													-- Below is an example: 
													-- 1. Receive a stock at $1/LB. Net weight received is 100lb. So this means line total is $100. $1 x $100 = $100. 
													-- 2. Lot can be cleaned. So after a lot is cleaned, net weight on lot level is reduced to 80 lb. 
													-- 3. Value of the line total will still remain at $100. 
													-- 4. So this means, cost needs to be changed from $1/LB to $1.25/LB.
													-- 5. Receiving 80lbs @ $1.25/lb is $100. This will match the value of the line item with the lot item. 
													ELSE 
														dbo.fnDivide(
															dbo.fnMultiply(
																dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItem.intWeightUOMId, DetailItem.dblUnitCost) 
																, ISNULL(DetailItem.dblNet, 0)
															)
															,
															CASE	WHEN  ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0) = 0 THEN 
																		dbo.fnCalculateQtyBetweenUOM(DetailItemLot.intItemUnitMeasureId, DetailItem.intWeightUOMId, DetailItemLot.dblQuantity)
																	-- Calculate the Net Qty
																	ELSE 
																		ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0)
															END 
														)
											END 

										-- If Gross/Net UOM is missing, 
										ELSE 
												CASE	
														-- If non-lot, convert the cost Cost UOM to Receive UOM
														WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 
															-- Convert the Cost UOM to Item UOM. 
															dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItem.intUnitMeasureId, DetailItem.dblUnitCost) 
													
														-- If lot, convert the cost Cost UOM to Lot UOM
														ELSE 														
															dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItemLot.intItemUnitMeasureId, DetailItem.dblUnitCost) 
												END 

								END
								-- (B) Other Charge
								+ 
								CASE 
									WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
										-- Convert the other charge to the currency used by the detail item. 
										dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId) / DetailItem.dblForexRate
									ELSE 
										-- No conversion. Detail item is already in functional currency. 
										dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId)
								END 									

							)
							-- (C) then convert the cost to the sub-currency value. 
							/ 
							CASE	WHEN DetailItem.ysnSubCurrency = 1 THEN 
										CASE WHEN ISNULL(Header.intSubCurrencyCents, 1) <> 0 THEN ISNULL(Header.intSubCurrencyCents, 1) ELSE 1 END 
									ELSE 
										1
							END

				,dblSalesPrice = 0  
				,intCurrencyId = Header.intCurrencyId  
				,dblExchangeRate = ISNULL(DetailItem.dblForexRate, 1)   
				,intTransactionId = Header.intInventoryReceiptId  
				,intTransactionDetailId  = DetailItem.intInventoryReceiptItemId
				,strTransactionId = Header.strReceiptNumber  
				,intTransactionTypeId = @INVENTORY_RECEIPT_TYPE  
				,intLotId = DetailItemLot.intLotId 
				,intSubLocationId = ISNULL(DetailItemLot.intSubLocationId, DetailItem.intSubLocationId) 
				,intStorageLocationId = ISNULL(DetailItemLot.intStorageLocationId, DetailItem.intStorageLocationId)
				,strActualCostId = Header.strActualCostId
				,intInTransitSourceLocationId = InTransitSourceLocation.intItemLocationId
				,intForexRateTypeId = DetailItem.intForexRateTypeId
				,dblForexRate = DetailItem.dblForexRate
		FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICInventoryReceiptItem DetailItem 
					ON Header.intInventoryReceiptId = DetailItem.intInventoryReceiptId 
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intLocationId = Header.intLocationId 
					AND ItemLocation.intItemId = DetailItem.intItemId
				LEFT JOIN dbo.tblICInventoryReceiptItemLot DetailItemLot
					ON DetailItem.intInventoryReceiptItemId = DetailItemLot.intInventoryReceiptItemId
				LEFT JOIN dbo.tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = DetailItem.intUnitMeasureId
				LEFT JOIN dbo.tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = DetailItemLot.intItemUnitMeasureId
				LEFT JOIN dbo.tblICItemUOM WeightUOM
					ON WeightUOM.intItemUOMId = DetailItem.intWeightUOMId
				LEFT JOIN dbo.tblICItemUOM CostUOM
					ON CostUOM.intItemUOMId = DetailItem.intCostUOMId
				LEFT JOIN dbo.tblICItemLocation InTransitSourceLocation 
					ON InTransitSourceLocation.intItemId = DetailItem.intItemId 
					AND InTransitSourceLocation.intLocationId = Header.intTransferorId

		WHERE	Header.intInventoryReceiptId = @intTransactionId   
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own

		-- Update currency fields to functional currency. 
		BEGIN 
			UPDATE	itemCost
			SET		dblExchangeRate = 1
					,dblForexRate = 1
					,intCurrencyId = @intFunctionalCurrencyId
			FROM	@ItemsForPost itemCost
			WHERE	ISNULL(itemCost.intCurrencyId, @intFunctionalCurrencyId) = @intFunctionalCurrencyId 

			UPDATE	itemCost
			SET		dblCost = dbo.fnMultiply(dblCost, ISNULL(dblForexRate, 1)) 
					,dblSalesPrice = dbo.fnMultiply(dblSalesPrice, ISNULL(dblForexRate, 1)) 
					,dblValue = dbo.fnMultiply(dblValue, ISNULL(dblForexRate, 1)) 
			FROM	@ItemsForPost itemCost
			WHERE	itemCost.intCurrencyId <> @intFunctionalCurrencyId 
		END
		  
		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
		BEGIN 
			-- Gather the company owned items. 
			INSERT INTO @CompanyOwnedItemsForPost (
					intItemId  
					,intItemLocationId 
					,intItemUOMId  
					,dtmDate  
					,dblQty  
					,dblUOMQty  
					,dblCost  
					,dblSalesPrice  
					,intCurrencyId  
					,dblExchangeRate  
					,intTransactionId  
					,intTransactionDetailId   
					,strTransactionId  
					,intTransactionTypeId  
					,intLotId 
					,intSubLocationId
					,intStorageLocationId
					,strActualCostId
					,intInTransitSourceLocationId
					,intForexRateTypeId
					,dblForexRate
			)
			SELECT 
					intItemId  
					,intItemLocationId 
					,intItemUOMId  
					,dtmDate  
					,dblQty  
					,dblUOMQty  
					,dblCost  
					,dblSalesPrice  
					,intCurrencyId  
					,dblExchangeRate  
					,intTransactionId  
					,intTransactionDetailId   
					,strTransactionId  
					,intTransactionTypeId  
					,intLotId 
					,intSubLocationId
					,intStorageLocationId
					,strActualCostId
					,intInTransitSourceLocationId
					,intForexRateTypeId
					,dblForexRate
			FROM	@ItemsForPost
			WHERE	dblQty > 0 
			
			-- Call the post routine for posting the company owned items 
			IF EXISTS (SELECT TOP 1 1 FROM @CompanyOwnedItemsForPost)
			BEGIN 
				IF @receiptType = @RECEIPT_TYPE_TRANSFER_ORDER
				BEGIN 
					SET @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY = @TRANSFER_ORDER_ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				END

				INSERT INTO @GLEntries (
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
				EXEC	@intReturnValue = dbo.uspICPostCosting  
						@CompanyOwnedItemsForPost  
						,@strBatchId  
						,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
						,@intEntityUserSecurityId

				IF @intReturnValue < 0 GOTO With_Rollback_Exit
			END
		END
	END 

	-- Process Storage items 
	BEGIN 
		INSERT INTO @StorageItemsForPost (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost  
				,dblSalesPrice  
				,intCurrencyId  
				,dblExchangeRate  
				,intTransactionId  
				,intTransactionDetailId   
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
				,intInTransitSourceLocationId
				,intForexRateTypeId
				,dblForexRate
		)  
		SELECT	intItemId = DetailItem.intItemId  
				,intItemLocationId = ItemLocation.intItemLocationId
				,intItemUOMId = 
							-- New Hierarchy:
							-- 1. Use the Gross/Net UOM (intWeightUOMId) 
							-- 2. If there is no Gross/Net UOM, then check the lot. 
								-- 2.1. If it is a Lot, use the Lot UOM. 
								-- 2.2. If it is not a Lot, use the Item UOM. 
							ISNULL( 
								DetailItem.intWeightUOMId, 
								CASE	WHEN ISNULL(DetailItemLot.intLotId, 0) <> 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) <> 0 THEN 
											DetailItemLot.intItemUnitMeasureId
										ELSE 
											DetailItem.intUnitMeasureId
								END 
							)
				,dtmDate = Header.dtmReceiptDate  
				,dblQty =						
							-- New Hierarchy:
							-- 1. If there is a Gross/Net UOM, use the Net Qty. 
								-- 2.1. If it is not a Lot, use the item's Net Qty. 
								-- 2.2. If it is a Lot, use the Lot's Net Qty. 
							-- 2. If there is no Gross/Net UOM, use the item or lot qty. 
								-- 2.1. If it is not a Lot, use the item Qty. 
								-- 2.2. If it is a Lot, use the lot qty. 
							CASE		-- Use the Gross/Net Qty if there is a Gross/Net UOM. 
										WHEN DetailItem.intWeightUOMId IS NOT NULL THEN 									
											CASE	-- When item is NOT a Lot, receive it by the item's net qty. 
													WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 
														ISNULL(DetailItem.dblNet, 0)
													
													-- When item is a LOT, get the net qty from the Lot record. 
													-- 1. If Net Qty is not provided, convert the Lot Qty into Gross/Net UOM. 
													-- 2. Else, get the Net Qty by using this formula: Gross Weight - Tare Weight. 
													ELSE 
																-- When Net Qty is missing, then convert the Lot Qty to Gross/Net UOM. 
														CASE	WHEN  ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0) = 0 THEN 
																	dbo.fnCalculateQtyBetweenUOM(DetailItemLot.intItemUnitMeasureId, DetailItem.intWeightUOMId, DetailItemLot.dblQuantity)
																-- Calculate the Net Qty
																ELSE 
																	ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0)
														END 
											END 

									-- If Gross/Net UOM is missing, then get the item/lot qty. 
									ELSE 
										CASE	-- When item is NOT a Lot, receive it by the item qty.
												WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 
													DetailItem.dblOpenReceive
												
												-- When item is a LOT, receive it by the Lot Qty. 
												ELSE 
													ISNULL(DetailItemLot.dblQuantity, 0)
										END 								

							END 

				,dblUOMQty = 
							-- New Hierarchy:
							-- 1. Use the Gross/Net UOM (intWeightUOMId) 
							-- 2. If there is no Gross/Net UOM, then check the lot. 
								-- 2.1. If it is a Lot, use the Lot UOM. 
								-- 2.2. If it is not a Lot, use the Item UOM. 
							ISNULL( 
								WeightUOM.dblUnitQty, 
								CASE	WHEN ISNULL(DetailItemLot.intLotId, 0) <> 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) <> 0 THEN 
											LotItemUOM.dblUnitQty
										ELSE 
											ItemUOM.dblUnitQty
								END 
							)
							
				,dblCost =	
							-- New Hierarchy:
							-- 1. If there is a Gross/Net UOM, convert the cost from Cost UOM to Gross/Net UOM. 
							-- 2. If Gross/Net UOM is not specified, then: 
								-- 2.1. If it is not a Lot, convert the cost from Cost UOM to Receive UOM. 
								-- 2.2. If it is a Lot, convert the cost from Cost UOM to Lot UOM. 
							-- 3. If sub-currency exists, then convert it to sub-currency. 
							-- (A + B) / C 
							(
								-- (A) Item Cost
								CASE	
										WHEN DetailItem.intWeightUOMId IS NOT NULL THEN 
											-- Convert the Cost UOM to Gross/Net UOM. 

											CASE	-- When item is NOT a Lot, use the cost line item. 
													WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 

														dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItem.intWeightUOMId, DetailItem.dblUnitCost) 
													
													--------------------------------------------------------------------------------------------------------
													-- Cleaned weight scenario. 
													--------------------------------------------------------------------------------------------------------
													-- When item is a LOT, recalculate the cost. 
													-- Below is an example: 
													-- 1. Receive a stock at $1/LB. Net weight received is 100lb. So this means line total is $100. $1 x $100 = $100. 
													-- 2. Lot can be cleaned. So after a lot is cleaned, net weight on lot level is reduced to 80 lb. 
													-- 3. Value of the line total will still remain at $100. 
													-- 4. So this means, cost needs to be changed from $1/LB to $1.25/LB.
													-- 5. Receiving 80lbs @ $1.25/lb is $100. This will match the value of the line item with the lot item. 
													ELSE 
														dbo.fnDivide(
															dbo.fnMultiply(
																dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItem.intWeightUOMId, DetailItem.dblUnitCost) 
																, ISNULL(DetailItem.dblNet, 0)
															)
															,
															CASE	WHEN  ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0) = 0 THEN 
																		dbo.fnCalculateQtyBetweenUOM(DetailItemLot.intItemUnitMeasureId, DetailItem.intWeightUOMId, DetailItemLot.dblQuantity)
																	-- Calculate the Net Qty
																	ELSE 
																		ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0)
															END 
														)
											END 

										-- If Gross/Net UOM is missing, 
										ELSE 
												CASE	
														-- If non-lot, convert the cost Cost UOM to Receive UOM
														WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 
															-- Convert the Cost UOM to Item UOM. 
															dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItem.intUnitMeasureId, DetailItem.dblUnitCost) 
													
														-- If lot, convert the cost Cost UOM to Lot UOM
														ELSE 														
															dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItemLot.intItemUnitMeasureId, DetailItem.dblUnitCost) 
												END 

								END
								-- (B) Other Charge
								+ 
								CASE 
									WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
										-- Convert the other charge to the currency used by the detail item. 
										dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId) / DetailItem.dblForexRate
									ELSE 
										-- No conversion. Detail item is already in functional currency. 
										dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId)
								END 									

							)
							-- (C) then convert the cost to the sub-currency value. 
							/ 
							CASE	WHEN DetailItem.ysnSubCurrency = 1 THEN 
										CASE WHEN ISNULL(Header.intSubCurrencyCents, 1) <> 0 THEN ISNULL(Header.intSubCurrencyCents, 1) ELSE 1 END 
									ELSE 
										1
							END

				,dblSalesPrice = 0  
				,intCurrencyId = Header.intCurrencyId  
				,dblExchangeRate = 1  
				,intTransactionId = Header.intInventoryReceiptId  
				,intTransactionDetailId  = DetailItem.intInventoryReceiptItemId
				,strTransactionId = Header.strReceiptNumber  
				,intTransactionTypeId = @INVENTORY_RECEIPT_TYPE  
				,intLotId = DetailItemLot.intLotId 
				,intSubLocationId = ISNULL(DetailItemLot.intSubLocationId, DetailItem.intSubLocationId) 
				,intStorageLocationId = ISNULL(DetailItemLot.intStorageLocationId, DetailItem.intStorageLocationId)
				,intInTransitSourceLocationId = InTransitSourceLocation.intItemLocationId
				,intForexRateTypeId = DetailItem.intForexRateTypeId
				,dblForexRate = DetailItem.dblForexRate
		FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICInventoryReceiptItem DetailItem 
					ON Header.intInventoryReceiptId = DetailItem.intInventoryReceiptId 					
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intLocationId = Header.intLocationId 
					AND ItemLocation.intItemId = DetailItem.intItemId
				LEFT JOIN dbo.tblICInventoryReceiptItemLot DetailItemLot
					ON DetailItem.intInventoryReceiptItemId = DetailItemLot.intInventoryReceiptItemId
				LEFT JOIN dbo.tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = DetailItem.intUnitMeasureId
				LEFT JOIN dbo.tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = DetailItemLot.intItemUnitMeasureId
				LEFT JOIN dbo.tblICItemUOM WeightUOM
					ON WeightUOM.intItemUOMId = DetailItem.intWeightUOMId
				LEFT JOIN dbo.tblICItemLocation InTransitSourceLocation 
					ON InTransitSourceLocation.intItemId = DetailItem.intItemId 
					AND InTransitSourceLocation.intLocationId = Header.intTransferorId
		WHERE	Header.intInventoryReceiptId = @intTransactionId   
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_Own) <> @OWNERSHIP_TYPE_Own

		-- Update currency fields to functional currency. 
		BEGIN 
			UPDATE	storageCost
			SET		dblExchangeRate = 1
					,dblForexRate = 1
					,intCurrencyId = @intFunctionalCurrencyId
			FROM	@StorageItemsForPost storageCost
			WHERE	ISNULL(storageCost.intCurrencyId, @intFunctionalCurrencyId) = @intFunctionalCurrencyId 

			UPDATE	storageCost
			SET		dblCost = dbo.fnMultiply(dblCost, ISNULL(dblForexRate, 1)) 
					,dblSalesPrice = dbo.fnMultiply(dblSalesPrice, ISNULL(dblForexRate, 1)) 
					,dblValue = dbo.fnMultiply(dblValue, ISNULL(dblForexRate, 1)) 
			FROM	@StorageItemsForPost storageCost
			WHERE	storageCost.intCurrencyId <> @intFunctionalCurrencyId 
		END
  
		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @StorageItemsForPost) 
		BEGIN 
			EXEC @intReturnValue = dbo.uspICPostStorage
					@StorageItemsForPost  
					,@strBatchId  
					,@intEntityUserSecurityId

			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END
	END

	-- Process the Inventory Receipt Taxes
	BEGIN 
		INSERT INTO @GLEntries (
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
		EXEC dbo.uspICPostInventoryReceiptTaxes 
			@intTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INVENTORY_RECEIPT_TYPE
			
	END 

	
END   

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 0   
BEGIN   
	-- Call the unpost routine 
	BEGIN 
		-- Unpost the company owned stocks. 
		INSERT INTO @GLEntries (
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
		EXEC	@intReturnValue = dbo.uspICUnpostCosting
				@intTransactionId
				,@strTransactionId
				,@strBatchId
				,@intEntityUserSecurityId
				,@ysnRecap

		IF @intReturnValue < 0 GOTO With_Rollback_Exit

		-- Unpost storage stocks. 
		EXEC	@intReturnValue = dbo.uspICUnpostStorage
				@intTransactionId
				,@strTransactionId
				,@strBatchId
				,@intEntityUserSecurityId
				,@ysnRecap
		
		IF @intReturnValue < 0 GOTO With_Rollback_Exit
				
		-- Unpost the Other Charges
		BEGIN 
			INSERT INTO @GLEntries (
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
			EXEC @intReturnValue = dbo.uspICUnpostInventoryReceiptOtherCharges 
				@intTransactionId
				,@strBatchId
				,@intEntityUserSecurityId
				,@INVENTORY_RECEIPT_TYPE	
				
			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END

		-- Unpost the Receipt Taxes
		BEGIN 
			INSERT INTO @GLEntries (
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
			EXEC @intReturnValue = dbo.uspICUnpostInventoryReceiptTaxes 
				@intTransactionId
				,@strBatchId
				,@intEntityUserSecurityId
				,@INVENTORY_RECEIPT_TYPE	
						
			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END

		-- Reduce the Gross weight for the lots when unposting the receipt. 
		UPDATE dbo.tblICLot
		SET		dblGrossWeight = Lot.dblGrossWeight - ItemLot.dblGrossWeight
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem 
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				INNER JOIN dbo.tblICInventoryReceiptItemLot ItemLot
					ON ItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
				INNER JOIN dbo.tblICLot Lot 
					ON Lot.intLotId = ItemLot.intLotId
		WHERE	Receipt.intInventoryReceiptId = @intTransactionId
				AND Receipt.strReceiptNumber = @strTransactionId				
	END 	
END   

-- Clean up the recap data. 
BEGIN 
	UPDATE @GLEntries
	SET dblDebitForeign = ISNULL(dblDebitForeign, 0)
		,dblCreditForeign = ISNULL(dblCreditForeign, 0) 
END 

-- Update the In-Transit Outbound and Inbound for Transfer Order
IF @ysnRecap = 0
BEGIN 
	DECLARE	@InTransit_Outbound AS InTransitTableType
	DECLARE	@InTransit_Inbound AS InTransitTableType

	INSERT INTO @InTransit_Outbound (
		[intItemId]
		,[intItemLocationId]
		,[intItemUOMId]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[dblQty]
		,[intTransactionId]
		,[strTransactionId]
		,[intTransactionTypeId]
	)
	SELECT	[intItemId]				= ri.intItemId
			,[intItemLocationId]	= il.intItemLocationId
			,[intItemUOMId]			= 
						-- New Hierarchy:
						-- 1. Use the Gross/Net UOM (intWeightUOMId) 
						-- 2. If there is no Gross/Net UOM, then check the lot. 
							-- 2.1. If it is a Lot, use the Lot UOM. 
							-- 2.2. If it is not a Lot, use the Item UOM. 
						ISNULL( 
							ri.intWeightUOMId, 
							CASE	WHEN ISNULL(ril.intLotId, 0) <> 0 AND dbo.fnGetItemLotType(ri.intItemId) <> 0 THEN 
										ril.intItemUnitMeasureId
									ELSE 
										ri.intUnitMeasureId
							END 
						)
			,[intLotId]				= ril.intLotId
			,[intSubLocationId]		= ri.intSubLocationId
			,[intStorageLocationId]	= ri.intStorageLocationId
			,[dblQty]				= 
						-- New Hierarchy:
						-- 1. If there is a Gross/Net UOM, use the Net Qty. 
							-- 2.1. If it is not a Lot, use the item's Net Qty. 
							-- 2.2. If it is a Lot, use the Lot's Net Qty. 
						-- 2. If there is no Gross/Net UOM, use the item or lot qty. 
							-- 2.1. If it is not a Lot, use the item Qty. 
							-- 2.2. If it is a Lot, use the lot qty. 
						CASE		-- Use the Gross/Net Qty if there is a Gross/Net UOM. 
									WHEN ri.intWeightUOMId IS NOT NULL THEN 									
										CASE	-- When item is NOT a Lot, receive it by the item's net qty. 
												WHEN ISNULL(ril.intLotId, 0) = 0 AND dbo.fnGetItemLotType(ri.intItemId) = 0 THEN 
													ISNULL(ri.dblNet, 0)
													
												-- When item is a LOT, get the net qty from the Lot record. 
												-- 1. If Net Qty is not provided, convert the Lot Qty into Gross/Net UOM. 
												-- 2. Else, get the Net Qty by using this formula: Gross Weight - Tare Weight. 
												ELSE 
															-- When Net Qty is missing, then convert the Lot Qty to Gross/Net UOM. 
													CASE	WHEN  ISNULL(ril.dblGrossWeight, 0) - ISNULL(ril.dblTareWeight, 0) = 0 THEN 
																dbo.fnCalculateQtyBetweenUOM(ril.intItemUnitMeasureId, ri.intWeightUOMId, ril.dblQuantity)
															-- Calculate the Net Qty
															ELSE 
																ISNULL(ril.dblGrossWeight, 0) - ISNULL(ril.dblTareWeight, 0)
													END 
										END 

								-- If Gross/Net UOM is missing, then get the item/lot qty. 
								ELSE 
									CASE	-- When item is NOT a Lot, receive it by the item qty.
											WHEN ISNULL(ril.intLotId, 0) = 0 AND dbo.fnGetItemLotType(ri.intItemId) = 0 THEN 
												ri.dblOpenReceive
												
											-- When item is a LOT, receive it by the Lot Qty. 
											ELSE 
												ISNULL(ril.dblQuantity, 0)
									END 								

						END 
			,[intTransactionId]		= r.intInventoryReceiptId
			,[strTransactionId]		= r.strReceiptNumber
			,[intTransactionTypeId] = @INVENTORY_RECEIPT_TYPE
	FROM	dbo.tblICInventoryReceipt r INNER JOIN dbo.tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN dbo.tblICItemLocation il 
				ON il.intItemId = ri.intItemId
				AND il.intLocationId = r.intTransferorId
			LEFT JOIN dbo.tblICInventoryReceiptItemLot ril
				ON ril.intInventoryReceiptItemId = ri.intInventoryReceiptItemId				
	WHERE	r.intInventoryReceiptId = @intTransactionId	
			AND r.strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER

	INSERT INTO @InTransit_Inbound (
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[intLotId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[dblQty]
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionTypeId]	
	)
	SELECT	[intItemId]				= ri.intItemId
			,[intItemLocationId]	= il.intItemLocationId
			,[intItemUOMId]			= 
						-- New Hierarchy:
						-- 1. Use the Gross/Net UOM (intWeightUOMId) 
						-- 2. If there is no Gross/Net UOM, then check the lot. 
							-- 2.1. If it is a Lot, use the Lot UOM. 
							-- 2.2. If it is not a Lot, use the Item UOM. 
						ISNULL( 
							ri.intWeightUOMId, 
							CASE	WHEN ISNULL(ril.intLotId, 0) <> 0 AND dbo.fnGetItemLotType(ri.intItemId) <> 0 THEN 
										ril.intItemUnitMeasureId
									ELSE 
										ri.intUnitMeasureId
							END 
						)
			,[intLotId]				= ril.intLotId
			,[intSubLocationId]		= ri.intSubLocationId
			,[intStorageLocationId]	= ri.intStorageLocationId
			,[dblQty]				= 
						-- New Hierarchy:
						-- 1. If there is a Gross/Net UOM, use the Net Qty. 
							-- 2.1. If it is not a Lot, use the item's Net Qty. 
							-- 2.2. If it is a Lot, use the Lot's Net Qty. 
						-- 2. If there is no Gross/Net UOM, use the item or lot qty. 
							-- 2.1. If it is not a Lot, use the item Qty. 
							-- 2.2. If it is a Lot, use the lot qty. 
						CASE		-- Use the Gross/Net Qty if there is a Gross/Net UOM. 
									WHEN ri.intWeightUOMId IS NOT NULL THEN 									
										CASE	-- When item is NOT a Lot, receive it by the item's net qty. 
												WHEN ISNULL(ril.intLotId, 0) = 0 AND dbo.fnGetItemLotType(ri.intItemId) = 0 THEN 
													ISNULL(ri.dblNet, 0)
													
												-- When item is a LOT, get the net qty from the Lot record. 
												-- 1. If Net Qty is not provided, convert the Lot Qty into Gross/Net UOM. 
												-- 2. Else, get the Net Qty by using this formula: Gross Weight - Tare Weight. 
												ELSE 
															-- When Net Qty is missing, then convert the Lot Qty to Gross/Net UOM. 
													CASE	WHEN  ISNULL(ril.dblGrossWeight, 0) - ISNULL(ril.dblTareWeight, 0) = 0 THEN 
																dbo.fnCalculateQtyBetweenUOM(ril.intItemUnitMeasureId, ri.intWeightUOMId, ril.dblQuantity)
															-- Calculate the Net Qty
															ELSE 
																ISNULL(ril.dblGrossWeight, 0) - ISNULL(ril.dblTareWeight, 0)
													END 
										END 

								-- If Gross/Net UOM is missing, then get the item/lot qty. 
								ELSE 
									CASE	-- When item is NOT a Lot, receive it by the item qty.
											WHEN ISNULL(ril.intLotId, 0) = 0 AND dbo.fnGetItemLotType(ri.intItemId) = 0 THEN 
												ri.dblOpenReceive
												
											-- When item is a LOT, receive it by the Lot Qty. 
											ELSE 
												ISNULL(ril.dblQuantity, 0)
									END 								

						END 
			,[intTransactionId]		= r.intInventoryReceiptId
			,[strTransactionId]		= r.strReceiptNumber
			,[intTransactionTypeId] = @INVENTORY_RECEIPT_TYPE
	FROM	dbo.tblICInventoryReceipt r INNER JOIN dbo.tblICInventoryReceiptItem ri
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN dbo.tblICItemLocation il 
				ON il.intItemId = ri.intItemId
				AND il.intLocationId = r.intLocationId
			LEFT JOIN dbo.tblICInventoryReceiptItemLot ril
				ON ril.intInventoryReceiptItemId = ri.intInventoryReceiptItemId				
	WHERE	r.intInventoryReceiptId = @intTransactionId	
			AND r.strReceiptType = @RECEIPT_TYPE_TRANSFER_ORDER

	UPDATE @InTransit_Outbound
	SET dblQty = CASE WHEN @ysnPost = 1 THEN -dblQty ELSE dblQty END
	
	UPDATE @InTransit_Inbound
	SET dblQty = CASE WHEN @ysnPost = 1 THEN -dblQty ELSE dblQty END

	EXEC dbo.uspICIncreaseInTransitOutBoundQty @InTransit_Outbound
	EXEC dbo.uspICIncreaseInTransitInBoundQty @InTransit_Inbound

	IF @ysnPost = 1 
		EXEC dbo.[uspICUpdateTransferOrderStatus] @intTransactionId, 3 -- Set status of the transfer order to 'Closed'
	ELSE 
		EXEC dbo.[uspICUpdateTransferOrderStatus] @intTransactionId, 1 -- Set status of the transfer order to 'Open'
END

--------------------------------------------------------------------------------------------  
-- If RECAP is TRUE, 
-- 1.	Store all the GL entries in a holding table. It will be used later as data  
--		for the recap screen.
--
-- 2.	Rollback the save point 
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 1
BEGIN 
	ROLLBACK TRAN @TransactionName
	EXEC dbo.uspGLPostRecap 
			@GLEntries
			,@intEntityUserSecurityId
	COMMIT TRAN @TransactionName
END 

--------------------------------------------------------------------------------------------  
-- If RECAP is FALSE,
-- 1. Book the G/L entries
-- 2. Update the ysnPosted flag in the transaction. Increase the concurrency. 
-- 3. Execute the integrations like updating the PO (if it exists)
-- 4. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 0
BEGIN 
	-- Check if blank GL entries are allowed
	-- If there is a company owned stock, do not allow blank gl entries. 
	SELECT	TOP 1 
			@ysnAllowBlankGLEntries = 0
	FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICItemLocation ItemLocation
				ON Header.intLocationId = ItemLocation.intLocationId
			INNER JOIN dbo.tblICInventoryReceiptItem DetailItem 
				ON Header.intInventoryReceiptId = DetailItem.intInventoryReceiptId 
				AND ItemLocation.intItemId = DetailItem.intItemId
			LEFT JOIN dbo.tblICInventoryReceiptItemLot DetailItemLot
				ON DetailItem.intInventoryReceiptItemId = DetailItemLot.intInventoryReceiptItemId
	WHERE	Header.intInventoryReceiptId = @intTransactionId   
			AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own

	IF @ysnAllowBlankGLEntries = 0 
	BEGIN 
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
	END 
		
	UPDATE	dbo.tblICInventoryReceipt  
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	strReceiptNumber = @strTransactionId  
	
	EXEC dbo.uspICPostInventoryReceiptIntegrations
		@ysnPost
		,@intTransactionId
		,@intEntityUserSecurityId

	COMMIT TRAN @TransactionName
END 
    
-- Create an Audit Log
IF @ysnRecap = 0 
BEGIN 
	DECLARE @strDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
			
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intTransactionId							-- Primary Key Value of the Inventory Receipt. 
			,@screenName = 'Inventory.view.InventoryReceipt'        -- Screen Namespace
			,@entityId = @intEntityUserSecurityId					-- Entity Id.
			,@actionType = @actionType                              -- Action Type
			,@changeDescription = @strDescription					-- Description
			,@fromValue = ''										-- Previous Value
			,@toValue = ''											-- New Value
END

GOTO Post_Exit

-- This is our immediate exit in case of exceptions controlled by this stored procedure
With_Rollback_Exit:
IF @@TRANCOUNT > 1 
BEGIN 
	ROLLBACK TRAN @TransactionName
	COMMIT TRAN @TransactionName
END

Post_Exit:
