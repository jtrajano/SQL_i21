﻿CREATE VIEW [dbo].[vyuRKLFuturePSTransaction]
AS

SELECT TOP 100 PERCENT * FROM (
SELECT intTotalLot-dblSelectedLot1 AS dblBalanceLot, 0.0 as dblSelectedLot ,* from  (
SELECT intSelectedInstrumentTypeId,
      strInternalTradeNo AS strTransactionNo
      ,dtmTransactionDate as dtmTransactionDate
      ,convert(int,ot.intNoOfContract) as intTotalLot
      ,IsNull((SELECT SUM (AD.dblMatchQty) from tblRKMatchFuturesPSDetail AD Group By AD.intLFutOptTransactionId 
                  Having ot.intFutOptTransactionId = AD.intLFutOptTransactionId), 0)  As dblSelectedLot1
      ,CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End strBuySell
      ,dblPrice as dblPrice
	  	   ,case when isnull(ot.dtmCreateDateTime,'')='' then ot.dtmTransactionDate else ot.dtmCreateDateTime end as dtmCreateDateTime
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
      ,ot.dblCommission as dblFutCommission
	  ,ot.intBrokerageCommissionId
	  ,dtmFilledDate
	  ,ot.intFutOptTransactionHeaderId,
	   c.intCurrencyID as intCurrencyId
	   ,c.intCent
	   ,c.ysnSubCurrency
	  ,ot.intBankId
	  ,ot.intBankAccountId
	   ,ot.intCurrencyExchangeRateTypeId
FROM tblRKFutOptTransaction ot
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId and ot.intInstrumentTypeId=1 and ot.strStatus='Filled'
JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
LEFT JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId AND ba.intEntityId = ot.intEntityId  AND ot.intInstrumentTypeId =1
LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId and intSelectedInstrumentTypeId=1
)t)t1  where dblBalanceLot > 0

UNION 

SELECT TOP 100 PERCENT * FROM (
SELECT intTotalLot-dblSelectedLot1 AS dblBalanceLot, 0.0 as dblSelectedLot ,* from  (
SELECT intSelectedInstrumentTypeId,
       strInternalTradeNo AS strTransactionNo
      ,dtmTransactionDate as dtmTransactionDate
      ,convert(int,ot.dblContractAmount) as intTotalLot
      ,IsNull((SELECT SUM (AD.dblMatchQty) from tblRKMatchFuturesPSDetail AD GROUP BY AD.intLFutOptTransactionId 
                  Having ot.intFutOptTransactionId = AD.intLFutOptTransactionId), 0)  As dblSelectedLot1
      ,CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End strBuySell
       ,ot.dblExchangeRate as dblPrice
	    ,case when isnull(ot.dtmCreateDateTime,'')='' then ot.dtmTransactionDate else ot.dtmCreateDateTime end as dtmCreateDateTime  
      ,strBook 
      ,strSubBook 
      ,null intFutureMarketId 
      ,null  intBrokerageAccountId
      ,null intLocationId
      ,null intFutureMonthId
      ,intCommodityId
      ,null intEntityId
      ,ISNULL(ot.intBookId,0) as intBookId
      ,ISNULL(ot.intSubBookId,0) as intSubBookId
      ,intFutOptTransactionId
      ,null dblContractSize
      ,null  dblFutCommission
	  ,null intBrokerageCommissionId
	  ,null dtmFilledDate
	  ,ot.intFutOptTransactionHeaderId
	  ,null as intCurrencyId
	  ,null as intCent
	  ,null ysnSubCurrency
	  ,ot.intBankId
	  ,ot.intBankAccountId
	  ,ot.intCurrencyExchangeRateTypeId  	
FROM tblRKFutOptTransaction ot
LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId
LEFT JOIN [dbo].[tblCMBank] AS ban ON ot.[intBankId] = ban.[intBankId]
LEFT JOIN [dbo].[tblCMBankAccount] AS banAcc ON ot.[intBankAccountId] = banAcc.[intBankAccountId]
LEFT JOIN [dbo].[tblSMCurrencyExchangeRateType] AS ce ON ot.[intCurrencyExchangeRateTypeId] = ce.[intCurrencyExchangeRateTypeId]
where intSelectedInstrumentTypeId=2 AND ot.intInstrumentTypeId = 3 and isnull(ysnLiquidation,0) = 0 
)t)t1 WHERE dblBalanceLot > 0 
Order by dtmCreateDateTime Asc, dblPrice desc




