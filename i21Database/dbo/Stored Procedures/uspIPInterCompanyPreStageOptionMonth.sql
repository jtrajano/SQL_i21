CREATE PROCEDURE uspIPInterCompanyPreStageOptionMonth @intOptionMonthId INT
	,@strRowState NVARCHAR(50) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblRKOptionsMonthPreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intOptionMonthId = @intOptionMonthId

	INSERT INTO tblRKOptionsMonthPreStage (
		intOptionMonthId
		,strRowState
		,strFeedStatus
		,strMessage
		)
	SELECT @intOptionMonthId
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
