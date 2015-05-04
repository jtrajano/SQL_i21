CREATE PROCEDURE [dbo].[uspMFPostConsumption]
	 @ysnPost BIT  = 0  
	,@ysnRecap BIT  = 0  
	,@intWorkOrderId int 
	,@intUserId  INT  = NULL   
	,@intEntityId INT  = NULL
	,@strRetBatchId nvarchar(40)=NULL OUT
	    
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
-- Constants  
--DECLARE @INVENTORY_RECEIPT_TYPE AS INT = 4
DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = null
DECLARE @INVENTORY_CONSUME AS INT = 8

-- Get the Inventory Receipt batch number
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
	Declare @strTransactionId nvarchar(50)

	SELECT TOP 1   
			@intTransactionId = intWorkOrderId
			,@strTransactionId=strWorkOrderNo
			,@ysnTransactionPostedFlag = 0  
			,@dtmDate = GetDate()  
			,@intCreatedEntityId = @intUserId  
	FROM	dbo.tblMFWorkOrder   
	WHERE	intWorkOrderId=@intWorkOrderId
END  

-- Read the user preference  
--BEGIN  
--	SELECT	@ysnAllowUserSelfPost = 1  
--	FROM	dbo.tblSMPreferences   
--	WHERE	strPreference = 'AllowUserSelfPost'   
--			AND LOWER(RTRIM(LTRIM(strValue))) = 'true'    
--			AND intUserID = @intUserId  
--END   
--------------------------------------------------------------------------------------------  
-- Validate  
--------------------------------------------------------------------------------------------  
-- Validate if the Inventory Receipt exists   
--IF @intTransactionId IS NULL  
--BEGIN   
--	-- Cannot find the transaction.  
--	RAISERROR(50004, 11, 1)  
--	GOTO Post_Exit  
--END   
  
-- Validate the date against the FY Periods  
--IF @ysnRecap = 0 AND EXISTS (SELECT 1 WHERE dbo.isOpenAccountingDate(@dtmDate) = 0) 
--BEGIN   
--	-- Unable to find an open fiscal year period to match the transaction date.  
--	RAISERROR(50005, 11, 1)  
--	GOTO Post_Exit  
--END  
  
---- Check if the transaction is already posted  
--IF @ysnPost = 1 AND @ysnTransactionPostedFlag = 1  
--BEGIN   
--	-- The transaction is already posted.  
--	RAISERROR(50007, 11, 1)  
--	GOTO Post_Exit  
--END   
  
---- Check if the transaction is already posted  
--IF @ysnPost = 0 AND @ysnTransactionPostedFlag = 0  
--BEGIN   
--	-- The transaction is already unposted.  
--	RAISERROR(50008, 11, 1)  
--	GOTO Post_Exit  
--END   
  
-- TODO Check if an item is inactive  
  
-- Check Company preference: Allow User Self Post  
--IF @ysnAllowUserSelfPost = 1 AND @intEntityId <> @intCreatedEntityId AND @ysnRecap = 0   
--BEGIN   
--	-- 'You cannot %s transactions you did not create. Please contact your local administrator.'  
--	IF @ysnPost = 1   
--	BEGIN   
--		RAISERROR(50013, 11, 1, 'Post')  
--		GOTO Post_Exit  
--	END   

--	IF @ysnPost = 0  
--	BEGIN  
--		RAISERROR(50013, 11, 1, 'Unpost')  
--		GOTO Post_Exit    
--	END  
--END   

-- Create and validate the lot numbers
--BEGIN 	
--	EXEC dbo.uspICCreateLotNumberOnInventoryReceipt @strTransactionId
--	IF @@ERROR <> 0 GOTO Post_Exit
--END
--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
--BEGIN TRAN @TransactionName
--SAVE TRAN @TransactionName

-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT   

SELECT @strRetBatchId=@strBatchId

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
			,strTransactionId  
			,intTransactionTypeId  
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
	)  
	SELECT	intItemId				= l.intItemId  
			,intItemLocationId		= l.intItemLocationId
			,intItemUOMId			= ISNULL(l.intWeightUOMId,l.intItemUOMId)
			,dtmDate				= GetDate()  
			,dblQty					= (- cl.dblQuantity)
			,dblUOMQty				= ItemUOM.dblUnitQty --l.dblWeightPerQty (Do not use the weight per qty. Use instead the actual unit qty of the UOM.)
			,dblCost				= l.dblLastCost
			,dblSalesPrice			= 0  
			,intCurrencyId			= null  
			,dblExchangeRate		= 1  
			,intTransactionId		= @intTransactionId
			,strTransactionId		= @strTransactionId
			,intTransactionTypeId	= @INVENTORY_CONSUME  
			,intLotId				= l.intLotId 
			,intSubLocationId		= l.intSubLocationId
			,intStorageLocationId	= l.intStorageLocationId
	FROM	tblMFWorkOrderConsumedLot cl INNER JOIN tblICLot l 
				ON cl.intLotId = l.intLotId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON cl.intItemUOMId = ItemUOM.intItemUOMId
	WHERE	cl.intWorkOrderId = @intTransactionId   
  
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