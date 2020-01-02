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
	DECLARE @tblRKDailyAveragePricePreStage TABLE (intDailyAveragePricePreStageId INT)

	INSERT INTO @tblRKDailyAveragePricePreStage (intDailyAveragePricePreStageId)
	SELECT intDailyAveragePricePreStageId
	FROM tblRKDailyAveragePricePreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intDailyAveragePricePreStageId = MIN(intDailyAveragePricePreStageId)
	FROM @tblRKDailyAveragePricePreStage

	WHILE @intDailyAveragePricePreStageId IS NOT NULL
	BEGIN
		SELECT @intDailyAveragePriceId = NULL
			,@strRowState = NULL
			,@intUserId = NULL
			,@intToCompanyId = NULL

		SELECT @intDailyAveragePriceId = intDailyAveragePriceId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblRKDailyAveragePricePreStage
		WHERE intDailyAveragePricePreStageId = @intDailyAveragePricePreStageId

		SELECT TOP 1 @strFromCompanyName = strName
		FROM tblIPMultiCompany
		WHERE ysnParent = 1

		SELECT TOP 1 @intToCompanyId = MC.intCompanyId
		FROM tblRKDailyAveragePrice DAP
		JOIN tblIPMultiCompany MC ON MC.intBookId = DAP.intBookId
			AND DAP.intDailyAveragePriceId = @intDailyAveragePriceId

		-- Process only Posted transaction
		IF EXISTS (
				SELECT 1
				FROM tblRKDailyAveragePrice t
				WHERE ISNULL(t.ysnPosted, 0) = 1
					AND t.intDailyAveragePriceId = @intDailyAveragePriceId
					AND t.intBookId IS NOT NULL
				)
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
