CREATE PROC uspRKGetNetHedgeDetail 
	@intCommodityId int,
	@intLocationId int = NULL
AS
IF ISNULL(@intLocationId, 0) <> 0

BEGIN
	SELECT l.strLocationName,ft.dtmFilledDate,ft.strInternalTradeNo,fm.strFutureMonth,
	CASE WHEN ft.intInstrumentTypeId=1 THEN 'Future' ELSE 'Option' END strInstrumentType,e.strName strBroker,ba.strAccountNumber, t.* FROM
	(SELECT f.intFutOptTransactionId,m.strFutMarketName, isnull(intNoOfContract,0) intNoOfContract,ISNULL(dblMatchQty,0) dblMatchQty,m.dblContractSize,m.intFutureMarketId,'Buy' as [BuySell] ,
	(ISNULL(intNoOfContract,0)-isnull(dblMatchQty,0)) OpenLots,
	(ISNULL(intNoOfContract,0)-isnull(dblMatchQty,0)) * m.dblContractSize as HedgedQty
	FROM tblRKFutOptTransaction f
	JOIN tblRKFutureMarket m on f.intFutureMarketId=m.intFutureMarketId
	LEFT JOIN tblRKMatchFuturesPSDetail psd on f.intFutOptTransactionId=psd.intLFutOptTransactionId
	WHERE f.strBuySell = 'Buy' and intCommodityId=@intCommodityId and f.intLocationId=@intLocationId
	UNION ALL
	SELECT f.intFutOptTransactionId,m.strFutMarketName,isnull(intNoOfContract,0) intNoOfContract,isnull(dblMatchQty,0) dblMatchQty,m.dblContractSize,m.intFutureMarketId,'Sell' as [BuySell],
		(ISNULL(intNoOfContract,0)-isnull(dblMatchQty,0)) OpenLots,
		-(isnull(intNoOfContract,0)-isnull(dblMatchQty,0)) * m.dblContractSize as HedgedQty
	FROM tblRKFutOptTransaction f
	JOIN tblRKFutureMarket m on f.intFutureMarketId=m.intFutureMarketId
	LEFT JOIN tblRKMatchFuturesPSDetail psd on f.intFutOptTransactionId=psd.intSFutOptTransactionId 
	WHERE f.strBuySell = 'Sell' And intCommodityId=@intCommodityId and f.intLocationId=@intLocationId
	) t
	JOIN tblRKFutOptTransaction ft on t.intFutOptTransactionId=ft.intFutOptTransactionId
	JOIN tblSMCompanyLocation l on l.intCompanyLocationId=ft.intLocationId
	JOIN tblRKFuturesMonth fm on ft.intFutureMonthId=fm.intFutureMonthId
	JOIN tblEntity e on e.intEntityId=ft.intEntityId
	JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=ft.intBrokerageAccountId
END
ELSE
BEGIN
SELECT l.strLocationName,ft.dtmFilledDate,ft.strInternalTradeNo,fm.strFutureMonth,
	CASE WHEN ft.intInstrumentTypeId=1 THEN 'Future' ELSE 'Option' END strInstrumentType,e.strName strBroker,ba.strAccountNumber, t.* FROM
	(SELECT f.intFutOptTransactionId,m.strFutMarketName, isnull(intNoOfContract,0) intNoOfContract,ISNULL(dblMatchQty,0) dblMatchQty,m.dblContractSize,m.intFutureMarketId,'Buy' as [BuySell] ,
	(ISNULL(intNoOfContract,0)-isnull(dblMatchQty,0)) OpenLots,
	(ISNULL(intNoOfContract,0)-isnull(dblMatchQty,0)) * m.dblContractSize as HedgedQty
	FROM tblRKFutOptTransaction f
	JOIN tblRKFutureMarket m on f.intFutureMarketId=m.intFutureMarketId
	LEFT JOIN tblRKMatchFuturesPSDetail psd on f.intFutOptTransactionId=psd.intLFutOptTransactionId
	WHERE f.strBuySell = 'Buy' and intCommodityId=@intCommodityId 
	UNION ALL
	SELECT f.intFutOptTransactionId,m.strFutMarketName,isnull(intNoOfContract,0) intNoOfContract,isnull(dblMatchQty,0) dblMatchQty,m.dblContractSize,m.intFutureMarketId,'Sell' as [BuySell],
		(ISNULL(intNoOfContract,0)-isnull(dblMatchQty,0)) OpenLots,
		-(isnull(intNoOfContract,0)-isnull(dblMatchQty,0)) * m.dblContractSize as HedgedQty
	FROM tblRKFutOptTransaction f
	JOIN tblRKFutureMarket m on f.intFutureMarketId=m.intFutureMarketId
	LEFT JOIN tblRKMatchFuturesPSDetail psd on f.intFutOptTransactionId=psd.intSFutOptTransactionId 
	WHERE f.strBuySell = 'Sell' And intCommodityId=@intCommodityId
	) t
	JOIN tblRKFutOptTransaction ft on t.intFutOptTransactionId=ft.intFutOptTransactionId
	JOIN tblSMCompanyLocation l on l.intCompanyLocationId=ft.intLocationId
	JOIN tblRKFuturesMonth fm on ft.intFutureMonthId=fm.intFutureMonthId
	JOIN tblEntity e on e.intEntityId=ft.intEntityId
	JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=ft.intBrokerageAccountId
END
