﻿CREATE PROCEDURE uspICPostInventoryReceipt  
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
SET ANSI_WARNINGS ON  
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------    
-- Create a unique transaction name. 
DECLARE @TransactionName AS VARCHAR(500) = 'InventoryReceipt' + CAST(NEWID() AS NVARCHAR(100));

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

-- Constants  
DECLARE @INVENTORY_RECEIPT_TYPE AS INT = 4
		,@STARTING_NUMBER_BATCH AS INT = 3  
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'AP Clearing'
		,@TRANSFER_ORDER_ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory In-Transit'
		,@INBOUND_SHIPMENT_ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory In-Transit'
		
		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

		-- Receipt Types
		,@RECEIPT_TYPE_PURCHASE_CONTRACT AS NVARCHAR(50) = 'Purchase Contract'
		,@RECEIPT_TYPE_PURCHASE_ORDER AS NVARCHAR(50) = 'Purchase Order'
		,@RECEIPT_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
		,@RECEIPT_TYPE_DIRECT AS NVARCHAR(50) = 'Direct'

		,@SOURCE_TYPE_NONE AS INT = 0
		,@SOURCE_TYPE_Scale AS INT = 1
		,@SOURCE_TYPE_InboundShipment AS INT = 2
		,@SOURCE_TYPE_Transport AS INT = 3
		,@SOURCE_TYPE_SettleStorage AS INT = 4
		,@SOURCE_TYPE_DeliverySheet AS INT = 5
		,@SOURCE_TYPE_PurchaseOrder AS INT = 6
		,@SOURCE_TYPE_Store AS INT = 7
		,@SOURCE_TYPE_TransferShipment AS INT = 9

-- Posting variables
DECLARE @strItemNo AS NVARCHAR(50)
		,@intItemId AS INT
		,@ysnAllowBlankGLEntries AS BIT = 1
		,@strCurrencyId AS NVARCHAR(50)
		,@strFunctionalCurrencyId AS NVARCHAR(50)
		,@strForexRateType AS NVARCHAR(50)
		,@intEntityVendorId AS INT = NULL 
		,@dblStandardCost NUMERIC(18, 6)
		,@strLocation AS NVARCHAR(50) 
		,@strLotNumber AS NVARCHAR(50) 

-- Get the default currency ID
DECLARE @intFunctionalCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType 
DECLARE @DummyGLEntries AS RecapTableType 
DECLARE @ItemsForInTransitCosting AS ItemInTransitCostingTableType
DECLARE @ItemsForTransferOrder AS ItemInTransitCostingTableType

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)  
 
-- Create the type of lot numbers
DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

DECLARE @intReturnValue AS INT 

DECLARE @strUnpostMode AS NVARCHAR(50)
SELECT	TOP 1
		@strUnpostMode = strIRUnpostMode
FROM	tblICCompanyPreference

-- Change the source type to 'Store' if the IR's location configured in the store. 
BEGIN 
	UPDATE	r
	SET		r.intSourceType = @SOURCE_TYPE_Store 
	FROM	dbo.tblICInventoryReceipt r LEFT JOIN tblSTStore s
				ON r.intLocationId = s.intCompanyLocationId
	WHERE	strReceiptNumber = @strTransactionId  
			AND s.intCompanyLocationId IS NOT NULL 
			AND r.intSourceType <> @SOURCE_TYPE_Store
END 

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
			,@intSourceType AS INT 
			,@strFobPoint AS NVARCHAR(50) 
			,@strDataSource AS NVARCHAR(50) 
  
	SELECT TOP 1   
			@intTransactionId = intInventoryReceiptId  
			,@ysnTransactionPostedFlag = ysnPosted  
			,@dtmDate = dtmReceiptDate  
			,@intCreatedEntityId = intEntityId  
			,@receiptType = strReceiptType
			,@intTransferorId = intTransferorId
			,@intLocationId = intLocationId
			,@intSourceType = intSourceType 
			,@strFobPoint = ft.strFobPoint
			,@intEntityVendorId = r.intEntityVendorId
			,@strDataSource = r.strDataSource
	FROM	dbo.tblICInventoryReceipt r LEFT JOIN tblSMFreightTerms ft
				ON r.intFreightTermId = ft.intFreightTermId
	WHERE	strReceiptNumber = @strTransactionId  
