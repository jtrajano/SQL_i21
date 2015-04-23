
CREATE PROCEDURE [dbo].[uspMFPostProduction]
	 @ysnPost BIT  = 0  
	,@ysnRecap BIT  = 0  
	,@intWorkOrderId int 
	,@intUserId  INT  = NULL   
	,@intEntityId INT  = NULL
	,@intStorageLocationId int=null
	,@dblWeight NUMERIC(18, 6)
	,@intWeightUOMId INT
	,@dblProduceQty NUMERIC(18, 6)
	,@intProduceUOMKey INT
	,@strBatchId nvarchar(40),
	@strLotNumber NVARCHAR(50)    
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
	Declare @intItemLocationId int
	Declare @intItemId int
	Declare @intLocationId int
	Declare @intSubLocationId int
	Declare @intLotId int

	SELECT TOP 1   
			@intTransactionId = intWorkOrderId
			,@ysnTransactionPostedFlag = 0  
			,@dtmDate = GetDate()  
			,@intCreatedEntityId = @intUserId
			,@strTransactionId = strWorkOrderNo
			,@intItemId=intItemId
			,@intLocationId=intLocationId  
	FROM	dbo.tblMFWorkOrder   
	WHERE	intWorkOrderId=@intWorkOrderId

	Select @intItemLocationId=intItemLocationId from tblICItemLocation where intLocationId=@intLocationId and intItemId=@intItemId
	Select @intSubLocationId=intSubLocationId from tblICStorageLocation where intStorageLocationId=@intStorageLocationId

END  

Declare @dblNewCost numeric(18,6)
Declare @dblNewUnitCost numeric(18,6)
Select @dblNewCost= [dbo].[fnGetTotalStockValueFromTransactionBatch](@intWorkOrderId,@strBatchId)

Set @dblNewCost=ABS(@dblNewCost)

Set @dblNewUnitCost=ABS(@dblNewCost)/@dblProduceQty

DECLARE @ItemsThatNeedLotId AS dbo.ItemLotTableType
CREATE TABLE #GeneratedLotItems (
	intLotId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intDetailId INT 
)

-- Create and validate the lot numbers
BEGIN 	
	Declare @strLifeTimeType NVARCHAR(50)
		,@intLifeTime INT
		,@dtmExpiryDate Datetime
		
		SELECT @strLifeTimeType = strLifeTimeType
			,@intLifeTime = intLifeTime
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		IF @strLifeTimeType = 'Years'
			SET @dtmExpiryDate = DateAdd(yy, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Months'
			SET @dtmExpiryDate = DateAdd(mm, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Days'
			SET @dtmExpiryDate = DateAdd(dd, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Hours'
			SET @dtmExpiryDate = DateAdd(hh, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Minutes'
			SET @dtmExpiryDate = DateAdd(mi, @intLifeTime, GetDate())
		Else
			SET @dtmExpiryDate = DateAdd(yy, 1, GetDate())


	INSERT INTO @ItemsThatNeedLotId (
			intLotId
			,strLotNumber
			,strLotAlias
			,intItemId
			,intItemLocationId
			,intSubLocationId
			,intStorageLocationId
			,dblQty
			,intItemUOMId
			,dblWeight
			,intWeightUOMId
			,dtmExpiryDate
			,dtmManufacturedDate
			,intOriginId
			,strBOLNo
			,strVessel
			,strReceiptNumber
			,strMarkings
			,strNotes
			,intEntityVendorId
			,strVendorLotNo
			,intVendorLocationId
			,strVendorLocation
			,intDetailId
			,ysnProduced		
	)
	SELECT	intLotId				= null
			,strLotNumber			= @strLotNumber
			,strLotAlias			= null
			,intItemId				= @intItemId
			,intItemLocationId		= @intItemLocationId
			,intSubLocationId		= @intSubLocationId
			,intStorageLocationId	= @intStorageLocationId
			,dblQty					= @dblProduceQty
			,intItemUOMId			= @intProduceUOMKey
			,dblWeight				= @dblWeight
			,intWeightUOMId			= @intWeightUOMId
			,dtmExpiryDate			= @dtmExpiryDate
			,dtmManufacturedDate	= GetDate()
			,intOriginId			= null
			,strBOLNo				= null
			,strVessel				= null
			,strReceiptNumber		= null
			,strMarkings			= null
			,strNotes				= null
			,intEntityVendorId		= null
			,strVendorLotNo			= null
			,intVendorLocationId	= null
			,strVendorLocation		= null
			,intDetailId			= @intWorkOrderId
			,ysnProduced			= 1

	EXEC dbo.uspICCreateUpdateLotNumber 
		@ItemsThatNeedLotId
		,@intUserId

Select TOP 1 @intLotId=intLotId from #GeneratedLotItems where intDetailId=@intWorkOrderId

END

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
	SELECT	intItemId = @intItemId 
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intWeightUOMId
			,dtmDate = GetDate()  
			,dblQty =	@dblWeight 
			,dblUOMQty = 1
			,dblCost = @dblNewUnitCost
			,dblSalesPrice = 0  
			,intCurrencyId = null  
			,dblExchangeRate = 1  
			,intTransactionId = @intTransactionId
			,strTransactionId = @strTransactionId
			,intTransactionTypeId = @INVENTORY_PRODUCE  
			,intLotId = @intLotId 
			,intSubLocationId = @intSubLocationId
			,intStorageLocationId = @intStorageLocationId
  
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

		Update @GLEntries Set dblDebit=@dblNewCost where strTransactionType='Produce'

		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
	END
END   


