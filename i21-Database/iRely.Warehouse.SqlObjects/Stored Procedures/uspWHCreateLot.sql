CREATE PROCEDURE uspWHCreateLot
	 @ysnPost BIT  = 0  
	,@ysnRecap BIT  = 0  
	,@intOrderHeaderId int 
	,@intItemId int   
	,@intUserId  INT  = NULL   
	,@intEntityId INT  = NULL
	,@intStorageLocationId int=null
	,@dblWeight NUMERIC(18, 6)
	,@intWeightUOMId INT
	,@dblUnitQty  NUMERIC(18, 6) = NULL
	,@dblProduceQty NUMERIC(18, 6)
	,@intProduceUOMKey INT
	,@strBatchId nvarchar(40)
	,@strLotNumber NVARCHAR(50)
	,@intBatchId int =NULL
	,@intLotId int Output
	,@strLotAlias nvarchar(50)
	,@strVendorLotNo nvarchar(50)=NULL
	,@strParentLotNumber nvarchar(50)=NULL
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  

-- Constants  
--DECLARE @INVENTORY_RECEIPT_TYPE AS INT = 4
DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Work In Progress'
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
	--Declare @intItemId int
	Declare @intLocationId int
	Declare @intSubLocationId int
	DECLARE @strBOLNo nvarchar(50)

	SELECT TOP 1   
			@intTransactionId = intOrderHeaderId
			,@ysnTransactionPostedFlag = 0  
			,@dtmDate = GetDate()  
			,@intCreatedEntityId = @intUserId
			,@strTransactionId = strBOLNo
			,@intLocationId=intShipToAddressId  
			,@strBOLNo = strBOLNo
	FROM	dbo.tblWHOrderHeader   
	WHERE	intOrderHeaderId=@intOrderHeaderId

	Select @intItemLocationId=intItemLocationId from tblICItemLocation where intLocationId=@intLocationId and intItemId=@intItemId
	Select @intSubLocationId=intSubLocationId from tblICStorageLocation where intStorageLocationId=@intStorageLocationId

END  

Declare @dblNewCost numeric(18,6)
Declare @dblNewUnitCost numeric(18,6)
Select @dblNewCost= [dbo].[fnGetTotalStockValueFromTransactionBatch](@intOrderHeaderId,@strBatchId)

Set @dblNewCost=ABS(@dblNewCost)

Set @dblNewUnitCost=ABS(@dblNewCost)/@dblProduceQty

DECLARE @ItemsThatNeedLotId AS dbo.ItemLotTableType
CREATE TABLE #GeneratedLotItems (
	intLotId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intDetailId INT
	,intParentLotId INT
	,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL 
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
			,strGarden
			,intDetailId
			,ysnProduced		
			,strTransactionId
			,strSourceTransactionId
			,intSourceTransactionTypeId
	)
	SELECT	intLotId					= null
			,strLotNumber				= @strLotNumber
			,strLotAlias				= @strLotAlias
			,intItemId					= @intItemId
			,intItemLocationId			= @intItemLocationId
			,intSubLocationId			= @intSubLocationId
			,intStorageLocationId		= @intStorageLocationId
			,dblQty						= @dblProduceQty
			,intItemUOMId				= @intProduceUOMKey
			,dblWeight					= (CASE	WHEN @intWeightUOMId=@intProduceUOMKey THEN NULL ELSE @dblWeight END)
			,intWeightUOMId				= (CASE	WHEN @intWeightUOMId=@intProduceUOMKey THEN NULL ELSE @intWeightUOMId END)
			,dtmExpiryDate				= @dtmExpiryDate
			,dtmManufacturedDate		= GetDate()
			,intOriginId				= null
			,strBOLNo					= null
			,strVessel					= null
			,strReceiptNumber			= null
			,strMarkings				= null
			,strNotes					= null
			,intEntityVendorId			= null
			,strVendorLotNo				= @strVendorLotNo
			,strGarden					= null
			,intDetailId				= @intOrderHeaderId
			,ysnProduced				= 1
			,strTransactionId			= @strBOLNo
			,strSourceTransactionId		= @strBOLNo
			,intSourceTransactionTypeId	= 4

	EXEC dbo.uspICCreateUpdateLotNumber 
		@ItemsThatNeedLotId
		,@intUserId

	Select TOP 1 @intLotId=intLotId from #GeneratedLotItems where intDetailId=@intOrderHeaderId

	EXEC dbo.uspMFCreateUpdateParentLotNumber @strParentLotNumber=@strParentLotNumber,
												@strParentLotAlias='',
												@intItemId=@intItemId,
												@dtmExpiryDate=@dtmExpiryDate,
												@intLotStatusId=1,
												@intEntityUserSecurityId =@intUserId,
												@intLotId=@intLotId,
												@intSubLocationId=@intSubLocationId,
												@intLocationId=@intLocationId

END

IF EXISTS(SELECT *FROM dbo.tblMFWorkOrder WHERE intWorkOrderId =@intOrderHeaderId AND intBlendRequirementId IS NULL)
BEGIN
	SELECT @intTransactionId=@intBatchId
	SELECT @strTransactionId=@strLotNumber 
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
			,intTransactionDetailId  
			,strTransactionId  
			,intTransactionTypeId  
			,intLotId 
			,intSubLocationId
			,intStorageLocationId
	)  
	SELECT	intItemId = @intItemId 
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intProduceUOMKey
			,dtmDate = GetDate()  
			,dblQty =	@dblProduceQty
			,dblUOMQty = 
						-- Get the unit qty of the Weight UOM or qty UOM
						CASE	WHEN (@intWeightUOMId=@intProduceUOMKey) THEN 
									(
										SELECT 1 
									)
								ELSE 
									(Case When @dblUnitQty is not null then @dblUnitQty else (
										SELECT	TOP 1 
												dblUnitQty
										FROM	dbo.tblICItemUOM
										WHERE	intItemUOMId = @intProduceUOMKey
									)end)
						END 
			,dblCost = @dblNewUnitCost
			,dblSalesPrice = 0  
			,intCurrencyId = null  
			,dblExchangeRate = 1  
			,intTransactionId = @intTransactionId
			,intTransactionDetailId = @intTransactionId
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
			,[dblDebitForeign]	
			,[dblDebitReport]	
			,[dblCreditForeign]	
			,[dblCreditReport]	
			,[dblReportingRate]	
			,[dblForeignRate]
			,[strRateType]
		)
		EXEC	dbo.uspICPostCosting  
				@ItemsForPost  
				,@strBatchId  
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				,@intUserId

		Delete from @GLEntries where strTransactionType='Consume'

		EXEC dbo.uspGLBookEntries @GLEntries, @ysnPost 
	END
END