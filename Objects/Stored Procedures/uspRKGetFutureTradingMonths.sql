CREATE PROCEDURE uspRKGetFutureTradingMonths
	@intFutureMarketId INT
	,@intMonthCode INT
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	IF EXISTS(SELECT TOP 1 1 FROM vyuRKGetAllowedFuturesMonthTraded WHERE intFutureMarketId = @intFutureMarketId AND intMonthCode = @intMonthCode)
	BEGIN
		SELECT TOP 2 intFutureMarketId
			,strFutureMonth
			,intMonthCode
			,strSymbol
		FROM vyuRKGetAllowedFuturesMonthTraded
		WHERE intFutureMarketId = @intFutureMarketId AND intMonthCode >= @intMonthCode
		ORDER BY intMonthCode ASC
	END
	ELSE 
	BEGIN
		SELECT TOP 1 intFutureMarketId
			,strFutureMonth
			,intMonthCode
			,strSymbol 
		FROM vyuRKGetAllowedFuturesMonthTraded
		WHERE intFutureMarketId = @intFutureMarketId AND intMonthCode > @intMonthCode
		ORDER BY intMonthCode ASC
	END
END