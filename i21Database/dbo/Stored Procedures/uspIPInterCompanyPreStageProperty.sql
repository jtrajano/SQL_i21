CREATE PROCEDURE uspIPInterCompanyPreStageProperty @intPropertyId INT
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblQMPropertyPreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intPropertyId = @intPropertyId

	INSERT INTO tblQMPropertyPreStage (
		intPropertyId
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intPropertyId
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
