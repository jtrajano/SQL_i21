CREATE PROCEDURE [dbo].[uspRKGetPriceHistory]
	 @FutureMarketId   INT
	,@dtmPriceDateTime DateTime
AS
BEGIN
	SELECT 
	 a.intFutSettlementPriceMonthId AS intPriceHistoryKey
	 ,b.dtmPriceDate
	 ,d.strFutMarketName AS strFutureMarket
	,c.strFutureMonth AS strFutureMonth
	,a.dblOpen
	,a.dblLow
	,a.dblHigh
	,a.dblLastSettle dblClose 
	,(a.dblLastSettle-a.dblOpen) dblChange
	FROM tblRKFutSettlementPriceMarketMap a 
	JOIN tblRKFuturesSettlementPrice b ON b.intFutureSettlementPriceId=a.intFutureSettlementPriceId
	JOIN tblRKFuturesMonth c ON c.intFutureMonthId=a.intFutureMonthId
	JOIN tblRKFutureMarket d ON d.intFutureMarketId=b.intFutureMarketId
	WHERE b.intFutureMarketId=@FutureMarketId AND dbo.fnRemoveTimeOnDate(b.dtmPriceDate)=dbo.fnRemoveTimeOnDate(@dtmPriceDateTime)
END