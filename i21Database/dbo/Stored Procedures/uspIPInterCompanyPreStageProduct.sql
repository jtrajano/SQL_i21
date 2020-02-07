CREATE PROCEDURE uspIPInterCompanyPreStageProduct @intProductId INT
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblQMProductPreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intProductId = @intProductId

	INSERT INTO tblQMProductPreStage (
		intProductId
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intProductId
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
