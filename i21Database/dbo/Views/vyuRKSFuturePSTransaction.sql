CREATE VIEW vyuRKSFuturePSTransaction
AS
SELECT TOP 100 PERCENT * FROM (
SELECT intTotalLot-dblSelectedLot1 AS dblBalanceLot, intTotalLot-dblSelectedLotRoll AS dblBalanceLotRoll, 0.0 as dblSelectedLot ,* from  (
SELECT intSelectedInstrumentTypeId,
      strInternalTradeNo AS strTransactionNo
      ,dtmTransactionDate as dtmTransactionDate
      ,convert(int,ot.intNoOfContract) as intTotalLot
      ,IsNull((SELECT SUM (AD.dblMatchQty) from tblRKMatchFuturesPSDetail AD inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId where A.strType = 'Realize' Group By AD.intSFutOptTransactionId 
                  Having ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0)  As dblSelectedLot1
	  ,IsNull((SELECT SUM (AD.dblMatchQty) from tblRKMatchFuturesPSDetail AD inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId where A.strType = 'Roll' Group By AD.intSFutOptTransactionId 
                  Having ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0)  As dblSelectedLotRoll
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
	   --This filter is to get the correct commission based on date						
      ,dblFutCommission = ISNULL((select TOP 1
		(case when bc.intFuturesRateType = 2 then 0  
			else  isnull(bc.dblFutCommission,0) / case when cur.ysnSubCurrency = 'true' then cur.intCent else 1 end 
		end) as dblFutCommission
		from tblRKBrokerageCommission bc
		LEFT JOIN tblSMCurrency cur on cur.intCurrencyID=bc.intFutCurrencyId
		where bc.intFutureMarketId = ot.intFutureMarketId and bc.intBrokerageAccountId = ot.intBrokerageAccountId and  ot.dtmTransactionDate between bc.dtmEffectiveDate and bc.dtmEndDate),0) * -1 --commision is always negative (RM-1174)
	  ,dtmFilledDate
	  ,ot.intFutOptTransactionHeaderId,
	   c.intCurrencyID as intCurrencyId,c.intCent,c.ysnSubCurrency 
	   	  ,ot.intBankId
	  ,ot.intBankAccountId
	  , ot.intCurrencyExchangeRateTypeId    
	  ,case when isnull(ot.dtmCreateDateTime,'')='' then ot.dtmTransactionDate else ot.dtmCreateDateTime end as dtmCreateDateTime     
FROM tblRKFutOptTransaction ot
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=ot.intFutureMarketId and ot.intInstrumentTypeId=1 and ot.strStatus='Filled'
JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
LEFT JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId AND ba.intEntityId = ot.intEntityId  AND ot.intInstrumentTypeId =1
LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId and intSelectedInstrumentTypeId=1 
)t)t1  --where dblBalanceLot > 0

UNION 

SELECT TOP 100 PERCENT * FROM (
SELECT intTotalLot-dblSelectedLot1 AS dblBalanceLot, intTotalLot-dblSelectedLotRoll AS dblBalanceLotRoll, 0.0 as dblSelectedLot ,* from  (
SELECT intSelectedInstrumentTypeId,
       strInternalTradeNo AS strTransactionNo
      ,dtmTransactionDate as dtmTransactionDate
      ,convert(int,ot.dblContractAmount) as intTotalLot
      ,IsNull((SELECT SUM (AD.dblMatchQty) from tblRKMatchFuturesPSDetail AD inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId where A.strType = 'Realize' GROUP BY AD.intSFutOptTransactionId 
                  Having ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0)  As dblSelectedLot1
	  ,IsNull((SELECT SUM (AD.dblMatchQty) from tblRKMatchFuturesPSDetail AD inner join tblRKMatchFuturesPSHeader A ON AD.intMatchFuturesPSHeaderId = A.intMatchFuturesPSHeaderId where A.strType = 'Roll' Group By AD.intSFutOptTransactionId 
                  Having ot.intFutOptTransactionId = AD.intSFutOptTransactionId), 0)  As dblSelectedLotRoll
      ,CASE WHEN strBuySell ='Buy' Then 'B' else 'S' End strBuySell
      ,ot.dblExchangeRate as dblPrice
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
	  ,null dtmFilledDate
	  ,ot.intFutOptTransactionHeaderId
	  ,null as intCurrencyId
	  ,null as intCent
	  ,null ysnSubCurrency  
	  	  ,ot.intBankId
	  ,ot.intBankAccountId 
	  , ot.intCurrencyExchangeRateTypeId       
	  ,case when isnull(ot.dtmCreateDateTime,'')='' then ot.dtmTransactionDate else ot.dtmCreateDateTime end as dtmCreateDateTime
FROM tblRKFutOptTransaction ot
LEFT JOIN tblCTBook b on b.intBookId=ot.intBookId
LEFT JOIN tblCTSubBook sb on sb.intSubBookId=ot.intSubBookId
LEFT JOIN [dbo].[tblCMBank] AS ban ON ot.[intBankId] = ban.[intBankId]
LEFT JOIN [dbo].[tblCMBankAccount] AS banAcc ON ot.[intBankAccountId] = banAcc.[intBankAccountId]
LEFT JOIN [dbo].[tblSMCurrencyExchangeRateType] AS ce ON ot.[intCurrencyExchangeRateTypeId] = ce.[intCurrencyExchangeRateTypeId]
where intSelectedInstrumentTypeId=2 AND ot.intInstrumentTypeId = 3 and isnull(ysnLiquidation,0) = 0
 )t)t1   --where  dblBalanceLot > 0
 Order by dtmCreateDateTime Asc, dblPrice desc