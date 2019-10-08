CREATE PROCEDURE uspIPInterCompanyPreStageCoverageEntry @intCoverageEntryId INT
	,@strRowState NVARCHAR(50) = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblRKCoverageEntryPreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intCoverageEntryId = @intCoverageEntryId

	INSERT INTO tblRKCoverageEntryPreStage (
		intCoverageEntryId
		,strRowState
		,strFeedStatus
		,strMessage
		)
	SELECT @intCoverageEntryId
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
