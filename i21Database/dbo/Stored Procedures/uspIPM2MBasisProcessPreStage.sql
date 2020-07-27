CREATE PROCEDURE uspIPM2MBasisProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intM2MBasisId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intM2MBasisPreStageId INT
	DECLARE @tblRKM2MBasisPreStage TABLE (intM2MBasisPreStageId INT)

	INSERT INTO @tblRKM2MBasisPreStage (intM2MBasisPreStageId)
	SELECT intM2MBasisPreStageId
	FROM tblRKM2MBasisPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intM2MBasisPreStageId = MIN(intM2MBasisPreStageId)
	FROM @tblRKM2MBasisPreStage

	IF @intM2MBasisPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKM2MBasisPreStage t
	JOIN @tblRKM2MBasisPreStage pt ON pt.intM2MBasisPreStageId = t.intM2MBasisPreStageId

	WHILE @intM2MBasisPreStageId IS NOT NULL
	BEGIN
		SELECT @intM2MBasisId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intM2MBasisId = intM2MBasisId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblRKM2MBasisPreStage WITH (NOLOCK)
		WHERE intM2MBasisPreStageId = @intM2MBasisPreStageId

		EXEC uspIPM2MBasisPopulateStgXML @intM2MBasisId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblRKM2MBasisPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intM2MBasisPreStageId = @intM2MBasisPreStageId

		SELECT @intM2MBasisPreStageId = MIN(intM2MBasisPreStageId)
		FROM @tblRKM2MBasisPreStage
		WHERE intM2MBasisPreStageId > @intM2MBasisPreStageId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKM2MBasisPreStage t
	JOIN @tblRKM2MBasisPreStage pt ON pt.intM2MBasisPreStageId = t.intM2MBasisPreStageId
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
