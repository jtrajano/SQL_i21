CREATE FUNCTION [dbo].[fnRKGetFutureOptionMonthsNotInUse](@intFutureMarketId int, @intMonthsOpen int, @ysnFutures bit = 0)
RETURNS @returntable TABLE(
	intMonthId INT
   ,strMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS
) 
AS
BEGIN

DECLARE @isValid BIT = 0 ;
DECLARE @ValidateCurrentMonth TABLE(
	 intMonthId INT
	,strMonth NVARCHAR(10) COLLATE Latin1_General_CI_AS);

IF (@ysnFutures = 1)
BEGIN
	INSERT INTO @ValidateCurrentMonth(intMonthId, strMonth)
	SELECT intFutureMonthId, strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMarketId = @intFutureMarketId
	AND intFutureMonthId NOT IN(
		SELECT TOP(@intMonthsOpen) intFutureMonthId 
		FROM tblRKFuturesMonth 
		WHERE intFutureMarketId = @intFutureMarketId
		ORDER BY CONVERT(datetime, dtmFutureMonthsDate, 103) ASC
	);

	IF EXISTS(SELECT TOP 1 1 FROM vyuRKGetFutureTradingMonthsInUse 
		WHERE strMonthName IN(
			SELECT strMonth FROM @ValidateCurrentMonth
		)
		AND intFutureMarketId = @intFutureMarketId
	)
	BEGIN
		INSERT INTO @returntable(intMonthId, strMonth)
		SELECT intMonthId, @intFutureMarketId 
		FROM @ValidateCurrentMonth V
		INNER JOIN (
			SELECT * FROM vyuRKGetFutureTradingMonthsInUse
			WHERE intFutureMarketId = @intFutureMarketId
		)FUT ON V.strMonth = FUT.strMonthName

		RETURN;
	END
END
ELSE
BEGIN
	INSERT INTO @ValidateCurrentMonth(intMonthId, strMonth)
	SELECT intOptionMonthId, strOptionMonth FROM tblRKOptionsMonth WHERE intFutureMarketId = @intFutureMarketId
	AND intOptionMonthId NOT IN(
		SELECT TOP(@intMonthsOpen) intOptionMonthId 
		FROM tblRKOptionsMonth 
		WHERE intFutureMarketId = @intFutureMarketId
		ORDER BY CONVERT(DATETIME, REPLACE(strOptionMonth, ' ',  ' 1, '),103)  ASC
	);

	IF EXISTS(SELECT TOP 1 1 FROM vyuRKGetOptionTradingMonthsInUse 
		WHERE strMonthName IN(
			SELECT strMonth FROM @ValidateCurrentMonth
		)
		AND intFutureMarketId = @intFutureMarketId
	)
	BEGIN
		INSERT INTO @returntable(intMonthId, strMonth)
		SELECT intMonthId, @intFutureMarketId 
		FROM @ValidateCurrentMonth V
		INNER JOIN (
			SELECT * FROM vyuRKGetOptionTradingMonthsInUse 
			WHERE intFutureMarketId = @intFutureMarketId
		)FUT ON V.strMonth = FUT.strMonthName

		RETURN;
	END
END

RETURN;

END