CREATE PROCEDURE uspAPIGetCompletedWorkOrder @guiApiUniqueId UNIQUEIDENTIFIER, @strStatus NVARCHAR(50) = ''
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	IF ISNULL(@strStatus, '') = ''
	BEGIN
		SELECT intBatchId
			,intItemId
			,strWorkOrderNo
			,strMessage
		FROM tblAPIWODetail
		WHERE intTransactionTypeId = 9
			AND ysnProcessed = 1
			AND ysnCompleted = 0
			AND guiApiUniqueId = @guiApiUniqueId

		UPDATE tblAPIWODetail
		SET ysnCompleted = 1
		WHERE intTransactionTypeId = 9
			AND ysnProcessed = 1
			AND ysnCompleted = 0
			AND guiApiUniqueId = @guiApiUniqueId
	END
	ELSE
	BEGIN
		SELECT intBatchId
			,intItemId
			,strWorkOrderNo
			,strMessage
		FROM tblAPIWODetail
		WHERE intTransactionTypeId = 9
			AND ysnProcessed = 1
			AND ysnCompleted = 0
			AND strFeedStatus = @strStatus
			AND guiApiUniqueId = @guiApiUniqueId

		UPDATE tblAPIWODetail
		SET ysnCompleted = 1
		WHERE intTransactionTypeId = 9
			AND ysnProcessed = 1
			AND ysnCompleted = 0
			AND strFeedStatus = @strStatus
			AND guiApiUniqueId = @guiApiUniqueId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
