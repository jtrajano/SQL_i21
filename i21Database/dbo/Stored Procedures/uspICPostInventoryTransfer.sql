CREATE PROCEDURE [dbo].[uspICPostInventoryTransfer]
	@ysnPost BIT  = 0  
	,@ysnRecap BIT  = 0  
	,@strTransactionId NVARCHAR(40) = NULL   
	,@intEntityUserSecurityId AS INT = NULL 
	,@strBatchId NVARCHAR(40) = NULL OUTPUT
	--,@ysnActualCostFromLocation BIT = 1 
	--,@ysnActualCostToLocation BIT = 1
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  

-- Create the temp table to skip a batch id from logging into the summary log. 
IF OBJECT_ID('tempdb..#tmpICLogRiskPositionFromOnHandSkipList') IS NULL  
BEGIN 
	CREATE TABLE #tmpICLogRiskPositionFromOnHandSkipList (
		strBatchId NVARCHAR(50) COLLATE Latin1_General_CI_AS 
	)
END 
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------    
-- Create a unique transaction name. 
DECLARE @TransactionName AS VARCHAR(500) = 'InventoryTransfer' + CAST(NEWID() AS NVARCHAR(100));

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

-- Constants  
DECLARE @INVENTORY_TRANSFER_TYPE AS INT = 12
		,@INVENTORY_TRANSFER_WITH_SHIPMENT_TYPE AS INT = 13

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

		,@STARTING_NUMBER_BATCH AS INT = 3 
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory' --'Inventory In-Transit'

-- Get the default currency ID and other variables. 
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
		,@strItemNo AS NVARCHAR(50)

-- Create the gl entries variable 
DECLARE	@GLEntries AS RecapTableType 
		,@ysnGLEntriesRequired AS BIT = 0
		,@intReturnValue AS INT
		,@DummyGLEntries AS RecapTableType 

DECLARE	@InTransit_Outbound AS InTransitTableType
		,@InTransit_Inbound AS InTransitTableType
		,@CompanyOwnedStockInTransit AS ItemInTransitCostingTableType

DECLARE	@sourceType_None AS INT = 0
		,@sourceType_Scale AS INT = 1
		,@sourceType_InboundShipment AS INT = 2
		,@sourceType_Transports AS INT = 3

DECLARE	@ownershipType_Own AS INT = 1
		,@ownershipType_Storage AS INT = 2
		,@ownershipType_ConsignedPurchase AS INT = 3

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
			,@intLocationId AS INT
			,@intSourceType AS INT 
			,@strTransferNo AS NVARCHAR(50)
  
	SELECT TOP 1   
			@intTransactionId = intInventoryTransferId
			,@ysnTransactionPostedFlag = ysnPosted
			,@dtmDate = dtmTransferDate
			,@intCreatedEntityId = intEntityId
			,@ysnShipmentRequired = ISNULL(ysnShipmentRequired, 0)
			,@strGLDescription = strDescription
			,@intLocationId = intFromLocationId
			,@intSourceType = intSourceType 
			,@strTransferNo = strTransferNo 
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
	EXEC uspICRaiseError 80167;  
	GOTO Post_Exit  
END   
  
-- Validate the date against the FY Periods  
IF @ysnRecap = 0 AND EXISTS (SELECT 1 WHERE dbo.isOpenAccountingDate(@dtmDate) = 0) 
BEGIN   
	-- Unable to find an open fiscal year period to match the transaction date.  
	EXEC uspICRaiseError 80168; 
	GOTO Post_Exit  
END  
  
-- Check if the transaction is already posted  
IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1  
BEGIN   
	-- The transaction is already posted.  
	EXEC uspICRaiseError 80169; 
	GOTO Post_Exit  
END   

IF @ysnRecap = 0 
BEGIN 
	UPDATE	dbo.tblICInventoryTransfer  
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	strTransferNo = @strTransactionId  
END 
  
-- Check if the transaction is already posted  
IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
BEGIN   
	-- The transaction is already unposted.  
	EXEC uspICRaiseError 80170; 
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
			AND i.strType <> 'Comment'
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
			AND i.strType <> 'Comment'
			AND t.intInventoryTransferId = @intTransactionId

		EXEC uspICRaiseError 80107, @TR, @R;
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
FROM tblICInventoryTransferDetail Detail
	INNER JOIN tblICInventoryTransfer Header ON Header.intInventoryTransferId = Detail.intInventoryTransferId
	INNER JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
	INNER JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Header.intToLocationId
WHERE Detail.intInventoryTransferId = @intTransactionId 
	AND ISNULL(dbo.fnICGetItemLocation(Detail.intItemId, Header.intToLocationId), -1) = -1
	AND Item.strType <> 'Comment'
		 
-- Check if all details with lotted items have lot numbers assigned.
IF EXISTS(
	SELECT TOP 1 1
	FROM tblICInventoryTransfer tf
		INNER JOIN tblICInventoryTransferDetail tfd ON tfd.intInventoryTransferId = tf.intInventoryTransferId
		INNER JOIN tblICItem i ON i.intItemId = tfd.intItemId
	WHERE tf.intInventoryTransferId = @intTransactionId
		AND tfd.intLotId IS NULL
		AND i.strType <> 'Comment'
		AND ISNULL(i.strLotTracking, 'No') <> 'No')
BEGIN
	EXEC uspICRaiseError 80085, @strTransactionId;
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
	EXEC uspICRaiseError 80026, @LocationId, @ItemId;
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
		EXEC uspICRaiseError 80172, 'Post';
		GOTO Post_Exit  
	END   

	IF @ysnPost = 0  
	BEGIN  
		EXEC uspICRaiseError 80172, 'Unpost';
		GOTO Post_Exit    
	END  
END   


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
BEGIN 
	SET @strBatchId = NULL 
	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 
END 

-- insert into the temp table
BEGIN 
	INSERT INTO #tmpICLogRiskPositionFromOnHandSkipList (strBatchId) VALUES (@strBatchId) 
END 

-- Check the locations if GL entries will be required. 
SELECT	@ysnGLEntriesRequired = 1
FROM	tblICInventoryTransfer 
WHERE	intInventoryTransferId = @intTransactionId 
		AND intFromLocationId <> intToLocationId

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
		DECLARE @CompanyOwnedStock AS ItemCostingTableType  
		INSERT INTO @CompanyOwnedStock (  
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
				,COALESCE(NULLIF(Detail.dblCost, 0.00), Lot.dblLastCost, ItemPricing.dblLastCost)
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
				,strActualCostId = Detail.strFromLocationActualCostId
		FROM tblICInventoryTransferDetail Detail 
			INNER JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
			INNER JOIN tblICInventoryTransfer Header ON Header.intInventoryTransferId = Detail.intInventoryTransferId
			LEFT JOIN dbo.tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Detail.intItemUOMId
			LEFT JOIN dbo.tblICLot Lot ON Lot.intLotId = Detail.intLotId
				AND Lot.intItemId = Detail.intItemId
			LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
			LEFT JOIN tblICItemUOM LotWeightUOM ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
			LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Header.intFromLocationId)
		WHERE Header.intInventoryTransferId = @intTransactionId
			AND Item.strType <> 'Comment'
			AND Detail.intOwnershipType = @ownershipType_Own

		DECLARE @StorageOwnedStock AS ItemCostingTableType  
		INSERT INTO @StorageOwnedStock (  
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
				,COALESCE(NULLIF(Detail.dblCost, 0.00), Lot.dblLastCost, ItemPricing.dblLastCost)
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
				,strActualCostId = Detail.strFromLocationActualCostId
		FROM tblICInventoryTransferDetail Detail 
			INNER JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
			INNER JOIN tblICInventoryTransfer Header ON Header.intInventoryTransferId = Detail.intInventoryTransferId
			LEFT JOIN dbo.tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Detail.intItemUOMId
			LEFT JOIN dbo.tblICLot Lot ON Lot.intLotId = Detail.intLotId
				AND Lot.intItemId = Detail.intItemId
			LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
			LEFT JOIN tblICItemUOM LotWeightUOM ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
			LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Header.intFromLocationId)
		WHERE Header.intInventoryTransferId = @intTransactionId
			AND Item.strType <> 'Comment'
			AND Detail.intOwnershipType = @ownershipType_Storage

		-------------------------------------------
		-- Call the costing SP (FROM stock)
		-------------------------------------------
		IF EXISTS (SELECT TOP 1 1 FROM @CompanyOwnedStock)
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
					@CompanyOwnedStock  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
					,@intEntityUserSecurityId

			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END 

		-------------------------------------------
		-- Call the storage sp
		-------------------------------------------
		IF EXISTS (SELECT TOP 1 1 FROM @StorageOwnedStock)
		BEGIN 
			EXEC	@intReturnValue = dbo.uspICPostStorage  
					@StorageOwnedStock 
					,@strBatchId  
					,@intEntityUserSecurityId

			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END 
	END

	-- Replace the cost for post-preview purposes only. 
	IF @intSourceType = @sourceType_Transports AND @ysnRecap = 1
	BEGIN 
		UPDATE	t
		SET		t.dblCost = dbo.fnCalculateCostBetweenUOM(stockUOM.intItemUOMId, t.intItemUOMId, Detail.dblCost)  
		FROM	tblICInventoryTransaction t INNER JOIN tblICInventoryTransferDetail Detail
					ON t.intTransactionId = Detail.intInventoryTransferId
					AND t.intTransactionDetailId = Detail.intInventoryTransferDetailId
				OUTER APPLY (
					SELECT	* 
					FROM	tblICItemUOM u
					WHERE	u.intItemId = Detail.intItemId
							AND u.ysnStockUnit = 1
				) stockUOM
		WHERE	t.strBatchId = @strBatchId
				AND t.strTransactionId = @strTransferNo
				AND NULLIF(Detail.dblCost, 0.00) IS NOT NULL 
	END 

	-- Process the "To" Stock (Shipment is NOT required). 
	IF @ysnShipmentRequired = 0 
	BEGIN 
		DECLARE @TransferCompanyOwnedStock AS ItemCostingTableType  
		INSERT INTO @TransferCompanyOwnedStock (  
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
				,dblQty = -FromStock.dblQty 
				,dblUOMQty = FromStock.dblUOMQty 
				,dblCost = ISNULL(FromStock.dblCost, 0)
				,dblSalesPrice = 0
				,@DefaultCurrencyId
				,dblExchangeRate = 1
				,@intTransactionId 
				,Detail.intInventoryTransferDetailId
				,@strTransactionId
				,@INVENTORY_TRANSFER_TYPE
				,Detail.intNewLotId
				,Detail.intToSubLocationId
				,Detail.intToStorageLocationId
				,strActualCostId = Detail.strToLocationActualCostId
		FROM	tblICInventoryTransfer Header INNER JOIN tblICInventoryTransferDetail Detail 
					ON Header.intInventoryTransferId = Detail.intInventoryTransferId
				INNER JOIN tblICItem Item 
					ON Item.intItemId = Detail.intItemId
				INNER JOIN dbo.tblICInventoryTransaction FromStock 
					ON FromStock.intTransactionDetailId = Detail.intInventoryTransferDetailId 
					AND FromStock.intTransactionId = Detail.intInventoryTransferId
					AND FromStock.intItemId = Detail.intItemId
					AND FromStock.strTransactionId = Header.strTransferNo
					AND FromStock.dblQty < 0 
				LEFT JOIN tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = Detail.intItemUOMId
				LEFT JOIN tblICItemUOM WeightUOM 
					ON WeightUOM.intItemUOMId = Detail.intGrossNetUOMId
		WHERE ISNULL(FromStock.ysnIsUnposted, 0) = 0
			AND FromStock.strBatchId = @strBatchId
			AND Item.strType <> 'Comment'
			AND Header.intInventoryTransferId = @intTransactionId
			AND Detail.intOwnershipType = @ownershipType_Own

		DECLARE @TransferStoragetock AS ItemCostingTableType  
		INSERT INTO @TransferStoragetock (  
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
				,COALESCE(Detail.intGrossNetUOMId, FromStock.intItemUOMId)
				,Header.dtmTransferDate
				,dblQty = CASE WHEN Detail.intGrossNetUOMId IS NULL THEN -FromStock.dblQty ELSE Detail.dblNet END
				,dblUOMQty = CASE WHEN Detail.intGrossNetUOMId IS NULL THEN FromStock.dblUOMQty ELSE WeightUOM.dblUnitQty END
				,dblCost = 
					CASE	WHEN Detail.intGrossNetUOMId IS NULL THEN ISNULL(FromStock.dblCost, 0) 
							ELSE 
								CASE	WHEN ISNULL(NULLIF(Detail.dblNet, 0), 0) = 0 THEN 0 
										ELSE dbo.fnDivide(dbo.fnMultiply(-FromStock.dblQty, FromStock.dblCost), Detail.dblNet)
								END 
					END
				,dblSalesPrice = 0
				,@DefaultCurrencyId
				,dblExchangeRate = 1
				,@intTransactionId 
				,Detail.intInventoryTransferDetailId
				,@strTransactionId
				,@INVENTORY_TRANSFER_TYPE
				,Detail.intNewLotId
				,Detail.intToSubLocationId
				,Detail.intToStorageLocationId
				,strActualCostId = Detail.strToLocationActualCostId
		FROM	tblICInventoryTransfer Header INNER JOIN tblICInventoryTransferDetail Detail 
					ON Header.intInventoryTransferId = Detail.intInventoryTransferId
				INNER JOIN tblICItem Item 
					ON Item.intItemId = Detail.intItemId
				INNER JOIN dbo.tblICInventoryTransactionStorage FromStock 
					ON FromStock.intTransactionDetailId = Detail.intInventoryTransferDetailId 
					AND FromStock.intTransactionId = Detail.intInventoryTransferId
					AND FromStock.intItemId = Detail.intItemId
					AND FromStock.strTransactionId = Header.strTransferNo
					AND FromStock.dblQty < 0 
				LEFT JOIN tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = Detail.intItemUOMId
				LEFT JOIN tblICItemUOM WeightUOM 
					ON WeightUOM.intItemUOMId = Detail.intGrossNetUOMId
		WHERE ISNULL(FromStock.ysnIsUnposted, 0) = 0
			AND FromStock.strBatchId = @strBatchId
			AND Item.strType <> 'Comment'
			AND Header.intInventoryTransferId = @intTransactionId
			AND Detail.intOwnershipType = @ownershipType_Storage

		-------------------------------------------
		-- Call the costing SP (TO stock)
		-------------------------------------------
		IF EXISTS (SELECT TOP 1 1 FROM @TransferCompanyOwnedStock)
		BEGIN 
			DELETE FROM #tmpICLogRiskPositionFromOnHandSkipList 

			EXEC	@intReturnValue = dbo.uspICPostCosting  
					@TransferCompanyOwnedStock  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
					,@intEntityUserSecurityId
					,DEFAULT
					,DEFAULT 
					,@ysnGLEntriesRequired

			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END

		-------------------------------------------
		-- Call the storage sp	
		-------------------------------------------
		IF EXISTS (SELECT TOP 1 1 FROM @TransferStoragetock)
		BEGIN 
			EXEC	@intReturnValue = dbo.uspICPostStorage  
					@TransferStoragetock  
					,@strBatchId  
					,@intEntityUserSecurityId

			IF @intReturnValue < 0 GOTO With_Rollback_Exit
		END 

		-- Clear the GL entries 
		DELETE FROM @GLEntries
	END

	-- Process the "To" Stock (Shipment is REQUIRED). 
	IF @ysnShipmentRequired = 1
	BEGIN 
		-- Get values for the In-Transit Costing 
		INSERT INTO @CompanyOwnedStockInTransit (
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[dtmDate] 
				,[dblQty] 
				,[dblUOMQty] 
				,[dblCost] 
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
		)
		SELECT
				[intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[dtmDate] 
				,-[dblQty] 
				,[dblUOMQty] 
				,[dblCost] 
				,[dblValue] 
				,[dblSalesPrice] 
				,[intCurrencyId] 
				,[dblExchangeRate] 
				,[intTransactionId] 
				,[intTransactionDetailId] 
				,[strTransactionId] 
				,[intTransactionTypeId] 
				,[intLotId] 
				,[intTransactionId] 
				,[strTransactionId] 
				,[intTransactionDetailId] 
				,[intFobPointId] = @FOB_DESTINATION
				,[intInTransitSourceLocationId] = FromStock.intItemLocationId
				,[intForexRateTypeId] = FromStock.intForexRateTypeId
				,[dblForexRate] = FromStock.dblForexRate
				,[intSourceEntityId]
		FROM	tblICInventoryTransaction FromStock 
		WHERE	FromStock.strTransactionId = @strTransactionId
				AND ISNULL(FromStock.ysnIsUnposted, 0) = 0 
				AND FromStock.strBatchId = @strBatchId
				AND FromStock.dblQty < 0 -- Ensure the Qty is negative. 

		IF EXISTS (SELECT TOP 1 1 FROM @CompanyOwnedStockInTransit)
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
					,[intSourceEntityId]
					,[intCommodityId]
			)
			EXEC	@intReturnValue = dbo.uspICPostInTransitCosting  
					@CompanyOwnedStockInTransit  
					,@strBatchId  
					,NULL 
					,@intEntityUserSecurityId
		END 
	END 

	-- Check if From and To locations are the same. If not, then generate the GL entries. 
	IF @ysnGLEntriesRequired = 1
	BEGIN
		-----------------------------------------
		-- Generate a new set of g/l entries
		-----------------------------------------
		IF @ysnShipmentRequired = 0 
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
			EXEC @intReturnValue = dbo.uspICCreateGLEntries 
				@strBatchId
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId
				,@strGLDescription
		END 
		ELSE IF @ysnShipmentRequired = 1
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
					,[intSourceEntityId]
					,[intCommodityId]
			)
			EXEC @intReturnValue = dbo.uspICCreateGLEntriesForInTransitCosting 
				@strBatchId
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId
				,@strGLDescription
		END 
		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END 


	IF @ysnGLEntriesRequired = 0
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
		EXEC @intReturnValue = dbo.uspICCreateGLEntriesForNegativeStockVariance
			@strBatchId
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
			,@intEntityUserSecurityId
			,@strGLDescription
	END
END   	

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 0   
BEGIN   
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

		exec @intReturnValue =  [dbo].[uspICUnpostStorage]
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

		IF EXISTS (
			SELECT	TOP 1 1 
			FROM	tblICInventoryTransfer t INNER JOIN tblICInventoryTransferDetail td
						ON t.intInventoryTransferId = td.intInventoryTransferId
			WHERE	t.intInventoryTransferId = @intTransactionId 
					AND t.intFromLocationId = t.intToLocationId
					AND td.intOwnershipType = @ownershipType_Own
		)
		BEGIN
			-- 'Post Preview is not applicable when doing an inventory transfer for the same location.'
			EXEC uspICRaiseError 80045;
			GOTO Post_Exit  
		END 
		ELSE 
		BEGIN 
			-- 'Post preview is not available. Financials are only booked for company-owned stocks.'
			EXEC uspICRaiseError 80185;
			GOTO Post_Exit  
		END 
	END 
	ELSE 
	BEGIN 
		ROLLBACK TRAN @TransactionName
		EXEC dbo.uspGLPostRecap 
				@GLEntries
				,@intEntityUserSecurityId
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
	IF (@ysnGLEntriesRequired = 1 AND EXISTS (SELECT TOP 1 1 FROM @CompanyOwnedStock))
		OR (EXISTS (SELECT TOP 1 1 FROM @GLEntries) AND @ysnPost = 0) 
	BEGIN 
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 	
	END
	
	IF @ysnPost = 1
	BEGIN
		UPDATE	dbo.tblICInventoryTransfer  
		SET		intStatusId = CASE ysnShipmentRequired WHEN 1 THEN 2 ELSE 3 END -- Status: In Transit
		WHERE	strTransferNo = @strTransactionId
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
				,[intFOBPointId]
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
					,[intFOBPointId]		= @FOB_DESTINATION
			FROM dbo.tblICInventoryTransfer h
				INNER JOIN dbo.tblICInventoryTransferDetail d ON h.intInventoryTransferId = d.intInventoryTransferId
				INNER JOIN dbo.tblICItem Item ON Item.intItemId = d.intItemId
				INNER JOIN dbo.tblICItemLocation itemLocation 
					ON itemLocation.intItemId = d.intItemId
					AND itemLocation.intLocationId = h.intFromLocationId
			WHERE h.intInventoryTransferId = @intTransactionId
				AND Item.strType <> 'Comment'
				AND d.intOwnershipType = @ownershipType_Own

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
				,[intFOBPointId]
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
					,[intFOBPointId]		= @FOB_DESTINATION
			FROM dbo.tblICInventoryTransfer h
				INNER JOIN dbo.tblICInventoryTransferDetail d ON h.intInventoryTransferId = d.intInventoryTransferId
				INNER JOIN dbo.tblICItem Item ON Item.intItemId = d.intItemId
				INNER JOIN dbo.tblICItemLocation itemLocation 
					ON itemLocation.intItemId = d.intItemId
					AND itemLocation.intLocationId = h.intToLocationId
			WHERE h.intInventoryTransferId = @intTransactionId
				AND ISNULL(h.ysnShipmentRequired, 0) = 1
				AND Item.strType <> 'Comment'
				AND d.intOwnershipType = @ownershipType_Own

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