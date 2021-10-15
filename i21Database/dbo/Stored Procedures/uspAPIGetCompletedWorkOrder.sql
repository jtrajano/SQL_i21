CREATE PROCEDURE uspAPIGetCompletedWorkOrder @strStatus NVARCHAR(50) = ''
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	IF ISNULL(@strStatus, '') = ''
	BEGIN
		SELECT intBatchId
			,strItemNo
			,strWorkOrderNo
			,strMessage
		FROM tblAPIWODetail
		WHERE intTransactionTypeId = 9
			AND ysnProcessed = 1
			AND ysnCompleted = 0

		UPDATE tblAPIWODetail
		SET ysnCompleted = 1
		WHERE intTransactionTypeId = 9
			AND ysnProcessed = 1
			AND ysnCompleted = 0
	END
	ELSE
	BEGIN
		SELECT intBatchId
			,strItemNo
			,strWorkOrderNo
			,strMessage
		FROM tblAPIWODetail
		WHERE intTransactionTypeId = 9
			AND ysnProcessed = 1
			AND ysnCompleted = 0
			AND strFeedStatus = @strStatus

		UPDATE tblAPIWODetail
		SET ysnCompleted = 1
		WHERE intTransactionTypeId = 9
			AND ysnProcessed = 1
			AND ysnCompleted = 0
			AND strFeedStatus = @strStatus
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
