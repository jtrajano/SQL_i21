CREATE PROCEDURE uspIPInterCompanyPreStageAttribute @intAttributeId INT
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblQMAttributePreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intAttributeId = @intAttributeId

	INSERT INTO tblQMAttributePreStage (
		intAttributeId
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intAttributeId
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
