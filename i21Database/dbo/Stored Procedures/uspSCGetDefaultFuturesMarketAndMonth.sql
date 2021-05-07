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
--Added this to get the value and if it is false then we do not need to validate the future market -MDG
DECLARE @ysnExchangeTraded BIT;
BEGIN
	SELECT TOP 1 @intFutureMarketId = ISNULL(intFutureMarketId, 0)
		,@ysnExchangeTraded = ysnExchangeTraded
	FROM tblICCommodity WHERE intCommodityId = @intCommodityId

	if @ysnExchangeTraded = 1
	begin
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
	end
	else
	begin
		select @intFutureMarketId = null, @intFutureMonthId = null
	end
	
END

