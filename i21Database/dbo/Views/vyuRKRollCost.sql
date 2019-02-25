CREATE VIEW vyuRKRollCost
	
AS
SELECT ft.intFutOptTransactionId,ft.intFutureMarketId,m.strFutMarketName,ft.intCommodityId,c.strCommodityCode,fm.strFutureMonth,ft.intFutureMonthId,    
convert( numeric(24,10),dblOpenContract) dblNoOfLot,ft.dblPrice dblQuantity,dblOpenContract*ft.dblPrice dblWtAvgOpenLongPosition,strInternalTradeNo,intFutOptTransactionHeaderId  
,intLocationId,dtmFilledDate dtmTransactionDate,intBookId,intSubBookId  
FROM tblRKFutOptTransaction ft  
join vyuRKGetOpenContract oc on ft.intFutOptTransactionId=oc.intFutOptTransactionId and strBuySell='Buy' and isnull(dblOpenContract,0) >0   
JOIN tblRKFutureMarket m on ft.intFutureMarketId=m.intFutureMarketId   
JOIN tblICCommodity c on ft.intCommodityId=c.intCommodityId  
JOIN tblRKFuturesMonth fm on ft.intFutureMarketId=fm.intFutureMarketId and ft.intFutureMonthId=fm.intFutureMonthId  
WHERE intSelectedInstrumentTypeId=1  AND intInstrumentTypeId=1