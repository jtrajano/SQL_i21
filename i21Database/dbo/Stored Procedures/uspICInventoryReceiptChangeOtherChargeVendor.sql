CREATE PROCEDURE [dbo].[uspICInventoryReceiptChangeOtherChargeVendor]
	@ReceiptId INT,
	@UserId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  
	
DECLARE 
	@INVENTORY_RECEIPT_TYPE AS INT = 4
	,@STARTING_NUMBER_BATCH AS INT = 3  

	,@strReceiptNumber AS NVARCHAR(50)
	,@intLocationId  AS INT 


SELECT 
	@strReceiptNumber = r.strReceiptNumber 
	,@intLocationId = r.intLocationId
FROM 
	tblICInventoryReceipt r 
WHERE 
	r.intInventoryReceiptId = @ReceiptId 
	AND r.ysnNewOtherChargeVendor = 1

-- Exit immediately if receipt does not exists. 
IF @strReceiptNumber IS NULL 
BEGIN 
	RETURN; 
END 

-- Calculate the new other charge tax if there is a new vendor. 
EXEC uspICCalculateInventoryReceiptOtherChargesTaxes
	@intInventoryReceiptId = @ReceiptId
	,@ysnNewVendorId = 1

-- Update the GL entries for the other charge. 
BEGIN 
	-- Call Starting number for Receipt Detail Update to prevent deadlocks. 
	BEGIN
		DECLARE @strUpdateRIDetail AS NVARCHAR(50)
		EXEC dbo.uspSMGetStartingNumber 155, @strUpdateRIDetail OUTPUT
		IF @@ERROR <> 0 RETURN;
	END 

	-- Get the next batch number
	BEGIN 
		DECLARE @strBatchId NVARCHAR(40)
		SET @strBatchId = NULL 
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId  
		IF @@ERROR <> 0 RETURN; 
	END

	-- Generate the GL entries for the tax changes
	DECLARE @GLEntries AS RecapTableType 
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
	EXEC uspICPostInventoryReceiptTaxes
		@intInventoryReceiptId = @ReceiptId
		,@strBatchId = @strBatchId
		,@intEntityUserSecurityId = @UserId
		,@intTransactionTypeId = @INVENTORY_RECEIPT_TYPE
		,@ysnNewVendorId = 1

	-- Book the GL entries 
	IF EXISTS (SELECT TOP 1 1 FROM @GLEntries)
	BEGIN 
		EXEC dbo.uspGLBookEntries @GLEntries, 1 
	END 
END

-- No need to add an audit log. CRUD has a built in audit log. It will automatically log the vendor change. 
