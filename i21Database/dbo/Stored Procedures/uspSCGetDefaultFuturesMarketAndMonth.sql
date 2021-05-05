CREATE PROCEDURE [dbo].[uspSCGetDefaultFuturesMarketAndMonth]
	@intCommodityId INT,
	@intFutureMarketId INT OUTPUT,
    @intFutureMonthId INT OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strCommodityCode NVARCHAR(50);
DECLARE @ErrorMessage NVARCHAR(200);

BEGIN
	SELECT TOP 1 @intFutureMarketId = ISNULL(intFutureMarketId, 0)
	FROM tblICCommodity WHERE intCommodityId = @intCommodityId

	IF(@intFutureMarketId = 0)
	BEGIN
		IF (SELECT COUNT(intFutureMarketId) FROM tblRKCommodityMarketMapping WHERE intCommodityId = @intCommodityId) = 1
			SELECT TOP 1 @intFutureMarketId = intFutureMarketId
			FROM tblRKCommodityMarketMapping WHERE intCommodityId = @intCommodityId
		ELSE
		BEGIN
			SELECT @strCommodityCode = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId
			SET @ErrorMessage = N'The default Futures Market in commodity ' + @strCommodityCode + ' is not maintained. Unable to get the settlement price.'
			RAISERROR (@ErrorMessage,16,1,'WITH NOWAIT')
		END
	END
			
	SELECT TOP 1 @intFutureMonthId = intFutureMonthId
	FROM tblRKFuturesMonth WHERE ysnExpired = 0 AND dtmSpotDate <= GETDATE() AND intFutureMarketId = @intFutureMarketId ORDER BY dtmSpotDate DESC, intYear DESC
END

