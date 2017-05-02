CREATE PROCEDURE [dbo].[uspICPostInventoryCount]
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
DECLARE @TransactionName AS VARCHAR(500) = 'Inventory Count Transaction' + CAST(NEWID() AS NVARCHAR(100));

-- Constants  
DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory Adjustment'

-- Get the Inventory Count batch number
DECLARE @strBatchId AS NVARCHAR(40) 
DECLARE @strItemNo AS NVARCHAR(50)

-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType
		,@intReturnValue AS INT
		,@ysnGLEntriesRequired AS BIT = 0

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)  
 
-- Create the type of lot numbers
DECLARE @LotType_Manual AS INT = 1
		,@LotType_Serial AS INT = 2

-- Read the transaction info   
BEGIN   
	DECLARE @dtmDate AS DATETIME   
			,@intTransactionId AS INT  
			,@intCreatedEntityId AS INT  
			,@ysnAllowUserSelfPost AS BIT   
			,@ysnTransactionPostedFlag AS BIT
			,@strCountDescription AS NVARCHAR(255)
			,@InventoryCount_TransactionType INT = 23
			,@intLocationId AS INT 

  
	SELECT TOP 1   
			@intTransactionId = intInventoryCountId
			,@ysnTransactionPostedFlag = ysnPosted
			,@dtmDate = dtmCountDate
			,@intCreatedEntityId = intEntityId
			,@strCountDescription = strDescription
			,@intLocationId = intLocationId
	FROM	dbo.tblICInventoryCount
	WHERE	strCountNo = @strTransactionId  
END  

--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
-- Validate if the Inventory Count exists   
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

-- Validate Lot Number for Lot-tracked items
DECLARE @ItemNo NVARCHAR(50)

SELECT TOP 1 @ItemNo = Item.strItemNo
FROM tblICInventoryCount IC 
	LEFT JOIN tblICInventoryCountDetail ICDetail ON ICDetail.intInventoryCountId = IC.intInventoryCountId
	LEFT JOIN tblICItem Item ON Item.intItemId = ICDetail.intItemId
WHERE IC.strCountNo = @strTransactionId AND Item.strLotTracking != 'No' AND (ICDetail.intLotId IS NULL OR ICDetail.intLotId NOT IN (SELECT intLotId FROM tblICLot WHERE intItemId = ICDetail.intItemId))

IF @ItemNo IS NOT NULL
	BEGIN
		-- Lot Number is invalid or missing for item {Item No.}
		EXEC uspICRaiseError 80130, @ItemNo;
		GOTO Post_Exit  
	END
-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId
IF @@ERROR <> 0 GOTO Post_Exit    

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
	SELECT 	intItemId				= Detail.intItemId
			,intItemLocationId		= ItemLocation.intItemLocationId
			,intItemUOMId			= Detail.intItemUOMId 
			,dtmDate				= Header.dtmCountDate
			,dblQty					= ISNULL(Detail.dblPhysicalCount, 0) - ISNULL(Detail.dblSystemCount, 0)
			,dblUOMQty				= ItemUOM.dblUnitQty	
			,dblCost				= dbo.fnMultiply(ISNULL(Detail.dblLastCost, ItemPricing.dblLastCost), ItemUOM.dblUnitQty)
			,0
			,dblSalesPrice			= 0
			,intCurrencyId			= @DefaultCurrencyId 
			,dblExchangeRate		= 1
			,intTransactionId		= Header.intInventoryCountId
			,intTransactionDetailId = Detail.intInventoryCountDetailId
			,strTransactionId		= Header.strCountNo
			,intTransactionTypeId	= @InventoryCount_TransactionType
			,intLotId				= Detail.intLotId
			,intSubLocationId		= Detail.intSubLocationId
			,intStorageLocationId	= Detail.intStorageLocationId
	FROM	dbo.tblICInventoryCount Header INNER JOIN dbo.tblICInventoryCountDetail Detail
				ON Header.intInventoryCountId = Detail.intInventoryCountId
				AND Detail.ysnRecount = 0
			INNER JOIN dbo.tblICItemLocation ItemLocation 
				ON ItemLocation.intLocationId = Header.intLocationId 
				AND ItemLocation.intItemId = Detail.intItemId
			INNER JOIN dbo.tblICItemPricing ItemPricing
				ON ItemPricing.intItemLocationId = ItemLocation.intItemLocationId
			LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON Detail.intItemUOMId = ItemUOM.intItemUOMId
	WHERE	Header.intInventoryCountId = @intTransactionId
			AND ISNULL(Detail.dblPhysicalCount, 0) <> ISNULL(Detail.dblSystemCount, 0)
	


	-----------------------------------
	--  Call the costing routine 
	-----------------------------------
	
	IF EXISTS (SELECT TOP 1 1 FROM @ItemsForAdjust)
	BEGIN 
		-----------------------------------------
		-- Generate the Costing
		-----------------------------------------
		EXEC	@intReturnValue = dbo.uspICPostCosting  
				@ItemsForAdjust  
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId
				,@strCountDescription

		IF @intReturnValue < 0 GOTO With_Rollback_Exit

		-----------------------------------------
		-- Generate a new set of g/l entries
		-----------------------------------------
		SET @ysnGLEntriesRequired = 1

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
			,@strCountDescription
	END				

	IF @intReturnValue < 0 GOTO With_Rollback_Exit
END   

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 0   
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

	ROLLBACK TRAN @TransactionName
	EXEC dbo.uspGLPostRecapOld 
			@GLEntries
			,@intTransactionId
			,@strTransactionId
			,'IC'
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
	-- If there are items for adjust, expect it to have g/l entries. 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN
		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost
	END

	UPDATE	dbo.tblICInventoryCount
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
			,dtmPosted = CASE WHEN @ysnPost = 1 THEN GETDATE() ELSE NULL END
	WHERE	intInventoryCountId = @intTransactionId

	COMMIT TRAN @TransactionName
END 

-- Update Status & Inventory Lock
IF EXISTS (SELECT 1 FROM dbo.tblICInventoryCount WHERE intInventoryCountId = @intTransactionId AND ysnPosted=1)
    BEGIN
        UPDATE dbo.tblICInventoryCount 
        SET intStatus = 4 --Closed
        WHERE intInventoryCountId=@intTransactionId

		--Unlock Inventory
		UPDATE il SET il.ysnLockedInventory = 0
		FROM tblICItemLocation il
			INNER JOIN tblICInventoryCount ic ON ic.intLocationId = il.intLocationId
			INNER JOIN tblICInventoryCountDetail icd ON icd.intInventoryCountId = ic.intInventoryCountId
				AND il.intItemId = icd.intItemId
		WHERE ic.intInventoryCountId = @intTransactionId
	END
ELSE
	BEGIN
		UPDATE dbo.tblICInventoryCount 
        SET intStatus = 3 --InventoryLocked
        WHERE intInventoryCountId=@intTransactionId

		--Lock Inventory
		UPDATE il SET il.ysnLockedInventory = 1
		FROM tblICItemLocation il
			INNER JOIN tblICInventoryCount ic ON ic.intLocationId = il.intLocationId
			INNER JOIN tblICInventoryCountDetail icd ON icd.intInventoryCountId = ic.intInventoryCountId
				AND il.intItemId = icd.intItemId
		WHERE ic.intInventoryCountId = @intTransactionId
	END

-- Create an Audit Log
IF @ysnRecap = 0 
BEGIN 
	DECLARE @strDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
			
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intTransactionId					-- Primary Key Value of the Inventory Count. 
			,@screenName = 'Inventory.view.InventoryCount'  -- Screen Namespace
			,@entityId = @intEntityUserSecurityId           -- Entity Id.
			,@actionType = @actionType                      -- Action Type
			,@changeDescription = @strDescription			-- Description
			,@fromValue = ''								-- Previous Value
			,@toValue = ''									-- New Value
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