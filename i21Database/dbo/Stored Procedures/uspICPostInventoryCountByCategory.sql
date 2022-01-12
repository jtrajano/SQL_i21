CREATE PROCEDURE [dbo].[uspICPostInventoryCountByCategory]
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
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------    
-- Create a unique transaction name. 
DECLARE @TransactionName AS VARCHAR(500) = 'InventoryCountByCategory' + CAST(NEWID() AS NVARCHAR(100));

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
BEGIN TRAN @TransactionName
SAVE TRAN @TransactionName

-- Constants  
DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Inventory Adjustment'

-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType
		,@intReturnValue AS INT
		,@InventoryCountByCategory AS INT 

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)  

SELECT	TOP 1 @InventoryCountByCategory = intTransactionTypeId
FROM	tblICInventoryTransactionType 
WHERE	strName = 'Inventory Count By Category'
 
-- Read the transaction info   
BEGIN   
	DECLARE @dtmDate AS DATETIME   
			,@intTransactionId AS INT  
			,@intCreatedEntityId AS INT  
			,@ysnAllowUserSelfPost AS BIT   
			,@ysnTransactionPostedFlag AS BIT
			,@InventoryCountByCategory_TransactionType INT = 23
			,@intLocationId AS INT
  
	SELECT TOP 1   
			@intTransactionId = intInventoryCountByCategoryId
			,@ysnTransactionPostedFlag = ysnPosted
			,@dtmDate = dtmCountDate
			,@intCreatedEntityId = intCreatedByUserId
			,@intLocationId = intLocationId
	FROM	dbo.tblICInventoryCountByCategory
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
	GOTO With_Rollback_Exit  
END   
  
-- Validate the date against the FY Periods  
IF @ysnRecap = 0 AND EXISTS (SELECT 1 WHERE dbo.isOpenAccountingDate(@dtmDate) = 0) 
BEGIN   
	-- Unable to find an open fiscal year period to match the transaction date.  
	EXEC uspICRaiseError 80168; 
	GOTO With_Rollback_Exit  
END  
  
-- Check if the transaction is already posted  
IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1  
BEGIN   
	-- The transaction is already posted.  
	EXEC uspICRaiseError 80169; 
	GOTO With_Rollback_Exit  
END   
  
-- Check if the transaction is already unposted  
IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
BEGIN   
	-- The transaction is already unposted.  
	EXEC uspICRaiseError 80170; 
	GOTO With_Rollback_Exit  
END   
 
IF @ysnRecap = 0
BEGIN 
	UPDATE	dbo.tblICInventoryCountByCategory
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
			,dtmPosted = CASE WHEN @ysnPost = 1 THEN GETDATE() ELSE NULL END
	WHERE	intInventoryCountByCategoryId = @intTransactionId
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
		GOTO With_Rollback_Exit  
	END   

	IF @ysnPost = 0  
	BEGIN  
		EXEC uspICRaiseError 80172, 'Unpost';
		GOTO With_Rollback_Exit    
	END  
END   


-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId
IF @@ERROR <> 0 GOTO With_Rollback_Exit    

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1  
BEGIN  
	DECLARE @CategoryCount AS ItemCostingTableType  
	INSERT INTO @CategoryCount (  
		intItemId  
		,intItemLocationId 
		,intItemUOMId  
		,dtmDate  
		,dblQty
		,dblUOMQty
		,dblCost
		,intTransactionId  
		,intTransactionDetailId   
		,strTransactionId  
		,intTransactionTypeId  
		,intSubLocationId
		,intStorageLocationId
		,intCurrencyId
		,intForexRateTypeId
		,dblForexRate
		,dblUnitRetail
		,intCategoryId
		,dblAdjustCostValue
		,dblAdjustRetailValue
	)  	
	SELECT 
		intItemId  = CategoryItem.intItemId
		,intItemLocationId  = CategoryItem.intItemLocationId
		,intItemUOMId  = CategoryItem.intItemUOMId
		,dtmDate = h.dtmCountDate
		,dblQty = 0 
		,dblUOMQty = 0 
		,dblCost = 0 
		,intTransactionId  = h.intInventoryCountByCategoryId
		,intTransactionDetailId = d.intInventoryCountByCategoryDetailId
		,strTransactionId = h.strCountNo
		,intTransactionTypeId = @InventoryCountByCategory
		,intSubLocationId = NULL 
		,intStorageLocationId = NULL 
		,intCurrencyId = @DefaultCurrencyId
		,intForexRateTypeId = NULL 
		,dblForexRate = 1 
		,dblUnitRetail = NULL 
		,intCategoryId = d.intCategoryId
		,dblAdjustCostValue = ISNULL(d.dblNewCost, 0) - ISNULL(d.dblCurrentCost, 0) 
		,dblAdjustRetailValue = ISNULL(d.dblNewRetail, 0) - ISNULL(d.dblCurrentRetail, 0) 
	FROM 
		tblICInventoryCountByCategory h INNER JOIN tblICInventoryCountByCategoryDetail d
			ON h.intInventoryCountByCategoryId = d.intInventoryCountByCategoryId
		INNER JOIN tblICCategory cat
			ON cat.intCategoryId = d.intCategoryId
		-- Find an item as host to the inventory count by category. 
		CROSS APPLY ( 
			SELECT TOP 1	
				i.intItemId
				,il.intItemLocationId
				,iu.intItemUOMId
			FROM 
				tblICItem i INNER JOIN tblICItemLocation il
					ON i.intItemId = il.intItemId 										
				INNER JOIN tblICItemUOM iu
					ON iu.intItemId = i.intItemId
					AND iu.ysnStockUnit = 1
				INNER JOIN tblICCostingMethod cm
					ON cm.intCostingMethodId = il.intCostingMethod
			WHERE 
				i.intCategoryId = cat.intCategoryId
				AND il.intLocationId = h.intLocationId 
				AND cm.strCostingMethod = 'CATEGORY'
		) CategoryItem
	WHERE
		h.intInventoryCountByCategoryId = @intTransactionId
		AND h.strCountNo = @strTransactionId
		
	-----------------------------------
	--  Call the costing routine 
	-----------------------------------	
	IF EXISTS (SELECT TOP 1 1 FROM @CategoryCount)
	BEGIN 
		-----------------------------------------
		-- Generate the Costing
		-----------------------------------------
		EXEC	@intReturnValue = dbo.uspICPostCosting  
				@CategoryCount  
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intEntityUserSecurityId

		IF @intReturnValue < 0 GOTO With_Rollback_Exit

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
				,[intSourceEntityId]
				,[intCommodityId]
		)
		EXEC @intReturnValue = dbo.uspICCreateGLEntries 
			@strBatchId
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
			,@intEntityUserSecurityId
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

--------------------------------------------------------------------------------------------  
-- If RECAP is TRUE, 
-- 1. Store all the GL entries in a holding table. It will be used later as data  
--	  for the recap screen.
-- 2. Rollback the save point 
-- 3. Book the G/L entries
-- 4. Commit the save point.
--------------------------------------------------------------------------------------------  
IF @ysnRecap = 1
BEGIN 
	ROLLBACK TRAN @TransactionName

	-- Save the GL Entries data into the GL Post Recap table by calling uspGLPostRecap. 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		EXEC dbo.uspGLPostRecap 
			@GLEntries
			,@intEntityUserSecurityId
	END 

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
	COMMIT TRAN @TransactionName
END 

-- Create an Audit Log
IF @ysnRecap = 0 
BEGIN 
	DECLARE @strDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
			
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intTransactionId					-- Primary Key Value of the Inventory Count. 
			,@screenName = 'Inventory.view.InventoryCountByCategory'  -- Screen Namespace
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
	RETURN -1;
END

Post_Exit: