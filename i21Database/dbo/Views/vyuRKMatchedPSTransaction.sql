CREATE VIEW [dbo].[vyuRKMatchedPSTransaction]

AS
SELECT *,(dblGrossPL-dblFutCommission) AS dblNetPL FROM(
SELECT 
((dblSPrice - dblLPrice)*dblMatchQty*dblContractSize) as dblGrossPL,* FROM
(
SELECT psh.intMatchFuturesPSHeaderId,
          psd.intMatchFuturesPSDetailId,
          ot.intFutOptTransactionId,     
          psd.intLFutOptTransactionId,
          psd.intSFutOptTransactionId,
          isnull(psd.dblMatchQty,0) as dblMatchQty,
          ot.dtmTransactionDate dtmLTransDate,
          ot1.dtmTransactionDate dtmSTransDate,
          isnull(ot.dblPrice,0) dblLPrice,
          isnull(ot1.dblPrice,0) dblSPrice,
          ot.strInternalTradeNo strLBrokerTradeNo,
          ot1.strInternalTradeNo strSBrokerTradeNo,
          fm.dblContractSize dblContractSize,0 as intConcurrencyId,
          CASE WHEN bc.intFuturesRateType= 2 then 0 else  isnull(bc.dblFutCommission,0)* isnull(psd.dblMatchQty,0) end as dblFutCommission         
FROM tblRKMatchFuturesPSHeader psh
JOIN tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId 
JOIN tblRKFutOptTransaction ot on psd.intLFutOptTransactionId= ot.intFutOptTransactionId
JOIN tblRKFutureMarket fm on ot.intFutureMarketId=fm.intFutureMarketId
JOIN tblRKBrokerageAccount ba on ot.intBrokerageAccountId=ba.intBrokerageAccountId and ot.intInstrumentTypeId in(1) 
LEFT JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId=ot.intFutureMarketId and ot.intBrokerageAccountId=bc.intBrokerageAccountId
JOIN tblRKFutOptTransaction ot1 on psd.intSFutOptTransactionId= ot1.intFutOptTransactionId
  )t)t1

