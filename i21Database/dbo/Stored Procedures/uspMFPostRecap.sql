CREATE PROCEDURE [dbo].[uspMFPostRecap] @strXml NVARCHAR(MAX)
	,@strBatchId NVARCHAR(50) = '' OUT
AS
DECLARE @strErrMsg NVARCHAR(MAX)
	,@GLEntries RecapTableType
	,@intUserId INT
	,@strType NVARCHAR(50)
	,@idoc INT
	,@intWorkOrderId INT
	,@intStatusId INT
	,@intTransactionFrom INT

BEGIN TRY
	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT @intWorkOrderId = intWorkOrderId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intUserId INT
			)

	SELECT @intStatusId = intStatusId
		,@intTransactionFrom = intTransactionFrom
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF (
			ISNULL(@intWorkOrderId, 0) = 0
			OR @intTransactionFrom = 4
			)
	BEGIN
		SET @strType = 'Post Simple Blend Production'
	END
	ELSE
	BEGIN
		IF @intStatusId = 10
			SET @strType = 'Post Consume Blend'

		IF @intStatusId = 12
			SET @strType = 'Post Produce Blend'

		IF @intStatusId = 13
		BEGIN
			SET @strType = 'Unpost Produce Blend'
		END
	END

	BEGIN TRAN

	IF OBJECT_ID('tempdb..#tblRecap') IS NOT NULL
		DROP TABLE #tblRecap

	--Create Temp table to hold Recap Data
	SELECT *
	INTO #tblRecap
	FROM @GLEntries

	IF @strType = 'Post Consume Blend'
	BEGIN
		EXEC uspMFEndBlendSheet @strXml
			,1
			,@strBatchId OUT
	END

	IF @strType = 'Post Produce Blend'
	BEGIN
		EXEC uspMFCompleteBlendSheet @strXml = @strXml
			,@ysnRecap = 1
			,@strBatchId = @strBatchId OUT
	END

	IF @strType = 'Post Simple Blend Production'
	BEGIN
		EXEC uspMFCompleteBlendSheet @strXml = @strXml
			,@ysnRecap = 1
			,@strBatchId = @strBatchId OUT
	END

	IF @strType = 'Unpost Produce Blend'
	BEGIN
		EXEC uspMFUnpostProducedLot @strXML = @strXml
			,@ysnRecap = 1
			,@strBatchId = @strBatchId OUT
	END

	INSERT INTO @GLEntries
	SELECT *
	FROM #tblRecap

	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	IF @strType = 'Post Consume Blend'
	BEGIN
		-- Get the next batch number
		EXEC dbo.uspSMGetStartingNumber 3
			,@strBatchId OUTPUT

		UPDATE @GLEntries
		SET strBatchId = @strBatchId
	END

	--Post Recap
	EXEC dbo.uspGLPostRecap @GLEntries
		,@intUserId
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
