CREATE PROCEDURE [dbo].[uspMFPostConsumption] @ysnPost BIT = 0
	,@ysnRecap BIT = 0
	,@intWorkOrderId INT
	,@intUserId INT = NULL
	,@intEntityId INT = NULL
	,@strRetBatchId NVARCHAR(40) = NULL OUT
	,@intBatchId INT = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @STARTING_NUMBER_BATCH AS INT = 3
	,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Work In Progress'
	,@INVENTORY_CONSUME AS INT = 8
	,@strBatchId AS NVARCHAR(40)
	,@GLEntries AS RecapTableType
	,@dtmDate AS DATETIME
	,@intTransactionId AS INT
	,@intCreatedEntityId AS INT
	,@strTransactionId NVARCHAR(50)
	,@intLocationId INT
	,@ItemsForPost AS ItemCostingTableType
	,@intRecordId INT
	,@intLotId INT
	,@intItemUOMId INT
	,@dblDefaultResidueQty NUMERIC(18, 6)
	,@intItemId INT
	,@intCategoryId INT
	,@intManufacturingCellId INT
	,@intSubLocationId INT
	
DECLARE @tblMFLot TABLE (
	intRecordId INT Identity(1, 1)
	,intLotId INT
	,intItemUOMId INT
	)

SET @ysnPost = ISNULL(@ysnPost, 0)

SELECT TOP 1 @strTransactionId = strWorkOrderNo
	,@dtmDate = GetDate()
	,@intCreatedEntityId = @intUserId
	,@intLocationId = intLocationId
	,@intItemId = intItemId
	,@intManufacturingCellId = intManufacturingCellId
	,@intSubLocationId = intSubLocationId
FROM dbo.tblMFWorkOrder
WHERE intWorkOrderId = @intWorkOrderId

SELECT @intCategoryId = intCategoryId
FROM dbo.tblICItem
WHERE intItemId = @intItemId

IF @intBatchId IS NULL
	OR @intBatchId = 0
BEGIN
	EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
		,@intItemId = @intItemId
		,@intManufacturingId = @intManufacturingCellId
		,@intSubLocationId = @intSubLocationId
		,@intLocationId = @intLocationId
		,@intOrderTypeId = NULL
		,@intBlendRequirementId = NULL
		,@intPatternCode = 33
		,@ysnProposed = 0
		,@strPatternString = @intBatchId OUTPUT
END

SELECT @intTransactionId = @intBatchId

SELECT @dtmDate = dbo.fnGetBusinessDate(@dtmDate, @intLocationId)

IF @dtmDate IS NULL
BEGIN
	SELECT @dtmDate = GetDate()
END

-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
	,@strBatchId OUTPUT

SELECT @strRetBatchId = @strBatchId

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1
BEGIN
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
		,dtmDate = @dtmDate
		,dblQty = (- cl.dblIssuedQuantity)
		,dblUOMQty = ItemUOM.dblUnitQty
		,dblCost = 0 --l.dblLastCost
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intTransactionId
		,intTransactionDetailId = cl.intWorkOrderConsumedLotId
		,strTransactionId = @strTransactionId
		,intTransactionTypeId = @INVENTORY_CONSUME
		,intLotId = NULL
		,intSubLocationId = cl.intSubLocationId
		,intStorageLocationId = cl.intStorageLocationId
		,intSourceTransactionId = @INVENTORY_CONSUME
		,strSourceTransactionId = @strTransactionId
	FROM dbo.tblMFWorkOrderConsumedLot cl
	JOIN dbo.tblICItem i ON cl.intItemId = i.intItemId
	JOIN dbo.tblICItemUOM ItemUOM ON cl.intItemIssuedUOMId = ItemUOM.intItemUOMId
	JOIN dbo.tblICItemLocation il ON i.intItemId = il.intItemId
		AND il.intLocationId = @intLocationId
	WHERE cl.intWorkOrderId = @intWorkOrderId
		AND ISNULL(cl.intLotId, 0) = 0

	--Lot Tracking
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
		,dtmDate = @dtmDate
		,dblQty = (- cl.dblQuantity)
		,dblUOMQty = ISNULL(WeightUOM.dblUnitQty, ItemUOM.dblUnitQty)
		,dblCost = l.dblLastCost
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intTransactionId
		,intTransactionDetailId = cl.intWorkOrderConsumedLotId
		,strTransactionId = @strTransactionId
		,intTransactionTypeId = @INVENTORY_CONSUME
		,intLotId = l.intLotId
		,intSubLocationId = l.intSubLocationId
		,intStorageLocationId = l.intStorageLocationId
		,intSourceTransactionId = @INVENTORY_CONSUME
		,strSourceTransactionId = @strTransactionId
	FROM dbo.tblMFWorkOrderConsumedLot cl
	JOIN dbo.tblICLot l ON cl.intLotId = l.intLotId
	JOIN dbo.tblICItemUOM ItemUOM ON l.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN dbo.tblICItemUOM WeightUOM ON l.intWeightUOMId = WeightUOM.intItemUOMId
	WHERE cl.intWorkOrderId = @intWorkOrderId

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

	EXEC dbo.uspGLBookEntries @GLEntries
		,@ysnPost

	UPDATE dbo.tblMFWorkOrder
	SET strBatchId = @strBatchId
		,intBatchID = @intBatchId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFWorkOrderConsumedLot
	SET strBatchId = @strBatchId
		,intBatchId = @intBatchId
	WHERE intWorkOrderId = @intWorkOrderId

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
		SELECT @intLotId = NULL

		SELECT @intLotId = intLotId
			,@intItemUOMId = intItemUOMId
		FROM @tblMFLot
		WHERE intRecordId = @intRecordId

		IF (
		(
			SELECT dblWeight
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
			) < 0.00001
		AND (
			SELECT dblWeight
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
			) > 0
		)
	OR (
		(
			SELECT dblQty
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
			) < 0.00001
		AND (
			SELECT dblQty
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
			) > 0
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
