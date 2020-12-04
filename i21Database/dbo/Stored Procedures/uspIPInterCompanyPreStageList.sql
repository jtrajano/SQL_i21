CREATE PROCEDURE uspIPInterCompanyPreStageList @intListId INT
	,@strListName NVARCHAR(50) = NULL
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
		,strListName
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intListId
		,@strListName
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
