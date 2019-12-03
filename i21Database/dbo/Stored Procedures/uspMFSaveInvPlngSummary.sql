CREATE PROCEDURE uspMFSaveInvPlngSummary (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @strErrMsg NVARCHAR(MAX)
		,@intInvPlngSummaryId INT
		,@idoc INT
		,@intTransactionCount INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intInvPlngSummaryId = intInvPlngSummaryId
	FROM OPENXML(@idoc, 'InvPlngSummarys/InvPlngSummary', 2) WITH (intInvPlngSummaryId INT)

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF @intInvPlngSummaryId IS NULL
	BEGIN
		INSERT INTO tblMFInvPlngSummary (
			strPlanName
			,intUnitMeasureId
			,intBookId
			,intSubBookId
			,intCreatedUserId
			,intLastModifiedUserId
			,intConcurrencyId
			)
		SELECT strPlanName
			,intUnitMeasureId
			,intBookId
			,intSubBookId
			,intCreatedUserId
			,intLastModifiedUserId
			,1
		FROM OPENXML(@idoc, 'InvPlngSummarys/InvPlngSummary', 2) WITH (
				strPlanName NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intUnitMeasureId INT
				,intBookId INT
				,intSubBookId INT
				,intCreatedUserId INT
				,intLastModifiedUserId INT
				)

		SELECT @intInvPlngSummaryId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		UPDATE InvPlngSummary
		SET strPlanName = x.strPlanName
			,intUnitMeasureId = x.intUnitMeasureId
			,intBookId = x.intBookId
			,intSubBookId = x.intSubBookId
			,intLastModifiedUserId = x.intLastModifiedUserId
			,intConcurrencyId=InvPlngSummary.intConcurrencyId+1
		FROM OPENXML(@idoc, 'InvPlngSummarys/InvPlngSummary', 2) WITH (
				intInvPlngSummaryId INT
				,strPlanName NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intUnitMeasureId INT
				,intBookId INT
				,intSubBookId INT
				,intLastModifiedUserId INT
				) x
		JOIN tblMFInvPlngSummary InvPlngSummary ON x.intInvPlngSummaryId = InvPlngSummary.intInvPlngSummaryId
		WHERE InvPlngSummary.intInvPlngSummaryId = @intInvPlngSummaryId
	END

	DELETE
	FROM tblMFInvPlngSummaryBatch
	WHERE NOT EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'InvPlngSummaryBatchs/InvPlngSummaryBatch', 2) WITH (intInvPlngSummaryBatchId INT) x
			WHERE x.intInvPlngSummaryBatchId = tblMFInvPlngSummaryBatch.intInvPlngSummaryBatchId
			)
		AND intInvPlngSummaryId = @intInvPlngSummaryId

	UPDATE SummaryBatch
	SET strBatch = x.strBatch
	FROM OPENXML(@idoc, 'InvPlngSummaryBatchs/InvPlngSummaryBatch', 2) WITH (
			strBatch NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,intInvPlngSummaryBatchId INT
			) x
	JOIN tblMFInvPlngSummaryBatch SummaryBatch ON SummaryBatch.intInvPlngSummaryBatchId = x.intInvPlngSummaryBatchId
	WHERE SummaryBatch.intInvPlngSummaryId = @intInvPlngSummaryId

	INSERT INTO tblMFInvPlngSummaryBatch (
		strBatch
		,intInvPlngSummaryId
		)
	SELECT strBatch
		,@intInvPlngSummaryId
	FROM OPENXML(@idoc, 'InvPlngSummaryBatchs/InvPlngSummaryBatch', 2) WITH (
			strBatch NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,intInvPlngSummaryBatchId INT
			)
	WHERE intInvPlngSummaryBatchId IS NULL

	DELETE
	FROM tblMFInvPlngSummaryDetail
	WHERE NOT EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'InvPlngSummaryDetails/InvPlngSummaryDetail', 2) WITH (intInvPlngSummaryDetailId INT) x
			WHERE x.intInvPlngSummaryDetailId = tblMFInvPlngSummaryDetail.intInvPlngSummaryDetailId
			)
		AND intInvPlngSummaryId = @intInvPlngSummaryId

	UPDATE SummaryDetail
	SET intAttributeId = x.intAttributeId
		,intItemId = x.intItemId
		,strFieldName = x.strFieldName
		,strValue = x.strValue
		,intMainItemId = x.intMainItemId
	FROM OPENXML(@idoc, 'InvPlngSummaryDetails/InvPlngSummaryDetail', 2) WITH (
			intAttributeId INT
			,intItemId INT
			,strFieldName NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,strValue NVARCHAR(100) COLLATE Latin1_General_CI_AS
			,intMainItemId INT
			,intInvPlngSummaryDetailId INT
			) x
	JOIN tblMFInvPlngSummaryDetail SummaryDetail ON SummaryDetail.intInvPlngSummaryDetailId = x.intInvPlngSummaryDetailId
		AND SummaryDetail.intInvPlngSummaryId = @intInvPlngSummaryId

	INSERT INTO tblMFInvPlngSummaryDetail (
		intAttributeId
		,intItemId
		,strFieldName
		,strValue
		,intMainItemId
		)
	SELECT intAttributeId
		,intItemId
		,strFieldName
		,strValue
		,intMainItemId
	FROM OPENXML(@idoc, 'InvPlngSummaryDetails/InvPlngSummaryDetail', 2) WITH (
			intAttributeId INT
			,intItemId INT
			,strFieldName NVARCHAR(50) COLLATE Latin1_General_CI_AS
			,strValue NVARCHAR(100) COLLATE Latin1_General_CI_AS
			,intMainItemId INT
			,intInvPlngSummaryId INT
			)
	WHERE intInvPlngSummaryId IS NULL

	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	RAISERROR (
			@strErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
