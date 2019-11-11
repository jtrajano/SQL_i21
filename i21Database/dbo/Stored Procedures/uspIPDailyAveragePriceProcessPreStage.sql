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

		SELECT @intDailyAveragePriceId = intDailyAveragePriceId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblRKDailyAveragePricePreStage
		WHERE intDailyAveragePricePreStageId = @intDailyAveragePricePreStageId

		-- Process only Posted transaction
		IF EXISTS (
				SELECT 1
				FROM tblRKDailyAveragePrice t
				WHERE ISNULL(t.ysnPosted, 0) = 1
					AND t.intDailyAveragePriceId = @intDailyAveragePriceId
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
