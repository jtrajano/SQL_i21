CREATE PROCEDURE uspIPInterCompanyPreStageDailyAveragePrice @intDailyAveragePriceId INT
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
	,@intBookId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblRKDailyAveragePricePreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intDailyAveragePriceId = @intDailyAveragePriceId

	INSERT INTO tblRKDailyAveragePricePreStage (
		intDailyAveragePriceId
		,intBookId
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intDailyAveragePriceId
		,@intBookId
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
