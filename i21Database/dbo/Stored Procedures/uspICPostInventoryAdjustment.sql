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
DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory Adjustment'

-- Get the Inventory Adjustment batch number
DECLARE @strBatchId AS NVARCHAR(40) 
DECLARE @strItemNo AS NVARCHAR(50)

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType 
		,@adjustmentTypeRequiresGLEntries AS BIT 

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)  
 
-- Create the type of lot numbers
DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

DECLARE @ADJUSTMENT_TYPE_QuantityChange AS INT = 1
		,@ADJUSTMENT_TYPE_UOMChange AS INT = 2
		,@ADJUSTMENT_TYPE_ItemChange AS INT = 3
		,@ADJUSTMENT_TYPE_LotStatusChange AS INT = 4
		,@ADJUSTMENT_TYPE_SplitLot AS INT = 5
		,@ADJUSTMENT_TYPE_ExpiryDateChange AS INT = 6
		,@ADJUSTMENT_TYPE_LotMerge AS INT = 7
		,@ADJUSTMENT_TYPE_LotMove AS INT = 8

-- Read the transaction info   
BEGIN   
	DECLARE @dtmDate AS DATETIME   
			,@intTransactionId AS INT  
			,@intCreatedEntityId AS INT  
			,@ysnAllowUserSelfPost AS BIT   
			,@ysnTransactionPostedFlag AS BIT
			,@strAdjustmentDescription AS NVARCHAR(255) 
			,@adjustmentType AS INT

  
	SELECT TOP 1   
			@intTransactionId = intInventoryAdjustmentId
			,@ysnTransactionPostedFlag = ysnPosted
			,@dtmDate = dtmAdjustmentDate
			,@intCreatedEntityId = intEntityId
			,@adjustmentType = intAdjustmentType
			,@strAdjustmentDescription = strDescription
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

-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT   
IF @@ERROR <> 0 GOTO Post_Exit    

-- Determine if Adjustment requires costing and GL entries. 
SELECT @adjustmentTypeRequiresGLEntries = 1
WHERE 	@adjustmentType IN (
			@ADJUSTMENT_TYPE_QuantityChange
			, @ADJUSTMENT_TYPE_SplitLot
			, @ADJUSTMENT_TYPE_LotMerge
			, @ADJUSTMENT_TYPE_LotMove
		)

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1  
BEGIN  
	DECLARE @ItemsForAdjust AS ItemCostingTableType  

	-----------------------------------
	--  Call Quantity Change 
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_QuantityChange
	BEGIN 
		INSERT INTO @ItemsForAdjust (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost  
				,dblValue 
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
		EXEC	dbo.uspICPostInventoryAdjustmentQtyChange
				@intTransactionId
	END 

	-----------------------------------
	--  Call UOM Change 
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_UOMChange
	BEGIN 
		INSERT INTO @ItemsForAdjust (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost  
				,dblValue 
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
		EXEC	dbo.uspICPostInventoryAdjustmentUOMChange
				@intTransactionId
	END 

	-----------------------------------
	--  Call Item Change 
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_ItemChange
	BEGIN 
		INSERT INTO @ItemsForAdjust (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost  
				,dblValue 
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
		EXEC	dbo.uspICPostInventoryAdjustmentItemChange
				@intTransactionId
	END 

	-----------------------------------
	--  Call Lot Status Change
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_LotStatusChange
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustmentLotStatusChange
				@intTransactionId
				,@ysnPost
	END 

	-----------------------------------
	--  Call Split Lot Change
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_SplitLot
	BEGIN 
	
		EXEC dbo.uspICPostInventoryAdjustmentSplitLotChange
				@intTransactionId
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intUserId
				,@strAdjustmentDescription	
	END 

	-----------------------------------
	--  Call Lot Merge
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_LotMerge
	BEGIN 
		INSERT INTO @ItemsForAdjust (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost
				,dblValue
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
		EXEC dbo.uspICPostInventoryAdjustmentLotMerge 
				@intTransactionId
				,@strBatchId
				,@intUserId
				,@strAdjustmentDescription	
	END 

	-----------------------------------
	--  Call Lot Move
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_LotMove
	BEGIN 
		INSERT INTO @ItemsForAdjust (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost
				,dblValue
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
		EXEC dbo.uspICPostInventoryAdjustmentLotMove
				@intTransactionId
				,@intUserId
	END 

	-----------------------------------
	--  Call Expiry Lot Change
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_ExpiryDateChange
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustmentExpiryLotChange
				@intTransactionId
				,@ysnPost
	END 
	
	-----------------------------------
	--  Call the costing routine 
	-----------------------------------
	IF @adjustmentTypeRequiresGLEntries = 1
	BEGIN 
		-----------------------------------------
		-- Generate the Costing
		-----------------------------------------
		IF EXISTS (SELECT TOP 1 1 FROM @ItemsForAdjust)
		BEGIN 
			EXEC	dbo.uspICPostCosting  
					@ItemsForAdjust  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@intUserId
					,@strAdjustmentDescription
		END				
				
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
		EXEC dbo.uspICCreateGLEntries 
			@strBatchId
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
			,@intUserId
			,@strAdjustmentDescription						
	END 
END   

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 0   
BEGIN   
	-- Call the unpost routine 
	IF @adjustmentType IN (
		@ADJUSTMENT_TYPE_QuantityChange
		, @ADJUSTMENT_TYPE_SplitLot
		, @ADJUSTMENT_TYPE_LotMerge
		, @ADJUSTMENT_TYPE_LotMove
	)
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

	IF @adjustmentType = @ADJUSTMENT_TYPE_LotStatusChange
	BEGIN 
		EXEC	dbo.uspICPostInventoryAdjustmentLotStatusChange
				@intTransactionId
				,@ysnPost
	END 	

	IF @adjustmentType = @ADJUSTMENT_TYPE_ExpiryDateChange
	BEGIN 
		EXEC	dbo.uspICPostInventoryAdjustmentExpiryLotChange
				@intTransactionId
				,@ysnPost
	END 	
	
END   

--------------------------------------------------------------------------------------------  
-- If RECAP is TRUE, 
-- 1. Store all the GL entries in a holding table. It will be used later as data  
--	  for the recap screen.
-- 2. Rollback the save point 
-- 3. Book the G/L entries
-- 4. Commit the save point.
--------------------------------------------------------------------------------------------  
IF	@ysnRecap = 1	
BEGIN 
	IF @adjustmentTypeRequiresGLEntries = 1
	BEGIN 
		ROLLBACK TRAN @TransactionName
		EXEC dbo.uspGLPostRecap 
				@GLEntries
				,@intTransactionId
				,@strTransactionId
				,'IC'
		COMMIT TRAN @TransactionName
	END 
	ELSE 
	BEGIN 
		ROLLBACK TRAN @TransactionName
		COMMIT TRAN @TransactionName

		-- Recap is not applicable for this type of transaction.
		RAISERROR(51098, 11, 1)  
		GOTO Post_Exit  
	END
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
	-- If there are items for adjust, expect it to have g/l entries. 
	IF @adjustmentTypeRequiresGLEntries = 1
	BEGIN 
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
	END

	UPDATE	dbo.tblICInventoryAdjustment  
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
			,dtmPostedDate = CASE WHEN @ysnPost = 1 THEN GETDATE() ELSE dtmPostedDate	END
			,dtmUnpostedDate = CASE WHEN @ysnPost = 0 THEN GETDATE() ELSE dtmUnpostedDate	END
	WHERE	strAdjustmentNo = @strTransactionId  

	COMMIT TRAN @TransactionName
END 

GOTO Post_Exit

-- This is an exit if stock is outdated. 
OutdatedStockOnHand_Exit: 
BEGIN 
	COMMIT TRAN @TransactionName
END

-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit: