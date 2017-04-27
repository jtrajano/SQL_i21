CREATE PROCEDURE uspICPostBuildAssembly
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
DECLARE @TransactionName AS VARCHAR(500) = 'Build Assembly Transaction' + CAST(NEWID() AS NVARCHAR(100));

-- Constants  
DECLARE @BUILD_ASSEMBLY_TYPE AS INT = 11
DECLARE @STARTING_NUMBER_BATCH AS INT = 3 

-- Get the Inventory Receipt batch number
DECLARE @strBatchId AS NVARCHAR(40) 
DECLARE @strItemNo AS NVARCHAR(50)

-- Get the default currency ID
DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType 
		,@intReturnValue AS INT

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)  
 
-- Read the transaction info   
BEGIN   
	DECLARE @dtmDate AS DATETIME   
	DECLARE @intTransactionId AS INT  
	DECLARE @intCreatedEntityId AS INT  
	DECLARE @ysnAllowUserSelfPost AS BIT   
	DECLARE @ysnTransactionPostedFlag AS BIT  
  
	SELECT TOP 1   
			@intTransactionId = intBuildAssemblyId
			,@ysnTransactionPostedFlag = ysnPosted
			,@dtmDate = dtmBuildDate
			,@intCreatedEntityId = intEntityId
	FROM	dbo.tblICBuildAssembly
	WHERE	strBuildNo = @strTransactionId
END  
  
--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
-- Validate if the Inventory Receipt exists   
IF @intTransactionId IS NULL  
BEGIN   
	-- Cannot find the transaction.  
	RAISERROR('Cannot find the transaction.', 11, 1)  
	GOTO Post_Exit  
END   
  
-- Validate the date against the FY Periods  
IF @ysnRecap = 0 AND EXISTS (SELECT 1 WHERE dbo.isOpenAccountingDate(@dtmDate) = 0) 
BEGIN   
	-- Unable to find an open fiscal year period to match the transaction date.  
	RAISERROR('Unable to find an open fiscal year period to match the transaction date.', 11, 1)  
	GOTO Post_Exit  
END  
  
-- Check if the transaction is already posted  
IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1  
BEGIN   
	-- The transaction is already posted.  
	RAISERROR('The transaction is already posted.', 11, 1)  
	GOTO Post_Exit  
END   
  
-- Check if the transaction is already posted  
IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
BEGIN   
	-- The transaction is already unposted.  
	RAISERROR('The transaction is already unposted.', 11, 1)  
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
		RAISERROR('You cannot %s transactions you did not create. Please contact your local administrator.', 11, 1, 'Post')  
		GOTO Post_Exit  
	END   

	IF @ysnPost = 0  
	BEGIN  
		RAISERROR('You cannot %s transactions you did not create. Please contact your local administrator.', 11, 1, 'Unpost')  
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
	-- Get the items to post  
	DECLARE @ItemsForPost AS ItemCostingTableType  
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
	SELECT Detail.intItemId
			, dbo.fnICGetItemLocation(Detail.intItemId, AssemblyItem.intLocationId)
			, Detail.intItemUOMId
			, AssemblyItem.dtmBuildDate
			, (ISNULL(Detail.dblQuantity, 0) * ISNULL(AssemblyItem.dblBuildQuantity, 0)) * -1
			, ItemUOM.dblUnitQty
			, Detail.dblCost
			, 0
			, @DefaultCurrencyId
			, 1
			, @intTransactionId
			, Detail.intBuildAssemblyDetailId
			, @strTransactionId
			, @BUILD_ASSEMBLY_TYPE
			, NULL
			, Detail.intSubLocationId
			, NULL
	FROM	tblICBuildAssembly AssemblyItem INNER JOIN tblICBuildAssemblyDetail Detail 
				ON AssemblyItem.intBuildAssemblyId = Detail.intBuildAssemblyId
			LEFT JOIN tblICItemUOM ItemUOM 
				ON ItemUOM.intItemUOMId = Detail.intItemUOMId
				AND ItemUOM.intItemId = Detail.intItemId
	WHERE	AssemblyItem.intBuildAssemblyId = @intTransactionId

	-- Call the post routine 
	BEGIN 
		EXEC	@intReturnValue = dbo.uspICPostCosting  
				@ItemsForPost  
				,@strBatchId  
				,NULL
				,@intEntityUserSecurityId

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END

	-- Get the assembly item to post  
	DECLARE @AssemblyItemForPost AS ItemCostingTableType  
	INSERT INTO @AssemblyItemForPost (  
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
	SELECT Item.intItemId
			, dbo.fnICGetItemLocation(Item.intItemId, Item.intLocationId)
			, Item.intItemUOMId
			, Item.dtmBuildDate
			, ISNULL(Item.dblBuildQuantity, 0)
			, ItemUOM.dblUnitQty
			, -1 * dbo.fnGetTotalStockValueFromTransactionBatch(@intTransactionId, @strBatchId) / ISNULL(Item.dblBuildQuantity, 0)
			, 0
			, @DefaultCurrencyId
			, 1
			, @intTransactionId
			, @intTransactionId
			, @strTransactionId
			, @BUILD_ASSEMBLY_TYPE
			, NULL
			, Item.intSubLocationId
			, NULL
	FROM	tblICBuildAssembly Item LEFT JOIN tblICItemUOM ItemUOM 
				ON ItemUOM.intItemUOMId = Item.intItemUOMId
	WHERE	Item.intBuildAssemblyId = @intTransactionId

	-- Call the post routine 
	BEGIN 
		EXEC	@intReturnValue = dbo.uspICPostCosting  
				@AssemblyItemForPost  
				,@strBatchId  
				,NULL
				,@intEntityUserSecurityId

		IF @intReturnValue < 0 GOTO With_Rollback_Exit
	END

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
			,NULL
			,@intEntityUserSecurityId
			,NULL

	IF @intReturnValue < 0 GOTO With_Rollback_Exit
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

	UPDATE	dbo.tblICBuildAssembly  
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	strBuildNo = @strTransactionId  

	COMMIT TRAN @TransactionName
END 

-- Create an Audit Log
IF @ysnRecap = 0 
BEGIN 
	DECLARE @strDescription AS NVARCHAR(100) 
			,@actionType AS NVARCHAR(50)

	SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
			
	EXEC	dbo.uspSMAuditLog 
			@keyValue = @intTransactionId							-- Primary Key Value of the Inventory Build Assembly. 
			,@screenName = 'Inventory.view.BuildAssemblyBlend'		-- Screen Namespace
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