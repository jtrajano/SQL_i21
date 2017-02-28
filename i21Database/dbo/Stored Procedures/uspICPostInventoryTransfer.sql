CREATE PROCEDURE [dbo].[uspICPostInventoryTransfer]
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
DECLARE @TransactionName AS VARCHAR(500) = 'Inventory Transfer Transaction' + CAST(NEWID() AS NVARCHAR(100));

-- Constants  
DECLARE @INVENTORY_TRANSFER_TYPE AS INT = 12
		,@INVENTORY_TRANSFER_WITH_SHIPMENT_TYPE AS INT = 13

DECLARE @STARTING_NUMBER_BATCH AS INT = 3 
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory In-Transit'

-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Get the Inventory Receipt batch number
DECLARE @strBatchId AS NVARCHAR(40) 
		,@strItemNo AS NVARCHAR(50)

-- Create the gl entries variable 
DECLARE		@GLEntries AS RecapTableType 
			,@ysnGLEntriesRequired AS BIT = 0
			,@intReturnValue AS INT

DECLARE		@InTransit_Outbound AS InTransitTableType
			,@InTransit_Inbound AS InTransitTableType

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)  
 
-- Read the transaction info   
BEGIN   
	DECLARE @dtmDate AS DATETIME   
			,@intTransactionId AS INT  
			,@intCreatedEntityId AS INT  
			,@ysnAllowUserSelfPost AS BIT   
			,@ysnTransactionPostedFlag AS BIT  
			,@ysnShipmentRequired AS BIT
			,@intTransactionType AS INT 
			,@strGLDescription AS NVARCHAR(255)
  
	SELECT TOP 1   
			@intTransactionId = intInventoryTransferId
			,@ysnTransactionPostedFlag = ysnPosted
			,@dtmDate = dtmTransferDate
			,@intCreatedEntityId = intEntityId
			,@ysnShipmentRequired = ISNULL(ysnShipmentRequired, 0)
			,@strGLDescription = strDescription
	FROM	dbo.tblICInventoryTransfer
	WHERE	strTransferNo = @strTransactionId
END  

--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
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

-- Don't allow unpost when there's a receipt
IF @ysnPost = 0
BEGIN
	IF EXISTS(SELECT TOP 1 1
		FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
			INNER JOIN tblICInventoryTransfer t ON t.intInventoryTransferId = ri.intOrderId
			INNER JOIN tblICInventoryTransferDetail td ON td.intInventoryTransferId = t.intInventoryTransferId
				AND td.intInventoryTransferDetailId = ri.intLineNo
			INNER JOIN tblICItem i ON i.intItemId = td.intItemId
		WHERE r.strReceiptType = 'Transfer Order'
			AND t.intInventoryTransferId = @intTransactionId
	)
	BEGIN
		DECLARE @TR VARCHAR(50)
		DECLARE @R VARCHAR(50)
		SELECT TOP 1 @TR = t.strTransferNo, @R = r.strReceiptNumber
		FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
			INNER JOIN tblICInventoryTransfer t ON t.intInventoryTransferId = ri.intOrderId
			INNER JOIN tblICInventoryTransferDetail td ON td.intInventoryTransferId = t.intInventoryTransferId
				AND td.intInventoryTransferDetailId = ri.intLineNo
			INNER JOIN tblICItem i ON i.intItemId = td.intItemId
		WHERE r.strReceiptType = 'Transfer Order'
			AND t.intInventoryTransferId = @intTransactionId

		RAISERROR(80107, 11, 1, @TR, @R)
	GOTO Post_Exit	
	END
END

-- Check if all Items are available under the To Location
SELECT TOP 1 
		Detail.intItemId, 
		Header.intToLocationId, 
		Item.strItemNo, 
		Location.strLocationName
INTO	#tempValidateItemLocation
FROM	tblICInventoryTransferDetail Detail	INNER JOIN tblICInventoryTransfer Header 
			ON Header.intInventoryTransferId = Detail.intInventoryTransferId
		INNER JOIN tblICItem Item 
			ON Item.intItemId = Detail.intItemId
		INNER JOIN tblSMCompanyLocation Location 
			ON Location.intCompanyLocationId = Header.intToLocationId
WHERE	Detail.intInventoryTransferId = @intTransactionId 
		AND ISNULL(dbo.fnICGetItemLocation(Detail.intItemId, Header.intToLocationId), -1) = -1
		 
-- Check if all details with lotted items have lot numbers assigned.
IF EXISTS(
	SELECT TOP 1 1
	FROM tblICInventoryTransfer tf
		INNER JOIN tblICInventoryTransferDetail tfd ON tfd.intInventoryTransferId = tf.intInventoryTransferId
		INNER JOIN tblICItem i ON i.intItemId = tfd.intItemId
	WHERE tf.intInventoryTransferId = @intTransactionId
		AND tfd.intLotId IS NULL
		AND ISNULL(i.strLotTracking, 'No') <> 'No')
BEGIN
	RAISERROR(80085, 11, 1, @strTransactionId)
	GOTO Post_Exit
END

IF EXISTS(SELECT TOP 1 1 FROM #tempValidateItemLocation)
BEGIN
	DECLARE @ItemId NVARCHAR(100),
		@LocationId NVARCHAR(100)

	SELECT TOP 1 
			@ItemId = strItemNo, 
			@LocationId = strLocationName 
	FROM	#tempValidateItemLocation

	IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE object_id = object_id('tempValidateItemLocation')) 
	DROP TABLE #tempValidateItemLocation
	
	-- Item %s is not available on location %s.
	RAISERROR(80026, 11, 1, @ItemId, @LocationId)  
	GOTO Post_Exit  
END

IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE object_id = object_id('tempValidateItemLocation')) DROP TABLE #tempValidateItemLocation

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

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

-- Create and validate the lot numbers
IF @ysnPost = 1
BEGIN 	
	DECLARE @intCreateUpdateLotError AS INT 

	EXEC @intCreateUpdateLotError = dbo.uspICCreateLotNumberOnInventoryTransfer 
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

-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT   

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1  
BEGIN  
	--	Initialize the transaction type and account-category-to-counter-inventory.
	BEGIN 
		-- If shipment required, change the transaction type to "Inventory Transfer with Shipment"
		-- Otherwise, keep the transaction type to "Inventory Transfer"
		SET @intTransactionType = 
			CASE	WHEN @ysnShipmentRequired = 1 THEN @INVENTORY_TRANSFER_WITH_SHIPMENT_TYPE 
					ELSE @INVENTORY_TRANSFER_TYPE 
			END
		
		-- If shipment is not required, then set to NULL the "account category to counter inventory". 
		SELECT @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY = NULL 
		WHERE @ysnShipmentRequired = 0
	END
	
	-- Process the "From" Stock 
	BEGIN 
		DECLARE @ItemsForRemovalPost AS ItemCostingTableType  
		INSERT INTO @ItemsForRemovalPost (  
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
		SELECT	Detail.intItemId  
				,dbo.fnICGetItemLocation(Detail.intItemId, Header.intFromLocationId)
				,intItemUOMId = Detail.intItemUOMId
				,Header.dtmTransferDate
				,dblQty = -Detail.dblQuantity
				,dblUOMQty = ItemUOM.dblUnitQty
				,ISNULL(Lot.dblLastCost, ItemPricing.dblLastCost)
				,0
				,@DefaultCurrencyId
				,1
				,@intTransactionId 
				,Detail.intInventoryTransferDetailId
				,@strTransactionId
				,@intTransactionType
				,Detail.intLotId 
				,Detail.intFromSubLocationId
				,Detail.intFromStorageLocationId
				,Header.strActualCostId 
		FROM	tblICInventoryTransferDetail Detail INNER JOIN tblICInventoryTransfer Header 
					ON Header.intInventoryTransferId = Detail.intInventoryTransferId
				LEFT JOIN dbo.tblICItemUOM ItemUOM
					ON ItemUOM.intItemUOMId = Detail.intItemUOMId
				LEFT JOIN dbo.tblICLot Lot
					ON Lot.intLotId = Detail.intLotId
					AND Lot.intItemId = Detail.intItemId
				LEFT JOIN tblICItemUOM LotItemUOM
					ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
				LEFT JOIN tblICItemUOM LotWeightUOM
					ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
				LEFT JOIN tblICItemPricing ItemPricing
					ON ItemPricing.intItemId = Detail.intItemId
					AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Header.intFromLocationId)
		WHERE	Header.intInventoryTransferId = @intTransactionId

		-------------------------------------------
		-- Call the costing SP	
		-------------------------------------------
		EXEC	@intReturnValue = dbo.uspICPostCosting  
				@ItemsForRemovalPost  
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
				,@intEntityUserSecurityId

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END

	-- Process the "To" Stock 
	IF @ysnShipmentRequired = 0 
	BEGIN 
		DECLARE @ItemsForTransferPost AS ItemCostingTableType  
		INSERT INTO @ItemsForTransferPost (  
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
		SELECT Detail.intItemId  
				,dbo.fnICGetItemLocation(Detail.intItemId, Header.intToLocationId)
				,FromStock.intItemUOMId  
				,Header.dtmTransferDate
				,-FromStock.dblQty
				,FromStock.dblUOMQty
				,ISNULL(FromStock.dblCost, 0)
				,0
				,@DefaultCurrencyId
				,1
				,@intTransactionId 
				,Detail.intInventoryTransferDetailId
				,@strTransactionId
				,@INVENTORY_TRANSFER_TYPE
				,Detail.intNewLotId
				,Detail.intToSubLocationId
				,Detail.intToStorageLocationId
				,Header.strActualCostId
		FROM	tblICInventoryTransferDetail Detail INNER JOIN tblICInventoryTransfer Header 
					ON Header.intInventoryTransferId = Detail.intInventoryTransferId
				INNER JOIN dbo.tblICInventoryTransaction FromStock
					ON Detail.intInventoryTransferDetailId = FromStock.intTransactionDetailId
					AND Detail.intInventoryTransferId = FromStock.intTransactionId
					AND FromStock.intItemId = Detail.intItemId
				LEFT JOIN tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = Detail.intItemUOMId
		WHERE	ISNULL(FromStock.ysnIsUnposted, 0) = 0
				AND FromStock.strBatchId = @strBatchId
				AND Header.intInventoryTransferId = @intTransactionId

		-- Clear the GL entries 
		DELETE FROM @GLEntries

		-------------------------------------------
		-- Call the costing SP
		-------------------------------------------
		EXEC	@intReturnValue = dbo.uspICPostCosting  
				@ItemsForTransferPost  
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
				,@intEntityUserSecurityId

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END

	-- Check if From and To locations are the same. If not, then generate the GL entries. 
	IF EXISTS (SELECT TOP 1 1 FROM tblICInventoryTransfer WHERE intInventoryTransferId = @intTransactionId AND intFromLocationId <> intToLocationId)
	BEGIN 	
		SET @ysnGLEntriesRequired = 1

		-----------------------------------------
		-- Generate a new set of g/l entries
		-----------------------------------------
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
		EXEC @intReturnValue = dbo.uspICCreateGLEntries 
			@strBatchId
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
			,@intEntityUserSecurityId
			,@strGLDescription

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END 
END   	

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 0   
BEGIN   
	-- Check if From and To locations are the same. If not, then generate the GL entries. 
	IF EXISTS (SELECT TOP 1 1 FROM tblICInventoryTransfer WHERE intInventoryTransferId = @intTransactionId AND intFromLocationId <> intToLocationId)
	BEGIN 
		SET @ysnGLEntriesRequired = 1;
	END 
	
	-- Call the unpost routine 
	BEGIN 
		-- Call the post routine 
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
	IF @ysnGLEntriesRequired = 0
	BEGIN 
		ROLLBACK TRAN @TransactionName
		COMMIT TRAN @TransactionName

		-- 'Recap is not applicable when doing an inventory transfer for the same location.'
		RAISERROR(80045, 11, 1)  
		GOTO Post_Exit  
	END 
	ELSE 
	BEGIN 
		ROLLBACK TRAN @TransactionName
		EXEC dbo.uspCMPostRecap @GLEntries
		COMMIT TRAN @TransactionName
	END 
END 

--------------------------------------------------------------------------------------------  
-- If RECAP is FALSE,
-- 1. Book the G/L entries
-- 2. Update the ysnPosted flag in the transaction. Increase the concurrency. 
-- 3. Update Status to Closed if transaction is posted and Shipment is not required.
-- 4. Update the PO (if it exists)
-- 5. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 0
BEGIN 	
	IF @ysnGLEntriesRequired = 1 
	BEGIN 
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 	
	END

	UPDATE	dbo.tblICInventoryTransfer  
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	strTransferNo = @strTransactionId  

	
	IF @ysnPost = 1
		BEGIN
			UPDATE	dbo.tblICInventoryTransfer  
			SET		intStatusId = 3 -- Status: Closed
			WHERE	strTransferNo = @strTransactionId AND ysnShipmentRequired=0   
		END
	ELSE
		BEGIN
			UPDATE	dbo.tblICInventoryTransfer  
			SET		intStatusId = 1 -- Status: Open
			WHERE	strTransferNo = @strTransactionId
		END

	-- If shipment required, then update the in-transit quantities. 
	IF @ysnShipmentRequired = 1
	BEGIN 
		-- Increase the In-Transit Outbound for the source location
		BEGIN 
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
			SELECT	[intItemId]				= d.intItemId
					,[intItemLocationId]	= itemLocation.intItemLocationId
					,[intItemUOMId]			= d.intItemUOMId
					,[intLotId]				= d.intLotId --itemLot.intLotId
					,[intSubLocationId]		= d.intFromSubLocationId
					,[intStorageLocationId]	= d.intFromStorageLocationId
					,[dblQty]				= CASE WHEN @ysnPost = 1 THEN d.dblQuantity ELSE -d.dblQuantity END 
					,[intTransactionId]		= h.intInventoryTransferId
					,[strTransactionId]		= h.strTransferNo
					,[intTransactionTypeId] = 12 -- Inventory Transfer
			FROM	dbo.tblICInventoryTransfer h INNER JOIN dbo.tblICInventoryTransferDetail d
						ON h.intInventoryTransferId = d.intInventoryTransferId
					INNER JOIN dbo.tblICItemLocation itemLocation
						ON itemLocation.intItemId = d.intItemId
						AND itemLocation.intLocationId = h.intFromLocationId
			WHERE	h.intInventoryTransferId = @intTransactionId

			EXEC dbo.uspICIncreaseInTransitOutBoundQty @InTransit_Outbound
		END

		-- If shipment required, increase the In-Transit Inbound for the destination. 
		BEGIN 
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
			SELECT	[intItemId]				= d.intItemId
					,[intItemLocationId]	= itemLocation.intItemLocationId
					,[intItemUOMId]			= d.intItemUOMId
					,[intLotId]				= d.intLotId --itemLot.intLotId
					,[intSubLocationId]		= d.intToSubLocationId
					,[intStorageLocationId]	= d.intToStorageLocationId
					,[dblQty]				= CASE WHEN @ysnPost = 1 THEN d.dblQuantity ELSE -d.dblQuantity END 
					,[intTransactionId]		= h.intInventoryTransferId
					,[strTransactionId]		= h.strTransferNo
					,[intTransactionTypeId] = 12 -- Inventory Transfer
			FROM	dbo.tblICInventoryTransfer h INNER JOIN dbo.tblICInventoryTransferDetail d
						ON h.intInventoryTransferId = d.intInventoryTransferId
					INNER JOIN dbo.tblICItemLocation itemLocation
						ON itemLocation.intItemId = d.intItemId
						AND itemLocation.intLocationId = h.intToLocationId
			WHERE	h.intInventoryTransferId = @intTransactionId
					AND ISNULL(h.ysnShipmentRequired, 0) = 1

			EXEC dbo.uspICIncreaseInTransitInBoundQty @InTransit_Inbound
		END 		
	END 

	COMMIT TRAN @TransactionName
END 

-- Create an Audit Log
IF @ysnRecap = 0 
BEGIN 
	DECLARE @strDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
			
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intTransactionId							-- Primary Key Value of the Inventory Transfer. 
			,@screenName = 'Inventory.view.InventoryTransfer'       -- Screen Namespace
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