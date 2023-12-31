﻿CREATE PROCEDURE uspICPostInventoryAdjustment  
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
		,@intReturnValue AS INT

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
		,@ADJUSTMENT_TYPE_LotOwnerChange AS INT = 9

-- Read the transaction info   
BEGIN   
	DECLARE @dtmDate AS DATETIME   
			,@intTransactionId AS INT  
			,@intCreatedEntityId AS INT  
			,@ysnAllowUserSelfPost AS BIT   
			,@ysnTransactionPostedFlag AS BIT
			,@strAdjustmentDescription AS NVARCHAR(255) 
			,@adjustmentType AS INT
			,@intLocationId AS INT 

  
	SELECT TOP 1   
			@intTransactionId = intInventoryAdjustmentId
			,@ysnTransactionPostedFlag = ysnPosted
			,@dtmDate = dtmAdjustmentDate
			,@intCreatedEntityId = intEntityId
			,@adjustmentType = intAdjustmentType
			,@strAdjustmentDescription = strDescription
			,@intLocationId = intLocationId 
	FROM	dbo.tblICInventoryAdjustment
	WHERE	strAdjustmentNo = @strTransactionId  
END  

--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
-- Validate if the Inventory Adjustment exists   
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
  
-- Check if the transaction is already unposted  
IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
BEGIN   
	-- The transaction is already unposted.  
	EXEC uspICRaiseError 80170; 
	GOTO Post_Exit  
END   

--------------------------------------------------------------------------------
-- Check if lot numbers are unique.	
--------------------------------------------------------------------------------
BEGIN 
	IF EXISTS(SELECT	Lot.intLotId, COUNT(Lot.intLotId) intCount
		FROM	dbo.tblICInventoryAdjustment Header
				INNER JOIN dbo.tblICInventoryAdjustmentDetail Detail ON Header.intInventoryAdjustmentId = Detail.intInventoryAdjustmentId
				INNER JOIN dbo.tblICLot Lot ON Lot.intLotId = Detail.intLotId
		WHERE	Header.intInventoryAdjustmentId = @intTransactionId
		GROUP BY Lot.intLotId
		HAVING COUNT(Lot.intLotId) > 1
	)
	BEGIN
		EXEC uspICRaiseError 80171; 		 
		GOTO Post_Exit  
	END
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
		GOTO Post_Exit  
	END   

	IF @ysnPost = 0  
	BEGIN  
		EXEC uspICRaiseError 80172, 'Unpost'; 		 
		GOTO Post_Exit    
	END  
END

-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId
IF @@ERROR <> 0 GOTO Post_Exit    

-- Determine if Adjustment requires costing and GL entries. 
SELECT @adjustmentTypeRequiresGLEntries = 1
WHERE 	@adjustmentType IN (
			@ADJUSTMENT_TYPE_QuantityChange
			, @ADJUSTMENT_TYPE_SplitLot
			, @ADJUSTMENT_TYPE_LotMerge
			, @ADJUSTMENT_TYPE_LotMove
			, @ADJUSTMENT_TYPE_ItemChange
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

	-- Because of the rounding issue at JavaScript, recalculate the Adjust By Quantity field. 
	-- Recalc by Pack Qty
	UPDATE	ad
	SET		ad.dblAdjustByQuantity = ad.dblNewQuantity - l.dblQty 
			,ad.dblQuantity = l.dblQty
	FROM	dbo.tblICInventoryAdjustment a INNER JOIN dbo.tblICInventoryAdjustmentDetail ad
				ON a.intInventoryAdjustmentId = ad.intInventoryAdjustmentId
			INNER JOIN dbo.tblICLot l
				ON l.intLotId = ad.intLotId 
				AND l.intItemUOMId = ad.intItemUOMId
	WHERE	a.strAdjustmentNo = @strTransactionId
			AND ad.dblNewQuantity IS NOT NULL 			
			AND a.ysnPosted = 0 
	
	-- Recalc by Weight Qty
	UPDATE	ad
	SET		ad.dblAdjustByQuantity = ad.dblNewQuantity - l.dblWeight
			,ad.dblQuantity = l.dblWeight
	FROM	dbo.tblICInventoryAdjustment a INNER JOIN dbo.tblICInventoryAdjustmentDetail ad
				ON a.intInventoryAdjustmentId = ad.intInventoryAdjustmentId
			INNER JOIN dbo.tblICLot l
				ON l.intLotId = ad.intLotId 
				AND l.intWeightUOMId = ad.intItemUOMId
				AND l.intItemUOMId <> ad.intItemUOMId
	WHERE	a.strAdjustmentNo = @strTransactionId
			AND ad.dblNewQuantity IS NOT NULL 	
			AND a.ysnPosted = 0 

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
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId
				,@strAdjustmentDescription
	END 

	-----------------------------------
	--  Call Lot Status Change
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_LotStatusChange
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostInventoryAdjustmentLotStatusChange
				@intTransactionId
				,@ysnPost

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END 

	-----------------------------------
	--  Call Split Lot Change
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_SplitLot
	BEGIN 	
		EXEC @intReturnValue = dbo.uspICPostInventoryAdjustmentSplitLotChange
				@intTransactionId
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId
				,@strAdjustmentDescription	

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END 

	-----------------------------------
	--  Call Lot Merge
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_LotMerge
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostInventoryAdjustmentLotMerge
				@intTransactionId
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId
				,@strAdjustmentDescription

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END 

	-----------------------------------
	--  Call Lot Move
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_LotMove
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostInventoryAdjustmentLotMove
				@intTransactionId
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId
				,@strAdjustmentDescription

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END 

	-----------------------------------
	--  Call Expiry Lot Change
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_ExpiryDateChange
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostInventoryAdjustmentExpiryLotChange
				@intTransactionId
				,@ysnPost

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END 

	-----------------------------------
	--  Call Lot Owner Change
	-----------------------------------
	IF @adjustmentType = @ADJUSTMENT_TYPE_LotOwnerChange
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostInventoryAdjustmentLotOwnerChange
				@intTransactionId
				,@ysnPost

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
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
			EXEC	@intReturnValue = dbo.uspICPostCosting  
					@ItemsForAdjust  
					,@strBatchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@intEntityUserSecurityId
					,@strAdjustmentDescription

			IF @intReturnValue < 0 GOTO With_Rollback_Exit
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
			,@strAdjustmentDescription

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
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

	IF @adjustmentType = @ADJUSTMENT_TYPE_LotOwnerChange
	BEGIN 
		EXEC @intReturnValue = dbo.uspICPostInventoryAdjustmentLotOwnerChange
				@intTransactionId
				,@ysnPost

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
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
		EXEC dbo.uspGLPostRecapOld 
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
		EXEC uspICRaiseError 80025;
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

-- Create an Audit Log
IF @ysnRecap = 0 
BEGIN 
	DECLARE @strDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
			
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intTransactionId							-- Primary Key Value of the Inventory Adjustment. 
			,@screenName = 'Inventory.view.InventoryAdjustment'     -- Screen Namespace
			,@entityId = @intEntityUserSecurityId                   -- Entity Id.
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