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
DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'AP Clearing'

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
  
-- TODO Check if an item is inactive  
  
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

-- Check if lot items are assigned with at least one lot id. 
-- Get the top record and tell the user about it. 
-- Msg: Please specify the lot numbers for %s.
SET @strItemNo = NULL 
SELECT	TOP 1 
		@strItemNo = Item.strItemNo		
FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		INNER JOIN dbo.tblICItem Item
			ON Item.intItemId = ReceiptItem.intItemId
		INNER JOIN dbo.tblICInventoryReceiptItemLot ItemLot
			ON ReceiptItem.intInventoryReceiptItemId = ItemLot.intInventoryReceiptItemId	
WHERE	dbo.fnGetItemLotType(ReceiptItem.intItemId) IN (@LotType_Manual)		
		AND ISNULL(ItemLot.intLotId, 0) = 0
		AND Receipt.strReceiptNumber = @strTransactionId
GROUP BY  ReceiptItem.intInventoryReceiptItemId, Item.strItemNo

IF @strItemNo IS NOT NULL AND @ysnPost = 1
BEGIN 
	RAISERROR(51037, 11, 1, @strItemNo)  
	GOTO Post_Exit  
END 

-- Check if all lot items and their quantities are valid. 
-- Get the top record and tell the user about it. 
-- Msg: The lot Quantity(ies) on %s must match its Open Receive Quantity.
SET @strItemNo = NULL 
SELECT	TOP 1 
		@strItemNo = Item.strItemNo
FROM	dbo.tblICInventoryReceipt Receipt INNER JOIN dbo.tblICInventoryReceiptItem ReceiptItem
			ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		INNER JOIN dbo.tblICItem Item
			ON Item.intItemId = ReceiptItem.intItemId
		LEFT JOIN dbo.tblICInventoryReceiptItemLot ItemLot
			ON ReceiptItem.intInventoryReceiptItemId = ItemLot.intInventoryReceiptItemId	
WHERE	dbo.fnGetItemLotType(ReceiptItem.intItemId) IN (@LotType_Manual, @LotType_Serial)	
		AND Receipt.strReceiptNumber = @strTransactionId
GROUP BY  ReceiptItem.intInventoryReceiptItemId, Item.strItemNo, ReceiptItem.dblOpenReceive
HAVING SUM(ISNULL(ItemLot.dblQuantity, 0)) <> ReceiptItem.dblOpenReceive

IF @strItemNo IS NOT NULL AND @ysnPost = 1
BEGIN 
	RAISERROR(51038, 11, 1, @strItemNo)  
	GOTO Post_Exit  
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
	-- Generate the lot numbers 
	EXEC dbo.uspICCreateLotNumberOnInventoryReceipt @strTransactionId
 
	-- Get the items to post  
	DECLARE @ItemsToPost AS ItemCostingTableType  
	INSERT INTO @ItemsToPost (  
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
	)  
	SELECT	intItemId = DetailItems.intItemId  
			,intItemLocationId = ItemLocation.intItemLocationId
			,intItemUOMId = ItemUOM.intItemUOMId
			,dtmDate = Header.dtmReceiptDate  
			,dblQty = DetailItems.dblOpenReceive  
			,dblUOMQty = ItemUOM.dblUnitQty
			,dblCost = DetailItems.dblUnitCost  
			,dblSalesPrice = 0  
			,intCurrencyId = Header.intCurrencyId  
			,dblExchangeRate = 1  
			,intTransactionId = Header.intInventoryReceiptId  
			,strTransactionId = Header.strReceiptNumber  
			,intTransactionTypeId = @INVENTORY_RECEIPT_TYPE  
			,intLotId = DetailItemsLot.intLotId   
	FROM	dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICItemLocation ItemLocation
				ON Header.intLocationId = ItemLocation.intLocationId
			INNER JOIN dbo.tblICInventoryReceiptItem DetailItems  
				ON Header.intInventoryReceiptId = DetailItems.intInventoryReceiptId 
				AND ItemLocation.intItemId = DetailItems.intItemId
			INNER JOIN dbo.tblICItemUOM ItemUOM
				ON DetailItems.intItemId = ItemUOM.intItemId
				AND DetailItems.intUnitMeasureId = ItemUOM.intItemUOMId
			LEFT JOIN dbo.tblICInventoryReceiptItemLot DetailItemsLot
				ON DetailItems.intInventoryReceiptItemId = DetailItemsLot.intInventoryReceiptItemId
	WHERE	Header.intInventoryReceiptId = @intTransactionId   
  
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
				@ItemsToPost  
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

	UPDATE	dbo.tblICInventoryReceipt  
	SET		ysnPosted = @ysnPost
			,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
	WHERE	strReceiptNumber = @strTransactionId  

	-- Update the received quantities from the Purchase Order
	EXEC dbo.[uspPOReceived] @intTransactionId 
		IF @@ERROR <> 0	GOTO Post_Exit

	COMMIT TRAN @TransactionName
END 
    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit: