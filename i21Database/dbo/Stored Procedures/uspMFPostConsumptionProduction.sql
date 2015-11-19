﻿CREATE PROCEDURE [dbo].[uspMFPostConsumptionProduction] @intWorkOrderId INT
	,@intItemId int
	,@strLotNumber NVARCHAR(50)
	,@dblWeight NUMERIC(18, 6)
	,@intWeightUOMId INT
	,@dblUnitQty NUMERIC(18, 6) = NULL
	,@dblQty NUMERIC(18, 6)
	,@intItemUOMId INT
	,@intUserId INT = NULL
	,@intBatchId int
	,@intLotId INT OUTPUT
	,@strLotAlias nvarchar(50)
	,@strVendorLotNo nvarchar(50)= NULL
	,@strParentLotNumber nvarchar(50)
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @STARTING_NUMBER_BATCH AS INT = 3
		,@INVENTORY_CONSUME AS INT = 8
		,@INVENTORY_PRODUCE AS INT = 9
		,@ItemsThatNeedLotId AS dbo.ItemLotTableType
		,@ItemsForPost AS ItemCostingTableType
		,@GLEntries AS RecapTableType
		,@strBatchId NVARCHAR(40)
		,@intItemLocationId INT
		,@strItemNo AS NVARCHAR(50)
		,@intLocationId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@dblNewCost NUMERIC(18, 6)
		,@dblNewUnitCost NUMERIC(18, 6)
		,@strLifeTimeType NVARCHAR(50)
		,@intLifeTime INT
		,@dtmExpiryDate DATETIME
		,@dtmPlannedDate datetime
		,@intItemStockUOMId int
		,@strWorkOrderNo NVARCHAR(50)
		,@dtmDate datetime

	SELECT TOP 1 @intLocationId = W.intLocationId
		,@intSubLocationId = SL.intSubLocationId
		,@intStorageLocationId =  W.intStorageLocationId
		,@dtmPlannedDate=dtmPlannedDate
		,@strWorkOrderNo=strWorkOrderNo 
	FROM dbo.tblMFWorkOrder W
	JOIN dbo.tblICStorageLocation SL on W.intStorageLocationId=SL.intStorageLocationId
	WHERE intWorkOrderId = @intWorkOrderId

	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
		,@strBatchId OUTPUT

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
	SELECT intItemId = l.intItemId
		,intItemLocationId = l.intItemLocationId
		,intItemUOMId = ISNULL(l.intWeightUOMId, l.intItemUOMId)
		,dtmDate = @dtmPlannedDate
		,dblQty = (- cl.dblQuantity)
		,dblUOMQty = (Case When l.intWeightUOMId is null then 1 else l.dblWeightPerQty End)
		,dblCost = l.dblLastCost
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intBatchId
		,intTransactionDetailId = cl.intWorkOrderConsumedLotId
		,strTransactionId = (Case When @strLotNumber is null or @strLotNumber='' Then @strWorkOrderNo else @strLotNumber End)
		,intTransactionTypeId = @INVENTORY_CONSUME
		,intLotId = l.intLotId
		,intSubLocationId = l.intSubLocationId
		,intStorageLocationId = l.intStorageLocationId
	FROM tblMFWorkOrderConsumedLot cl
	INNER JOIN tblICLot l ON cl.intLotId = l.intLotId
	INNER JOIN dbo.tblICItemUOM ItemUOM ON cl.intItemUOMId = ItemUOM.intItemUOMId
	WHERE cl.intWorkOrderId = @intWorkOrderId and cl.intBatchId=@intBatchId

	EXEC dbo.uspICPostCosting @ItemsForPost
		,@strBatchId
		,NULL
		,@intUserId

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intLocationId = @intLocationId
		AND intItemId = @intItemId

	SELECT @intItemStockUOMId = intItemUOMId
	FROM tblICItemUOM
	WHERE intItemId = @intItemId and ysnStockUnit=1 

	SELECT @dblNewCost = [dbo].[fnGetTotalStockValueFromTransactionBatch](@intBatchId, @strBatchId)

	SET @dblNewCost = ABS(@dblNewCost)

	SET @dblNewUnitCost = ABS(@dblNewCost) / @dblQty

	DECLARE @dblCostPerStockUOM NUMERIC(18,6)

	IF @intItemStockUOMId=@intItemUOMId
	BEGIN
		SELECT @dblCostPerStockUOM=@dblNewUnitCost
	END
	ELSE
	BEGIN
		SELECT @dblCostPerStockUOM=dbo.fnCalculateUnitCost(@dblNewUnitCost,@dblUnitQty)
	END

	CREATE TABLE #GeneratedLotItems (
		intLotId INT
		,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,intDetailId INT
		,intParentLotId INT
		,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	)

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
		,intGradeId
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
		)
	SELECT intLotId = NULL
		,strLotNumber = @strLotNumber
		,strLotAlias = @strLotAlias
		,intItemId = @intItemId
		,intItemLocationId = @intItemLocationId
		,intSubLocationId = @intSubLocationId
		,intStorageLocationId = @intStorageLocationId
		,dblQty = @dblQty
		,intItemUOMId = @intItemUOMId
		,dblWeight = @dblWeight
		,intWeightUOMId = @intWeightUOMId
		,dtmExpiryDate = @dtmExpiryDate
		,dtmManufacturedDate = @dtmPlannedDate
		,intOriginId = NULL
		,intGradeId = NULL 
		,strBOLNo = NULL
		,strVessel = NULL
		,strReceiptNumber = NULL
		,strMarkings = NULL
		,strNotes = NULL
		,intEntityVendorId = NULL
		,strVendorLotNo = @strVendorLotNo
		,strGarden = NULL
		,intDetailId = @intWorkOrderId
		,ysnProduced = 1

	EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
		,@intUserId

	SELECT TOP 1 @intLotId = intLotId
	FROM #GeneratedLotItems
	WHERE intDetailId = @intWorkOrderId

	SELECT @dtmDate=GETDATE()

	EXEC dbo.uspMFCreateUpdateParentLotNumber @strParentLotNumber=@strParentLotNumber,
											@strParentLotAlias='',
											@intItemId=@intItemId,
											@dtmExpiryDate=@dtmExpiryDate,
											@intLotStatusId=1,
											@intEntityUserSecurityId =@intUserId,
											@intLotId=@intLotId

	DELETE
	FROM @ItemsForPost

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
	SELECT intItemId = @intItemId
		,intItemLocationId = @intItemLocationId
		,intItemUOMId = (CASE WHEN @intItemStockUOMId=@intItemUOMId THEN @intItemUOMId ELSE @intWeightUOMId END)
		,dtmDate = @dtmPlannedDate
		,dblQty = (CASE WHEN @intItemStockUOMId=@intItemUOMId THEN @dblQty ELSE @dblWeight END) 
		,dblUOMQty = 1
		,dblCost = @dblCostPerStockUOM
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intBatchId
		,strTransactionId = (Case When @strLotNumber is null or @strLotNumber='' Then @strWorkOrderNo else @strLotNumber End)
		,intTransactionTypeId = @INVENTORY_PRODUCE
		,intLotId = @intLotId
		,intSubLocationId = @intSubLocationId
		,intStorageLocationId = @intStorageLocationId

	EXEC dbo.uspICPostCosting @ItemsForPost
		,@strBatchId
		,NULL
		,@intUserId

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
	EXEC dbo.uspICCreateGLEntries @strBatchId
		,NULL
		,@intUserId

	Update @GLEntries Set dblDebit=(Select sum(dblCredit) from @GLEntries where strTransactionType='Consume') where strTransactionType='Produce'

	EXEC dbo.uspGLBookEntries @GLEntries
		,1
END
