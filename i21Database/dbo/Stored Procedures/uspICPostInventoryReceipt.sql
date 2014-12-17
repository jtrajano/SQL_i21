CREATE PROCEDURE uspICPostInventoryReceipt  
 @ysnPost    BIT  = 0  
 ,@ysnRecap    BIT  = 0  
 ,@strTransactionId  NVARCHAR(40) = NULL   
 ,@intUserId    INT  = NULL   
 ,@intEntityId   INT  = NULL    
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------  
  
-- Constants  
DECLARE @INVENTORY_RECEIPT_TYPE AS INT = 2  
DECLARE @STARTING_NUMBER_INVENTORY_RECEIPT AS INT = 23  
  
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
   @intTransactionId = intInventoryReceiptId  
   ,@ysnTransactionPostedFlag = ysnPosted  
   ,@dtmDate = dtmReceiptDate  
   ,@intCreatedEntityId = intEntityId  
 FROM [dbo].tblICInventoryReceipt   
 WHERE strReceiptNumber = @strTransactionId  
END  
   
-- Read the user preference  
BEGIN  
 SELECT @ysnAllowUserSelfPost = 1  
 FROM dbo.tblSMPreferences   
 WHERE strPreference = 'AllowUserSelfPost'   
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
IF EXISTS (SELECT 1 WHERE [dbo].isOpenAccountingDate(@dtmDate) = 0) AND @ysnRecap = 0  
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
  
--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1  
BEGIN   
 -- Get the items to post  
 DECLARE @ItemsToPost AS ItemCostingTableType  
 INSERT INTO @ItemsToPost (  
   intItemId  
   ,intLocationId  
   ,dtmDate  
   ,dblUnitQty  
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
 SELECT intItemId = DetailItems.intItemId  
   ,intLocationId = Header.intLocationId  
   ,dtmDate = Header.dtmReceiptDate  
   ,dblUnitQty = DetailItems.dblReceived  
   ,dblUOMQty = 1  
   ,dblCost = DetailItems.dblUnitCost  
   ,dblSalesPrice = 0  
   ,intCurrencyId = Header.intCurrencyId  
   ,dblExchangeRate = 1  
   ,intTransactionId = Header.intInventoryReceiptId  
   ,strTransactionId = Header.strReceiptNumber  
   ,intTransactionTypeId = @INVENTORY_RECEIPT_TYPE  
   ,intLotId= NULL   
 FROM dbo.tblICInventoryReceipt Header INNER JOIN dbo.tblICInventoryReceiptItem DetailItems  
    ON Header.intInventoryReceiptId = DetailItems.intInventoryReceiptId  
 WHERE Header.intInventoryReceiptId = @intTransactionId  
  
 DECLARE @strBatchId AS NVARCHAR(40)  
 EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_INVENTORY_RECEIPT, @strBatchId OUTPUT   
  
 -- Call the post routine  
 EXEC dbo.uspICPostCosting  
  @ItemsToPost  
  ,@strBatchId  
  ,'A/P Clearing'  
  ,@intUserId    
END   
  
--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 0   
BEGIN   
 -- TODO: Unpost routine  
 PRINT 'TODO: Unpost routine';  
END   
  
--------------------------------------------------------------------------------------------  
-- Update the ysnPosted flag on the transaction   
--------------------------------------------------------------------------------------------  
BEGIN   
 UPDATE dbo.tblICInventoryReceipt  
 SET  ysnPosted = @ysnPost  
 WHERE strReceiptNumber = @strTransactionId  
END   
  
-- Goto statement for immediate exit.   
-- Do not commit or rollback within this stored procedure. Let the calling code do the rollback or commit.   
Post_Exit: