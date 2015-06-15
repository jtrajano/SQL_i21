CREATE PROCEDURE uspICPostInventoryReceipt  
	@ysnPost BIT  = 0  
	,@ysnRecap BIT  = 0  
	,@strTransactionId NVARCHAR(40) = NULL   
	,@intUserId  INT  = NULL   
	,@intEntityId INT  = NULL    
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
		
		,@OWNERSHIP_TYPE_OWN AS INT = 1
		,@OWNERSHIP_TYPE_STORAGE AS INT = 2
		,@OWNERSHIP_TYPE_CONSIGNED_PURCHASE AS INT = 3
		,@OWNERSHIP_TYPE_CONSIGNED_SALE AS INT = 4

-- Posting variables
DECLARE @strBatchId AS NVARCHAR(40) 
		,@strItemNo AS NVARCHAR(50)
		,@ysnAllowBlankGLEntries AS BIT = 1

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType 

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)  
 
-- Create the type of lot numbers
DECLARE @LotType_Manual AS INT = 1
	,@LotType_Serial AS INT = 2

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

-- Read the user preference  
BEGIN  
	SELECT	@ysnAllowUserSelfPost = 1  
	FROM	dbo.tblSMPreferences   
	WHERE	strPreference = 'AllowUserSelfPost'   
			AND LOWER(RTRIM(LTRIM(strValue))) = 'true'    
			AND intUserID = @intUserId  
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

-- Check Company preference: Allow User Self Post  
IF @ysnAllowUserSelfPost = 1 AND @intEntityId <> @intCreatedEntityId AND @ysnRecap = 0   
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

-- Check the UOM
--IF @ysnPost = 1 
--BEGIN 
--	DECLARE @intUOMError AS INT

--	EXEC @intUOMError = dbo.uspICValidateInventoryRecieptwithPO
--		@strTransactionId

--	IF @intUOMError <> 0 
--		GOTO Post_Exit    
--END 