END  

 
--------------------------------------------------------------------------------------------  
-- BEGIN Validate  
--------------------------------------------------------------------------------------------  
BEGIN 
	DECLARE @strBillNumber AS NVARCHAR(50)
	DECLARE @strChargeItem AS NVARCHAR(50)


	-- Validate Receipt Total
	
	-- Source Type must be equal to 0 - None to trigger Receipt Total Validation
	IF @intSourceType = 0
	BEGIN

		DECLARE @ysnValidateReceiptTotal AS BIT

		SELECT TOP 1 @ysnValidateReceiptTotal = ysnValidateReceiptTotal FROM tblICCompanyPreference

		-- Company Preference if Receipt Total should be validated
		IF @ysnValidateReceiptTotal = 1
		BEGIN

			DECLARE @ysnValidReceiptTotal AS BIT

			EXEC uspICValidateReceiptTotal @intTransactionId, @ysnValidReceiptTotal OUTPUT

			IF @ysnValidReceiptTotal = 0
			BEGIN
				EXEC uspICRaiseError 80266;
				GOTO With_Rollback_Exit
			END
		END
	END

	-- Validate if the Inventory Receipt exists   
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

	IF @ysnRecap = 0 
	BEGIN 
		UPDATE	dbo.tblICInventoryReceipt  
		SET		ysnPosted = @ysnPost
				,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
		WHERE	strReceiptNumber = @strTransactionId  
	END 
  
	-- Check if the transaction is already posted  
	IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
	BEGIN   
		-- The transaction is already unposted.  
		EXEC uspICRaiseError 80170; 
		GOTO With_Rollback_Exit  
	END   

	-- Check Company preference: Allow User Self Post  
	IF	dbo.fnIsAllowUserSelfPost(@intEntityUserSecurityId) = 1 
		AND @intEntityUserSecurityId <> @intCreatedEntityId 
		AND @ysnRecap = 0   
	BEGIN   
		-- 'You cannot {Post or Unpost} transactions you did not create. Please contact your local administrator.'  
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

	-- Do not allow unpost if Bill has been created for the inventory receipt
	IF @ysnPost = 0 AND @ysnRecap = 0 
	BEGIN 

		SELECT TOP 1 
			@strBillNumber = bill.strBillId
		FROM
			tblICInventoryReceiptItem ri 
			OUTER APPLY (
				SELECT TOP 1 
					b.strBillId
					,b.dtmDateCreated
				FROM 
					tblAPBill b INNER JOIN tblAPBillDetail bd
						ON b.intBillId = bd.intBillId
				WHERE
					bd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
			) bill
		WHERE
			ri.intInventoryReceiptId = @intTransactionId
			AND bill.strBillId IS NOT NULL 
			-- If source type is Inbound Shipment, do not validate if the Voucher is created before Inventory Receipt. 
			-- Otherwise, validate all other scenarios. 
			AND (
				(ri.dtmDateCreated <= bill.dtmDateCreated AND @intSourceType = @SOURCE_TYPE_InboundShipment) 
				OR (@intSourceType <> @SOURCE_TYPE_InboundShipment OR @intSourceType IS NULL) 
			)


		IF ISNULL(@strBillNumber, '') <> ''
		BEGIN 
			-- 'Unable to Unreceive. The inventory receipt has a voucher in {Voucher Id}.'
			EXEC uspICRaiseError 80056, @strBillNumber; 
			GOTO With_Rollback_Exit    
		END 

	END 

	-- Do not allow unpost if other charge is already billed. 
	IF @ysnPost = 0 AND @ysnRecap = 0 
	BEGIN 
		SET @strBillNumber = NULL 

		SELECT TOP 1 
			@strBillNumber = bill.strBillId
		FROM
			tblICInventoryReceiptCharge rc
			OUTER APPLY (
				SELECT TOP 1 
					b.strBillId
				FROM 
					tblAPBill b INNER JOIN tblAPBillDetail bd
						ON b.intBillId = bd.intBillId
				WHERE
					bd.intInventoryReceiptChargeId = rc.intInventoryReceiptChargeId
			) bill
		WHERE
			rc.intInventoryReceiptId = @intTransactionId
			AND bill.strBillId IS NOT NULL 

		IF ISNULL(@strBillNumber, '') <> ''
		BEGIN 
			-- 'Unable to unpost. Charge {Other Charge Id} has a voucher in {Voucher Id}.'
			EXEC uspICRaiseError 80102, @strChargeItem, @strBillNumber;
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
	BEGIN
		SET @strItemNo = NULL
		SELECT TOP 1 
			@strItemNo = item.strItemNo
		FROM 
			tblICInventoryReceiptItem receiptItem 			
			INNER JOIN tblICItem item 
				ON item.intItemId = receiptItem.intItemId
			LEFT JOIN tblICInventoryReceiptItemLot itemLot 
				ON itemLot.intInventoryReceiptItemId = receiptItem.intInventoryReceiptItemId
		WHERE 
			receiptItem.intInventoryReceiptId = @intTransactionId
			AND dbo.fnGetItemLotType(item.intItemId) <> 0
			AND itemLot.intInventoryReceiptItemLotId IS NULL
			
		IF @strItemNo IS NOT NULL
		BEGIN
			-- 'Lotted item {Item No} should should have lot(s) specified.'
			EXEC uspICRaiseError 80090, @strItemNo
			GOTO With_Rollback_Exit  
		END
	END

	-- Do not allow post if total lot Qty does not match receive Qty
	BEGIN 
		SET @strItemNo = NULL 
		SET @intItemId = NULL 

		DECLARE @OpenReceiveQty AS NUMERIC(38,20)
		DECLARE @LotQty AS NUMERIC(38,20)
		DECLARE @OpenReceiveQtyInItemUOM AS NUMERIC(38,20)
		DECLARE @LotQtyInItemUOM AS NUMERIC(38,20)


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
				OUTER APPLY (
					SELECT  TotalLotQtyInItemUOM = SUM(
								dbo.fnCalculateQtyBetweenUOM(
									ISNULL(AggregrateLot.intItemUnitMeasureId, ri.intUnitMeasureId)
									,ri.intUnitMeasureId
									,AggregrateLot.dblQuantity
								)
							)
							,TotalLotQty = SUM(ISNULL(AggregrateLot.dblQuantity, 0))
					FROM	tblICInventoryReceiptItemLot AggregrateLot INNER JOIN dbo.tblICInventoryReceiptItem ri
								ON AggregrateLot.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					WHERE	
						AggregrateLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId 
						AND (
							AggregrateLot.strCondition NOT IN ('Swept', 'Skimmed') -- Do not include the Swept or Skimmed in the total.
							OR AggregrateLot.strCondition IS NULL
						)
				) ItemLot					
		WHERE	dbo.fnGetItemLotType(ReceiptItem.intItemId) <> 0 
				AND Receipt.strReceiptNumber = @strTransactionId
				AND ROUND(ISNULL(ItemLot.TotalLotQtyInItemUOM, 0), 6) <> ROUND(ReceiptItem.dblOpenReceive,6)
				AND Item.strType IN ('Inventory', 'Bundle')
				
			
		IF @intItemId IS NOT NULL 
		BEGIN 
			IF ISNULL(@strItemNo, '') = '' 
				SET @strItemNo = 'Item with id ' + CAST(@intItemId AS NVARCHAR(50)) 

			-- 'The Qty to Receive for {Item} is {Open Receive Qty}. Total Lot Quantity is {Total Lot Qty}. The difference is {Calculated difference}.'
			DECLARE @difference AS NUMERIC(38, 20) = ABS(@OpenReceiveQty - @LotQtyInItemUOM);
			EXEC uspICRaiseError 80267, @strItemNo, @OpenReceiveQty, @LotQtyInItemUOM, @difference
			GOTO With_Rollback_Exit; 
		END 
	END 

	-- Check if receipt items and lots have gross/net UOM and have gross qty and net qty when the items have Lot Weights Required enabled in Item setup.	
	BEGIN 
		SET @intItemId = NULL

		SELECT TOP 1 
			@strItemNo = i.strItemNo
			,@intItemId = i.intItemId
		FROM 
			tblICInventoryReceiptItem ri 			
			INNER JOIN tblICItem i 
				ON i.intItemId = ri.intItemId
		WHERE 
			ri.intInventoryReceiptId = @intTransactionId
			AND i.ysnLotWeightsRequired = 1
			AND i.strLotTracking <> 'No'
			AND (
				ri.intWeightUOMId IS NULL 
				OR ISNULL(ri.dblGross, 0) = 0 
				OR ISNULL(ri.dblNet, 0) = 0
			)
			
		IF @intItemId IS NOT NULL
		BEGIN
			-- 'Gross/Net UOM and weights are required for item %s.'
			EXEC uspICRaiseError 80190, @strItemNo
			GOTO With_Rollback_Exit 	
		END
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
			EXEC uspICRaiseError 80112, @strReturnId
			GOTO With_Rollback_Exit  
		END 
	END 

	-- Check if the transaction is using a foreign currency and it has a missing forex rate type. 
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
				AND ReceiptItem.intForexRateTypeId IS NULL 
				AND Receipt.intCurrencyId IS NOT NULL 
				AND Receipt.intCurrencyId <> @intFunctionalCurrencyId

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- {Transaction Id} is on foreign currency. Default Rate Type is required for Inventory in Company Configuration -> System Manager -> Multi Currency.
			EXEC uspICRaiseError 80217, @strTransactionId;
			GOTO With_Rollback_Exit; 
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
				,@strForexRateType = ForexRateType.strCurrencyExchangeRateType 
		FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId				
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = ReceiptItem.intItemId
				LEFT JOIN tblSMCurrency c
					ON c.intCurrencyID =  Receipt.intCurrencyId
				LEFT JOIN tblSMCurrency fc
					ON fc.intCurrencyID = @intFunctionalCurrencyId
				LEFT JOIN tblSMCurrencyExchangeRateType ForexRateType
					ON ForexRateType.intCurrencyExchangeRateTypeId = ReceiptItem.intForexRateTypeId
		WHERE	Receipt.intInventoryReceiptId = @intTransactionId
				AND ISNULL(ReceiptItem.dblForexRate, 0) = 0 
				AND Receipt.intCurrencyId IS NOT NULL 
				AND Receipt.intCurrencyId <> @intFunctionalCurrencyId

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- {Transaction Id} is using a foreign currency. {Item No} is missing a forex rate. Please review the Currency Exchange Rates and check if {Foreign Currency} to {Functional Currency} for {Rate Type} has a valid effective date and forex rate.
			EXEC uspICRaiseError 80162, @strTransactionId, @strItemNo, @strCurrencyId, @strFunctionalCurrencyId, @strForexRateType;
			GOTO With_Rollback_Exit; 
		END 
	END

	/* 
	BEGIN COMMENT (IC-8603)
	Do not update records in tblICInventoryReceiptItem during posting. 
	Other modules are reading it. Update will trigger a Page Lock (IX) and cause a deadlock. 

	---- Update Warehouse Ref# for line items and lots
	--UPDATE ri
	--SET ri.strWarehouseRefNo = r.strWarehouseRefNo
	--FROM tblICInventoryReceiptItem ri
	--	INNER JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ri.intInventoryReceiptId
	--WHERE r.intInventoryReceiptId = @intTransactionId
	END COMMENT (IC-8603) 
	*/

	-- Check if company-owned item and the location that doesn't allow zero cost
	-- 1 or NULL: No
	-- 2: Yes
	-- 3: Yes, with warning message
	BEGIN 
		SET @intItemId = NULL

		SELECT	
			@strItemNo = Item.strItemNo
			,@intItemId = Item.intItemId
			,@strLocation = Company.strLocationName
		FROM
			tblICInventoryReceipt r 
			INNER JOIN tblICInventoryReceiptItem ri 
				ON r.intInventoryReceiptId = ri.intInventoryReceiptId			
			INNER JOIN tblICItem Item 
				ON ri.intItemId = Item.intItemId
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intItemId = Item.intItemId
				AND ItemLocation.intLocationId = r.intLocationId
			INNER JOIN tblSMCompanyLocation Company 
				ON Company.intCompanyLocationId = ItemLocation.intLocationId
		WHERE 		
			r.strReceiptNumber = @strTransactionId
			AND ISNULL(ri.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
			AND ri.dblUnitCost <= 0						
			AND ISNULL(ItemLocation.intAllowZeroCostTypeId, 1) = 1
		
		IF @intItemId IS NOT NULL
		BEGIN
			-- 'Zero cost is not allowed in "%s" location for item "%s".'
			EXEC uspICRaiseError 80229, @strLocation, @strItemNo
			GOTO With_Rollback_Exit 	
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

	-- Check if the Missing Lots are not posted with negative qty. 
	BEGIN
		SELECT @strItemNo = NULL
				,@intItemId = NULL 
				,@strLotNumber = NULL 		

		SELECT TOP 1 
				@strTransactionId = Receipt.strReceiptNumber 
				,@strItemNo = Item.strItemNo
				,@intItemId = Item.intItemId
				,@strLotNumber = Lot.strLotNumber 
		FROM	dbo.tblICInventoryReceipt Receipt 
				INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId				
				INNER JOIN tblICInventoryReceiptItemLot ReceiptLot
					ON ReceiptLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId 
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = ReceiptItem.intItemId
				INNER JOIN tblICLot Lot
					ON Lot.intLotId = ReceiptLot.intLotId 
		WHERE	Receipt.intInventoryReceiptId = @intTransactionId
				AND ReceiptLot.strCondition = 'Missing'
				AND (ReceiptItem.dblOpenReceive < 0 OR ReceiptLot.dblQuantity < 0) 

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- '{Lot Number} is a missing lot it should not have a negative quantity.'
			EXEC uspICRaiseError 80268, @strLotNumber;
			GOTO With_Rollback_Exit; 
		END 		 
	END

	-- Check if multiple lots are not allowed. 
	BEGIN
		SELECT @strItemNo = NULL
				,@intItemId = NULL 

		SELECT TOP 1 
				@strTransactionId = Receipt.strReceiptNumber 
				,@strItemNo = Item.strItemNo
				,@intItemId = Item.intItemId
		FROM	dbo.tblICInventoryReceipt Receipt 
				INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
					ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId				
				INNER JOIN dbo.tblICItem Item
					ON Item.intItemId = ReceiptItem.intItemId
				CROSS APPLY (				
					SELECT c = COUNT(1) 
					FROM tblICInventoryReceiptItemLot ReceiptLot
					WHERE 
						ReceiptLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId 				
				) lotCount 
				CROSS APPLY (
					SELECT TOP 1 * FROM tblICCompanyPreference 
				) pref
		WHERE	Receipt.intInventoryReceiptId = @intTransactionId
				AND lotCount.c > 1
				AND pref.strSingleOrMultipleLots = 'Single'

		IF @intItemId IS NOT NULL 
		BEGIN 
			-- '{Lot Number} is a missing lot it should not have a negative quantity.'
			EXEC uspICRaiseError 80269, @strItemNo;
			GOTO With_Rollback_Exit; 
		END 		 
	END
END
--------------------------------------------------------------------------------------------  
-- END Validate  
--------------------------------------------------------------------------------------------  

-- Call Starting number for Receipt Detail Update to prevent deadlocks. 
BEGIN
	DECLARE @strUpdateRIDetail AS NVARCHAR(50)
	EXEC dbo.uspSMGetStartingNumber 155, @strUpdateRIDetail OUTPUT
	IF @@ERROR <> 0 GOTO With_Rollback_Exit;
END 

-- Get the next batch number
BEGIN 
	SET @strBatchId = NULL 
	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId  
	IF @@ERROR <> 0 GOTO With_Rollback_Exit;
END


-- Create and validate the lot numbers
IF @ysnPost = 1
BEGIN 	
	DECLARE @intCreateUpdateLotError AS INT 

	UPDATE lot
	SET 
		lot.strWarehouseRefNo = r.strWarehouseRefNo
		,lot.strWarrantNo = ISNULL(NULLIF(RTRIM(LTRIM(lot.strWarrantNo)), ''), r.strWarrantNo) -- Ensure the lot is using the same warrant number when posting the IR. 
		,lot.intWarrantStatus = ISNULL(lot.intWarrantStatus, r.intWarrantStatus) -- Ensure the lot is using the same warrant status when posting the IR.
	FROM tblICInventoryReceiptItemLot lot 
		INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptItemId = lot.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ri.intInventoryReceiptId
	WHERE r.intInventoryReceiptId = @intTransactionId

	EXEC @intCreateUpdateLotError = dbo.uspICCreateLotNumberOnInventoryReceipt 
			@strTransactionId
			,@intEntityUserSecurityId
			,@ysnPost

	IF @intCreateUpdateLotError <> 0 GOTO With_Rollback_Exit;
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
	DECLARE @NonInventoryItemsForPost AS ItemCostingTableType  

	DECLARE @StorageItemsForPost AS ItemCostingTableType  
	DECLARE @MissingLotsForPost AS ItemCostingTableType  

	-- Process the Other Charges
	BEGIN 
		---- Calculate the other charges. 
		--EXEC dbo.uspICCalculateOtherCharges
		--	@intTransactionId			

		-- Allocate the other charges and surcharges. 
		EXEC dbo.uspICAllocateInventoryReceiptOtherCharges 
			@intTransactionId		
				
		---- Calculate Other Charges Taxes
		--EXEC dbo.uspICCalculateInventoryReceiptOtherChargesTaxes
		--	@intTransactionId

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
			,@INVENTORY_RECEIPT_TYPE
			,@ysnPost

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
			
	END 

	---- Validate the receipt total. Do not allow negative receipt total. 
	--IF	(dbo.fnICGetReceiptTotals(@intTransactionId, 6) < 0) 
	--	AND ISNULL(@ysnRecap, 0) = 0
	--	AND @intSourceType <> @SOURCE_TYPE_Store	
	--	--AND @strDataSource <> 'Reverse'
	--BEGIN
	--	-- Unable to Post {Receipt Number}. The Inventory Receipt total is negative.
	--	EXEC uspICRaiseError 80181, @strTransactionId;
	--	GOTO With_Rollback_Exit;
	--END

	-- Get the items to post. 
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
				,intCategoryId
				,dblUnitRetail
				,intSourceEntityId
				,strBOLNumber 
				,intTicketId
				,strCondition
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
											,DetailItem.ysnSubCurrency
											,Header.intSubCurrencyCents
											,DEFAULT 
											,DetailItem.intComputeItemTotalOption
											,DetailItem.dblOpenReceive
										)
										--/ Header.intSubCurrencyCents 

										-- (B) Other Charge
										+ 
										dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) 
										--CASE 
										--	WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 

										--		-- Convert the other charge to the currency used by the detail item. 
										--		dbo.fnDivide(
										--			dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) 
										--			,DetailItem.dblForexRate
										--		)
										--	ELSE 
										--		-- No conversion. Detail item is already in functional currency. 
										--		dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
										--END 									
										+
										CASE 
											WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
												dbo.fnDivide(
													dbo.fnICGetAddToCostTaxFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) 
													,DetailItem.dblForexRate
												)
											ELSE 												
												dbo.fnICGetAddToCostTaxFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
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
											,DEFAULT 
											,DetailItem.intComputeItemTotalOption
											,DetailItem.dblOpenReceive
										)
										-- (B) Other Charge
										+ 
										dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) 
										--CASE 
										--	WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
										--		-- Convert the other charge to the currency used by the detail item. 
										--		dbo.fnDivide(
										--			dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) 
										--			,DetailItem.dblForexRate
										--		)
										--	ELSE 
										--		-- No conversion. Detail item is already in functional currency. 
										--		dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
										--END	 									
										+
										CASE 
											WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
												dbo.fnDivide(
													dbo.fnICGetAddToCostTaxFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) 
													,DetailItem.dblForexRate
												)
											ELSE 
												dbo.fnICGetAddToCostTaxFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
										END
									)							
							END
				,dblSalesPrice = 0  
				,intCurrencyId = Header.intCurrencyId  
				,dblExchangeRate = ISNULL(DetailItem.dblForexRate, 1)   
				,intTransactionId = Header.intInventoryReceiptId  
				,intTransactionDetailId  = DetailItem.intInventoryReceiptItemId
				,strTransactionId = Header.strReceiptNumber  
				,intTransactionTypeId = @INVENTORY_RECEIPT_TYPE  
				,intLotId = DetailItemLot.intLotId 
				,intSubLocationId = DetailItem.intSubLocationId --ISNULL(DetailItemLot.intSubLocationId, DetailItem.intSubLocationId) 
				,intStorageLocationId = ISNULL(DetailItemLot.intStorageLocationId, DetailItem.intStorageLocationId)
				,strActualCostId = DetailItem.strActualCostId
				,intInTransitSourceLocationId = InTransitSourceLocation.intItemLocationId
				,intForexRateTypeId = DetailItem.intForexRateTypeId
				,dblForexRate = DetailItem.dblForexRate
				,intCategoryId = i.intCategoryId
				,dblUnitRetail = 
					dbo.fnCalculateReceiptUnitCost(
						DetailItem.intItemId
						,DetailItem.intUnitMeasureId		
						,DetailItem.intCostUOMId
						,DetailItem.intWeightUOMId
						,DetailItem.dblUnitRetail
						,DetailItem.dblNet
						,DetailItemLot.intLotId
						,DetailItemLot.intItemUnitMeasureId
						,AggregrateItemLots.dblTotalNet --Lot Net Wgt or Volume
						,NULL--DetailItem.ysnSubCurrency
						,NULL--Header.intSubCurrencyCents
						,DEFAULT 
						,DetailItem.intComputeItemTotalOption
						,DetailItem.dblOpenReceive
					)
				,intSourceEntityId = Header.intEntityVendorId
				,strBOLNumber = Header.strBillOfLading 
				,intTicketId = CASE WHEN Header.intSourceType = 1 THEN DetailItem.intSourceId ELSE NULL END 
				,DetailItemLot.strCondition

		FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICInventoryReceiptItem DetailItem 
					ON Header.intInventoryReceiptId = DetailItem.intInventoryReceiptId 
				INNER JOIN tblICItem i 
					ON DetailItem.intItemId = i.intItemId 
				INNER JOIN dbo.tblICItemLocation ItemLocation
					ON ItemLocation.intItemId = DetailItem.intItemId
					AND ItemLocation.intLocationId = (
						CASE WHEN Header.strReceiptNumber = @RECEIPT_TYPE_TRANSFER_ORDER THEN Header.intTransferorId ELSE Header.intLocationId END 
					)
					
				LEFT JOIN dbo.tblICInventoryReceiptItemLot DetailItemLot
					ON DetailItem.intInventoryReceiptItemId = DetailItemLot.intInventoryReceiptItemId
					AND dbo.fnGetItemLotType(DetailItem.intItemId) IN (1,2,3)
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
				AND i.strType <> 'Bundle' -- Do not include Bundle items in the item costing. Bundle components are the ones included in the item costing.
				
		-- Update the @ItemsForPost for source type and source no.
		BEGIN
			UPDATE i
			SET
				i.strSourceType = v.strSourceType
				,i.strSourceNumber = v.strSourceNumber			
			FROM 
				@ItemsForPost i INNER JOIN vyuICGetReceiptItemSource v
					ON i.intTransactionDetailId = v.intInventoryReceiptItemId
					AND i.intTransactionId = v.intInventoryReceiptId
		END 

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
					,dblForexCost = dblCost
			FROM	@ItemsForPost itemCost
			WHERE	itemCost.intCurrencyId <> @intFunctionalCurrencyId 
		END
	END

	-- Get the missing lots to post. 
	BEGIN 
		INSERT INTO @MissingLotsForPost (
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblCost] 
			,[dblForexCost]
			,[dblValue]
			,[dblSalesPrice] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[intTransactionId] 
			,[intTransactionDetailId] 
			,[strTransactionId] 
			,[intTransactionTypeId] 
			,[intLotId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[ysnIsStorage] 
			,[strActualCostId] 
			,[intSourceTransactionId] 
			,[strSourceTransactionId] 
			,[intInTransitSourceLocationId] 
			,[intForexRateTypeId] 
			,[dblForexRate] 
			,[intStorageScheduleTypeId] 
			,[dblUnitRetail] 
			,[intCategoryId] 
			,[dblAdjustCostValue] 
			,[dblAdjustRetailValue] 
			,[intCostingMethod] 
			,[ysnAllowVoucher] 
			,[strSourceType]
			,[strSourceNumber]
			,[strBOLNumber]
			,[intTicketId]
		)
		SELECT 
			itemsToPost.intItemId
			,itemsToPost.intItemLocationId
			,itemsToPost.intItemUOMId
			,itemsToPost.dtmDate
			,dblQty = -itemsToPost.dblQty
			,itemsToPost.dblUOMQty
			,itemsToPost.dblCost
			,itemsToPost.dblForexCost 
			,itemsToPost.dblValue
			,itemsToPost.dblSalesPrice
			,itemsToPost.intCurrencyId
			,itemsToPost.dblExchangeRate
			,itemsToPost.intTransactionId
			,itemsToPost.intTransactionDetailId
			,itemsToPost.strTransactionId
			,itemsToPost.intTransactionTypeId
			,itemsToPost.intLotId
			,itemsToPost.intSubLocationId
			,itemsToPost.intStorageLocationId
			,itemsToPost.ysnIsStorage
			,itemsToPost.strActualCostId
			,itemsToPost.intSourceTransactionId
			,itemsToPost.strSourceTransactionId
			,itemsToPost.intInTransitSourceLocationId
			,itemsToPost.intForexRateTypeId
			,itemsToPost.dblForexRate
			,itemsToPost.intStorageScheduleTypeId
			,itemsToPost.dblUnitRetail
			,itemsToPost.intCategoryId
			,itemsToPost.dblAdjustCostValue
			,itemsToPost.dblAdjustRetailValue
			,itemsToPost.intCostingMethod
			,itemsToPost.ysnAllowVoucher
			,itemsToPost.strSourceType
			,itemsToPost.strSourceNumber
			,itemsToPost.strBOLNumber
			,itemsToPost.intTicketId
		FROM	
			@ItemsForPost itemsToPost INNER JOIN tblICItem i 
				ON itemsToPost.intItemId = i.intItemId
		WHERE
			i.strType <> 'Non-Inventory'
			and itemsToPost.strCondition = 'Missing'
	END 	

	-- Get the non-inventory items
	BEGIN 
		INSERT INTO @NonInventoryItemsForPost (
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty] 
			,[dblCost] 
			,[dblForexCost]
			,[dblValue]
			,[dblSalesPrice] 
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[intTransactionId] 
			,[intTransactionDetailId] 
			,[strTransactionId] 
			,[intTransactionTypeId] 
			,[intLotId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[ysnIsStorage] 
			,[strActualCostId] 
			,[intSourceTransactionId] 
			,[strSourceTransactionId] 
			,[intInTransitSourceLocationId] 
			,[intForexRateTypeId] 
			,[dblForexRate] 
			,[intStorageScheduleTypeId] 
			,[dblUnitRetail] 
			,[intCategoryId] 
			,[dblAdjustCostValue] 
			,[dblAdjustRetailValue] 
			,[intCostingMethod] 
			,[ysnAllowVoucher] 
			,[strSourceType]
			,[strSourceNumber]
			,[strBOLNumber]
			,[intTicketId]
		)
		SELECT 
			itemsToPost.intItemId
			,itemsToPost.intItemLocationId
			,itemsToPost.intItemUOMId
			,itemsToPost.dtmDate
			,itemsToPost.dblQty
			,itemsToPost.dblUOMQty
			,itemsToPost.dblCost
			,itemsToPost.dblForexCost 
			,itemsToPost.dblValue
			,itemsToPost.dblSalesPrice
			,itemsToPost.intCurrencyId
			,itemsToPost.dblExchangeRate
			,itemsToPost.intTransactionId
			,itemsToPost.intTransactionDetailId
			,itemsToPost.strTransactionId
			,itemsToPost.intTransactionTypeId
			,itemsToPost.intLotId
			,itemsToPost.intSubLocationId
			,itemsToPost.intStorageLocationId
			,itemsToPost.ysnIsStorage
			,itemsToPost.strActualCostId
			,itemsToPost.intSourceTransactionId
			,itemsToPost.strSourceTransactionId
			,itemsToPost.intInTransitSourceLocationId
			,itemsToPost.intForexRateTypeId
			,itemsToPost.dblForexRate
			,itemsToPost.intStorageScheduleTypeId
			,itemsToPost.dblUnitRetail
			,itemsToPost.intCategoryId
			,itemsToPost.dblAdjustCostValue
			,itemsToPost.dblAdjustRetailValue
			,itemsToPost.intCostingMethod
			,itemsToPost.ysnAllowVoucher
			,itemsToPost.strSourceType
			,itemsToPost.strSourceNumber
			,itemsToPost.strBOLNumber
			,itemsToPost.intTicketId
		FROM	
			@ItemsForPost itemsToPost INNER JOIN tblICItem i 
				ON itemsToPost.intItemId = i.intItemId
		WHERE
			i.strType = 'Non-Inventory'
	END 

	-- Process the company owned-stocks. 
	BEGIN
		-- Remove the non-inventory types from @ItemsForPost 
		DELETE itemsToPost
		FROM	
			@ItemsForPost itemsToPost INNER JOIN tblICItem i 
				ON itemsToPost.intItemId = i.intItemId
		WHERE
			i.strType = 'Non-Inventory'			

		-- Validate the item cost. 
		BEGIN
			SET @intItemId = NULL 
			SET @strItemNo = NULL 
			SET @dblStandardCost = NULL 
					   
			SELECT	TOP 1 
					@intItemId = i.intItemId
					,@strItemNo = i.strItemNo
					,@dblStandardCost = pricing.dblStandardCost
			FROM	@ItemsForPost itemToPost INNER JOIN tblICItem i
						ON itemToPost.intItemId = i.intItemId
					INNER JOIN tblAPVendor vendor
						ON itemToPost.intSourceEntityId = vendor.intEntityId
					INNER JOIN tblICItemUOM stockUOM
						ON stockUOM.intItemId = itemToPost.intItemId
						AND stockUOM.ysnStockUnit = 1
					INNER JOIN tblICItemPricing pricing
						ON pricing.intItemId = itemToPost.intItemId
						AND pricing.intItemLocationId = itemToPost.intItemLocationId
			WHERE
				ISNULL(dbo.fnCalculateCostBetweenUOM(itemToPost.intItemUOMId, stockUOM.intItemUOMId, itemToPost.dblCost), 0) > ISNULL(pricing.dblStandardCost, 0)
				AND vendor.ysnMatchVendorCost = 1
				AND itemToPost.dblQty > 0
				AND ISNULL(itemToPost.dblCost, 0) <> 0 

			IF @intItemId IS NOT NULL 
			BEGIN 
				-- 'The cost for {Item No} is more than the vendor cost of {#,##0.00}. Unable to post.'
				EXEC uspICRaiseError 80235, @strItemNo, @dblStandardCost
				GOTO With_Rollback_Exit    
			END 
		END

		-- Receive the company owned stocks.  
		IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
		BEGIN 
			INSERT INTO @CompanyOwnedItemsForPost (
					intItemId  
					,intItemLocationId 
					,intItemUOMId  
					,dtmDate  
					,dblQty  
					,dblUOMQty  
					,dblCost  
					,dblForexCost 
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
					,intCategoryId
					,dblUnitRetail
					,intSourceEntityId
					,strSourceType
					,strSourceNumber
					,strBOLNumber
					,intTicketId
			)
			SELECT 
					intItemId  
					,intItemLocationId 
					,intItemUOMId  
					,dtmDate  
					,dblQty  
					,dblUOMQty  
					,dblCost  
					,dblForexCost 
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
					,intCategoryId
					,dblUnitRetail
					,intSourceEntityId
					,strSourceType
					,strSourceNumber
					,strBOLNumber
					,intTicketId
			FROM	@ItemsForPost
		
			-- Call the post routine for posting the company owned items 
			IF EXISTS (SELECT TOP 1 1 FROM @CompanyOwnedItemsForPost)
			BEGIN 
				-- In-Transit GL Entries from Inbound Shipment 
				IF (@intSourceType = @SOURCE_TYPE_InboundShipment AND @strFobPoint = 'Origin')					
				BEGIN 				
					INSERT INTO @DummyGLEntries (
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
					EXEC	@intReturnValue = dbo.uspICPostCosting  
							@CompanyOwnedItemsForPost  
							,@strBatchId  
							,@TRANSFER_ORDER_ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
							,@intEntityUserSecurityId

					IF @intReturnValue < 0 GOTO With_Rollback_Exit

					-- Create the GL entries specific for Inventory Receipt
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
					EXEC	@intReturnValue = uspICCreateReceiptGLEntries
							@strBatchId 
							,NULL -- @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
							,@intEntityUserSecurityId

					IF @intReturnValue < 0 GOTO With_Rollback_Exit
				END 
				
				-- In-Transit GL entries from Transfer Order 
				ELSE IF @receiptType = @RECEIPT_TYPE_TRANSFER_ORDER
					OR @intSourceType = @SOURCE_TYPE_TransferShipment
				BEGIN 
					INSERT INTO @DummyGLEntries (
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
					EXEC	@intReturnValue = dbo.uspICPostCosting  
							@CompanyOwnedItemsForPost  
							,@strBatchId  
							,@TRANSFER_ORDER_ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
							,@intEntityUserSecurityId
										
					IF @intReturnValue < 0 GOTO With_Rollback_Exit
				END 

				-- GL Entries for a regular Inventory Receipt. 
				ELSE 
				BEGIN 
					-- Do the inventory valuation
					INSERT INTO @DummyGLEntries (
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
					EXEC	@intReturnValue = dbo.uspICPostCosting  
							@CompanyOwnedItemsForPost  
							,@strBatchId  
							,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
							,@intEntityUserSecurityId

					IF @intReturnValue < 0 GOTO With_Rollback_Exit


					-- Retain this code for Transfer Orders that was posted not using the In-Transit costing. 
					IF @receiptType = @RECEIPT_TYPE_TRANSFER_ORDER
					BEGIN 
						SET @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY = @TRANSFER_ORDER_ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY

						-- -- Assign the Source Location Id. 			
						-- UPDATE	t
						-- SET		t.intInTransitSourceLocationId = UDT.intInTransitSourceLocationId
						-- FROM	tblICInventoryTransaction t INNER JOIN @CompanyOwnedItemsForPost UDT
						-- 			ON t.intItemId = UDT.intItemId
						-- 			AND t.intItemLocationId = UDT.intItemLocationId
						-- 			AND t.intItemUOMId = UDT.intItemUOMId
						-- 			AND t.dblQty = UDT.dblQty
						-- 			AND t.intTransactionId = UDT.intTransactionId
						-- 			AND t.intTransactionDetailId = UDT.intTransactionDetailId
						-- 			AND t.strTransactionId = UDT.strTransactionId
						-- WHERE	t.dblQty > 0 
						-- 		AND UDT.intInTransitSourceLocationId IS NOT NULL 
					END 

					-- Create the GL entries specific for Inventory Receipt
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
					EXEC	@intReturnValue = uspICCreateReceiptGLEntries
							@strBatchId 
							,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
							,@intEntityUserSecurityId
					IF @intReturnValue < 0 GOTO With_Rollback_Exit
				END 			
			END
		END

		-- Reduce In-Transit stocks coming from Inbound Shipment. 
		IF	EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)	
			AND @intSourceType = @SOURCE_TYPE_InboundShipment 
			AND @strFobPoint = 'Origin'					
		BEGIN 
			-- Get values for the In-Transit Costing 
			INSERT INTO @ItemsForInTransitCosting (
					[intItemId] 
					,[intItemLocationId] 
					,[intItemUOMId] 
					,[dtmDate] 
					,[dblQty] 
					,[dblUOMQty] 
					,[dblCost] 
					,[dblForexCost]
					,[dblValue] 
					,[dblSalesPrice] 
					,[intCurrencyId] 
					,[dblExchangeRate] 
					,[intTransactionId] 
					,[intTransactionDetailId] 
					,[strTransactionId] 
					,[intTransactionTypeId] 
					,[intLotId] 
					,[intSourceTransactionId] 
					,[strSourceTransactionId] 
					,[intSourceTransactionDetailId]
					,[intFobPointId]
					,[intInTransitSourceLocationId]
					,[intForexRateTypeId]
					,[dblForexRate]
					,[intSourceEntityId]
					,[strBOLNumber]
					,[intTicketId]
					,[strSourceType]
					,[strSourceNumber]
			)
			SELECT
					t.[intItemId] 
					,t.[intItemLocationId] 
					,t.intItemUOMId
					,r.[dtmReceiptDate] 
					,dblQty = 
						-ri.dblOpenReceive
						--CASE 
						--	WHEN ri.intComputeItemTotalOption = 1 AND t.intItemUOMId = ri.intUnitMeasureId THEN -ri.dblOpenReceive
						--	WHEN ri.intComputeItemTotalOption = 0 AND t.intItemUOMId = ri.intWeightUOMId THEN -ri.dblNet 
						--	ELSE 
						--		-ri.dblOpenReceive
						--END 
					,t.[dblUOMQty] 
					,t.[dblCost] 
					,t.[dblForexCost]
					,t.[dblValue] 
					,t.[dblSalesPrice] 
					,t.[intCurrencyId] 
					,t.[dblExchangeRate] 
					,[intTransactionId] = r.intInventoryReceiptId 
					,[intTransactionDetailId] = ri.intInventoryReceiptItemId
					,[strTransactionId] = r.strReceiptNumber
					,[intTransactionTypeId] = @INVENTORY_RECEIPT_TYPE  
					,t.[intLotId]
					,t.[intTransactionId] 
					,t.[strTransactionId] 
					,t.[intTransactionDetailId] 
					,t.[intFobPointId] 
					,[intInTransitSourceLocationId] = t.intInTransitSourceLocationId
					,[intForexRateTypeId] = t.intForexRateTypeId
					,[dblForexRate] = t.dblForexRate
					,[intSourceEntityId] = r.intEntityVendorId
					,strBOLNumber = r.strBillOfLading
					,intTicketId = CASE WHEN r.intSourceType = 1 THEN ri.intSourceId ELSE NULL END 
					,[strSourceType] = v.strSourceType
					,[strSourceNumber] = v.strSourceNumber 

			FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
						ON r.intInventoryReceiptId = ri.intInventoryReceiptId
					INNER JOIN vyuICGetReceiptItemSource v
						ON v.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
						AND v.intInventoryReceiptId = v.intInventoryReceiptId
					INNER JOIN vyuLGLoadContainerLookup loadShipmentLookup
						ON loadShipmentLookup.intLoadDetailId = ri.intSourceId
						AND loadShipmentLookup.intLoadContainerId = ri.intContainerId 
					INNER JOIN tblICInventoryTransaction t 
						ON t.strTransactionId = loadShipmentLookup.strLoadNumber
						AND t.intTransactionDetailId = loadShipmentLookup.intLoadDetailId
					LEFT JOIN tblICItemLocation il 
						ON il.intLocationId = r.intLocationId
						AND il.intItemId = ri.intItemId 
					LEFT JOIN tblICItemUOM iu 
						ON iu.intItemUOMId = ri.intUnitMeasureId
					LEFT JOIN tblICItem i 
						ON ri.intItemId = i.intItemId 

			WHERE	r.strReceiptNumber = @strTransactionId
					AND t.ysnIsUnposted = 0 
					AND (
						t.intFobPointId = @FOB_ORIGIN
						OR (@intSourceType = @SOURCE_TYPE_TransferShipment)
					)
					AND t.dblQty > 0
					AND i.strType <> 'Bundle' -- Do not include Bundle items in the in-transit costing. Bundle components are the ones included in the in-transit costing. 
					
			-- Update the @ItemsForPost for source type and source no.
			BEGIN
				UPDATE i
				SET
					i.strSourceType = v.strSourceType
					,i.strSourceNumber = v.strSourceNumber			
				FROM 
					@ItemsForInTransitCosting i INNER JOIN vyuICGetReceiptItemSource v
						ON i.intTransactionDetailId = v.intInventoryReceiptItemId
						AND i.intTransactionId = v.intInventoryReceiptId
			END 

			IF EXISTS (SELECT TOP 1 1 FROM @ItemsForInTransitCosting)
			BEGIN 

				-- Call the post routine for the In-Transit costing (Inbound Shipment) 
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
				EXEC	@intReturnValue = dbo.uspICPostInTransitCosting  
						@ItemsForInTransitCosting  
						,@strBatchId  
						,NULL -- 'Inventory' 
						,@intEntityUserSecurityId
			END 

			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END 

		-- Reduce In-Transit stocks coming from Transfer Order (Inventory Transfer) 
		ELSE IF	(
				@receiptType = @RECEIPT_TYPE_TRANSFER_ORDER
				AND @intSourceType <> @SOURCE_TYPE_TransferShipment
			) 			
			AND EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)	
		BEGIN 
			-- Get values for the In-Transit Costing 
			INSERT INTO @ItemsForTransferOrder (
					[intItemId] 
					,[intItemLocationId] 
					,[intItemUOMId] 
					,[dtmDate] 
					,[dblQty] 
					,[dblUOMQty] 
					,[dblCost] 
					,[intCurrencyId] 
					,[dblExchangeRate] 
					,[intTransactionId] 
					,[intTransactionDetailId] 
					,[strTransactionId] 
					,[intTransactionTypeId] 
					,[intLotId] 
					,[intSourceTransactionId] 
					,[strSourceTransactionId] 
					,[intSourceTransactionDetailId]					
					,[intInTransitSourceLocationId]
					,[intForexRateTypeId]
					,[dblForexRate]
					,[intSourceEntityId]
					,[strBOLNumber]
					,[intTicketId]
					,[strSourceType]
					,[strSourceNumber]
			)
			SELECT 
					[intItemId]				= t.intItemId  
					,[intItemLocationId]	= t.intItemLocationId
					,[intItemUOMId]			= t.intItemUOMId
					,[dtmDate]				= r.dtmReceiptDate
					,[dblQty]				= 
							CASE 
								WHEN ri.intUnitMeasureId = t.intItemUOMId THEN -ri.dblOpenReceive 
								WHEN ri.intWeightUOMId = t.intItemUOMId THEN -ri.dblNet
								ELSE 
									dbo.fnCalculateQtyBetweenUOM(
										ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId)
										,t.intItemUOMId
										,CASE 
											WHEN ri.intWeightUOMId IS NOT NULL THEN 
												-ri.dblNet
											ELSE 
												-ri.dblOpenReceive
										END 								
									)
							END 
									
					,[dblUOMQty]			= t.dblUOMQty
					,[dblCost]				= valuationCost.dblCost 
					,[intCurrencyId]		= t.intCurrencyId
					,[dblExchangeRate]		= t.dblExchangeRate
					,[intTransactionId]		= r.intInventoryReceiptId
					,[intTransactionDetailId]	= ri.intInventoryReceiptItemId
					,[strTransactionId]			= r.strReceiptNumber
					,[intTransactionTypeId]		= @INVENTORY_RECEIPT_TYPE
					,[intLotId]					= t.intLotId
					,[intSourceTransactionId]	= t.intTransactionId
					,[strSourceTransactionId]	= t.strTransactionId
					,[intSourceTransactionDetailId] = t.intTransactionDetailId
					,[intInTransitSourceLocationId] = dbo.fnICGetItemLocation(t.intItemId, r.intTransferorId)
					,[intForexRateTypeId]			= t.intForexRateTypeId --ri.intForexRateTypeId
					,[dblForexRate]					= t.dblForexRate --ri.dblForexRate
					,[intSourceEntityId]		= NULL 
					,[strBOLNumber] = r.strBillOfLading
					,[intTicketId] = ri.intTicketId 
					,[strSourceType] = v.strSourceType
					,[strSourceNumber] = v.strSourceNumber
			FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
						ON r.intInventoryReceiptId = ri.intInventoryReceiptId
					INNER JOIN tblICItem i
						ON i.intItemId = ri.intItemId
					INNER JOIN vyuICGetReceiptItemSource v
						ON ri.intInventoryReceiptItemId = v.intInventoryReceiptItemId
						AND r.intInventoryReceiptId = v.intInventoryReceiptId
					CROSS APPLY (
						SELECT 
							dblCost = 
								dbo.fnDivide(
									SUM(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0))
									,SUM(ISNULL(t.dblQty, 0))
								)							
						FROM 				
							tblICInventoryTransfer th INNER JOIN tblICInventoryTransferDetail td 
								ON th.intInventoryTransferId = td.intInventoryTransferId
							INNER JOIN tblICInventoryTransaction t 
								ON t.strTransactionId = th.strTransferNo
								AND t.intTransactionDetailId = td.intInventoryTransferDetailId						
								AND t.intItemId = ri.intItemId 
								AND t.dblQty > 0 
								AND t.ysnIsUnposted = 0 
						WHERE
							td.intItemId = ri.intItemId 
							AND (
								(
									td.intInventoryTransferDetailId = ri.intSourceId
									AND td.intInventoryTransferId = ri.intOrderId
									AND ri.intInventoryTransferDetailId IS NULL 
									AND ri.intInventoryTransferId IS NULL 
								)
								OR (
									td.intInventoryTransferDetailId = ri.intInventoryTransferDetailId
									AND td.intInventoryTransferId = ri.intInventoryTransferId
								)
							)
					) valuationCost 		
					CROSS APPLY (
						SELECT TOP 1
							t.*
						FROM 				
							tblICInventoryTransfer th INNER JOIN tblICInventoryTransferDetail td 
								ON th.intInventoryTransferId = td.intInventoryTransferId
							INNER JOIN tblICInventoryTransaction t 
								ON t.strTransactionId = th.strTransferNo
								AND t.intTransactionDetailId = td.intInventoryTransferDetailId						
								AND t.intItemId = ri.intItemId 
								AND t.dblQty > 0 
								AND t.ysnIsUnposted = 0 
						WHERE
							td.intItemId = ri.intItemId 
							AND (
								(
									td.intInventoryTransferDetailId = ri.intSourceId
									AND td.intInventoryTransferId = ri.intOrderId
									AND ri.intInventoryTransferDetailId IS NULL 
									AND ri.intInventoryTransferId IS NULL 
								)
								OR (
									td.intInventoryTransferDetailId = ri.intInventoryTransferDetailId
									AND td.intInventoryTransferId = ri.intInventoryTransferId
								)
							)
					) t

			WHERE	r.strReceiptNumber = @strTransactionId
					AND i.strType <> 'Bundle' -- Do not include Bundle items in the in-transit costing. Bundle components are the ones included in the in-transit costing. 				

			IF EXISTS (SELECT TOP 1 1 FROM @ItemsForTransferOrder)
			BEGIN 
				-- Call the post routine for the In-Transit costing. 
				INSERT INTO @DummyGLEntries (
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
				EXEC	@intReturnValue = dbo.uspICPostInTransitCosting  
						@ItemsForTransferOrder  
						,@strBatchId  
						,'Inventory'
						,@intEntityUserSecurityId
			END 

			IF @intReturnValue < 0 GOTO With_Rollback_Exit
						
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
			EXEC	@intReturnValue = dbo.uspICCreateReceiptGLEntriesForInTransit
					@strBatchId  
					,'Inventory'
					,@intEntityUserSecurityId
					,DEFAULT 
					,@intLocationId

			IF @intReturnValue < 0 GOTO With_Rollback_Exit			
		END 

		-- Reduce In-Transit stocks coming from Logistics - Transfer Shipment 
		ELSE IF	(
				@receiptType = @RECEIPT_TYPE_TRANSFER_ORDER 
				AND @intSourceType = @SOURCE_TYPE_TransferShipment
			) 			
			AND EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)	
		BEGIN 
			-- Get values for the In-Transit Costing 
			INSERT INTO @ItemsForTransferOrder (
					[intItemId] 
					,[intItemLocationId] 
					,[intItemUOMId] 
					,[dtmDate] 
					,[dblQty] 
					,[dblUOMQty] 
					,[dblCost] 
					,[dblForexCost]
					,[intCurrencyId] 
					,[dblExchangeRate] 
					,[intTransactionId] 
					,[intTransactionDetailId] 
					,[strTransactionId] 
					,[intTransactionTypeId] 
					,[intLotId] 
					,[intSourceTransactionId] 
					,[strSourceTransactionId] 
					,[intSourceTransactionDetailId]					
					,[intInTransitSourceLocationId]
					,[intForexRateTypeId]
					,[dblForexRate]
					,[intSourceEntityId]
					,[strBOLNumber]
					,[intTicketId]
					,[strSourceType]
					,[strSourceNumber]
			)
			SELECT 
					[intItemId]				= t.intItemId  
					,[intItemLocationId]	= t.intItemLocationId
					,[intItemUOMId]			= t.intItemUOMId
					,[dtmDate]				= r.dtmReceiptDate
					,[dblQty]				= 
							CASE 
								WHEN ri.intUnitMeasureId = t.intItemUOMId THEN -ri.dblOpenReceive 
								WHEN ri.intWeightUOMId = t.intItemUOMId THEN -ri.dblNet
								ELSE 
									dbo.fnCalculateQtyBetweenUOM(
										ISNULL(ri.intWeightUOMId, ri.intUnitMeasureId)
										,t.intItemUOMId
										,CASE 
											WHEN ri.intWeightUOMId IS NOT NULL THEN 
												-ri.dblNet
											ELSE 
												-ri.dblOpenReceive
										END 								
									)
							END 
									
					,[dblUOMQty]			= t.dblUOMQty
					,[dblCost]				= valuationCost.dblCost 							
					,[dblForexCost]			= valuationCost.dblForexCost 
					,[intCurrencyId]		= t.intCurrencyId
					,[dblExchangeRate]		= t.dblExchangeRate
					,[intTransactionId]		= r.intInventoryReceiptId
					,[intTransactionDetailId]	= ri.intInventoryReceiptItemId
					,[strTransactionId]			= r.strReceiptNumber
					,[intTransactionTypeId]		= @INVENTORY_RECEIPT_TYPE
					,[intLotId]					= t.intLotId
					,[intSourceTransactionId]	= t.intInventoryTransactionId
					,[strSourceTransactionId]	= t.strTransactionId
					,[intSourceTransactionDetailId] = t.intTransactionDetailId
					,[intInTransitSourceLocationId] = dbo.fnICGetItemLocation(t.intItemId, r.intTransferorId)
					,[intForexRateTypeId]			= t.intForexRateTypeId --ri.intForexRateTypeId
					,[dblForexRate]					= t.dblForexRate --ri.dblForexRate
					,[intSourceEntityId]		= NULL 
					,[strBOLNumber] = r.strBillOfLading
					,[intTicketId] = ri.intTicketId 
					,[strSourceType] = v.strSourceType
					,[strSourceNumber] = v.strSourceNumber
			FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
						ON r.intInventoryReceiptId = ri.intInventoryReceiptId
					INNER JOIN tblICItem i
						ON i.intItemId = ri.intItemId
					INNER JOIN vyuICGetReceiptItemSource v
						ON ri.intInventoryReceiptItemId = v.intInventoryReceiptItemId
						AND r.intInventoryReceiptId = v.intInventoryReceiptId
					INNER JOIN vyuLGLoadContainerLookup loadShipmentLookup
						ON loadShipmentLookup.intLoadDetailId = ri.intSourceId
						AND loadShipmentLookup.intLoadContainerId = ri.intContainerId 
					CROSS APPLY (
						SELECT 
							dblCost = 
								dbo.fnDivide(
									SUM(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0))
									,SUM(ISNULL(t.dblQty, 0))
								)
							,dblForexCost = 
								dbo.fnDivide(
									SUM(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblForexCost, 0)))
									,SUM(ISNULL(t.dblQty, 0))
								)
						FROM 				
							tblICInventoryTransaction t 
						WHERE 
							t.strTransactionId = loadShipmentLookup.strLoadNumber
							AND t.intTransactionDetailId = loadShipmentLookup.intLoadDetailId	
							AND t.intItemId = ri.intItemId 
							AND t.dblQty > 0 
							AND t.ysnIsUnposted = 0 
					) valuationCost 		
					CROSS APPLY (
						SELECT TOP 1
							t.*
						FROM 				
							tblICInventoryTransaction t 
						WHERE 
							t.strTransactionId = loadShipmentLookup.strLoadNumber
							AND t.intTransactionDetailId = loadShipmentLookup.intLoadDetailId	
							AND t.intItemId = ri.intItemId 
							AND t.dblQty > 0 
							AND t.ysnIsUnposted = 0 
					) t

			WHERE	r.strReceiptNumber = @strTransactionId
					AND t.ysnIsUnposted = 0 				
					AND t.dblQty > 0
					AND i.strType <> 'Bundle' -- Do not include Bundle items in the in-transit costing. Bundle components are the ones included in the in-transit costing. 		

			IF EXISTS (SELECT TOP 1 1 FROM @ItemsForTransferOrder)
			BEGIN 
				-- Call the post routine for the In-Transit costing. 
				INSERT INTO @DummyGLEntries (
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
				EXEC	@intReturnValue = dbo.uspICPostInTransitCosting  
						@ItemsForTransferOrder  
						,@strBatchId  
						,'Inventory'
						,@intEntityUserSecurityId
			END 

			IF @intReturnValue < 0 GOTO With_Rollback_Exit

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
			EXEC	@intReturnValue = dbo.uspICCreateReceiptGLEntriesForInTransit
					@strBatchId  
					,'Inventory'
					,@intEntityUserSecurityId
					,DEFAULT 
					,@intLocationId

			IF @intReturnValue < 0 GOTO With_Rollback_Exit			
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
				,intSourceEntityId
				,strBOLNumber 
				,intTicketId
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
											,DetailItem.ysnSubCurrency
											,Header.intSubCurrencyCents
											,DEFAULT 
											,DetailItem.intComputeItemTotalOption
											,DetailItem.dblOpenReceive
										)
										--/ Header.intSubCurrencyCents 

										-- (B) Other Charge
										+ 
										dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
										--CASE 
										--	WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
										--		-- Convert the other charge to the currency used by the detail item. 
										--		dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) / DetailItem.dblForexRate
										--	ELSE 
										--		-- No conversion. Detail item is already in functional currency. 
										--		dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
										--END 									

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
											,DEFAULT 
											,DetailItem.intComputeItemTotalOption
											,DetailItem.dblOpenReceive
										)
										-- (B) Other Charge
										+ 
										dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
										--CASE 
										--	WHEN ISNULL(Header.intCurrencyId, @intFunctionalCurrencyId) <> @intFunctionalCurrencyId AND ISNULL(DetailItem.dblForexRate, 0) <> 0 THEN 
										--		-- Convert the other charge to the currency used by the detail item. 
										--		dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT) / DetailItem.dblForexRate
										--	ELSE 
										--		-- No conversion. Detail item is already in functional currency. 
										--		dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId, DEFAULT)
										--END
									)
							END

				,dblSalesPrice = 0  
				,intCurrencyId = Header.intCurrencyId  
				,dblExchangeRate = 1  
				,intTransactionId = Header.intInventoryReceiptId  
				,intTransactionDetailId  = DetailItem.intInventoryReceiptItemId
				,strTransactionId = Header.strReceiptNumber  
				,intTransactionTypeId = @INVENTORY_RECEIPT_TYPE  
				,intLotId = DetailItemLot.intLotId 
				,intSubLocationId = DetailItem.intSubLocationId -- ISNULL(DetailItemLot.intSubLocationId, DetailItem.intSubLocationId) 
				,intStorageLocationId = ISNULL(DetailItemLot.intStorageLocationId, DetailItem.intStorageLocationId)
				,intInTransitSourceLocationId = InTransitSourceLocation.intItemLocationId
				,intForexRateTypeId = DetailItem.intForexRateTypeId
				,dblForexRate = DetailItem.dblForexRate
				,intSourceEntityId = Header.intEntityVendorId
				,strBOLNumber = Header.strBillOfLading 
				,intTicketId = CASE WHEN Header.intSourceType = 1 THEN DetailItem.intSourceId ELSE NULL END 
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
				LEFT JOIN tblICItem i
					ON DetailItem.intItemId = i.intItemId
		WHERE	Header.intInventoryReceiptId = @intTransactionId   
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_Own) <> @OWNERSHIP_TYPE_Own
				AND i.strType <> 'Bundle' -- Do not include Bundle items in the in-transit costing. Bundle components are the ones included in the in-transit costing. 

		-- Update the @ItemsForPost for source type and source no.
		BEGIN
			UPDATE i
			SET
				i.strSourceType = v.strSourceType
				,i.strSourceNumber = v.strSourceNumber			
			FROM 
				@StorageItemsForPost i INNER JOIN vyuICGetReceiptItemSource v
					ON i.intTransactionDetailId = v.intInventoryReceiptItemId
					AND i.intTransactionId = v.intInventoryReceiptId
		END		
		
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
					,dblForexCost = dblCost 
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
			,[intSourceEntityId]
			,[intCommodityId]
		)	
		EXEC dbo.uspICPostInventoryReceiptTaxes 
			@intTransactionId
			,@strBatchId
			,@intEntityUserSecurityId
			,@INVENTORY_RECEIPT_TYPE		
	END 

	-- Process the GL Entries for the Non-Stock Items
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
		EXEC	@intReturnValue = uspICCreateReceiptGLEntriesForNonStockItems
					@NonInventoryItemsForPost 
					,@strBatchId 
					,@intTransactionId 
					,@intEntityUserSecurityId 					

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END
	
	-- Process the GL entries for Missing Stocks
	BEGIN 
		IF EXISTS (SELECT TOP 1 1 FROM @MissingLotsForPost)
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
			EXEC	@intReturnValue = dbo.uspICPostMissingLot
					@MissingLotsToPost = @MissingLotsForPost
					,@strBatchId = @strBatchId
					,@intEntityUserSecurityId = @intEntityUserSecurityId
		END
	END 

	-- Process the decimal discrepancy
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
		EXEC @intReturnValue = uspICCreateReceiptGLEntriesToFixDecimalDiscrepancy
			@strReceiptNumber = @strTransactionId
			,@strBatchId = @strBatchId
			,@GLEntries = @GLEntries
			,@intEntityUserSecurityId = @intEntityUserSecurityId

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END	
END   

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 0   
BEGIN   
	-- Call the default unpost routine. 
	IF ISNULL(@strUnpostMode, 'Default') = 'Default' 
		OR (
			ISNULL(@strUnpostMode, 'Default') = 'Force Purchase Contract Unpost' 
			AND @receiptType <> @RECEIPT_TYPE_PURCHASE_CONTRACT
		)
	BEGIN 
		-- Unpost the non-inventory items
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
			EXEC dbo.uspICCreateReversalGLEntriesForNonStockItems
				@strBatchId
				,@intTransactionId
				,@strTransactionId
				,@intEntityUserSecurityId
			;
		END 

		-- Unpost the company owned stocks. 
		-- This will also include the unposting of the missing lots. 
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
				,[intSourceEntityId]
				,[intCommodityId]
			)	
			EXEC @intReturnValue = dbo.uspICPostInventoryReceiptOtherCharges 
				@intTransactionId
				,@strBatchId
				,@intEntityUserSecurityId
				,@INVENTORY_RECEIPT_TYPE	
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
				,@INVENTORY_RECEIPT_TYPE	
						
			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END

		---- Unpost the the decimal discrepancy
		--BEGIN 
		--	INSERT INTO @GLEntries (
		--			[dtmDate] 
		--			,[strBatchId]
		--			,[intAccountId]
		--			,[dblDebit] 
		--			,[dblCredit]					
		--			,[dblDebitUnit]
		--			,[dblCreditUnit]
		--			,[strDescription]
		--			,[strCode]
		--			,[strReference]
		--			,[intCurrencyId]
		--			,[dblExchangeRate]
		--			,[dtmDateEntered]
		--			,[dtmTransactionDate]
		--			,[strJournalLineDescription]
		--			,[intJournalLineNo]
		--			,[ysnIsUnposted]
		--			,[intUserId]
		--			,[intEntityId]
		--			,[strTransactionId]
		--			,[intTransactionId]
		--			,[strTransactionType]
		--			,[strTransactionForm]
		--			,[strModuleName]
		--			,[intConcurrencyId]
		--			,[dblDebitForeign]
		--			,[dblDebitReport]	
		--			,[dblCreditForeign]	
		--			,[dblCreditReport]	
		--			,[dblReportingRate]	
		--			,[dblForeignRate]
		--			,[strRateType]
		--			,[intSourceEntityId]
		--			,[intCommodityId]
		--	)
		--	EXEC @intReturnValue = uspICCreateReceiptGLEntriesToFixDecimalDiscrepancy
		--		@strReceiptNumber = @strTransactionId
		--		,@strBatchId = @strBatchId
		--		,@GLEntries = @GLEntries
		--		,@intEntityUserSecurityId = @intEntityUserSecurityId
		--		,@ysnPost = 0 

		--	IF @intReturnValue < 0 GOTO With_Rollback_Exit
		--END	

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

		-- Update the Lot's Qty and Weights. 
		BEGIN 
			UPDATE	Lot 
			SET		Lot.dblQty = 0
					,Lot.dblWeight = 0			
			FROM	dbo.tblICLot Lot INNER JOIN tblICInventoryReceiptItemLot ril
						ON Lot.intLotId = ril.intLotId
					INNER JOIN tblICInventoryReceiptItem ri
						ON ril.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
						AND Lot.intItemId = ri.intItemId
					INNER JOIN tblICInventoryReceipt r
						ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			WHERE
					r.strReceiptNumber = @strTransactionId
					AND ril.strCondition = 'Missing'
					AND r.ysnPosted = 0

			UPDATE	Lot 
			SET		Lot.dblTare = 0
					,Lot.dblGrossWeight = 0
			FROM	dbo.tblICLot Lot INNER JOIN tblICInventoryReceiptItemLot ril
						ON Lot.intLotId = ril.intLotId
					INNER JOIN tblICInventoryReceiptItem ri
						ON ril.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
						AND Lot.intItemId = ri.intItemId
					INNER JOIN tblICInventoryReceipt r
						ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			WHERE
					r.strReceiptNumber = @strTransactionId
					AND ril.strCondition = 'Missing'
					AND r.ysnPosted = 0
					AND ISNULL(Lot.dblTarePerQty, 0) <> 0 				
		END 
				
		-- Unpost the IC-AP-Clearing
		BEGIN 
			INSERT INTO tblICAPClearing (
				[intTransactionId]
				,[strTransactionId]
				,[intTransactionType]
				,[strReferenceNumber]
				,[dtmDate]
				,[intEntityVendorId]
				,[intLocationId]
				,[intInventoryReceiptItemId]
				,[intInventoryReceiptItemTaxId]
				,[intInventoryReceiptChargeId]
				,[intInventoryReceiptChargeTaxId]
				,[intInventoryShipmentChargeId]
				,[intInventoryShipmentChargeTaxId]
				,[intAccountId]
				,[intItemId]
				,[intItemUOMId]
				,[dblQuantity]
				,[dblAmount]
				,[strBatchId]
			)
			SELECT 
				[intTransactionId]
				,[strTransactionId]
				,[intTransactionType]
				,[strReferenceNumber]
				,[dtmDate]
				,[intEntityVendorId]
				,[intLocationId]
				,[intInventoryReceiptItemId]
				,[intInventoryReceiptItemTaxId]
				,[intInventoryReceiptChargeId]
				,[intInventoryReceiptChargeTaxId]
				,[intInventoryShipmentChargeId]
				,[intInventoryShipmentChargeTaxId]
				,[intAccountId]
				,[intItemId]
				,[intItemUOMId]
				,[dblQuantity]
				,[dblAmount]
				,[strBatchId] = @strBatchId
			FROM 
				tblICAPClearing
			WHERE
				strTransactionId = @strTransactionId
				AND ysnIsUnposted = 0 
		END 		
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
		,[intFOBPointId]
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
			,[intStorageLocationId]	= ISNULL(ril.intStorageLocationId, ri.intStorageLocationId) 
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
			,[intFOBPointId]		= @FOB_DESTINATION
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
			,[intFOBPointId]
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
			,[intStorageLocationId]	= ISNULL(ril.intStorageLocationId, ri.intStorageLocationId) 
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
			,[intFOBPointId]		= @FOB_DESTINATION
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

	-- Update the Inbound and Outbound In-Transit Qty for the Transfer Orders. 
	EXEC dbo.uspICIncreaseInTransitOutBoundQty @InTransit_Outbound
	EXEC dbo.uspICIncreaseInTransitInBoundQty @InTransit_Inbound
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
		IF @ysnPost = 1 
		BEGIN 
			-- Post preview is not available. Financials are only booked for company-owned stocks.
			EXEC uspICRaiseError 80185; 		
		END 
			
		IF @ysnPost = 0 AND ISNULL(@strUnpostMode, 'Default') = 'Default' 
		BEGIN 
			-- Post preview is not available. Financials are only booked for company-owned stocks.
			EXEC uspICRaiseError 80185; 			
		END 
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

	-- Allow blank GL entries if unpost mode is not set to 'default'. 
	IF @ysnAllowBlankGLEntries = 0 AND @ysnPost = 0 AND ISNULL(@strUnpostMode, 'Default') <> 'Default'
	BEGIN 
		SET @ysnAllowBlankGLEntries = 1
	END 

	IF @ysnAllowBlankGLEntries = 0 OR EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
	END 	

	-- Add the AP Clearing
	BEGIN 
		DECLARE @APClearing AS APClearing

		INSERT INTO @APClearing (
			[intTransactionId]
			,[strTransactionId]
			,[intTransactionType]
			,[strReferenceNumber]
			,[dtmDate]
			,[intEntityVendorId]
			,[intLocationId]
			,[intTransactionDetailId]
			,[intAccountId]
			,[intItemId]
			,[intItemUOMId]
			,[dblQuantity]
			,[dblAmount]	
			,[strCode]
		)
		SELECT DISTINCT 
			[intTransactionId]
			,[strTransactionId]
			,[intTransactionType]
			,[strReferenceNumber]
			,[dtmDate]
			,[intEntityVendorId]
			,[intLocationId]
			,[intTransactionDetailId] = 
				COALESCE(
					intInventoryReceiptItemId
					,intInventoryReceiptChargeId					
				)
			,[intAccountId]
			,[intItemId]
			,[intItemUOMId]
			,[dblQuantity]
			,[dblAmount] = g.dblAmount
			,[strCode] = 'IR'
		FROM 
			tblICAPClearing ap
			CROSS APPLY (
				SELECT 
					dblAmount = SUM(g.dblAmount) 
				FROM
					tblICAPClearing g
				WHERE
					g.strBatchId = @strBatchId
					AND (
						(g.intInventoryReceiptItemId = ap.intInventoryReceiptItemId AND ap.intInventoryReceiptItemId IS NOT NULL)
						OR (g.intInventoryReceiptChargeId = ap.intInventoryReceiptChargeId AND ap.intInventoryReceiptChargeId IS NOT NULL)
					)
			) g
		WHERE
			strBatchId = @strBatchId

		EXEC dbo.uspAPClearing
			@APClearing
			,@ysnPost

		-- Update the IC-AP Clearing when unposting the transaction. 
		IF @ysnPost = 0 
		BEGIN 			
			UPDATE tblICAPClearing
			SET 				
				dblQuantity = -dblQuantity -- Negate the Qty
				,dblAmount = -dblAmount -- Negate the Amount 				
			WHERE 
				strTransactionId = @strTransactionId
				AND strBatchId = @strBatchId

			UPDATE tblICAPClearing
			SET 
				ysnIsUnposted = 1 -- Flag the AP Clearing as unposted. 
			WHERE 
				strTransactionId = @strTransactionId
				AND ysnIsUnposted = 0 
		END 
	END 

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
	RETURN -1
END

Post_Exit:
