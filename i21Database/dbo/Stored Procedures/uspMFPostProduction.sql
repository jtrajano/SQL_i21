CREATE PROCEDURE [dbo].[uspMFPostProduction] @ysnPost BIT = 0
	,@ysnRecap BIT = 0
	,@intWorkOrderId INT
	,@intItemId INT
	,@intUserId INT = NULL
	,@intEntityId INT = NULL
	,@intStorageLocationId INT = NULL
	,@dblWeight NUMERIC(38, 20)
	,@intWeightUOMId INT
	,@dblUnitQty NUMERIC(38, 20) = NULL
	,@dblProduceQty NUMERIC(38, 20)
	,@intProduceUOMKey INT
	,@strBatchId NVARCHAR(40)
	,@strLotNumber NVARCHAR(50)
	,@intBatchId INT = NULL
	,@intLotId INT OUTPUT
	,@strLotAlias NVARCHAR(50)
	,@strVendorLotNo NVARCHAR(50) = NULL
	,@strParentLotNumber NVARCHAR(50) = NULL
	,@strVessel NVARCHAR(100) = NULL
	,@dtmProductionDate DATETIME = NULL
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
	DECLARE @strTransactionId NVARCHAR(50)
	DECLARE @intItemLocationId INT
	--Declare @intItemId int
	DECLARE @intLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @strLotTracking NVARCHAR(50)

	SELECT TOP 1 @intTransactionId = intWorkOrderId
		,@ysnTransactionPostedFlag = 0
		,@dtmDate = GetDate()
		,@intCreatedEntityId = @intUserId
		,@strTransactionId = strWorkOrderNo
		,@intLocationId = intLocationId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF @dtmProductionDate > @dtmDate
		OR @dtmProductionDate IS NULL
	BEGIN
		SELECT @dtmProductionDate = @dtmDate
	END

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intLocationId = @intLocationId
		AND intItemId = @intItemId

	SELECT @intSubLocationId = intSubLocationId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId

	SELECT @strLotTracking = strLotTracking
	FROM tblICItem
	WHERE intItemId = @intItemId
END

DECLARE @dblNewCost NUMERIC(38, 20)
DECLARE @dblNewUnitCost NUMERIC(38, 20)

SELECT @dblNewCost = [dbo].[fnGetTotalStockValueFromTransactionBatch](@intWorkOrderId, @strBatchId)

SET @dblNewCost = ABS(@dblNewCost)
SET @dblNewUnitCost = ABS(@dblNewCost) / @dblProduceQty

DECLARE @ItemsThatNeedLotId AS dbo.ItemLotTableType

CREATE TABLE #GeneratedLotItems (
	intLotId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intDetailId INT
	,intParentLotId INT
	,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	)

-- Create and validate the lot numbers
IF @strLotTracking <> 'No'
BEGIN
	DECLARE @strLifeTimeType NVARCHAR(50)
		,@intLifeTime INT
		,@dtmExpiryDate DATETIME

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
	ELSE
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
	SELECT intLotId = NULL
		,strLotNumber = @strLotNumber
		,strLotAlias = @strLotAlias
		,intItemId = @intItemId
		,intItemLocationId = @intItemLocationId
		,intSubLocationId = @intSubLocationId
		,intStorageLocationId = @intStorageLocationId
		,dblQty = @dblProduceQty
		,intItemUOMId = @intProduceUOMKey
		,dblWeight = (
			CASE 
				WHEN @intWeightUOMId = @intProduceUOMKey
					THEN NULL
				ELSE @dblWeight
				END
			)
		,intWeightUOMId = (
			CASE 
				WHEN @intWeightUOMId = @intProduceUOMKey
					THEN NULL
				ELSE @intWeightUOMId
				END
			)
		,dtmExpiryDate = @dtmExpiryDate
		,dtmManufacturedDate = @dtmProductionDate
		,intOriginId = NULL
		,strBOLNo = NULL
		,strVessel = @strVessel
		,strReceiptNumber = NULL
		,strMarkings = NULL
		,strNotes = NULL
		,intEntityVendorId = NULL
		,strVendorLotNo = @strVendorLotNo
		,strGarden = NULL
		,intDetailId = @intWorkOrderId
		,ysnProduced = 1
		,strTransactionId = @strTransactionId
		,strSourceTransactionId = @strTransactionId
		,intSourceTransactionTypeId = @INVENTORY_PRODUCE

	EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
		,@intUserId

	SELECT TOP 1 @intLotId = intLotId
	FROM #GeneratedLotItems
	WHERE intDetailId = @intWorkOrderId

	EXEC dbo.uspMFCreateUpdateParentLotNumber @strParentLotNumber = @strParentLotNumber
		,@strParentLotAlias = ''
		,@intItemId = @intItemId
		,@dtmExpiryDate = @dtmExpiryDate
		,@intLotStatusId = 1
		,@intEntityUserSecurityId = @intUserId
		,@intLotId = @intLotId
		,@intSubLocationId = @intSubLocationId
		,@intLocationId = @intLocationId
END

IF EXISTS (
		SELECT *
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId
			AND intBlendRequirementId IS NULL
		)
BEGIN
	SELECT @intTransactionId = @intBatchId

	SELECT @strTransactionId = @strLotNumber
END

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1
BEGIN
	-- Get the items to post  
	DECLARE @ItemsForPost AS ItemCostingTableType

	IF @strLotTracking = 'No'
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
			,intSourceTransactionId
			,strSourceTransactionId
			)
		SELECT intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intProduceUOMKey
			,dtmDate = @dtmProductionDate
			,dblQty = @dblProduceQty
			,dblUOMQty = 1
			,dblCost = @dblNewUnitCost
			,dblSalesPrice = 0
			,intCurrencyId = NULL
			,dblExchangeRate = 1
			,intTransactionId = @intTransactionId
			,intTransactionDetailId = @intTransactionId
			,strTransactionId = @strTransactionId
			,intTransactionTypeId = @INVENTORY_PRODUCE
			,intLotId = NULL
			,intSubLocationId = @intSubLocationId
			,intStorageLocationId = @intStorageLocationId
			,intSourceTransactionId = @INVENTORY_PRODUCE
			,strSourceTransactionId = @strTransactionId
	ELSE
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
			,intSourceTransactionId
			,strSourceTransactionId
			)
		SELECT intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intProduceUOMKey
			,dtmDate = @dtmProductionDate
			,dblQty = @dblProduceQty
			,dblUOMQty =
			-- Get the unit qty of the Weight UOM or qty UOM
			CASE 
				WHEN (@intWeightUOMId = @intProduceUOMKey)
					THEN (
							SELECT 1
							)
				ELSE (
						CASE 
							WHEN @dblUnitQty IS NOT NULL
								THEN @dblUnitQty
							ELSE (
									SELECT TOP 1 dblUnitQty
									FROM dbo.tblICItemUOM
									WHERE intItemUOMId = @intProduceUOMKey
									)
							END
						)
				END
			,dblCost = @dblNewUnitCost
			,dblSalesPrice = 0
			,intCurrencyId = NULL
			,dblExchangeRate = 1
			,intTransactionId = @intTransactionId
			,intTransactionDetailId = @intTransactionId
			,strTransactionId = @strTransactionId
			,intTransactionTypeId = @INVENTORY_PRODUCE
			,intLotId = @intLotId
			,intSubLocationId = @intSubLocationId
			,intStorageLocationId = @intStorageLocationId
			,intSourceTransactionId = @INVENTORY_PRODUCE
			,strSourceTransactionId = @strTransactionId

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
			)
		EXEC dbo.uspICPostCosting @ItemsForPost
			,@strBatchId
			,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
			,@intUserId

		DELETE
		FROM @GLEntries
		WHERE strTransactionType = 'Consume'

		EXEC dbo.uspGLBookEntries @GLEntries
			,@ysnPost
	END
END
