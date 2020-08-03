CREATE PROCEDURE uspIPAttributeProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intAttributeId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intAttributePreStageId INT
	DECLARE @tblQMAttributePreStage TABLE (intAttributePreStageId INT)

	INSERT INTO @tblQMAttributePreStage (intAttributePreStageId)
	SELECT intAttributePreStageId
	FROM tblQMAttributePreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intAttributePreStageId = MIN(intAttributePreStageId)
	FROM @tblQMAttributePreStage

	IF @intAttributePreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblQMAttributePreStage t
	JOIN @tblQMAttributePreStage pt ON pt.intAttributePreStageId = t.intAttributePreStageId

	WHILE @intAttributePreStageId IS NOT NULL
	BEGIN
		SELECT @intAttributeId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intAttributeId = intAttributeId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblQMAttributePreStage WITH (NOLOCK)
		WHERE intAttributePreStageId = @intAttributePreStageId

		EXEC uspIPAttributePopulateStgXML @intAttributeId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblQMAttributePreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intAttributePreStageId = @intAttributePreStageId

		SELECT @intAttributePreStageId = MIN(intAttributePreStageId)
		FROM @tblQMAttributePreStage
		WHERE intAttributePreStageId > @intAttributePreStageId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblQMAttributePreStage t
	JOIN @tblQMAttributePreStage pt ON pt.intAttributePreStageId = t.intAttributePreStageId
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
