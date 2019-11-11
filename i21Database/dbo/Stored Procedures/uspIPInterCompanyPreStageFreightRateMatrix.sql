CREATE PROCEDURE uspIPInterCompanyPreStageFreightRateMatrix @intFreightRateMatrixId INT
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM tblLGFreightRateMatrixPreStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intFreightRateMatrixId = @intFreightRateMatrixId

	INSERT INTO tblLGFreightRateMatrixPreStage (
		intFreightRateMatrixId
		,strRowState
		,intUserId
		,strFeedStatus
		,strMessage
		)
	SELECT @intFreightRateMatrixId
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
