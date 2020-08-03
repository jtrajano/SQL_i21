CREATE PROCEDURE uspIPCoverageEntryProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intCoverageEntryId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intCoverageEntryPreStageId INT
		,@strFromCompanyName NVARCHAR(150)
	DECLARE @tblRKCoverageEntryPreStage TABLE (intCoverageEntryPreStageId INT)

	INSERT INTO @tblRKCoverageEntryPreStage (intCoverageEntryPreStageId)
	SELECT intCoverageEntryPreStageId
	FROM tblRKCoverageEntryPreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intCoverageEntryPreStageId = MIN(intCoverageEntryPreStageId)
	FROM @tblRKCoverageEntryPreStage

	IF @intCoverageEntryPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKCoverageEntryPreStage t
	JOIN @tblRKCoverageEntryPreStage pt ON pt.intCoverageEntryPreStageId = t.intCoverageEntryPreStageId

	WHILE @intCoverageEntryPreStageId IS NOT NULL
	BEGIN
		SELECT @intCoverageEntryId = NULL
			,@strRowState = NULL
			,@intUserId = NULL
			,@intToCompanyId = NULL

		SELECT @intCoverageEntryId = intCoverageEntryId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblRKCoverageEntryPreStage WITH (NOLOCK)
		WHERE intCoverageEntryPreStageId = @intCoverageEntryPreStageId

		SELECT TOP 1 @intToCompanyId = intCompanyId
		FROM tblIPMultiCompany WITH (NOLOCK)
		WHERE ysnParent = 1

		SELECT TOP 1 @strFromCompanyName = MC.strName
		FROM tblRKCoverageEntry C WITH (NOLOCK)
		JOIN tblIPMultiCompany MC WITH (NOLOCK) ON MC.intBookId = C.intBookId
			AND C.intCoverageEntryId = @intCoverageEntryId

		-- Process only Posted transaction
		IF EXISTS (
				SELECT 1
				FROM tblRKCoverageEntry t WITH (NOLOCK)
				WHERE ISNULL(t.ysnPosted, 0) = 1
					AND t.intCoverageEntryId = @intCoverageEntryId
					AND t.intBookId IS NOT NULL
				) OR @strRowState = 'Delete'
		BEGIN
			EXEC uspIPCoverageEntryPopulateStgXML @intCoverageEntryId
				,@intToEntityId
				,@intCompanyLocationId
				,@strToTransactionType
				,@intToCompanyId
				,@strRowState
				,0
				,@intToBookId
				,@intUserId
				,@strFromCompanyName
		END

		UPDATE tblRKCoverageEntryPreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intCoverageEntryPreStageId = @intCoverageEntryPreStageId

		SELECT @intCoverageEntryPreStageId = MIN(intCoverageEntryPreStageId)
		FROM @tblRKCoverageEntryPreStage
		WHERE intCoverageEntryPreStageId > @intCoverageEntryPreStageId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKCoverageEntryPreStage t
	JOIN @tblRKCoverageEntryPreStage pt ON pt.intCoverageEntryPreStageId = t.intCoverageEntryPreStageId
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
