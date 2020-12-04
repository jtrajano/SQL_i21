CREATE PROCEDURE uspIPInterCompanyPreStageSampleType @intSampleTypeId INT
	,@strSampleTypeName NVARCHAR(50) = NULL
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblQMSampleTypePreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intSampleTypeId = @intSampleTypeId

	INSERT INTO tblQMSampleTypePreStage (
		intSampleTypeId
		,strSampleTypeName
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intSampleTypeId
		,@strSampleTypeName
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
