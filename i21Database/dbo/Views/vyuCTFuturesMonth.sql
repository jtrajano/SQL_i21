CREATE VIEW [dbo].[vyuCTFuturesMonth]

AS 

	SELECT	intFutureMonthId,
			REPLACE(strFutureMonth,' ','('+strSymbol+') ') strFutureMonthYear,
			intFutureMarketId 
	FROM	tblRKFuturesMonth
