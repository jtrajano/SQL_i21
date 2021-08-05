CREATE PROCEDURE [dbo].[uspQMInterCompanyPreStageSample] @intSampleId INT
	,@strRowState NVARCHAR(50) = NULL
	,@intBookId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	IF NOT EXISTS (
			SELECT 1
			FROM tblIPMultiCompany
			)
	BEGIN
		RETURN
	END

	DELETE
	FROM tblQMSamplePreStage
	WHERE ISNULL(strFeedStatus, '') IN ('', 'HOLD')
		AND intSampleId = @intSampleId

	IF EXISTS (
			SELECT 1
			FROM tblQMSample WITH (NOLOCK)
			WHERE intSampleId = @intSampleId
				AND intBookId IS NOT NULL
			)
		OR (
			ISNULL(@strRowState, '') = 'Delete'
			AND @intBookId IS NOT NULL
			)
		INSERT INTO tblQMSamplePreStage (
			intSampleId
			,strRowState
			,strFeedStatus
			,strMessage
			,intBookId
			)
		SELECT @intSampleId
			,ISNULL(@strRowState, '')
			,''
			,''
			,@intBookId
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
