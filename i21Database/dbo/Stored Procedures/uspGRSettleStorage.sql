CREATE PROCEDURE [dbo].[uspGRSettleStorage]
	@intEntityUserSecurityId AS INT 
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- CONSTANTS  
DECLARE		
	@STARTING_NUMBER_BATCH AS INT = 3  
	
DECLARE		
	-- Variables used by uspICPostStorage			
	@ItemsToStorage AS ItemCostingTableType 
	,@strBatchId AS NVARCHAR(20)
	
	--  Variables used by uspICAddItemReceipt
	,@ReceiptStagingTable ReceiptStagingTable 
	,@OtherCharges ReceiptOtherChargesTableType 
	
	-- Variables used by uspICProcessToBill
	,@intReceiptId AS INT
	,@intBillId AS INT 

	-- Variables used by uspICPostInventoryReceipt
	,@strReceiptNumber AS NVARCHAR(50)

	-- Variables used by uspAPPostBill
	,@success AS BIT 

-- Step 1: Validate
-- TODO: Add any validations
-- For example:
/*
	-- 'You cannot %s transactions you did not create. Please contact your local administrator.'  
	BEGIN   
		RAISERROR('You cannot %s transactions you did not create. Please contact your local administrator.', 11, 1, 'Post')  
		GOTO Post_Exit  
	END   
*/

-- Step 2: Initialize the variables
BEGIN 
	
	-- Get the next batch number
	BEGIN 
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT  
		IF @@ERROR <> 0 GOTO SettleStorage_Exit;
	END

	-- Create the temp table used by uspICAddItemReceipt
	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
	BEGIN 
		CREATE TABLE #tmpAddItemReceiptResult (
			intSourceId INT
			,intInventoryReceiptId INT
		)
	END 
END 
	
-- Step 3: Reduce the On-Storage Quantity. 
BEGIN 
	-- TODO: Populate the @ItemsToStorage

	-- You can refer to uspICPostInventoryShipment on how to populate the data for @ItemsToStorage
	EXEC uspICPostStorage 
		@ItemsToStorage
		, @strBatchId
		, @intEntityUserSecurityId

	IF @@ERROR <> 0 GOTO SettleStorage_Exit;
END 


-- Step 4: Create the Inventory-Receipt. 

-- Use the Inventory Receipt to add the stock. Make sure it has cost.
-- Posting the Inventory Receipt will increase the Inventory and A/P Clearing. 
BEGIN 
	-- TODO: Populate the data for @ReceiptStagingTable
	-- TODO: Populate the data for @OtherCharges
	
	-- You can refer to uspTRLoadProcessToInventoryReceipt on how to populate the data for @ReceiptStagingTable and @OtherCharges
	EXEC dbo.uspICAddItemReceipt 
		@ReceiptStagingTable
		,@OtherCharges
		,@intEntityUserSecurityId;
	IF @@ERROR <> 0 GOTO SettleStorage_Exit;

END 

-- If uspICAddItemReceipt is successful in creating the IR transaction, there will be data in #tmpAddItemReceiptResult
IF EXISTS (SELECT TOP 1 1 FROM #tmpAddItemReceiptResult)
BEGIN 
	-- Get top record to process. 
	SELECT TOP 1 
			@strReceiptNumber = strReceiptNumber
			,@intReceiptId = intInventoryReceiptId
	FROM	#tmpAddItemReceiptResult result INNER JOIN tblICInventoryReceipt r
				ON result.intInventoryReceiptId = r.intInventoryReceiptId

	-- Step 5: Auto-post the Inventory Receipt. 
	IF @intReceiptId IS NOT NULL 
	BEGIN 
		EXEC uspICPostInventoryReceipt 
			@ysnPost = 1
			, @ysnRecap = 0
			, @strTransactionId = @strReceiptNumber
			, @intEntityUserSecurityId = @intEntityUserSecurityId
		IF @@ERROR <> 0 GOTO SettleStorage_Exit;

	END

	-- Step 6: Process the IR to Voucher. 
	IF @intReceiptId IS NOT NULL 
	BEGIN 
		EXEC uspICProcessToBill 
				@intReceiptId
				, @intEntityUserSecurityId
				, @intBillId OUTPUT 
		IF @@ERROR <> 0 GOTO SettleStorage_Exit;	
	END 

	-- Step 7: Auto-post the Voucher. 
	IF @intBillId IS NOT NULL 
	BEGIN 
		EXEC [dbo].[uspAPPostBill]
			@post = 1
			,@recap = 0
			,@isBatch = 0
			,@param = @intBillId
			,@userId = @intEntityUserSecurityId
			,@success = @success OUTPUT
		IF @@ERROR <> 0 GOTO SettleStorage_Exit;	
	END

	-- Remove the receipt id from the list. 
	DELETE FROM #tmpAddItemReceiptResult
	WHERE	intInventoryReceiptId = @intReceiptId
END 

SettleStorage_Exit: 