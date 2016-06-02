﻿CREATE PROCEDURE [dbo].[uspMFPostConsumptionProduction] @intWorkOrderId INT
	,@intItemId INT
	,@strLotNumber NVARCHAR(50)
	,@dblWeight NUMERIC(38, 20)
	,@intWeightUOMId INT
	,@dblUnitQty NUMERIC(38, 20) = NULL
	,@dblQty NUMERIC(38, 20)
	,@intItemUOMId INT
	,@intUserId INT = NULL
	,@intBatchId INT
	,@intLotId INT OUTPUT
	,@strLotAlias NVARCHAR(50)
	,@strVendorLotNo NVARCHAR(50) = NULL
	,@strParentLotNumber NVARCHAR(50)
	,@intStorageLocationId INT
	,@dtmProductionDate DATETIME = NULL
	,@intTransactionDetailId INT = NULL
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
		,@dblNewCost NUMERIC(38, 20)
		,@dblNewUnitCost NUMERIC(38, 20)
		,@strLifeTimeType NVARCHAR(50)
		,@intLifeTime INT
		,@dtmExpiryDate DATETIME
		,@intItemStockUOMId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@dtmDate DATETIME

	SELECT @dtmDate = GETDATE()

	SELECT TOP 1 @intLocationId = W.intLocationId
		,@strWorkOrderNo = strWorkOrderNo
	FROM dbo.tblMFWorkOrder W
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intSubLocationId = SL.intSubLocationId
	FROM dbo.tblICStorageLocation SL
	WHERE SL.intStorageLocationId = @intStorageLocationId

	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
		,@strBatchId OUTPUT

	--Non Lot Tracking
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
	SELECT intItemId = cl.intItemId
		,intItemLocationId = il.intItemLocationId
		,intItemUOMId = cl.intItemIssuedUOMId
		,dtmDate = GetDate()
		,dblQty = (- cl.dblIssuedQuantity)
		,dblUOMQty = ItemUOM.dblUnitQty
		,dblCost = 0 --l.dblLastCost
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intBatchId
		,intTransactionDetailId = cl.intWorkOrderConsumedLotId
		,strTransactionId = @strWorkOrderNo
		,intTransactionTypeId = @INVENTORY_CONSUME
		,intLotId = NULL
		,intSubLocationId = cl.intSubLocationId
		,intStorageLocationId = cl.intStorageLocationId
		,intSourceTransactionId = @INVENTORY_CONSUME
		,strSourceTransactionId = @strWorkOrderNo
	FROM tblMFWorkOrderConsumedLot cl
	INNER JOIN tblICItem i ON cl.intItemId = i.intItemId
	INNER JOIN dbo.tblICItemUOM ItemUOM ON cl.intItemIssuedUOMId = ItemUOM.intItemUOMId
	INNER JOIN tblICItemLocation il ON i.intItemId = il.intItemId
		AND il.intLocationId = @intLocationId
	WHERE cl.intWorkOrderId = @intWorkOrderId
		AND cl.intBatchId = @intBatchId
		AND ISNULL(cl.intLotId, 0) = 0

	IF @dtmProductionDate > @dtmDate
		OR @dtmProductionDate IS NULL
	BEGIN
		SELECT @dtmProductionDate = @dtmDate
	END

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
	SELECT intItemId = l.intItemId
		,intItemLocationId = l.intItemLocationId
		,intItemUOMId = ISNULL(l.intWeightUOMId, l.intItemUOMId)
		,dtmDate = @dtmProductionDate
		,dblQty = (- cl.dblQuantity)
		,dblUOMQty = ISNULL(WeightUOM.dblUnitQty, ItemUOM.dblUnitQty)
		,dblCost = l.dblLastCost
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intBatchId
		,intTransactionDetailId = cl.intWorkOrderConsumedLotId
		,strTransactionId = @strWorkOrderNo
		,intTransactionTypeId = @INVENTORY_CONSUME
		,intLotId = l.intLotId
		,intSubLocationId = l.intSubLocationId
		,intStorageLocationId = l.intStorageLocationId
		,intSourceTransactionId = @INVENTORY_CONSUME
		,strSourceTransactionId = @strWorkOrderNo
	FROM tblMFWorkOrderConsumedLot cl
	INNER JOIN tblICLot l ON cl.intLotId = l.intLotId
	INNER JOIN dbo.tblICItemUOM ItemUOM ON l.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN dbo.tblICItemUOM WeightUOM ON l.intWeightUOMId = WeightUOM.intItemUOMId
	WHERE cl.intWorkOrderId = @intWorkOrderId
		AND cl.intBatchId = @intBatchId

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
	WHERE intItemId = @intItemId
		AND ysnStockUnit = 1

	SELECT @dblNewCost = [dbo].[fnGetTotalStockValueFromTransactionBatch](@intBatchId, @strBatchId)

	SET @dblNewCost = ABS(@dblNewCost)
	SET @dblNewUnitCost = ABS(@dblNewCost) / @dblQty

	DECLARE @dblOtherCharges NUMERIC(18, 6)
		,@dblPercentage NUMERIC(18, 6)
		,@dblStandardCost NUMERIC(18, 6)

	SELECT @dblStandardCost = SUM(IP.dblStandardCost)
	FROM dbo.tblMFWorkOrderRecipeItem RI
	JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
		AND RI.ysnCostAppliedAtInvoice = 0
		AND I.strType = 'Other Charge'
	JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
		AND IL.intLocationId = @intLocationId
	JOIN dbo.tblICItemPricing IP ON IP.intItemId = I.intItemId
		AND IP.intItemLocationId = IL.intItemLocationId
	WHERE intWorkOrderId = @intWorkOrderId
		AND RI.intRecipeItemTypeId = 1

	SELECT @dblPercentage = dblPercentage
	FROM tblMFWorkOrderRecipeItem RI
	WHERE intWorkOrderId = @intWorkOrderId
		AND RI.intRecipeItemTypeId = 2
		AND RI.intItemId = @intItemId

	IF @dblPercentage IS NULL
	BEGIN
		SELECT @dblPercentage = 100
	END

	SELECT @dblOtherCharges = SUM((
				CASE 
					WHEN intMarginById = 2
						THEN P.dblStandardCost + RI.dblMargin
					ELSE P.dblStandardCost + (@dblStandardCost * RI.dblMargin / 100)
					END
				) * @dblQty / R.dblQuantity)
	FROM dbo.tblMFWorkOrderRecipeItem RI
	JOIN dbo.tblMFWorkOrderRecipe R ON R.intWorkOrderId = RI.intWorkOrderId
		AND R.intRecipeId = RI.intRecipeId
	JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
		AND RI.intRecipeItemTypeId = 1
		AND RI.ysnCostAppliedAtInvoice = 0
		AND I.strType = 'Other Charge'
	JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
		AND IL.intLocationId = @intLocationId
	JOIN dbo.tblICItemPricing P ON P.intItemId = I.intItemId
		AND P.intItemLocationId = IL.intItemLocationId
	WHERE RI.intWorkOrderId = @intWorkOrderId

	SELECT @dblOtherCharges = @dblOtherCharges * @dblPercentage / 100

	IF @dblOtherCharges IS NOT NULL
		AND @dblOtherCharges > 0
	BEGIN
		SELECT @dblNewUnitCost = @dblNewUnitCost + @dblOtherCharges
	END

	DECLARE @dblCostPerStockUOM NUMERIC(38, 20)

	IF @intItemStockUOMId = @intItemUOMId
	BEGIN
		SELECT @dblCostPerStockUOM = @dblNewUnitCost
	END
	ELSE
	BEGIN
		SELECT @dblCostPerStockUOM = dbo.fnCalculateUnitCost(@dblNewUnitCost, @dblUnitQty)
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
		,dblQty = @dblQty
		,intItemUOMId = @intItemUOMId
		,dblWeight = @dblWeight
		,intWeightUOMId = @intWeightUOMId
		,dtmExpiryDate = @dtmExpiryDate
		,dtmManufacturedDate = @dtmProductionDate
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
		,intDetailId = @intBatchId
		,ysnProduced = 1
		,strTransactionId = @strWorkOrderNo
		,strSourceTransactionId = @strWorkOrderNo
		,intSourceTransactionTypeId = @INVENTORY_PRODUCE

	EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
		,@intUserId

	SELECT TOP 1 @intLotId = intLotId
	FROM #GeneratedLotItems
	WHERE intDetailId = @intBatchId

	EXEC dbo.uspMFCreateUpdateParentLotNumber @strParentLotNumber = @strParentLotNumber
		,@strParentLotAlias = ''
		,@intItemId = @intItemId
		,@dtmExpiryDate = @dtmExpiryDate
		,@intLotStatusId = 1
		,@intEntityUserSecurityId = @intUserId
		,@intLotId = @intLotId
		,@intSubLocationId = @intSubLocationId
		,@intLocationId = @intLocationId

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
		,intSourceTransactionId
		,strSourceTransactionId
		,intTransactionDetailId
		)
	SELECT intItemId = @intItemId
		,intItemLocationId = @intItemLocationId
		,intItemUOMId = (
			CASE 
				WHEN @intItemStockUOMId = @intItemUOMId
					THEN @intItemUOMId
				ELSE @intWeightUOMId
				END
			)
		,dtmDate = @dtmProductionDate
		,dblQty = (
			CASE 
				WHEN @intItemStockUOMId = @intItemUOMId
					THEN @dblQty
				ELSE @dblWeight
				END
			)
		,dblUOMQty = 1
		,dblCost = @dblCostPerStockUOM
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intBatchId
		,strTransactionId = @strWorkOrderNo
		,intTransactionTypeId = @INVENTORY_PRODUCE
		,intLotId = @intLotId
		,intSubLocationId = @intSubLocationId
		,intStorageLocationId = @intStorageLocationId
		,intSourceTransactionId = @INVENTORY_PRODUCE
		,strSourceTransactionId = @strWorkOrderNo
		,intTransactionDetailId = @intTransactionDetailId

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

	UPDATE @GLEntries
	SET dblDebit = (
			SELECT sum(dblCredit)
			FROM @GLEntries
			WHERE strTransactionType = 'Consume'
			)
	WHERE strTransactionType = 'Produce'

	EXEC dbo.uspGLBookEntries @GLEntries
		,1

	UPDATE dbo.tblMFWorkOrderConsumedLot
	SET strBatchId = @strBatchId
	WHERE intWorkOrderId = @intWorkOrderId
		AND intBatchId = @intBatchId

	UPDATE dbo.tblMFWorkOrderProducedLot
	SET strBatchId = @strBatchId
	WHERE intWorkOrderId = @intWorkOrderId
		AND intBatchId = @intBatchId

	DECLARE @intRecordId INT
		,@intLotId1 INT
	DECLARE @tblMFLot TABLE (
		intRecordId INT Identity(1, 1)
		,intLotId INT
		,intItemUOMId INT
		)

	INSERT INTO @tblMFLot (
		intLotId
		,intItemUOMId
		)
	SELECT intLotId
		,intItemUOMId
	FROM dbo.tblMFWorkOrderConsumedLot
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecordId = Min(intRecordId)
	FROM @tblMFLot

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intLotId1 = NULL
			,@intItemUOMId = NULL

		SELECT @intLotId1 = intLotId
			,@intItemUOMId = intItemUOMId
		FROM @tblMFLot
		WHERE intRecordId = @intRecordId

		IF (
				(
					SELECT dblWeight
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId1
					) < 0.00001
				)
			AND (
				(
					SELECT dblQty
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId1
					) < 0.00001
				)
		BEGIN
			EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
				,@dblNewLotQty = 0
				,@intAdjustItemUOMId = @intItemUOMId
				,@intUserId = @intUserId
				,@strReasonCode = 'Residue qty clean up'
				,@strNotes = 'Residue qty clean up'
		END

		SELECT @intRecordId = Min(intRecordId)
		FROM @tblMFLot
		WHERE intRecordId > @intRecordId
	END
END
