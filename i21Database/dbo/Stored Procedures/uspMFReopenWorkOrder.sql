CREATE PROCEDURE uspMFReopenWorkOrder (
	@intWorkOrderId INT
	,@intUserId INT
	)
AS
BEGIN TRY
	DECLARE @strCostAdjustmentBatchId NVARCHAR(50)
		,@intLocationId INT
		,@intTransactionId INT
		,@strTransactionId NVARCHAR(50)
		,@GLEntries AS RecapTableType
		,@intManufacturingProcessId INT
		,@strCostDistribution NVARCHAR(50)
		,@ErrMsg NVARCHAR(MAX)
		,@intTransactionCount INT

	SELECT @intManufacturingProcessId = intManufacturingProcessId
		,@strCostAdjustmentBatchId = strCostAdjustmentBatchId
		,@intLocationId = intLocationId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strCostDistribution = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 107 --Cost Distribution during close work order

	IF @strCostDistribution IS NULL
		OR @strCostDistribution = ''
	BEGIN
		SELECT @strCostDistribution = 'False'
	END

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	UPDATE tblMFWorkOrder
	SET intStatusId = 10
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GETDATE()
	WHERE intWorkOrderId = @intWorkOrderId

	IF @strCostAdjustmentBatchId IS NOT NULL
		AND @strCostDistribution = 'True'
	BEGIN
		SELECT @intTransactionId = intTransactionId
			,@strTransactionId = strTransactionId
		FROM tblICInventoryTransaction
		WHERE strBatchId = @strCostAdjustmentBatchId

		INSERT INTO @GLEntries (
			dtmDate
			,strBatchId
			,intAccountId
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strDescription
			,strCode
			,strReference
			,intCurrencyId
			,dblExchangeRate
			,dtmDateEntered
			,dtmTransactionDate
			,strJournalLineDescription
			,intJournalLineNo
			,ysnIsUnposted
			,intUserId
			,intEntityId
			,strTransactionId
			,intTransactionId
			,strTransactionType
			,strTransactionForm
			,strModuleName
			,intConcurrencyId
			,dblDebitForeign
			,dblDebitReport
			,dblCreditForeign
			,dblCreditReport
			,dblReportingRate
			,dblForeignRate
			)
		EXEC dbo.uspICCreateGLEntriesOnCostAdjustment @strBatchId = @strCostAdjustmentBatchId
			,@intEntityUserSecurityId = @intUserId
			,@strGLDescription = ''
			,@ysnPost = 0
			,@AccountCategory_Cost_Adjustment = 'Work In Progress'

		IF EXISTS (
				SELECT *
				FROM @GLEntries
				)
		BEGIN
			EXEC dbo.uspGLBookEntries @GLEntries
				,0
		END
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH

