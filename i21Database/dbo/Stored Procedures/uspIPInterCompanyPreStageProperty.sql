CREATE PROCEDURE uspIPInterCompanyPreStageProperty @intPropertyId INT
	,@strPropertyName NVARCHAR(100) = NULL
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
		,strPropertyName
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intPropertyId
		,@strPropertyName
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
