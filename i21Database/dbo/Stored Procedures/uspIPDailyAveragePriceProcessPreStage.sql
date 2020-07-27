CREATE PROCEDURE uspIPDailyAveragePriceProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intDailyAveragePriceId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intDailyAveragePricePreStageId INT
		,@strFromCompanyName NVARCHAR(150)
		,@intBookId INT
		,@intDeleteBookId INT
	DECLARE @tblRKDailyAveragePricePreStage TABLE (intDailyAveragePricePreStageId INT)
	DECLARE @intCompanyId INT

	SELECT @intCompanyId = intCompanyId
	FROM dbo.tblIPMultiCompany
	WHERE ysnCurrentCompany = 1

	UPDATE dbo.tblRKDailyAveragePrice
	SET intCompanyId = @intCompanyId
	WHERE intCompanyId IS NULL

	INSERT INTO @tblRKDailyAveragePricePreStage (intDailyAveragePricePreStageId)
	SELECT intDailyAveragePricePreStageId
	FROM tblRKDailyAveragePricePreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intDailyAveragePricePreStageId = MIN(intDailyAveragePricePreStageId)
	FROM @tblRKDailyAveragePricePreStage

	IF @intDailyAveragePricePreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKDailyAveragePricePreStage t
	JOIN @tblRKDailyAveragePricePreStage pt ON pt.intDailyAveragePricePreStageId = t.intDailyAveragePricePreStageId

	WHILE @intDailyAveragePricePreStageId IS NOT NULL
	BEGIN
		SELECT @intDailyAveragePriceId = NULL
			,@strRowState = NULL
			,@intUserId = NULL
			,@intToCompanyId = NULL
			,@intDeleteBookId = NULL

		SELECT @intDailyAveragePriceId = intDailyAveragePriceId
			,@strRowState = strRowState
			,@intUserId = intUserId
			,@intDeleteBookId = intBookId
		FROM tblRKDailyAveragePricePreStage WITH (NOLOCK)
		WHERE intDailyAveragePricePreStageId = @intDailyAveragePricePreStageId

		SELECT TOP 1 @strFromCompanyName = strName
			,@intBookId = intBookId
		FROM tblIPMultiCompany WITH (NOLOCK)
		WHERE ysnParent = 1

		SELECT TOP 1 @intToCompanyId = MC.intCompanyId
		FROM tblRKDailyAveragePrice DAP WITH (NOLOCK)
		JOIN tblIPMultiCompany MC WITH (NOLOCK) ON MC.intBookId = DAP.intBookId
			AND DAP.intDailyAveragePriceId = @intDailyAveragePriceId

		IF @strRowState = 'Delete'
		BEGIN
			SELECT TOP 1 @intToCompanyId = MC.intCompanyId
			FROM tblIPMultiCompany MC WITH (NOLOCK)
			WHERE MC.intBookId = @intDeleteBookId
		END

		-- Process only Posted transaction
		IF EXISTS (
				SELECT 1
				FROM tblRKDailyAveragePrice t WITH (NOLOCK)
				WHERE ISNULL(t.ysnPosted, 0) = 1
					AND t.intDailyAveragePriceId = @intDailyAveragePriceId
					AND t.intBookId IS NOT NULL
					AND t.intBookId <> @intBookId
				) OR @strRowState = 'Delete'
		BEGIN
			EXEC uspIPDailyAveragePricePopulateStgXML @intDailyAveragePriceId
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

		UPDATE tblRKDailyAveragePricePreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intDailyAveragePricePreStageId = @intDailyAveragePricePreStageId

		SELECT @intDailyAveragePricePreStageId = MIN(intDailyAveragePricePreStageId)
		FROM @tblRKDailyAveragePricePreStage
		WHERE intDailyAveragePricePreStageId > @intDailyAveragePricePreStageId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKDailyAveragePricePreStage t
	JOIN @tblRKDailyAveragePricePreStage pt ON pt.intDailyAveragePricePreStageId = t.intDailyAveragePricePreStageId
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