-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT  
IF @@ERROR <> 0 GOTO Post_Exit;

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
			,@intUserId
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
	DECLARE @CustodyItemsForPost AS ItemCostingTableType  

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
							-- Check if it is processing a lot item or not. 
							-- If it is a lot, 
							--		If there is no weight UOM, convert the Item-Lot-Qty to the UOM of the Detail-Item.
							--		If there is a weight UOM, receive the qty in weights. 
							-- Otherwise
							--		Receive the qty from the detail item. 
							CASE	WHEN ISNULL(DetailItemLot.intLotId, 0) <> 0  THEN 
										CASE	-- The item has no weight UOM. Receive it by converting the Qty to the Detail-Item UOM. 
												WHEN ISNULL(DetailItem.intWeightUOMId, 0) = 0  THEN 												
													dbo.fnCalculateQtyBetweenUOM(ISNULL(DetailItemLot.intItemUnitMeasureId, DetailItem.intUnitMeasureId), DetailItem.intUnitMeasureId, DetailItemLot.dblQuantity)
											
												-- The item has a weight UOM. 
												ELSE 
													-- If there is weight value (non-zero), use it. 
													-- Otherwise, convert the Qty from Detail-Item-Lot-UOM to the Detail-Item-Weight-UOM. 
													CASE	WHEN  ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0) = 0 THEN 
																dbo.fnCalculateQtyBetweenUOM(DetailItemLot.intItemUnitMeasureId, DetailItem.intWeightUOMId, DetailItemLot.dblQuantity)
															ELSE 
																ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0)
													END
										END 									
									ELSE	
										DetailItem.dblOpenReceive
							END 				
				,dblUOMQty = 
							-- Get the unit qy of the Weight UOM (if used) or from the DetailItem.intUnitMeasureId
							CASE	WHEN ISNULL(DetailItem.intWeightUOMId, 0) <> 0 THEN 
										(
											SELECT	TOP 1 
													dblUnitQty
											FROM	dbo.tblICItemUOM
											WHERE	intItemUOMId = DetailItem.intWeightUOMId									
										)
									ELSE 
										(
											SELECT	TOP 1 
													dblUnitQty
											FROM	dbo.tblICItemUOM
											WHERE	intItemUOMId = DetailItem.intUnitMeasureId
										)
							END 

				,dblCost =	-- If Weight is used, use the Cost per Weight. Otherwise, use the cost per qty. 
							CASE	WHEN ISNULL(DetailItem.intWeightUOMId, 0) <> 0 THEN 
										dbo.fnCalculateCostPerWeight (
											dbo.fnCalculateCostPerLot ( 
												DetailItem.intUnitMeasureId
												,DetailItem.intWeightUOMId
												,DetailItemLot.intItemUnitMeasureId
												,DetailItem.dblUnitCost
											) * DetailItemLot.dblQuantity
											,ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0)
										) 

									ELSE 
										DetailItem.dblUnitCost  
							END 

				,dblSalesPrice = 0  
				,intCurrencyId = Header.intCurrencyId  
				,dblExchangeRate = 1  
				,intTransactionId = Header.intInventoryReceiptId  
				,intTransactionDetailId  = DetailItem.intInventoryReceiptItemId
				,strTransactionId = Header.strReceiptNumber  
				,intTransactionTypeId = @INVENTORY_RECEIPT_TYPE  
				,intLotId = DetailItemLot.intLotId 
				,intSubLocationId = DetailItem.intSubLocationId
				,intStorageLocationId = DetailItemLot.intStorageLocationId
		FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICItemLocation ItemLocation
					ON Header.intLocationId = ItemLocation.intLocationId
				INNER JOIN dbo.tblICInventoryReceiptItem DetailItem 
					ON Header.intInventoryReceiptId = DetailItem.intInventoryReceiptId 
					AND ItemLocation.intItemId = DetailItem.intItemId
				LEFT JOIN dbo.tblICInventoryReceiptItemLot DetailItemLot
					ON DetailItem.intInventoryReceiptItemId = DetailItemLot.intInventoryReceiptItemId
		WHERE	Header.intInventoryReceiptId = @intTransactionId   
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_OWN) = @OWNERSHIP_TYPE_OWN
  
		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
		BEGIN 
			SET @ysnAllowBlankGLEntries = 0

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
			)
			EXEC	dbo.uspICPostCosting  
					@ItemsForPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@intUserId
		END
	END 

	-- Process custody items 
	BEGIN 
		INSERT INTO @CustodyItemsForPost (  
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
							-- Check if it is processing a lot item or not. 
							-- If it is a lot, 
							--		If there is no weight UOM, convert the Item-Lot-Qty to the UOM of the Detail-Item.
							--		If there is a weight UOM, receive the qty in weights. 
							-- Otherwise
							--		Receive the qty from the detail item. 
							CASE	WHEN ISNULL(DetailItemLot.intLotId, 0) <> 0  THEN 
										CASE	-- The item has no weight UOM. Receive it by converting the Qty to the Detail-Item UOM. 
												WHEN ISNULL(DetailItem.intWeightUOMId, 0) = 0  THEN 												
													dbo.fnCalculateQtyBetweenUOM(ISNULL(DetailItemLot.intItemUnitMeasureId, DetailItem.intUnitMeasureId), DetailItem.intUnitMeasureId, DetailItemLot.dblQuantity)
											
												-- The item has a weight UOM. 
												ELSE 
													-- If there is weight value (non-zero), use it. 
													-- Otherwise, convert the Qty from Detail-Item-Lot-UOM to the Detail-Item-Weight-UOM. 
													CASE	WHEN  ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0) = 0 THEN 
																dbo.fnCalculateQtyBetweenUOM(DetailItemLot.intItemUnitMeasureId, DetailItem.intWeightUOMId, DetailItemLot.dblQuantity)
															ELSE 
																ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0)
													END
										END 									
									ELSE	
										DetailItem.dblOpenReceive
							END 				
				,dblUOMQty = 
							-- Get the unit qy of the Weight UOM (if used) or from the DetailItem.intUnitMeasureId
							CASE	WHEN ISNULL(DetailItem.intWeightUOMId, 0) <> 0 THEN 
										(
											SELECT	TOP 1 
													dblUnitQty
											FROM	dbo.tblICItemUOM
											WHERE	intItemUOMId = DetailItem.intWeightUOMId									
										)
									ELSE 
										(
											SELECT	TOP 1 
													dblUnitQty
											FROM	dbo.tblICItemUOM
											WHERE	intItemUOMId = DetailItem.intUnitMeasureId
										)
							END 

				,dblCost =	-- If Weight is used, use the Cost per Weight. Otherwise, use the cost per qty. 
							CASE	WHEN ISNULL(DetailItem.intWeightUOMId, 0) <> 0 THEN 
										dbo.fnCalculateCostPerWeight (
											dbo.fnCalculateCostPerLot ( 
												DetailItem.intUnitMeasureId
												,DetailItem.intWeightUOMId
												,DetailItemLot.intItemUnitMeasureId
												,DetailItem.dblUnitCost
											) * DetailItemLot.dblQuantity
											,ISNULL(DetailItemLot.dblGrossWeight, 0) - ISNULL(DetailItemLot.dblTareWeight, 0)
										) 

									ELSE 
										DetailItem.dblUnitCost  
							END 

				,dblSalesPrice = 0  
				,intCurrencyId = Header.intCurrencyId  
				,dblExchangeRate = 1  
				,intTransactionId = Header.intInventoryReceiptId  
				,intTransactionDetailId  = DetailItem.intInventoryReceiptItemId
				,strTransactionId = Header.strReceiptNumber  
				,intTransactionTypeId = @INVENTORY_RECEIPT_TYPE  
				,intLotId = DetailItemLot.intLotId 
				,intSubLocationId = DetailItem.intSubLocationId
				,intStorageLocationId = DetailItemLot.intStorageLocationId
		FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICItemLocation ItemLocation
					ON Header.intLocationId = ItemLocation.intLocationId
				INNER JOIN dbo.tblICInventoryReceiptItem DetailItem 
					ON Header.intInventoryReceiptId = DetailItem.intInventoryReceiptId 
					AND ItemLocation.intItemId = DetailItem.intItemId
				LEFT JOIN dbo.tblICInventoryReceiptItemLot DetailItemLot
					ON DetailItem.intInventoryReceiptItemId = DetailItemLot.intInventoryReceiptItemId
		WHERE	Header.intInventoryReceiptId = @intTransactionId   
				AND ISNULL(DetailItem.intOwnershipType, @OWNERSHIP_TYPE_OWN) <> @OWNERSHIP_TYPE_OWN
  
		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @CustodyItemsForPost) 
		BEGIN 
			EXEC	dbo.uspICPostCustody
					@CustodyItemsForPost  
					,@strBatchId  
					,@intUserId
		END
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
		)
		EXEC	dbo.uspICUnpostCosting
				@intTransactionId
				,@strTransactionId
				,@strBatchId
				,@intUserId						
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
-- 3. Update the PO (if it exists)
-- 4. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 0
BEGIN 
	IF @ysnAllowBlankGLEntries = 0 
	BEGIN 
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
	END 
	
	UPDATE	dbo.tblICInventoryReceipt  
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	strReceiptNumber = @strTransactionId  

	-- Update the received quantities from the Purchase Order
	EXEC dbo.[uspPOReceived] 
		@intTransactionId 
		,@ysnPost

	COMMIT TRAN @TransactionName
END 
    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit: