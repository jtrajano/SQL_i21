CREATE PROCEDURE uspIPFutureMarketProcessPreStage
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intToBookId INT
		,@intFutureMarketId INT
		,@strRowState NVARCHAR(50) = NULL
		,@intUserId INT
		,@strFutMarketName NVARCHAR(30)
		,@dblForecastPrice NUMERIC(18, 6)
	DECLARE @tblRKFutureMarket TABLE (intFutureMarketId INT)

	INSERT INTO @tblRKFutureMarket (intFutureMarketId)
	SELECT intFutureMarketId
	FROM tblRKFutureMarket WITH (NOLOCK)

	SELECT @intFutureMarketId = MIN(intFutureMarketId)
	FROM @tblRKFutureMarket

	WHILE @intFutureMarketId IS NOT NULL
	BEGIN
		SELECT @strFutMarketName = NULL
			,@dblForecastPrice = NULL

		SELECT @strFutMarketName = strFutMarketName
			,@dblForecastPrice = ISNULL(dblForecastPrice, 0)
			,@strRowState = 'Modified'
		FROM tblRKFutureMarket WITH (NOLOCK)
		WHERE intFutureMarketId = @intFutureMarketId

		IF NOT EXISTS (
				SELECT 1
				FROM tblRKFutureMarketStage
				WHERE strFutMarketName = @strFutMarketName
				)
		BEGIN
			EXEC uspIPFutureMarketPopulateStgXML @intFutureMarketId
				,@intToEntityId
				,@intCompanyLocationId
				,@strToTransactionType
				,@intToCompanyId
				,@strRowState
				,0
				,@intToBookId
				,@intUserId
		END
		ELSE
		BEGIN
			UPDATE tblRKFutureMarketStage
			SET dblForecastPrice = @dblForecastPrice
				,strFeedStatus = NULL
				,strMessage = NULL
			WHERE strFutMarketName = @strFutMarketName
				AND ISNULL(dblForecastPrice, 0) <> @dblForecastPrice
		END

		SELECT @intFutureMarketId = MIN(intFutureMarketId)
		FROM @tblRKFutureMarket
		WHERE intFutureMarketId > @intFutureMarketId
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
