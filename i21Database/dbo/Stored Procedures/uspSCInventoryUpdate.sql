CREATE PROCEDURE [dbo].[uspSCInventortUpdate]
	 @intTicketId INT
	,@intUserId INT = NULL
	,@intEntityId INT = NULL
	,@dblProduceQty NUMERIC(18, 6)
	,@intProduceUOMKey INT
	,@strBatchId NVARCHAR(40)
	,@dblScaleCost NUMERIC(18, 6)
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
DECLARE @INVENTORY_PRODUCE AS INT = 9
-- Get the Inventory Receipt batch number
--DECLARE @strBatchId AS NVARCHAR(40) 
DECLARE @strItemNo AS NVARCHAR(50)
-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType
DECLARE @ysnPost AS BIT  = 1

-- Ensure ysnPost is not NULL  
SET @ysnPost = ISNULL(@ysnPost, 0)

-- Read the transaction info   
BEGIN
	DECLARE @dtmDate AS DATETIME
	DECLARE @intTransactionId AS INT
	DECLARE @intCreatedEntityId AS INT
	DECLARE @ysnAllowUserSelfPost AS BIT
	DECLARE @ysnTransactionPostedFlag AS BIT
	DECLARE @strTransactionId NVARCHAR(50)
	DECLARE @intItemLocationId INT
	DECLARE @intItemId INT
	DECLARE @intLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @intLotId INT

	SELECT TOP 1 @intTransactionId = intTicketId
		,@ysnTransactionPostedFlag = 0
		,@dtmDate = GetDate()
		,@intCreatedEntityId = @intUserId
		,@strTransactionId = strTicketNumber
		,@intItemId = intItemId
		,@intLocationId = intProcessingLocationId
	FROM dbo.tblSCTicket
	WHERE intTicketId = @intTicketId

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intLocationId = @intLocationId
		AND intItemId = @intItemId
END

DECLARE @dblNewCost NUMERIC(18, 6)


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
	SELECT intItemId = @intItemId
		,intItemLocationId = @intItemLocationId
		,intItemUOMId = @intProduceUOMKey
		,dtmDate = GetDate()
		,dblQty = @dblProduceQty
		,dblUOMQty = 1
		,dblCost = @dblScaleCost
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intTransactionId
		,intTransactionDetailId = @intTransactionId
		,strTransactionId = @strTransactionId
		,intTransactionTypeId = @INVENTORY_PRODUCE
		,intLotId = null
		,intSubLocationId = null
		,intStorageLocationId = null

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
			,[dblDebitForeign]	
			,[dblDebitReport]	
			,[dblCreditForeign]	
			,[dblCreditReport]	
			,[dblReportingRate]	
			,[dblForeignRate]
			,[strRateType]
		)
		EXEC dbo.uspICPostCosting @ItemsForPost
			,@strBatchId
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
			,@intUserId
	END
END
