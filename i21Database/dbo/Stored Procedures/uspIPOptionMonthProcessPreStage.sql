CREATE PROCEDURE uspIPOptionMonthProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intOptionMonthId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intOptionMonthPreStageId INT
	DECLARE @tblRKOptionsMonthPreStage TABLE (intOptionMonthPreStageId INT)

	INSERT INTO @tblRKOptionsMonthPreStage (intOptionMonthPreStageId)
	SELECT intOptionMonthPreStageId
	FROM tblRKOptionsMonthPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intOptionMonthPreStageId = MIN(intOptionMonthPreStageId)
	FROM @tblRKOptionsMonthPreStage

	IF @intOptionMonthPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKOptionsMonthPreStage t
	JOIN @tblRKOptionsMonthPreStage pt ON pt.intOptionMonthPreStageId = t.intOptionMonthPreStageId

	WHILE @intOptionMonthPreStageId IS NOT NULL
	BEGIN
		SELECT @intOptionMonthId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intOptionMonthId = intOptionMonthId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblRKOptionsMonthPreStage WITH (NOLOCK)
		WHERE intOptionMonthPreStageId = @intOptionMonthPreStageId

		EXEC uspIPOptionMonthPopulateStgXML @intOptionMonthId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblRKOptionsMonthPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intOptionMonthPreStageId = @intOptionMonthPreStageId

		SELECT @intOptionMonthPreStageId = MIN(intOptionMonthPreStageId)
		FROM @tblRKOptionsMonthPreStage
		WHERE intOptionMonthPreStageId > @intOptionMonthPreStageId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKOptionsMonthPreStage t
	JOIN @tblRKOptionsMonthPreStage pt ON pt.intOptionMonthPreStageId = t.intOptionMonthPreStageId
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
