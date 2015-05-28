CREATE PROCEDURE [dbo].[uspICPostInventoryTransfer]
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
DECLARE @TransactionName AS VARCHAR(500) = 'Inventory Transfer Transaction' + CAST(NEWID() AS NVARCHAR(100));

-- Constants  
DECLARE @INVENTORY_TRANSFER_TYPE AS INT = 12
		,@INVENTORY_TRANSFER_WITH_SHIPMENT_TYPE AS INT = 13

DECLARE @STARTING_NUMBER_BATCH AS INT = 3 
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory In-Transit'

-- Get the Inventory Receipt batch number
DECLARE @strBatchId AS NVARCHAR(40) 
DECLARE @strItemNo AS NVARCHAR(50)

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType 

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
  
	SELECT TOP 1   
			@intTransactionId = intInventoryTransferId
			,@ysnTransactionPostedFlag = ysnPosted
			,@dtmDate = dtmTransferDate
			,@intCreatedEntityId = intEntityId
			,@ysnShipmentRequired = ISNULL(ysnShipmentRequired, 0)
	FROM	dbo.tblICInventoryTransfer
	WHERE	strTransferNo = @strTransactionId
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

-- Check if all Items are avaiable under the To Location
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
	
	RAISERROR(51099, 11, 1, @ItemId, @LocationId)  
	GOTO Post_Exit  
END

IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE object_id = object_id('tempValidateItemLocation')) DROP TABLE #tempValidateItemLocation

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
			,@intUserId
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
		) 
		SELECT	Detail.intItemId  
				,dbo.fnICGetItemLocation(Detail.intItemId, Header.intFromLocationId)
				,Detail.intItemUOMId  
				,Header.dtmTransferDate
				,Detail.dblQuantity * -1
				,ItemUOM.dblUnitQty
				,Detail.dblCost  
				,0
				,NULL
				,1
				,@intTransactionId 
				,Detail.intInventoryTransferDetailId
				,@strTransactionId
				,@intTransactionType
				,Detail.intLotId 
				,Detail.intFromSubLocationId
				,Detail.intFromStorageLocationId
		FROM	tblICInventoryTransferDetail Detail LEFT JOIN tblICInventoryTransfer Header 
					ON Header.intInventoryTransferId = Detail.intInventoryTransferId
				LEFT JOIN tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = Detail.intItemUOMId

		-----------------------------------------
		-- Generate the g/l entries
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
		)
		EXEC	dbo.uspICPostCosting  
				@ItemsForRemovalPost  
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
				,@intUserId
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
		) 
		SELECT Detail.intItemId  
				,dbo.fnICGetItemLocation(Detail.intItemId, Header.intToLocationId)
				,Detail.intItemUOMId  
				,Header.dtmTransferDate
				,FromStock.dblQty * -1
				,FromStock.dblUOMQty
				,FromStock.dblCost
				,0
				,NULL
				,1
				,@intTransactionId 
				,Detail.intInventoryTransferDetailId
				,@strTransactionId
				,@INVENTORY_TRANSFER_TYPE
				,Detail.intNewLotId
				,Detail.intToSubLocationId
				,Detail.intToStorageLocationId
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

		-- Clear the GL entries 
		DELETE FROM @GLEntries

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
		)
		EXEC	dbo.uspICPostCosting  
				@ItemsForTransferPost  
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY 
				,@intUserId
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
	EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 

	UPDATE	dbo.tblICInventoryTransfer  
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	strTransferNo = @strTransactionId  

	COMMIT TRAN @TransactionName
END 
    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit: