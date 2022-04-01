CREATE PROCEDURE [dbo].[uspLGPostInventoryTransfer]
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
DECLARE @TransactionName AS VARCHAR(500) = 'LogisticsTransfer' + CAST(NEWID() AS NVARCHAR(100));

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

-- Constants  
DECLARE @INVENTORY_TRANSFER_TYPE AS INT = 12
		,@INVENTORY_TRANSFER_WITH_SHIPMENT_TYPE AS INT = 60

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

		,@STARTING_NUMBER_BATCH AS INT = 3 
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory' --'Inventory In-Transit'

-- Get the default currency ID and other variables. 
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
		,@strItemNo AS NVARCHAR(50)
		,@intItemId AS INT 

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
			@intTransactionId = L.intLoadId
			,@ysnTransactionPostedFlag = ysnPosted
			,@dtmDate = dtmScheduledDate
			,@intCreatedEntityId = intEntityId
			,@ysnShipmentRequired = 1 /* Shipment Always Required for Transfer Shipments */
			,@strGLDescription = I.strDescription
			,@intLocationId = LD.intPCompanyLocationId 
			,@intSourceType = intSourceType 
			,@strTransferNo = L.strLoadNumber 
	FROM	dbo.tblLGLoad L
			INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			INNER JOIN tblICItem I ON I.intItemId = LD.intItemId
	WHERE	strLoadNumber = @strTransactionId
END  

--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
-- Validate if the Transfer Shipment exists   
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
	UPDATE	dbo.tblLGLoad  
	SET		ysnPosted = @ysnPost
			,intShipmentStatus = 3
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	strLoadNumber = @strTransactionId  
END 
  
-- Check if the transaction is already posted  
IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
BEGIN   
	-- The transaction is already unposted.  
	EXEC uspICRaiseError 80170; 
	GOTO With_Rollback_Exit  
END

-- Don't allow unpost when there's a receipt
IF @ysnPost = 0
BEGIN
	IF EXISTS(SELECT TOP 1 1
		FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
			INNER JOIN tblLGLoad l ON l.intLoadId = ri.intOrderId
			INNER JOIN tblLGLoadDetail ld ON ld.intLoadId = l.intLoadId
				AND ld.intLoadDetailId = ri.intSourceId
			INNER JOIN tblICItem i ON i.intItemId = ld.intItemId
		WHERE r.strReceiptType = 'Transfer Order'
			AND i.strType <> 'Comment'
			AND l.intLoadId = @intTransactionId
	)
	BEGIN
		DECLARE @LS VARCHAR(50)
		DECLARE @R VARCHAR(50)
		SELECT TOP 1 @LS = l.strLoadNumber, @R = r.strReceiptNumber
		FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
			INNER JOIN tblLGLoad l ON l.intLoadId = ri.intOrderId
			INNER JOIN tblLGLoadDetail ld ON ld.intLoadId = l.intLoadId
				AND ld.intLoadDetailId = ri.intSourceId
			INNER JOIN tblICItem i ON i.intItemId = ld.intItemId
		WHERE r.strReceiptType = 'Transfer Order'
			AND i.strType <> 'Comment'
			AND l.intLoadId = @intTransactionId

		EXEC uspICRaiseError 80107, @LS, @R;
		GOTO With_Rollback_Exit	
	END
END

-- Check if all Items are available under the To Location
SELECT TOP 1 
		Detail.intItemId, 
		intToLocationId = ISNULL(WH.intCompanyLocationId, Detail.intSCompanyLocationId),
		Item.strItemNo, 
		Loc.strLocationName
INTO	#tempValidateItemLocation
FROM tblLGLoadDetail Detail
	INNER JOIN tblLGLoad Header ON Header.intLoadId = Detail.intLoadId
	INNER JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
	OUTER APPLY (
		SELECT TOP 1 clsl.intCompanyLocationId FROM tblLGLoadWarehouse lw 
		INNER JOIN tblSMCompanyLocationSubLocation clsl ON lw.intSubLocationId = clsl.intCompanyLocationSubLocationId
		WHERE lw.intLoadId = Header.intLoadId) WH
	INNER JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId = ISNULL(WH.intCompanyLocationId, Detail.intSCompanyLocationId)
WHERE Detail.intLoadId = @intTransactionId 
	AND ISNULL(dbo.fnICGetItemLocation(Detail.intItemId, Loc.intCompanyLocationId), -1) = -1
	AND Item.strType <> 'Comment'
		 
-- Check if all details with lotted items have lot numbers assigned.
IF EXISTS(
	SELECT TOP 1 1
	FROM tblLGLoad l
		INNER JOIN tblLGLoadDetail ld ON ld.intLoadId = l.intLoadId
		INNER JOIN tblLGLoadDetailLot ldl ON ldl.intLoadDetailId = ld.intLoadDetailId
		INNER JOIN tblICItem i ON i.intItemId = ld.intItemId
	WHERE l.intLoadId = @intTransactionId
		AND ldl.intLotId IS NULL
		AND i.strType <> 'Comment'
		AND ISNULL(i.strLotTracking, 'No') <> 'No')
BEGIN
	EXEC uspICRaiseError 80085, @strTransactionId;
	GOTO With_Rollback_Exit
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
	GOTO With_Rollback_Exit  
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
		GOTO With_Rollback_Exit  
	END   

	IF @ysnPost = 0  
	BEGIN  
		EXEC uspICRaiseError 80172, 'Unpost';
		GOTO With_Rollback_Exit    
	END  
END   

-- Validate the "to" storage unit. 
BEGIN 
	SET @intItemId = NULL 
	SET @strItemNo = NULL 

	SELECT TOP 1 
		@intItemId = i.intItemId
		,@strItemNo = i.strItemNo
	FROM 
		tblLGLoad l INNER JOIN tblLGLoadDetail ld
			ON l.intLoadId = ld.intLoadId
		INNER JOIN tblICItem i 
			ON i.intItemId = ld.intItemId
		OUTER APPLY (
			SELECT TOP 1 clsl.intCompanyLocationId, lw.intSubLocationId, lw.intStorageLocationId FROM tblLGLoadWarehouse lw 
			INNER JOIN tblSMCompanyLocationSubLocation clsl ON lw.intSubLocationId = clsl.intCompanyLocationSubLocationId
			WHERE lw.intLoadId = l.intLoadId) WH
		INNER JOIN tblICStorageLocation storageUnit
			ON storageUnit.intStorageLocationId = ld.intSStorageLocationId
	WHERE
		l.strLoadNumber = @strTransferNo
		AND storageUnit.intLocationId <> ISNULL(WH.intCompanyLocationId, ld.intSCompanyLocationId)

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- The "to" storage location in {Item No} is invalid.
		EXEC uspICRaiseError 80256, @strItemNo; 
		GOTO With_Rollback_Exit  		
	END 
END 

-- Validate the "to" storage location. 
BEGIN 
	SET @intItemId = NULL 
	SET @strItemNo = NULL 

	SELECT TOP 1 
		@intItemId = i.intItemId
		,@strItemNo = i.strItemNo
	FROM 
		tblLGLoad l INNER JOIN tblLGLoadDetail ld
			ON l.intLoadId = ld.intLoadId
		INNER JOIN tblICItem i 
			ON i.intItemId = ld.intItemId
		OUTER APPLY (
			SELECT TOP 1 clsl.intCompanyLocationId, lw.intSubLocationId, lw.intStorageLocationId FROM tblLGLoadWarehouse lw 
			INNER JOIN tblSMCompanyLocationSubLocation clsl ON lw.intSubLocationId = clsl.intCompanyLocationSubLocationId
			WHERE lw.intLoadId = l.intLoadId) WH
		INNER JOIN tblSMCompanyLocationSubLocation storageLocation
			ON storageLocation.intCompanyLocationSubLocationId = ISNULL(WH.intSubLocationId, ld.intSSubLocationId)
	WHERE
		l.strLoadNumber = @strTransferNo
		AND storageLocation.intCompanyLocationId <> ISNULL(WH.intCompanyLocationId, ld.intSCompanyLocationId)

	IF @intItemId IS NOT NULL 
	BEGIN 
		-- 'The "to" storage unit in {Item No} is invalid.'
		EXEC uspICRaiseError 80256, @strItemNo; 
		GOTO With_Rollback_Exit  		
	END 
END 

-- Create and validate the lot numbers
IF @ysnPost = 1
BEGIN 	
	DECLARE @intCreateUpdateLotError AS INT 

	EXEC @intCreateUpdateLotError = dbo.uspLGCreateLotNumberOnInventoryTransfer 
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

-- GL Entries always required for Transfer Shipments
SELECT	@ysnGLEntriesRequired = 1

-- Add to the "not-to-log" list if shipment is not required 
IF @ysnShipmentRequired <> 1
BEGIN 
	INSERT INTO #tmpICLogRiskPositionFromOnHandSkipList (strBatchId) VALUES (@strBatchId) 
END 

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
				,intTicketId 
		) 
		SELECT	Detail.intItemId  
				,dbo.fnICGetItemLocation(Detail.intItemId, Detail.intPCompanyLocationId)
				,intItemUOMId = Detail.intItemUOMId
				,Header.dtmScheduledDate
				,dblQty = -Detail.dblQuantity
				,dblUOMQty = ItemUOM.dblUnitQty
				,COALESCE(Lot.dblLastCost, ItemPricing.dblLastCost)
				,0
				,@DefaultCurrencyId
				,1
				,@intTransactionId 
				,Detail.intLoadDetailId
				,@strTransactionId
				,@intTransactionType
				,DetailLot.intLotId 
				,Detail.intPSubLocationId
				,Detail.intPStorageLocationId
				,strActualCostId = NULL
				,intTicketId = NULL
		FROM tblLGLoadDetail Detail 
			INNER JOIN tblICItem Item ON Item.intItemId = Detail.intItemId
			INNER JOIN tblLGLoad Header ON Header.intLoadId = Detail.intLoadId
			LEFT JOIN tblLGLoadDetailLot DetailLot ON DetailLot.intLoadDetailId = Detail.intLoadDetailId
			OUTER APPLY (
					SELECT TOP 1 clsl.intCompanyLocationId, lw.intSubLocationId, lw.intStorageLocationId FROM tblLGLoadWarehouse lw 
					INNER JOIN tblSMCompanyLocationSubLocation clsl ON lw.intSubLocationId = clsl.intCompanyLocationSubLocationId
					WHERE lw.intLoadId = Header.intLoadId) WH
			LEFT JOIN dbo.tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Detail.intItemUOMId
			LEFT JOIN dbo.tblICLot Lot ON Lot.intLotId = DetailLot.intLotId
				AND Lot.intItemId = Detail.intItemId
			LEFT JOIN tblICItemUOM LotItemUOM ON LotItemUOM.intItemUOMId = Lot.intItemUOMId
			LEFT JOIN tblICItemUOM LotWeightUOM ON LotWeightUOM.intItemUOMId = Lot.intWeightUOMId
			LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = Detail.intItemId
				AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(Detail.intItemId, Detail.intPCompanyLocationId)
		WHERE Header.intLoadId = @intTransactionId
			AND Item.strType <> 'Comment'

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
	END

	-- Replace the cost for post-preview purposes only. 
	--IF @intSourceType = @sourceType_Transports AND @ysnRecap = 1
	--BEGIN 
	--	UPDATE	t
	--	SET		t.dblCost = dbo.fnCalculateCostBetweenUOM(stockUOM.intItemUOMId, t.intItemUOMId, Detail.dblCost)  
	--	FROM	tblICInventoryTransaction t INNER JOIN tblLGLoadDetail Detail
	--				ON t.intTransactionId = Detail.intLoadId
	--				AND t.intTransactionDetailId = Detail.intLoadDetailId
	--			OUTER APPLY (
	--				SELECT	* 
	--				FROM	tblICItemUOM u
	--				WHERE	u.intItemId = Detail.intItemId
	--						AND u.ysnStockUnit = 1
	--			) stockUOM
	--	WHERE	t.strBatchId = @strBatchId
	--			AND t.strTransactionId = @strTransferNo
	--			AND NULLIF(Detail.dblCost, 0.00) IS NOT NULL 
	--END 

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
				,[intTicketId]
				,[strSourceType]
				,[strSourceNumber]
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
				,[intTicketId]
				,[strSourceType]
				,[strSourceNumber]
		FROM	tblICInventoryTransaction FromStock 
		WHERE	FromStock.strTransactionId = @strTransactionId
				AND ISNULL(FromStock.ysnIsUnposted, 0) = 0 
				AND FromStock.strBatchId = @strBatchId
				AND FromStock.dblQty < 0 -- Ensure the Qty is negative. 

		IF EXISTS (SELECT TOP 1 1 FROM @CompanyOwnedStockInTransit)
		BEGIN 
			DELETE FROM #tmpICLogRiskPositionFromOnHandSkipList

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
		IF @ysnShipmentRequired = 1
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


	IF (@ysnShipmentRequired = 1 OR @ysnGLEntriesRequired = 0)
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
		DELETE FROM #tmpICLogRiskPositionFromOnHandSkipList

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
	EXEC dbo.uspGLPostRecap 
			@GLEntries
			,@intEntityUserSecurityId
	COMMIT TRAN @TransactionName
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
		OR (EXISTS (SELECT TOP 1 1 FROM @GLEntries)) 
	BEGIN 
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 	
	END
	
	IF @ysnPost = 1
	BEGIN
		UPDATE	dbo.tblLGLoad  
		SET		intShipmentStatus = 3 -- Status: In Transit
		WHERE	strLoadNumber = @strTransactionId
	END
	ELSE
	BEGIN
		UPDATE	dbo.tblLGLoad  
		SET		intShipmentStatus = 1 -- Status: Scheduled
		WHERE	strLoadNumber = @strTransactionId
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
					,[intLotId]				= l.intLotId --itemLot.intLotId
					,[intSubLocationId]		= d.intPSubLocationId
					,[intStorageLocationId]	= d.intPStorageLocationId
					,[dblQty]				= CASE WHEN @ysnPost = 1 THEN ISNULL(l.dblLotQuantity, d.dblQuantity) ELSE -ISNULL(l.dblLotQuantity, d.dblQuantity) END 
					,[intTransactionId]		= h.intLoadId
					,[strTransactionId]		= h.strLoadNumber
					,[intTransactionTypeId] = 12 -- Inventory Transfer
					,[intFOBPointId]		= @FOB_DESTINATION
			FROM dbo.tblLGLoad h
				INNER JOIN dbo.tblLGLoadDetail d ON h.intLoadId = d.intLoadId
				INNER JOIN dbo.tblLGLoadDetailLot l ON l.intLoadDetailId = d.intLoadDetailId
				INNER JOIN dbo.tblICItem Item ON Item.intItemId = d.intItemId
				INNER JOIN dbo.tblICItemLocation itemLocation 
					ON itemLocation.intItemId = d.intItemId
					AND itemLocation.intLocationId = d.intPCompanyLocationId
			WHERE h.intLoadId = @intTransactionId
				AND Item.strType <> 'Comment'

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
					,[intLotId]				= l.intLotId --itemLot.intLotId
					,[intSubLocationId]		= ISNULL(wh.intSubLocationId, d.intSSubLocationId)
					,[intStorageLocationId]	= ISNULL(wh.intStorageLocationId, d.intSStorageLocationId)
					,[dblQty]				= CASE WHEN @ysnPost = 1 THEN d.dblQuantity ELSE -d.dblQuantity END 
					,[intTransactionId]		= h.intLoadId
					,[strTransactionId]		= h.strLoadNumber
					,[intTransactionTypeId] = 12 -- Inventory Transfer
					,[intFOBPointId]		= @FOB_DESTINATION
			FROM dbo.tblLGLoad h
				INNER JOIN dbo.tblLGLoadDetail d ON h.intLoadId = d.intLoadId
				INNER JOIN dbo.tblLGLoadDetailLot l ON l.intLoadDetailId = d.intLoadDetailId
				OUTER APPLY (
					SELECT TOP 1 clsl.intCompanyLocationId, lw.intSubLocationId, lw.intStorageLocationId FROM tblLGLoadWarehouse lw 
					INNER JOIN tblSMCompanyLocationSubLocation clsl ON lw.intSubLocationId = clsl.intCompanyLocationSubLocationId
					WHERE lw.intLoadId = h.intLoadId) wh
				INNER JOIN dbo.tblICItem Item ON Item.intItemId = d.intItemId
				INNER JOIN dbo.tblICItemLocation itemLocation 
					ON itemLocation.intItemId = d.intItemId
					AND itemLocation.intLocationId = ISNULL(wh.intCompanyLocationId, d.intSCompanyLocationId)
			WHERE h.intLoadId = @intTransactionId
				AND Item.strType <> 'Comment'

			EXEC dbo.uspICIncreaseInTransitInBoundQty @InTransit_Inbound
		END 		
	END 

	--------------------------------------------------------------------
	-- Call the Risk Log sp for Customer-Owned or Storage stocks. 
	--------------------------------------------------------------------
	BEGIN 
		EXEC @intReturnValue = dbo.uspICLogRiskPositionFromOnStorage
			@strBatchId
			,@strTransactionId
			,@intEntityUserSecurityId

		IF @intReturnValue < 0 RETURN @intReturnValue
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
			,@screenName = 'Logistics.view.ShipmentSchedule'        -- Screen Namespace
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