CREATE VIEW [dbo].[vyuCTFuturesMonth]

AS 

	SELECT	intFutureMonthId,
			REPLACE(strFutureMonth,' ','('+strSymbol+') ') strFutureMonthYear,
			intFutureMarketId,
			dtmFutureMonthsDate,
			strSymbol,
			intYear,
			dtmFirstNoticeDate,
			dtmLastNoticeDate,
			dtmLastTradingDate,
			dtmSpotDate,
			ysnExpired,
			MONTH(CONVERT(DATETIME,'01 '+strFutureMonth)) intMonth
	FROM	tblRKFuturesMonth
