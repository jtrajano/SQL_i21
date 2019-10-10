CREATE PROCEDURE uspIPInterCompanyPreStageFutOptTransaction @intFutOptTransactionHeaderId INT
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblRKFutOptTransactionHeaderPreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intFutOptTransactionHeaderId = @intFutOptTransactionHeaderId

	INSERT INTO tblRKFutOptTransactionHeaderPreStage (
		intFutOptTransactionHeaderId
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intFutOptTransactionHeaderId
		,@strRowState
		,@intUserId
		,''
		,''
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
