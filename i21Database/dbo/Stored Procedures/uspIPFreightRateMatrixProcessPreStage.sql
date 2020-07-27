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

	IF @intFreightRateMatrixPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblLGFreightRateMatrixPreStage t
	JOIN @tblLGFreightRateMatrixPreStage pt ON pt.intFreightRateMatrixPreStageId = t.intFreightRateMatrixPreStageId

	WHILE @intFreightRateMatrixPreStageId IS NOT NULL
	BEGIN
		SELECT @intFreightRateMatrixId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intFreightRateMatrixId = intFreightRateMatrixId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblLGFreightRateMatrixPreStage WITH (NOLOCK)
		WHERE intFreightRateMatrixPreStageId = @intFreightRateMatrixPreStageId

		-- Check to process only 'General' type
		IF EXISTS (
				SELECT 1
				FROM tblLGFreightRateMatrix t WITH (NOLOCK)
				WHERE t.intType = 2
					AND t.intFreightRateMatrixId = @intFreightRateMatrixId
				) OR @strRowState = 'Delete'
		BEGIN
			EXEC uspIPFreightRateMatrixPopulateStgXML @intFreightRateMatrixId
				,@intToEntityId
				,@intCompanyLocationId
				,@strToTransactionType
				,@intToCompanyId
				,@strRowState
				,0
				,@intToBookId
				,@intUserId
		END

		UPDATE tblLGFreightRateMatrixPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intFreightRateMatrixPreStageId = @intFreightRateMatrixPreStageId

		SELECT @intFreightRateMatrixPreStageId = MIN(intFreightRateMatrixPreStageId)
		FROM @tblLGFreightRateMatrixPreStage
		WHERE intFreightRateMatrixPreStageId > @intFreightRateMatrixPreStageId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblLGFreightRateMatrixPreStage t
	JOIN @tblLGFreightRateMatrixPreStage pt ON pt.intFreightRateMatrixPreStageId = t.intFreightRateMatrixPreStageId
		AND t.strFeedStatus = 'In-Progress'
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
