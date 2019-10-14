CREATE PROCEDURE uspIPInterCompanyPreStageFreightRateMatrix @intFreightRateMatrixId INT
	,@strRowState NVARCHAR(50)
	,@intUserId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	DELETE
	FROM dbo.tblLGFreightRateMatrixPreStage
	WHERE strFeedStatus IS NULL
		AND intFreightRateMatrixId = @intFreightRateMatrixId

	INSERT INTO dbo.tblLGFreightRateMatrixPreStage (
		intFreightRateMatrixId
		,strRowState
		,intUserId
		)
	SELECT @intFreightRateMatrixId
		,@strRowState
		,@intUserId

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


