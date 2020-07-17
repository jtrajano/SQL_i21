CREATE PROCEDURE [dbo].[uspQMInterCompanyPreStageSample] @intSampleId INT
	,@strRowState NVARCHAR(50) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblQMSamplePreStage
	WHERE ISNULL(strFeedStatus, '') IN ('', 'HOLD')
		AND intSampleId = @intSampleId

	INSERT INTO tblQMSamplePreStage (
		intSampleId
		,strRowState
		,strFeedStatus
		,strMessage
		)
	SELECT @intSampleId
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
