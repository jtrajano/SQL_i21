CREATE PROCEDURE uspMFWastage_LotDelete
     @intBatchId INT
	,@intUserId INT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(Max)
	DECLARE @strShiftActivityNo NVARCHAR(50)
		,@intShiftActivityId INT

	SELECT @intShiftActivityId = intShiftActivityId
	FROM tblMFWastage
	WHERE intBatchId = @intBatchId

	SELECT @strShiftActivityNo = strShiftActivityNumber
	FROM tblMFShiftActivity
	WHERE intShiftActivityId = @intShiftActivityId

	DECLARE @GLEntries AS RecapTableType
		,@strBatchId NVARCHAR(50)

	SELECT @strBatchId = strBatchId
	FROM tblICInventoryTransaction
	WHERE intTransactionId = @intBatchId
		AND strTransactionId = @strShiftActivityNo

	BEGIN TRAN

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

	COMMIT TRAN
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
