﻿CREATE VIEW vyuRKSFuturePSTransaction
AS
SELECT TOP 100 PERCENT * FROM (
SELECT strTotalLot-dblSelectedLot1 AS dblBalanceLot, 0.0 as dblSelectedLot ,* from  (
SELECT 
      strInternalTradeNo AS strTransactionNo
      ,dtmTransactionDate as dtmTransactionDate
      ,ot.intNoOfContract as strTotalLot
      ,IsNull((SELECT SUM (AD.dblMatchQty) from tblRKMatchFuturesPSDetail AD Group By AD.intSFutOptTransactionId 
                  Having ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0)  As dblSelectedLot1
      ,CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End strBuySell
      ,dblPrice as dblPrice
      ,strBook 
      ,strSubBook 
      ,ot.intFutureMarketId 
      ,ot.intBrokerageAccountId
      ,ot.intLocationId
      ,ot.intFutureMonthId
      ,ot.intCommodityId
      ,ot.intEntityId
      ,ISNULL(ot.intBookId,0) as intBookId
      ,ISNULL(ot.intSubBookId,0) as intSubBookId
      ,intFutOptTransactionId
      ,fm.dblContractSize
      ,case when bc.intFuturesRateType= 2 then 0 else  isnull(bc.dblFutCommission,0) end as dblFutCommission,dtmFilledDate 
	  ,ot.intFutOptTransactionHeaderId,
	  c.intCurrencyID as intCurrencyId,c.intCent,ysnSubCurrency 
FROM tblRKFutOptTransaction ot
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId and ot.intInstrumentTypeId=1 and ot.strStatus='Filled' 
JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId=ot.intFutureMarketId and ot.intBrokerageAccountId=bc.intBrokerageAccountId
JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId 
	AND ba.intEntityId = ot.intEntityId  AND ot.intInstrumentTypeId IN(1,3) 
LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId)t )t1  where dblBalanceLot > 0 
ORDER BY dtmFilledDate 
