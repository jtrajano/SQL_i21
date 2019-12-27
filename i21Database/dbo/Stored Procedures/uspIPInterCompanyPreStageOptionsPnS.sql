CREATE PROCEDURE uspIPInterCompanyPreStageOptionsPnS @intOptionsMatchPnSHeaderId INT
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblRKOptionsMatchPnSHeaderPreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intOptionsMatchPnSHeaderId = @intOptionsMatchPnSHeaderId

	INSERT INTO tblRKOptionsMatchPnSHeaderPreStage (
		intOptionsMatchPnSHeaderId
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intOptionsMatchPnSHeaderId
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
