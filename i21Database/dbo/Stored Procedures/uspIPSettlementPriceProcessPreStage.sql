CREATE PROCEDURE uspIPSettlementPriceProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intFutureSettlementPriceId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@intFutureSettlementPricePreStageId INT
	DECLARE @tblRKFuturesSettlementPricePreStage TABLE (intFutureSettlementPricePreStageId INT)

	INSERT INTO @tblRKFuturesSettlementPricePreStage (intFutureSettlementPricePreStageId)
	SELECT intFutureSettlementPricePreStageId
	FROM tblRKFuturesSettlementPricePreStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intFutureSettlementPricePreStageId = MIN(intFutureSettlementPricePreStageId)
	FROM @tblRKFuturesSettlementPricePreStage

	WHILE @intFutureSettlementPricePreStageId IS NOT NULL
	BEGIN
		SELECT @intFutureSettlementPriceId = NULL
			,@strRowState = NULL
			,@intUserId = NULL

		SELECT @intFutureSettlementPriceId = intFutureSettlementPriceId
			,@strRowState = strRowState
			,@intUserId = intUserId
		FROM tblRKFuturesSettlementPricePreStage
		WHERE intFutureSettlementPricePreStageId = @intFutureSettlementPricePreStageId

		EXEC uspIPSettlementPricePopulateStgXML @intFutureSettlementPriceId
			,@intToEntityId
			,@intCompanyLocationId
			,@strToTransactionType
			,@intToCompanyId
			,@strRowState
			,0
			,@intToBookId
			,@intUserId

		UPDATE tblRKFuturesSettlementPricePreStage
		SET strFeedStatus = 'Processed'
			,strMessage = 'Success'
		WHERE intFutureSettlementPricePreStageId = @intFutureSettlementPricePreStageId

		SELECT @intFutureSettlementPricePreStageId = MIN(intFutureSettlementPricePreStageId)
		FROM @tblRKFuturesSettlementPricePreStage
		WHERE intFutureSettlementPricePreStageId > @intFutureSettlementPricePreStageId
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
