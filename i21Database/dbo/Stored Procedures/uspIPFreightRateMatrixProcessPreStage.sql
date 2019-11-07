CREATE PROCEDURE uspIPFreightRateMatrixProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intFreightRateMatrixId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intFreightRateMatrixPreStageId INT
	DECLARE @tblLGFreightRateMatrixPreStage TABLE (intFreightRateMatrixPreStageId INT)

	INSERT INTO @tblLGFreightRateMatrixPreStage (intFreightRateMatrixPreStageId)
	SELECT intFreightRateMatrixPreStageId
	FROM tblLGFreightRateMatrixPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intFreightRateMatrixPreStageId = MIN(intFreightRateMatrixPreStageId)
	FROM @tblLGFreightRateMatrixPreStage

	WHILE @intFreightRateMatrixPreStageId IS NOT NULL
	BEGIN
		SELECT @intFreightRateMatrixId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intFreightRateMatrixId = intFreightRateMatrixId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblLGFreightRateMatrixPreStage
		WHERE intFreightRateMatrixPreStageId = @intFreightRateMatrixPreStageId

		EXEC uspIPFreightRateMatrixPopulateStgXML @intFreightRateMatrixId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblLGFreightRateMatrixPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intFreightRateMatrixPreStageId = @intFreightRateMatrixPreStageId

		SELECT @intFreightRateMatrixPreStageId = MIN(intFreightRateMatrixPreStageId)
		FROM @tblLGFreightRateMatrixPreStage
		WHERE intFreightRateMatrixPreStageId > @intFreightRateMatrixPreStageId
	END
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
