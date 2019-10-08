CREATE PROCEDURE uspIPInterCompanyPreStageFutureMonth @intFutureMonthId INT
	,@strRowState NVARCHAR(50) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblRKFuturesMonthPreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intFutureMonthId = @intFutureMonthId

	INSERT INTO tblRKFuturesMonthPreStage (
		intFutureMonthId
		,strRowState
		,strFeedStatus
		,strMessage
		)
	SELECT @intFutureMonthId
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
