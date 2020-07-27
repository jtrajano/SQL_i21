CREATE PROCEDURE uspIPTestProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intTestId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intTestPreStageId INT
	DECLARE @tblQMTestPreStage TABLE (intTestPreStageId INT)

	INSERT INTO @tblQMTestPreStage (intTestPreStageId)
	SELECT intTestPreStageId
	FROM tblQMTestPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intTestPreStageId = MIN(intTestPreStageId)
	FROM @tblQMTestPreStage

	IF @intTestPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblQMTestPreStage t
	JOIN @tblQMTestPreStage pt ON pt.intTestPreStageId = t.intTestPreStageId

	WHILE @intTestPreStageId IS NOT NULL
	BEGIN
		SELECT @intTestId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intTestId = intTestId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblQMTestPreStage WITH (NOLOCK)
		WHERE intTestPreStageId = @intTestPreStageId

		EXEC uspIPTestPopulateStgXML @intTestId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblQMTestPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intTestPreStageId = @intTestPreStageId

		SELECT @intTestPreStageId = MIN(intTestPreStageId)
		FROM @tblQMTestPreStage
		WHERE intTestPreStageId > @intTestPreStageId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblQMTestPreStage t
	JOIN @tblQMTestPreStage pt ON pt.intTestPreStageId = t.intTestPreStageId
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
