CREATE PROCEDURE [dbo].[uspMFPostConsumption] @ysnPost BIT = 0
	,@ysnRecap BIT = 0
	,@intWorkOrderId INT
	,@intUserId INT = NULL
	,@intEntityId INT = NULL
	,@strRetBatchId NVARCHAR(40) = NULL OUT
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
DECLARE @INVENTORY_CONSUME AS INT = 8
-- Get the Inventory Receipt batch number
DECLARE @strBatchId AS NVARCHAR(40)
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
	DECLARE @intItemId INT
	DECLARE @strLotTracking NVARCHAR(50)
	DECLARE @intLocationId INT

	SELECT TOP 1 @intTransactionId = intWorkOrderId
		,@strTransactionId = strWorkOrderNo
		,@ysnTransactionPostedFlag = 0
		,@dtmDate = GetDate()
		,@intCreatedEntityId = @intUserId
		,@intItemId = intItemId
		,@intLocationId = intLocationId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId
END

SELECT @dtmDate = dbo.fnGetBusinessDate(@dtmDate, @intLocationId)

IF @dtmDate IS NULL
BEGIN
	SELECT @dtmDate = GetDate()
END

-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
	,@strBatchId OUTPUT

SELECT @strRetBatchId = @strBatchId

SELECT @strLotTracking = strLotTracking
FROM tblICItem
WHERE intItemId = @intItemId

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1
BEGIN
	-- Get the items to post  
	DECLARE @ItemsForPost AS ItemCostingTableType

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
	FROM tblMFWorkOrderConsumedLot cl
	INNER JOIN tblICItem i ON cl.intItemId = i.intItemId
	INNER JOIN dbo.tblICItemUOM ItemUOM ON cl.intItemIssuedUOMId = ItemUOM.intItemUOMId
	INNER JOIN tblICItemLocation il ON i.intItemId = il.intItemId
		AND il.intLocationId = @intLocationId
	WHERE cl.intWorkOrderId = @intTransactionId
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
	FROM tblMFWorkOrderConsumedLot cl
	INNER JOIN tblICLot l ON cl.intLotId = l.intLotId
	INNER JOIN dbo.tblICItemUOM ItemUOM ON l.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN dbo.tblICItemUOM WeightUOM ON l.intWeightUOMId = WeightUOM.intItemUOMId
	WHERE cl.intWorkOrderId = @intTransactionId

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

		EXEC dbo.uspGLBookEntries @GLEntries
			,@ysnPost
	END

	UPDATE tblMFWorkOrder
	SET strBatchId = @strBatchId
	WHERE intWorkOrderId = @intWorkOrderId

	DECLARE @intRecordId INT
		,@intLotId INT
	DECLARE @tblMFLot TABLE (
		intRecordId INT Identity(1, 1)
		,intLotId INT
		)

	INSERT INTO @tblMFLot (intLotId)
	SELECT intLotId
	FROM dbo.tblMFWorkOrderConsumedLot
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecordId = Min(intRecordId)
	FROM @tblMFLot

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intLotId = NULL

		SELECT @intLotId = intLotId
		FROM @tblMFLot
		WHERE intRecordId = @intRecordId

		IF (
				(
					SELECT dblWeight
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId
					) < 0.01
				)
			AND (
				(
					SELECT dblQty
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId
					) < 0.01
				)
		BEGIN
			--EXEC dbo.uspMFLotAdjustQty
			-- @intLotId =@intLotId,       
			-- @dblNewLotQty =0,
			-- @intUserId=@intUserId ,
			-- @strReasonCode ='Residue qty clean up',
			-- @strNotes ='Residue qty clean up'
			UPDATE tblICLot
			SET dblWeight = 0
				,dblQty = 0
			WHERE intLotId = @intLotId
		END

		UPDATE tblICLot
		SET dblWeight = dblQty
		WHERE dblQty <> dblWeight
			AND intItemUOMId = intWeightUOMId
			AND intLotId = @intLotId

		SELECT @intRecordId = Min(intRecordId)
		FROM @tblMFLot
		WHERE intRecordId > @intRecordId
	END
END
