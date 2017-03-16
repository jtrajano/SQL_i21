CREATE PROCEDURE uspMFWastage_LotUpdate
	@strXml NVARCHAR(Max)
	,@intWastageId INT
	,@strLotNumber NVARCHAR(50) OUTPUT
	,@intLotId INT OUTPUT
	,@intBatchId INT OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(Max)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @intItemId INT
		,@intWorkOrderId INT
		,@intStorageLocationId INT
		,@dblWeight NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@intUserId INT
		,@strShiftActivityNo NVARCHAR(50)
		,@intLocationId INT
		,@intItemLocationId INT
		,@dblStandardCost NUMERIC(38, 20)

	-- New Data
	SELECT @strLotNumber = strLotNumber
		,@intLotId = ISNULL(intLotId, '')
		,@intItemId = intItemId
		,@intWorkOrderId = ISNULL(intWorkOrderId, '')
		,@intStorageLocationId = intStorageLocationId
		,@dblWeight = dblWeight
		,@intWeightUOMId = intWeightUOMId
		,@intUserId = intUserId
		,@strShiftActivityNo = strShiftActivityNo
		,@intBatchId = intBatchId
		,@intLocationId = intLocationId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			strLotNumber NVARCHAR(50)
			,intLotId INT
			,intItemId INT
			,intWorkOrderId INT
			,intStorageLocationId INT
			,dblWeight NUMERIC(38, 20)
			,intWeightUOMId INT
			,intUserId INT
			,strShiftActivityNo NVARCHAR(50)
			,intBatchId INT
			,intLocationId INT
			)

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intItemId = @intItemId
		AND intLocationId = @intLocationId

	SELECT @dblStandardCost = ISNULL(dblStandardCost, 0)
	FROM tblICItemPricing
	WHERE intItemId = @intItemId
		AND intItemLocationId = @intItemLocationId

	DECLARE @GLEntries AS RecapTableType
		,@strBatchId NVARCHAR(50)

	SELECT @strBatchId = strBatchId
	FROM tblICInventoryTransaction
	WHERE intTransactionId = @intBatchId
		AND strTransactionId = @strShiftActivityNo

	BEGIN TRAN

	-- Old Lot UnPosting
	IF (ISNULL(@strBatchId, '') <> '')
	BEGIN
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
		EXEC uspICUnpostCosting @intBatchId
			,@strShiftActivityNo
			,@strBatchId
			,@intUserId
			,0

		EXEC uspGLBookEntries @GLEntries
			,0
	END

	-- Posting
	IF (@dblStandardCost > 0)
	BEGIN
		EXEC uspMFWastage_LotCreate @strXml
			,@strLotNumber OUTPUT
			,@intLotId OUTPUT
			,@intBatchId OUTPUT
	END
	ELSE
	BEGIN
		SELECT @intBatchId = NULL
			,@intLotId = NULL
			,@strLotNumber = ''
	END

	EXEC sp_xml_removedocument @idoc

	COMMIT TRAN
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
