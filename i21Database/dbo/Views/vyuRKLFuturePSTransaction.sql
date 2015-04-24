CREATE VIEW vyuRKLFuturePSTransaction
AS
SELECT * FROM (
SELECT strTotalLot-dblSelectedLot1 AS dblBalanceLot, Case WHEN dblSelectedLot1=0 THEN strTotalLot else dblSelectedLot1 end dblSelectedLot ,* from  (
SELECT 
      strBrokerTradeNo AS strTransactionNo
      ,dtmTransactionDate as dtmTransactionDate
      ,ot.intNoOfContract as strTotalLot
      ,IsNull((SELECT SUM (AD.dblMatchQty) from tblRKMatchFuturesPSDetail AD Group By AD.intLFutOptTransactionId 
                  Having ot.intFutOptTransactionId = AD.intLFutOptTransactionId), 0)  As dblSelectedLot1
      ,CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End strBuySell
      ,dblPrice as dblPrice
      ,strBook 
      ,strSubBook 
      ,ot.intFutureMarketId 
      ,ot.intBrokerageAccountId
      ,ot.intLocationId
      ,ot.intFutureMonthId
      ,ot.intCommodityId
      ,ot.intBrokerId
     ,ISNULL(ot.intBookId,0) as intBookId
      ,ISNULL(ot.intSubBookId,0) as intSubBookId
      ,intFutOptTransactionId
      ,fm.dblContractSize
      ,case when bc.intFuturesRateType= 2 then 0 else  isnull(bc.dblFutCommission,0)* isnull(fm.dblContractSize,0) end as dblFutCommission
FROM tblRKFutOptTransaction ot
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId
LEFT JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId=ot.intFutureMarketId 
JOIN tblRKBrokerageAccount ba on bc.intBrokerageAccountId=ba.intBrokerageAccountId and ba.intInstrumentTypeId=1
AND ba.intBrokerageAccountId=bc.intBrokerageAccountId 
LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId )t)t1  where dblBalanceLot > 0
