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

	SELECT TOP 1 @intLocationId = intLocationId
		,@intSubLocationId = intSubLocationId
		,@intStorageLocationId = intStorageLocationId
		,@dtmPlannedDate=dtmPlannedDate
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
		,@strBatchId OUTPUT

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intLocationId = @intLocationId
		AND intItemId = @intItemId

	SELECT @dblNewCost = [dbo].[fnGetTotalStockValueFromTransactionBatch](@intWorkOrderId, @strBatchId)

	SET @dblNewCost = ABS(@dblNewCost)
	SET @dblNewUnitCost = ABS(@dblNewCost) / @dblQty

	CREATE TABLE #GeneratedLotItems (
		intLotId INT
		,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,intDetailId INT
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
		,intVendorLocationId
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
		,strVendorLotNo = NULL
		,intVendorLocationId = NULL
		,intDetailId = @intWorkOrderId
		,ysnProduced = 1

	EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
		,@intUserId

	SELECT TOP 1 @intLotId = intLotId
	FROM #GeneratedLotItems
	WHERE intDetailId = @intWorkOrderId

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
		,dblUOMQty = (Case When l.intWeightUOMId is null then 0 else ItemUOM.dblUnitQty End)
		,dblCost = l.dblLastCost
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intBatchId
		,intTransactionDetailId = cl.intWorkOrderConsumedLotId
		,strTransactionId = @strLotNumber
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
		,intItemUOMId = @intItemUOMId
		,dtmDate = @dtmPlannedDate
		,dblQty = @dblQty
		,dblUOMQty = CASE 
			WHEN (@intWeightUOMId = @intItemUOMId)
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
								WHERE intItemUOMId = @intItemUOMId
								)
						END
					)
			END
		,dblCost = @dblNewUnitCost
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intBatchId
		,strTransactionId = @strLotNumber
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
		)
	EXEC dbo.uspICCreateGLEntries @strBatchId
		,NULL
		,@intUserId

	Update @GLEntries Set dblDebit=(Select sum(dblCredit) from @GLEntries where strTransactionType='Consume') where strTransactionType='Produce'

	EXEC dbo.uspGLBookEntries @GLEntries
		,1
END
