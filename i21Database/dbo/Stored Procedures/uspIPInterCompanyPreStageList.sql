CREATE PROCEDURE uspIPInterCompanyPreStageList @intListId INT
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblQMListPreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intListId = @intListId

	INSERT INTO tblQMListPreStage (
		intListId
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intListId
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
