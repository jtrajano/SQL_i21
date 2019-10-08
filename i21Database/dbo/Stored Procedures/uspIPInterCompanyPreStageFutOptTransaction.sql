CREATE PROCEDURE uspIPInterCompanyPreStageFutOptTransaction @intFutOptTransactionHeaderId INT
	,@strRowState NVARCHAR(50) = NULL
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
		,strFeedStatus
		,strMessage
		)
	SELECT @intFutOptTransactionHeaderId
		,@strRowState
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
