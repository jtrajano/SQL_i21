CREATE PROCEDURE uspICPostInventoryAdjustment  
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
DECLARE @TransactionName AS VARCHAR(500) = 'Inventory Adjustment Transaction' + CAST(NEWID() AS NVARCHAR(100));

-- Constants  
DECLARE @INVENTORY_ADJUSTMENT_TYPE AS INT = 10
DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) 

-- Get the Inventory Adjustment batch number
DECLARE @strBatchId AS NVARCHAR(40) 
DECLARE @strItemNo AS NVARCHAR(50)

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
			@intTransactionId = intInventoryAdjustmentId
			,@ysnTransactionPostedFlag = ysnPosted
			,@dtmDate = dtmAdjustmentDate
			,@intCreatedEntityId = intEntityId
	FROM	dbo.tblICInventoryAdjustment
	WHERE	strAdjustmentNo = @strTransactionId  
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
-- Validate if the Inventory Adjustment exists   
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
  
-- Check if the transaction is already unposted  
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

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT   

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1  
BEGIN  
	DECLARE @ItemsForPost AS ItemCostingTableType  

	-- TODO: Quantity Change. One for Lot and another one for non-lot. 		
	-- TODO: UOM Change. One for Lot and another one for non-lot. 
	-- TODO: Item Change. One for Lot and another one for non-lot. 
	-- TODO: Lot Status Change. This one is for lot only. 
	-- TODO: Split Lot. This one is for lot only. 
	-- TODO: Expiry date change. This one is for lot only. 
	
	----------------------------------------
	--  TODO Process the original data first. 
	----------------------------------------
	BEGIN 
		-- Insert the data into @ItemsForPost
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
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
		)  	
		SELECT	intItemId = Detail.intItemId
				,intItemLocationId = ItemLocation.intItemLocationId
				,intItemUOMId = NULL -- Detail.
				,dtmDate = Header.dtmAdjustmentDate  
				,dblQty = NULL -- Detail.
				,dblUOMQty = NULL -- Detail.
							--(
							--	SELECT	TOP 1 
							--			dblUnitQty
							--	FROM	dbo.tblICItemUOM
							--	WHERE	intItemUOMId = DetailItem.intUnitMeasureId
							--)

				,dblCost =	NULL -- Detail.
				,dblSalesPrice = 0  
				,intCurrencyId = NULL -- None
				,dblExchangeRate = 1  
				,intTransactionId = Header.intInventoryAdjustmentId  
				,strTransactionId = Header.strAdjustmentNo
				,intTransactionTypeId = @INVENTORY_ADJUSTMENT_TYPE  
				,intLotId = NULL -- Detail.intLotId
				,intSubLocationId = NULL -- Detail.intSubLocationId
				,intStorageLocationId = NULL -- Detail.intStorageLocationId
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICItemLocation ItemLocation
					ON Header.intLocationId = ItemLocation.intLocationId
				INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail 
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId 
					AND ItemLocation.intItemId = Detail.intItemId
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId   
  
		-- Call the post routine 
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
			EXEC	dbo.uspICPostCosting  
					@ItemsForPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@intUserId
		END
	END 
	
	-- TODO 
	-- Retrieve cost that needs to go with the new data. 
	-- Scenario:
	-- 1.	Adjust from one item/location/sub-location/storage-location/Lot id, total the cost from the original data. 
	--		Use the total cost as the cost for the new data.

	-----------------------------------
	--  TODO Then process the new data
	-----------------------------------
	BEGIN 
		-- Insert the data into @ItemsForPost
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
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
		)  	
		SELECT	intItemId = Detail.intItemId
				,intItemLocationId = ItemLocation.intItemLocationId
				,intItemUOMId = NULL -- Detail.
				,dtmDate = Header.dtmAdjustmentDate  
				,dblQty = NULL -- Detail.
				,dblUOMQty = NULL -- Detail.
							--(
							--	SELECT	TOP 1 
							--			dblUnitQty
							--	FROM	dbo.tblICItemUOM
							--	WHERE	intItemUOMId = DetailItem.intUnitMeasureId
							--)

				,dblCost =	NULL -- Detail.
				,dblSalesPrice = 0  
				,intCurrencyId = NULL -- None
				,dblExchangeRate = 1  
				,intTransactionId = Header.intInventoryAdjustmentId  
				,strTransactionId = Header.strAdjustmentNo
				,intTransactionTypeId = @INVENTORY_ADJUSTMENT_TYPE  
				,intLotId = NULL -- Detail.intLotId
				,intSubLocationId = NULL -- Detail.intSubLocationId
				,intStorageLocationId = NULL -- Detail.intStorageLocationId
		FROM	dbo.tblICInventoryAdjustment Header INNER JOIN dbo.tblICItemLocation ItemLocation
					ON Header.intLocationId = ItemLocation.intLocationId
				INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail 
					ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId 
					AND ItemLocation.intItemId = Detail.intItemId
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId   
  
		-- Call the post routine 
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
			EXEC	dbo.uspICPostCosting  
					@ItemsForPost  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
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
	EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 

	UPDATE	dbo.tblICInventoryAdjustment  
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	strAdjustmentNo = @strTransactionId  

	COMMIT TRAN @TransactionName
END 
    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit: