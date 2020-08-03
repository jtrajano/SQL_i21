CREATE PROCEDURE uspIPProductProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intProductId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intProductPreStageId INT
	DECLARE @tblQMProductPreStage TABLE (intProductPreStageId INT)

	INSERT INTO @tblQMProductPreStage (intProductPreStageId)
	SELECT intProductPreStageId
	FROM tblQMProductPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intProductPreStageId = MIN(intProductPreStageId)
	FROM @tblQMProductPreStage

	IF @intProductPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblQMProductPreStage t
	JOIN @tblQMProductPreStage pt ON pt.intProductPreStageId = t.intProductPreStageId

	WHILE @intProductPreStageId IS NOT NULL
	BEGIN
		SELECT @intProductId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intProductId = intProductId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblQMProductPreStage WITH (NOLOCK)
		WHERE intProductPreStageId = @intProductPreStageId

		EXEC uspIPProductPopulateStgXML @intProductId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblQMProductPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intProductPreStageId = @intProductPreStageId

		SELECT @intProductPreStageId = MIN(intProductPreStageId)
		FROM @tblQMProductPreStage
		WHERE intProductPreStageId > @intProductPreStageId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblQMProductPreStage t
	JOIN @tblQMProductPreStage pt ON pt.intProductPreStageId = t.intProductPreStageId
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
