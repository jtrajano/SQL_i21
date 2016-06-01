﻿CREATE PROCEDURE uspICPostInventoryReceipt  
	@ysnPost BIT  = 0  
	,@ysnRecap BIT  = 0  
	,@strTransactionId NVARCHAR(40) = NULL   
	,@intEntityUserSecurityId AS INT = NULL 
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
		
		,@OWNERSHIP_TYPE_Own AS INT = 1
		,@OWNERSHIP_TYPE_Storage AS INT = 2
		,@OWNERSHIP_TYPE_ConsignedPurchase AS INT = 3
		,@OWNERSHIP_TYPE_ConsignedSale AS INT = 4

-- Posting variables
DECLARE @strBatchId AS NVARCHAR(40) 
		,@strItemNo AS NVARCHAR(50)
		,@intItemId AS INT
		,@ysnAllowBlankGLEntries AS BIT = 1

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
	DECLARE @intTransactionId AS INT  
	DECLARE @intCreatedEntityId AS INT  
	DECLARE @ysnAllowUserSelfPost AS BIT   
	DECLARE @ysnTransactionPostedFlag AS BIT  
  
	SELECT TOP 1   
			@intTransactionId = intInventoryReceiptId  
			,@ysnTransactionPostedFlag = ysnPosted  
			,@dtmDate = dtmReceiptDate  
			,@intCreatedEntityId = intEntityId  
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
			-- 'Unable to Unreceive. The {Other Charge} is already billed in {Bill Id}.'
			RAISERROR(51174, 11, 1, @strChargeItem, @strBillNumber)  
			GOTO Post_Exit    
		END 

	END 

	-------------------------------------------------------------------------------------
	-- Note: Need to change this validation as a settable configuration in IC. 
	-- Dallmayr seems to use Item Net weight as the "received weight". 
	-- They clean the coffee per lot. Net wgt at Lot is the actual wgt. 
	-- See IC-2176 for more info. 
	-------------------------------------------------------------------------------------
	-- Do not allow post if there is Gross/Net UOM and there is a Net Qty mismatch between the line item and its lot. 
	--IF @ysnPost = 1 AND @ysnRecap = 0 
	--BEGIN 
	--	SET @intItemId = NULL 
	--	SET @strItemNo = NULL 

	--	DECLARE @strNetQty AS NVARCHAR(50)
	--			,@strLotNetQty AS NVARCHAR(50)

	--	SELECT	TOP 1 
	--			@intItemId = Item.intItemId
	--			,@strItemNo = Item.strItemNo
	--			,@strNetQty = CONVERT(NVARCHAR, CAST(ReceiptItem.dblNet AS MONEY), 1)
	--			,@strLotNetQty = CONVERT(NVARCHAR, CAST(ReceiptItemLot.dblTotalLotNet AS MONEY), 1)
	--	FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
	--				ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId				
	--			INNER JOIN dbo.tblICItem Item
	--				ON Item.intItemId = ReceiptItem.intItemId
	--			INNER JOIN (
	--				SELECT	dblTotalLotNet = SUM(ISNULL(dblGrossWeight, 0) - ISNULL(dblTareWeight, 0))
	--						,intInventoryReceiptItemId
	--				FROM	dbo.tblICInventoryReceiptItemLot 
	--				GROUP BY intInventoryReceiptItemId					
	--			) ReceiptItemLot 
	--				ON ReceiptItemLot.intInventoryReceiptItemId = ReceiptItem.intInventoryReceiptItemId
	--	WHERE	Receipt.intInventoryReceiptId = @intTransactionId
	--			AND ReceiptItem.intWeightUOMId IS NOT NULL 
	--			AND dbo.fnGetItemLotType(ReceiptItem.intItemId) IN (1, 2)  
	--			AND ReceiptItem.dblNet <> ReceiptItemLot.dblTotalLotNet

	--	IF @intItemId IS NOT NULL 
	--	BEGIN 
	--		-- 'Net quantity mistmatch. It is {Net Qty} on item {Item} but the total net from the lot(s) is {Lot total Net Qty}.'
	--		RAISERROR(80081, 11, 1, @strNetQty, @strItemNo, @strLotNetQty)  
	--		GOTO Post_Exit    
	--	END 
	--END 

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

END

-- Get the next batch number
BEGIN 
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
							CASE	
									WHEN DetailItem.intWeightUOMId IS NOT NULL THEN 
										-- Convert the Cost UOM to Gross/Net UOM. 
										dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItem.intWeightUOMId, DetailItem.dblUnitCost) 
										+ dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId)

									-- If Gross/Net UOM is missing, 
									ELSE 
											CASE	
													-- If non-lot, convert the cost Cost UOM to Receive UOM
													WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 
														-- Convert the Cost UOM to Item UOM. 
														dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItem.intUnitMeasureId, DetailItem.dblUnitCost) 
														+ dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId)
													
													-- If lot, convert the cost Cost UOM to Lot UOM
													ELSE 														
														dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItemLot.intItemUnitMeasureId, DetailItem.dblUnitCost) 
														+ dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId)
											END 

							END
							-- and then convert the cost to the sub-currency value. 
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
				,strActualCostId = Header.strActualCostId
		FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICItemLocation ItemLocation
					ON Header.intLocationId = ItemLocation.intLocationId
				INNER JOIN dbo.tblICInventoryReceiptItem DetailItem 
					ON Header.intInventoryReceiptId = DetailItem.intInventoryReceiptId 
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

		WHERE	Header.intInventoryReceiptId = @intTransactionId   
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_Own) = @OWNERSHIP_TYPE_Own
  
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
			FROM	@ItemsForPost
			WHERE	dblQty > 0 

			-- Gather the item returns
			INSERT INTO @ReturnItemsForPost (
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
			FROM	@ItemsForPost
			WHERE	dblQty < 0 
			
			-- Call the post routine for posting the company owned items 
			IF EXISTS (SELECT TOP 1 1 FROM @CompanyOwnedItemsForPost)
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
				)
				EXEC	@intReturnValue = dbo.uspICPostCosting  
						@CompanyOwnedItemsForPost  
						,@strBatchId  
						,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
						,@intEntityUserSecurityId

				IF @intReturnValue < 0 GOTO With_Rollback_Exit
			END
		
			-- Call the post routine for posting the return items 
			IF EXISTS (SELECT TOP 1 1 FROM @ReturnItemsForPost)
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
				)
				EXEC	@intReturnValue = dbo.uspICPostReturnCosting  
						@ReturnItemsForPost  
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
		)  
		SELECT	intItemId = DetailItem.intItemId  
				,intItemLocationId = ItemLocation.intItemLocationId
				,intItemUOMId = 
							-- Use weight UOM id if it is present. Otherwise, use the qty UOM. 
							CASE	WHEN ISNULL(DetailItem.intWeightUOMId, 0) <> 0 THEN DetailItem.intWeightUOMId 
									ELSE DetailItem.intUnitMeasureId 
							END
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
							CASE	
									WHEN DetailItem.intWeightUOMId IS NOT NULL THEN 
										-- Convert the Cost UOM to Gross/Net UOM. 
										dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItem.intWeightUOMId, DetailItem.dblUnitCost) 
										+ dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId)

									-- If Gross/Net UOM is missing, 
									ELSE 
											CASE	
													-- If non-lot, convert the cost Cost UOM to Receive UOM
													WHEN ISNULL(DetailItemLot.intLotId, 0) = 0 AND dbo.fnGetItemLotType(DetailItem.intItemId) = 0 THEN 
														-- Convert the Cost UOM to Item UOM. 
														dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItem.intUnitMeasureId, DetailItem.dblUnitCost) 
														+ dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId)
													
													-- If lot, convert the cost Cost UOM to Lot UOM
													ELSE 														
														dbo.fnCalculateCostBetweenUOM(ISNULL(DetailItem.intCostUOMId, DetailItem.intUnitMeasureId), DetailItemLot.intItemUnitMeasureId, DetailItem.dblUnitCost) 
														+ dbo.fnGetOtherChargesFromInventoryReceipt(DetailItem.intInventoryReceiptItemId)
											END 

							END
							-- and then convert the cost to the sub-currency value. 
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
		FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICItemLocation ItemLocation
					ON Header.intLocationId = ItemLocation.intLocationId
				INNER JOIN dbo.tblICInventoryReceiptItem DetailItem 
					ON Header.intInventoryReceiptId = DetailItem.intInventoryReceiptId 
					AND ItemLocation.intItemId = DetailItem.intItemId
				LEFT JOIN dbo.tblICInventoryReceiptItemLot DetailItemLot
					ON DetailItem.intInventoryReceiptItemId = DetailItemLot.intInventoryReceiptItemId
				LEFT JOIN dbo.tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = DetailItem.intUnitMeasureId
				LEFT JOIN dbo.tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = DetailItemLot.intItemUnitMeasureId
				LEFT JOIN dbo.tblICItemUOM WeightUOM
					ON WeightUOM.intItemUOMId = DetailItem.intWeightUOMId
		WHERE	Header.intInventoryReceiptId = @intTransactionId   
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_Own) <> @OWNERSHIP_TYPE_Own
  
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
	EXEC dbo.uspCMPostRecap @GLEntries
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
