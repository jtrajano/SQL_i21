CREATE PROCEDURE uspICPostInventoryReturn  
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
DECLARE @TransactionName AS VARCHAR(500) = 'InventoryReturn' + CAST(NEWID() AS NVARCHAR(100));

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

-- Constants  
DECLARE @INVENTORY_RETURN_TYPE AS INT = 42
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
		,@RECEIPT_TYPE_INVENTORY_RETURN AS NVARCHAR(50) = 'Inventory Return'

-- Posting variables
DECLARE @strItemNo AS NVARCHAR(50)
		,@intItemId AS INT
		,@ysnAllowBlankGLEntries AS BIT = 1
		,@strCurrencyId AS NVARCHAR(50)
		,@strFunctionalCurrencyId AS NVARCHAR(50)
		,@intEntityVendorId AS INT 
		
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
			,@intEntityVendorId = intEntityVendorId
	FROM	dbo.tblICInventoryReceipt   
	WHERE	strReceiptNumber = @strTransactionId  
END  
  
--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
BEGIN 
	DECLARE @strBillNumber AS NVARCHAR(50)
	DECLARE @strChargeItem AS NVARCHAR(50)

	-- Validate if the Inventory Return exists   
	IF @intTransactionId IS NULL  
	BEGIN   
		-- Cannot find the transaction.  
		EXEC uspICRaiseError 80167; 
		GOTO With_Rollback_Exit  
	END   
  
	-- Validate the date against the FY Periods  
	IF @ysnRecap = 0 AND EXISTS (SELECT 1 WHERE dbo.isOpenAccountingDate(@dtmDate) = 0) 
	BEGIN   
		-- Unable to find an open fiscal year period to match the transaction date.  
		EXEC uspICRaiseError 80168; 
		GOTO With_Rollback_Exit  
	END  
  
	-- Check if the transaction is already posted  
	IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1  
	BEGIN   
		-- The transaction is already posted.  
		EXEC uspICRaiseError 80169; 
		GOTO With_Rollback_Exit  
	END   
  
	-- Check if the transaction is already posted  
	IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
	BEGIN   
		-- The transaction is already unposted.  
		EXEC uspICRaiseError 80170; 
		GOTO With_Rollback_Exit  
	END   

	IF @ysnRecap = 0 
	BEGIN 
		UPDATE	dbo.tblICInventoryReceipt  
		SET		ysnPosted = @ysnPost
				,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
		WHERE	strReceiptNumber = @strTransactionId  
	END

	-- Check Company preference: Allow User Self Post  
	IF	dbo.fnIsAllowUserSelfPost(@intEntityUserSecurityId) = 1 
		AND @intEntityUserSecurityId <> @intCreatedEntityId 
		AND @ysnRecap = 0   
	BEGIN   
		-- 'You cannot %s transactions you did not create. Please contact your local administrator.'  
		IF @ysnPost = 1   
		BEGIN   
			EXEC uspICRaiseError 80172, 'Post';
			GOTO With_Rollback_Exit  
		END   

		IF @ysnPost = 0  
		BEGIN  
			EXEC uspICRaiseError 80172, 'Unpost';
			GOTO With_Rollback_Exit    
		END  
	END   

	-- Do not allow unpost if Bill has been created for the inventory return
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
			-- 'Unable to unpost. The inventory return has a voucher in {Voucher id}.'
			EXEC uspICRaiseError 80101, @strBillNumber
			GOTO With_Rollback_Exit    
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
			EXEC uspICRaiseError 80102, @strChargeItem, @strBillNumber
			GOTO With_Rollback_Exit    
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
			EXEC uspICRaiseError 80082, @strItemNo
			GOTO With_Rollback_Exit    
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
		EXEC uspICRaiseError 80090, @strItemNo
		GOTO With_Rollback_Exit  
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
			EXEC uspICRaiseError 80162, @strTransactionId, @strItemNo, @strCurrencyId, @strFunctionalCurrencyId;
			GOTO With_Rollback_Exit; 
		END 
	END 
END

-- Check if sub location and storage locations are valid. 
BEGIN
	DECLARE @ysnValidLocation BIT
	EXEC dbo.uspICValidateReceiptItemLocations @intTransactionId, @ysnValidLocation OUTPUT, @strItemNo OUTPUT 

	IF @ysnValidLocation = 0
	BEGIN 
		-- The sub location and storage unit in {Item No} does not match.
		EXEC uspICRaiseError 80087, @strItemNo
		GOTO With_Rollback_Exit
	END 
END

-- Validations related to lot numbers
BEGIN 
	DECLARE @strUnitMeasure AS NVARCHAR(50)
	DECLARE @OpenReceiveQty AS NUMERIC(38,20)
	DECLARE @LotQty AS NUMERIC(38,20)
	DECLARE @OpenReceiveQtyInItemUOM AS NUMERIC(38,20)
	DECLARE @LotQtyInItemUOM AS NUMERIC(38,20)
	DECLARE @ReceiptItemNet  AS NUMERIC(38,20)

	DECLARE @CleanWgtCount AS INT = 0
	DECLARE @FormattedReceivedQty AS NVARCHAR(50)
	DECLARE @FormattedLotQty AS NVARCHAR(50)
	DECLARE @FormattedDifference AS NVARCHAR(50)
	DECLARE @FormattedReceiptItemNet AS NVARCHAR(50)

	-- Check if the unit quantities on the UOM table are valid. 
	BEGIN 
		SELECT	TOP 1 
				@strItemNo = Item.strItemNo
				,@intItemId = Item.intItemId
				,@strUnitMeasure = UOM.strUnitMeasure
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
				INNER JOIN dbo.tblICItem Item
					ON ReceiptItem.intItemId = Item.intItemId
				INNER JOIN dbo.tblICItemUOM ItemUOM
					ON ItemUOM.intItemId = ReceiptItem.intItemId
				INNER JOIN dbo.tblICUnitMeasure UOM
					ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
		WHERE	ISNULL(ItemUOM.dblUnitQty, 0) <= 0

		IF @intItemId IS NOT NULL 
		BEGIN 
			IF ISNULL(@strItemNo, '') = '' 
				SET @strItemNo = 'an item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

			-- 'Please correct the unit qty in UOM {UOM} on {Item}.'
			EXEC uspICRaiseError 80017, @strUnitMeasure, @strItemNo;
			GOTO With_Rollback_Exit; 
		END 
	END 
		
	-- Check if the Qty to Return matches with the total Lot Qty. 
	SET @strItemNo = NULL 
	SET @intItemId = NULL 

	SELECT	TOP 1 
			@strItemNo					= Item.strItemNo
			,@intItemId					= Item.intItemId
			,@OpenReceiveQty			= ReceiptItem.dblOpenReceive
			,@LotQty					= ISNULL(ItemLot.TotalLotQty, 0)
			,@LotQtyInItemUOM			= ISNULL(ItemLot.TotalLotQtyInItemUOM, 0)
			,@OpenReceiveQtyInItemUOM	= ReceiptItem.dblOpenReceive
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = ReceiptItem.intItemId
			LEFT JOIN (
				SELECT  AggregrateLot.intInventoryReceiptItemId
						,TotalLotQtyInItemUOM = SUM(
							dbo.fnCalculateQtyBetweenUOM(
								ISNULL(AggregrateLot.intItemUnitMeasureId, tblICInventoryReceiptItem.intUnitMeasureId)
								,tblICInventoryReceiptItem.intUnitMeasureId
								,AggregrateLot.dblQuantity
							)
						)
						,TotalLotQty = SUM(ISNULL(AggregrateLot.dblQuantity, 0))
				FROM	dbo.tblICInventoryReceipt INNER JOIN dbo.tblICInventoryReceiptItem 
							ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId
						INNER JOIN dbo.tblICInventoryReceiptItemLot AggregrateLot
							ON tblICInventoryReceiptItem.intInventoryReceiptItemId = AggregrateLot.intInventoryReceiptItemId
				WHERE	tblICInventoryReceipt.strReceiptNumber = @strTransactionId				
				GROUP BY AggregrateLot.intInventoryReceiptItemId
			) ItemLot
				ON ItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId											
	WHERE	dbo.fnGetItemLotType(ReceiptItem.intItemId) <> 0 
			AND Receipt.strReceiptNumber = @strTransactionId
			AND ROUND(ISNULL(ItemLot.TotalLotQtyInItemUOM, 0), 6) <> ROUND(ReceiptItem.dblOpenReceive,6)
			
	IF @intItemId IS NOT NULL 
	BEGIN 
		IF ISNULL(@strItemNo, '') = '' 
			SET @strItemNo = 'Item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

		-- 'The Qty to Return for {Item} is {Open Receive Qty}. Total Lot Quantity is {Total Lot Qty}. The difference is {Calculated difference}.'
		DECLARE @difference AS NUMERIC(38, 20) = ABS(@OpenReceiveQty - @LotQtyInItemUOM);
		EXEC uspICRaiseError 80158, @strItemNo, @OpenReceiveQty, @LotQtyInItemUOM, @difference
		GOTO With_Rollback_Exit; 
	END 

	-------------------------------------------------------------------------------------
	-- Note: Need to change this validation as a settable configuration in IC. 
	-- Dallmayr seems to use Item Net weight as the "received weight". 
	-- They clean the coffee per lot. Net wgt at Lot is the actual wgt. 
	-- See IC-2176 and IC-2341 for more info. 
	-------------------------------------------------------------------------------------		
	---- Check if the Item Receipt Net qty matches with the total Net qty from the lots. 
	--SET @strItemNo = NULL 
	--SET @intItemId = NULL 

	SELECT	TOP 1 
			@strItemNo					= Item.strItemNo
			,@intItemId					= Item.intItemId
			,@OpenReceiveQty			= ReceiptItem.dblOpenReceive
			,@ReceiptItemNet			= ReceiptItem.dblNet
			,@LotQty					= ISNULL(ItemLot.TotalLotQty, 0)
			,@LotQtyInItemUOM			= ISNULL(ItemLot.TotalLotQtyInItemUOM, 0)
			,@OpenReceiveQtyInItemUOM	= ReceiptItem.dblNet
			,@CleanWgtCount				= ISNULL(clean.CleanCount, 0)
	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
			INNER JOIN dbo.tblICItem Item
				ON Item.intItemId = ReceiptItem.intItemId
			LEFT JOIN (
				SELECT  AggregrateLot.intInventoryReceiptItemId
						,TotalLotQtyInItemUOM = SUM(ISNULL(AggregrateLot.dblGrossWeight, 0) - ISNULL(AggregrateLot.dblTareWeight, 0))
						,TotalLotQty = SUM(ISNULL(AggregrateLot.dblGrossWeight, 0) - ISNULL(AggregrateLot.dblTareWeight, 0))
				FROM	dbo.tblICInventoryReceipt INNER JOIN dbo.tblICInventoryReceiptItem 
							ON tblICInventoryReceipt.intInventoryReceiptId = tblICInventoryReceiptItem.intInventoryReceiptId
						INNER JOIN dbo.tblICInventoryReceiptItemLot AggregrateLot
							ON tblICInventoryReceiptItem.intInventoryReceiptItemId = AggregrateLot.intInventoryReceiptItemId
				WHERE	tblICInventoryReceipt.strReceiptNumber = @strTransactionId				
				GROUP BY AggregrateLot.intInventoryReceiptItemId
			) ItemLot
				ON ItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
			LEFT OUTER JOIN (
					SELECT COUNT(intInventoryReceiptItemLotId) CleanCount, intInventoryReceiptItemId
					FROM dbo.tblICInventoryReceiptItemLot
					WHERE strCondition = 'Clean Wgt'
					GROUP BY intInventoryReceiptItemId
			) clean ON clean.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId										
	WHERE	dbo.fnGetItemLotType(ReceiptItem.intItemId) <> 0 
			AND Receipt.strReceiptNumber = @strTransactionId
			AND ROUND(ItemLot.TotalLotQtyInItemUOM,6) <> ROUND(ReceiptItem.dblNet,6)
			AND ReceiptItem.intWeightUOMId IS NOT NULL -- There is a Gross/Net UOM. 
			
	IF @intItemId IS NOT NULL AND @CleanWgtCount = 0
	BEGIN 
		
		IF ISNULL(@strItemNo, '') = '' 
			SET @strItemNo = 'Item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

		SET @FormattedReceiptItemNet =  CONVERT(NVARCHAR, CAST(@ReceiptItemNet AS MONEY), 1)
		SET @FormattedLotQty =  CONVERT(NVARCHAR, CAST(@LotQtyInItemUOM AS MONEY), 1)
		SET @FormattedDifference =  CAST(ABS(@ReceiptItemNet - @LotQtyInItemUOM) AS NVARCHAR(50))

		-- 'Net quantity mismatch. It is {@FormattedReceiptItemNet} on item {@strItemNo} but the total net from the lot(s) is {@FormattedLotQty}.'		
		EXEC uspICRaiseError 80081, @ReceiptItemNet, @strItemNo, @LotQtyInItemUOM; 
		GOTO With_Rollback_Exit; 
	END 
END

-- Get the next batch number
BEGIN	
	SET @strBatchId = NULL 
	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId
	IF @@ERROR <> 0 GOTO With_Rollback_Exit;
END

-------------------------------------------------------------------------------------------  
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
			,[intSourceEntityId]
			,[intCommodityId]
		)	
		EXEC @intReturnValue = dbo.uspICPostInventoryReceiptOtherCharges 
			@intTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INVENTORY_RETURN_TYPE
			,@ysnPost

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
				,intSourceEntityId
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

							-- If Sub-Currency: (A / C + B) 
							-- Else: (A + B) 

							CASE	
								WHEN DetailItem.ysnSubCurrency = 1 AND ISNULL(Header.intSubCurrencyCents, 1) <> 0 THEN 
									(
										-- (A) Item Cost
										dbo.fnCalculateReceiptUnitCost(
											DetailItem.intItemId
											,DetailItem.intUnitMeasureId		
											,DetailItem.intCostUOMId
											,DetailItem.intWeightUOMId
											,DetailItem.dblUnitCost
											,DetailItem.dblNet
											,DetailItemLot.intLotId
											,DetailItemLot.intItemUnitMeasureId
											,AggregrateItemLots.dblTotalNet --Lot Net Wgt or Volume
											,NULL--DetailItem.ysnSubCurrency
											,NULL--Header.intSubCurrencyCents
										)
										/ Header.intSubCurrencyCents 

										-- (B) Other Charge
										+ 
										CASE 
											WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
												-- Convert the other charge to the currency used by the detail item. 
												dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) / DetailItem.dblForexRate
											ELSE 
												-- No conversion. Detail item is already in functional currency. 
												dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
										END 									

									)										
								ELSE 
									(
										-- (A) Item Cost
										dbo.fnCalculateReceiptUnitCost(
											DetailItem.intItemId
											,DetailItem.intUnitMeasureId		
											,DetailItem.intCostUOMId
											,DetailItem.intWeightUOMId
											,DetailItem.dblUnitCost
											,DetailItem.dblNet
											,DetailItemLot.intLotId
											,DetailItemLot.intItemUnitMeasureId
											,AggregrateItemLots.dblTotalNet
											,NULL--DetailItem.ysnSubCurrency
											,NULL--Header.intSubCurrencyCents
										)
										-- (B) Other Charge
										+ 
										CASE 
											WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
												-- Convert the other charge to the currency used by the detail item. 
												dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) / DetailItem.dblForexRate
											ELSE 
												-- No conversion. Detail item is already in functional currency. 
												dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
										END
									)							
							END

				,dblSalesPrice = 0  
				,intCurrencyId = Header.intCurrencyId  
				,dblExchangeRate = ISNULL(DetailItem.dblForexRate, 1) 
				,intTransactionId = Header.intInventoryReceiptId  
				,intTransactionDetailId  = DetailItem.intInventoryReceiptItemId
				,strTransactionId = Header.strReceiptNumber  
				,intTransactionTypeId = @INVENTORY_RETURN_TYPE  
				,intLotId = DetailItemLot.intLotId 
				,intSubLocationId = ISNULL(l.intSubLocationId, DetailItem.intSubLocationId)
				,intStorageLocationId = ISNULL(l.intStorageLocationId, DetailItem.intStorageLocationId) 
				,strActualCostId = DetailItem.strActualCostId
				,intInTransitSourceLocationId = InTransitSourceLocation.intItemLocationId
				,intForexRateTypeId = DetailItem.intForexRateTypeId
				,dblForexRate = DetailItem.dblForexRate
				,intSourceEntityId = Header.intEntityVendorId
		FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICInventoryReceiptItem DetailItem 
					ON Header.intInventoryReceiptId = DetailItem.intInventoryReceiptId 
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intLocationId = Header.intLocationId 
					AND ItemLocation.intItemId = DetailItem.intItemId
				LEFT JOIN dbo.tblICInventoryReceiptItemLot DetailItemLot
					ON DetailItem.intInventoryReceiptItemId = DetailItemLot.intInventoryReceiptItemId
				LEFT JOIN tblICLot l
					ON l.intLotId = DetailItemLot.intLotId
				OUTER APPLY (
					SELECT  dblTotalNet = SUM(
								CASE	WHEN  ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0) = 0 THEN -- If Lot net weight is zero, convert the 'Pack' Qty to the Volume or Weight. 											
											ISNULL(dbo.fnCalculateQtyBetweenUOM(ReceiptItemLot.intItemUnitMeasureId, ReceiptItem.intWeightUOMId, ReceiptItemLot.dblQuantity), 0) 
										ELSE 
											ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0)
								END 
							)
					FROM	tblICInventoryReceiptItem ReceiptItem INNER JOIN tblICInventoryReceiptItemLot ReceiptItemLot
								ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId
					WHERE	ReceiptItem.intInventoryReceiptItemId = DetailItem.intInventoryReceiptItemId
				) AggregrateItemLots
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
					,intSourceEntityId
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
					,intSourceEntityId
			FROM	@ItemsForPost
			WHERE	dblQty > 0 
		
			-- Call the post routine for posting the company owned items 
			IF EXISTS (SELECT TOP 1 1 FROM @CompanyOwnedItemsForPost)
			BEGIN 
				IF @receiptType = @RECEIPT_TYPE_TRANSFER_ORDER
				BEGIN 
					SET @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY = @TRANSFER_ORDER_ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				END

				-- Do the inventory valuation
				EXEC	@intReturnValue = dbo.uspICPostReturnCosting  
						@CompanyOwnedItemsForPost  
						,@strBatchId  
						,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
						,@intEntityUserSecurityId

				IF @intReturnValue < 0 GOTO With_Rollback_Exit

				-- Create the GL entries specific for Inventory Return 
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
						,[intSourceEntityId]
						,[intCommodityId]
				)
				EXEC	@intReturnValue = uspICCreateReturnGLEntries
						@strBatchId 
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

							-- If Sub-Currency: (A / C + B) 
							-- Else: (A + B) 

							CASE	
								WHEN DetailItem.ysnSubCurrency = 1 AND ISNULL(Header.intSubCurrencyCents, 1) <> 0 THEN 
									(
										-- (A) Item Cost
										dbo.fnCalculateReceiptUnitCost(
											DetailItem.intItemId
											,DetailItem.intUnitMeasureId		
											,DetailItem.intCostUOMId
											,DetailItem.intWeightUOMId
											,DetailItem.dblUnitCost
											,DetailItem.dblNet
											,DetailItemLot.intLotId
											,DetailItemLot.intItemUnitMeasureId
											,AggregrateItemLots.dblTotalNet --Lot Net Wgt or Volume
											,NULL--DetailItem.ysnSubCurrency
											,NULL--Header.intSubCurrencyCents
										)
										/ Header.intSubCurrencyCents 

										-- (B) Other Charge
										+ 
										CASE 
											WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
												-- Convert the other charge to the currency used by the detail item. 
												dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) / DetailItem.dblForexRate
											ELSE 
												-- No conversion. Detail item is already in functional currency. 
												dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
										END 									

									)										
								ELSE 
									(
										-- (A) Item Cost
										dbo.fnCalculateReceiptUnitCost(
											DetailItem.intItemId
											,DetailItem.intUnitMeasureId		
											,DetailItem.intCostUOMId
											,DetailItem.intWeightUOMId
											,DetailItem.dblUnitCost
											,DetailItem.dblNet
											,DetailItemLot.intLotId
											,DetailItemLot.intItemUnitMeasureId
											,AggregrateItemLots.dblTotalNet
											,NULL--DetailItem.ysnSubCurrency
											,NULL--Header.intSubCurrencyCents
										)
										-- (B) Other Charge
										+ 
										CASE 
											WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
												-- Convert the other charge to the currency used by the detail item. 
												dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) / DetailItem.dblForexRate
											ELSE 
												-- No conversion. Detail item is already in functional currency. 
												dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
										END
									)							
							END

				,dblSalesPrice = 0  
				,intCurrencyId = Header.intCurrencyId  
				,dblExchangeRate = ISNULL(DetailItem.dblForexRate, 1)   
				,intTransactionId = Header.intInventoryReceiptId  
				,intTransactionDetailId  = DetailItem.intInventoryReceiptItemId
				,strTransactionId = Header.strReceiptNumber  
				,intTransactionTypeId = @INVENTORY_RETURN_TYPE  
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
				OUTER APPLY (
					SELECT  dblTotalNet = SUM(
								CASE	WHEN  ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0) = 0 THEN -- If Lot net weight is zero, convert the 'Pack' Qty to the Volume or Weight. 											
											ISNULL(dbo.fnCalculateQtyBetweenUOM(ReceiptItemLot.intItemUnitMeasureId, ReceiptItem.intWeightUOMId, ReceiptItemLot.dblQuantity), 0) 
										ELSE 
											ISNULL(ReceiptItemLot.dblGrossWeight, 0) - ISNULL(ReceiptItemLot.dblTareWeight, 0)
								END 
							)
					FROM	tblICInventoryReceiptItem ReceiptItem INNER JOIN tblICInventoryReceiptItemLot ReceiptItemLot
								ON ReceiptItem.intInventoryReceiptItemId = ReceiptItemLot.intInventoryReceiptItemId
					WHERE	ReceiptItem.intInventoryReceiptItemId = DetailItem.intInventoryReceiptItemId
				) AggregrateItemLots
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
  
		-- Negate the qty 
		UPDATE @StorageItemsForPost
		SET		dblQty = -dblQty 

		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @StorageItemsForPost) 
		BEGIN 
			EXEC	@intReturnValue = dbo.uspICPostStorage
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
			,[intSourceEntityId]
			,[intCommodityId]
		)	
		EXEC dbo.uspICPostInventoryReceiptTaxes 
			@intTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INVENTORY_RETURN_TYPE			
	END 

	-- Decrease the Gross weight for the lots when posting the inventory return. 
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
				,[intSourceEntityId]
				,[intCommodityId]
		)
		EXEC	@intReturnValue = dbo.uspICUnpostReturnCosting
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
				,[intSourceEntityId]
				,[intCommodityId]
			)	
			EXEC @intReturnValue = dbo.uspICPostInventoryReceiptOtherCharges 
				@intTransactionId
				,@strBatchId
				,@intEntityUserSecurityId
				,@INVENTORY_RETURN_TYPE					
				,@ysnPost
								
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
				,[intSourceEntityId]
				,[intCommodityId]
			)	
			EXEC @intReturnValue = dbo.uspICUnpostInventoryReceiptTaxes 
				@intTransactionId
				,@strBatchId
				,@intEntityUserSecurityId
				,@INVENTORY_RETURN_TYPE	
						
			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END

		-- Increase the Gross weight for the lots when unposting the inventory return. 
		UPDATE dbo.tblICLot
		SET		dblGrossWeight = Lot.dblGrossWeight + ItemLot.dblGrossWeight
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

	-- Save the GL Entries data into the GL Post Recap table by calling uspGLPostRecap. 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		EXEC dbo.uspGLPostRecap 
			@GLEntries
			,@intEntityUserSecurityId
	END 
	ELSE 
	BEGIN 
		-- Post preview is not available. Financials are only booked for company-owned stocks.
		EXEC uspICRaiseError 80185; 
	END 

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
	
	-- Reuse this sp for Inventory Return 
	EXEC dbo.uspICPostInventoryReceiptIntegrations 
		@ysnPost
		,@intTransactionId
		,@intEntityUserSecurityId

	EXEC dbo.uspICProcessPayables 
		@intReceiptId = @intTransactionId
		,@ysnPost = @ysnPost
		,@intEntityUserSecurityId = @intEntityUserSecurityId

	COMMIT TRAN @TransactionName
END 

-- Recalculate Totals
EXEC dbo.uspICInventoryReceiptCalculateTotals @ReceiptId = @intTransactionId, @ForceRecalc = 1
    
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
	RETURN -1; 
END

Post_Exit:
