CREATE PROCEDURE uspMFSaveInvPlngSummary (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @strErrMsg NVARCHAR(MAX)
		,@idoc INT
		,@intTransactionCount INT
		,@strInvPlngReportMasterID NVARCHAR(MAX)
		,@intTableConcurrencyId INT
		,@intConcurrencyId INT
		,@intInvPlngSummaryId INT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intInvPlngSummaryId = intInvPlngSummaryId
		,@strInvPlngReportMasterID = strInvPlngReportMasterID
		,@intConcurrencyId = intConcurrencyId
	FROM OPENXML(@idoc, 'root/InvPlngSummary', 2) WITH (
			intInvPlngSummaryId INT
			,strInvPlngReportMasterID NVARCHAR(MAX)
			,intConcurrencyId INT
			)

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF @intInvPlngSummaryId IS NULL
	BEGIN
		INSERT INTO tblMFInvPlngSummary (
			strPlanName
			,dtmDate
			,intUnitMeasureId
			,intBookId
			,intSubBookId
			,strComment
			,intCreatedUserId
			,intLastModifiedUserId
			,intConcurrencyId
			)
		SELECT strPlanName
			,GETDATE()
			,intUnitMeasureId
			,intBookId
			,intSubBookId
			,strComment
			,intCreatedUserId
			,intLastModifiedUserId
			,1
		FROM OPENXML(@idoc, 'root/InvPlngSummary', 2) WITH (
				strPlanName NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intUnitMeasureId INT
				,intBookId INT
				,intSubBookId INT
				,strComment NVARCHAR(MAX)
				,intCreatedUserId INT
				,intLastModifiedUserId INT
				)

		SELECT @intInvPlngSummaryId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		SELECT @intTableConcurrencyId = intConcurrencyId
		FROM tblMFInvPlngSummary
		WHERE intInvPlngSummaryId = @intInvPlngSummaryId

		IF @intTableConcurrencyId <> @intConcurrencyId
		BEGIN
			RAISERROR (
					'Demand summary data is already modified by other user. Please refresh.'
					,16
					,1
					,'WITH NOWAIT'
					)
		END

		UPDATE InvPlngSummary
		SET strPlanName = x.strPlanName
			,intUnitMeasureId = x.intUnitMeasureId
			,intBookId = x.intBookId
			,intSubBookId = x.intSubBookId
			,strComment = x.strComment
			,intLastModifiedUserId = x.intLastModifiedUserId
			,intConcurrencyId = (InvPlngSummary.intConcurrencyId + 1)
		FROM OPENXML(@idoc, 'root/InvPlngSummary', 2) WITH (
				intInvPlngSummaryId INT
				,strPlanName NVARCHAR(50) COLLATE Latin1_General_CI_AS
				,intUnitMeasureId INT
				,intBookId INT
				,intSubBookId INT
				,strComment NVARCHAR(MAX)
				,intLastModifiedUserId INT
				) x
		JOIN tblMFInvPlngSummary InvPlngSummary ON x.intInvPlngSummaryId = InvPlngSummary.intInvPlngSummaryId
		WHERE InvPlngSummary.intInvPlngSummaryId = @intInvPlngSummaryId
	END

	DELETE
	FROM tblMFInvPlngSummaryBatch
	WHERE intInvPlngSummaryId = @intInvPlngSummaryId

	INSERT INTO tblMFInvPlngSummaryBatch (
		intInvPlngSummaryId
		,intInvPlngReportMasterID
		)
	SELECT @intInvPlngSummaryId
		,Item Collate Latin1_General_CI_AS
	FROM [dbo].[fnSplitString](@strInvPlngReportMasterID, ',')

	DELETE
	FROM tblMFInvPlngSummaryDetail
	WHERE NOT EXISTS (
			SELECT *
			FROM OPENXML(@idoc, 'root/InvPlngSummaryDetails/InvPlngSummaryDetail', 2) WITH (intInvPlngSummaryDetailId INT) x
			WHERE x.intInvPlngSummaryDetailId = tblMFInvPlngSummaryDetail.intInvPlngSummaryDetailId
			)
		AND intInvPlngSummaryId = @intInvPlngSummaryId

	UPDATE SummaryDetail
	SET intAttributeId = x.intAttributeId
		,intItemId = x.intItemId
		,strFieldName = x.strFieldName
		,strValue = x.strValue
		,intMainItemId = x.intMainItemId
	FROM OPENXML(@idoc, 'root/InvPlngSummaryDetails/InvPlngSummaryDetail', 2) WITH (
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
	FROM OPENXML(@idoc, 'root/InvPlngSummaryDetails/InvPlngSummaryDetail', 2) WITH (
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

	SELECT @intInvPlngSummaryId AS intInvPlngSummaryId
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
