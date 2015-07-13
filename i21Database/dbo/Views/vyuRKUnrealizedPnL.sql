CREATE VIEW vyuRKUnrealizedPnL  
AS  


SELECT *,(GrossPnL-dblFutCommission) NetPnL from (  
SELECT (convert(int,isnull((Long1-MatchLong),0)- isnull(Sell1-MatchShort,0)))*dblContractSize GrossPnL,isnull(((Long1-MatchLong)*dblPrice),0) LongWaitedPrice,  
isnull((Long1-MatchLong),0) as dblLong,isnull(Sell1-MatchShort,0) as dblShort, isnull(((Sell1-MatchShort)*dblPrice),0) ShortWaitedPrice,  
CASE WHEN Long1 > 0  THEN (Long1 * dblFutCommission1) ELSE (Sell1 * dblFutCommission1) END AS dblFutCommission,
convert(int,isnull((Long1-MatchLong),0)- isnull(Sell1-MatchShort,0)) as  intNet,   
* FROM  
(   
SELECT  intFutOptTransactionId,
  fm.strFutMarketName,  
    om.strFutureMonth,ot.intFutureMonthId,ot.intCommodityId,ot.intFutureMarketId,  
    ot.dtmFilledDate as dtmTradeDate,  
    ot.strInternalTradeNo,  
    e.strName,  
    acc.strAccountNumber,  
    cb.strBook,  
    csb.strSubBook,  
    sp.strSalespersonId,  
    icc.strCommodityCode,  
    sl.strLocationName,     
    ot.intNoOfContract as intOriginalQty,  
    Case WHEN ot.strBuySell='Buy' THEN isnull(ot.intNoOfContract,0) ELSE null end Long1 ,  
    Case WHEN ot.strBuySell='Sell' THEN isnull(ot.intNoOfContract,0) ELSE null end Sell1,   
    ot.intNoOfContract as intNet1,  
    ot.dblPrice as dblActual,  
    null as dblClosing,    
    isnull(ot.dblPrice,0) dblPrice,  
    fm.dblContractSize dblContractSize,0 as intConcurrencyId,  
    CASE WHEN bc.intFuturesRateType= 1 then 0 else  isnull(bc.dblFutCommission,0) end as dblFutCommission1,  
   isnull((select sum(dblMatchQty) from tblRKMatchFuturesPSDetail psd WHERE psd.intLFutOptTransactionId=ot.intFutOptTransactionId),0)as MatchLong,  
   isnull((select sum(dblMatchQty) from tblRKMatchFuturesPSDetail psd WHERE psd.intSFutOptTransactionId=ot.intFutOptTransactionId),0)as MatchShort            
             
 FROM tblRKFutOptTransaction ot   
 JOIN tblRKFuturesMonth om on om.intFutureMonthId=ot.intFutureMonthId   and ot.strStatus='Filled'
 JOIN tblRKBrokerageAccount acc on acc.intBrokerageAccountId=ot.intBrokerageAccountId  
 JOIN tblICCommodity icc on icc.intCommodityId=ot.intCommodityId  
 JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=ot.intLocationId  
 join tblARSalesperson sp on sp.intEntitySalespersonId= ot.intTraderId  
 JOIN tblEntity e on e.intEntityId=ot.intEntityId  
 JOIN tblRKFutureMarket fm on ot.intFutureMarketId=fm.intFutureMarketId  
 JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId=ot.intFutureMarketId AND ot.intBrokerageAccountId=bc.intBrokerageAccountId   
 JOIN tblRKBrokerageAccount ba on bc.intBrokerageAccountId=ba.intBrokerageAccountId and ot.intInstrumentTypeId in(1) and( ot.dblStrike is null or ot.dblStrike=0)  
 LEFT JOIN tblCTBook cb on cb.intBookId= ot.intBookId  
 LEFT join tblCTSubBook csb on csb.intSubBookId=ot.intSubBookId  
  )t1)t1 WHERE (dblLong > 0 or dblShort > 0)  
    
UNION ALL
    
SELECT *,(GrossPnL-dblFutCommission) NetPnL from (  
SELECT (convert(int,isnull((Long1-MatchLong),0)- isnull(Sell1-MatchShort,0)))*dblContractSize GrossPnL,isnull(((Long1-MatchLong)*dblPrice),0) LongWaitedPrice,  
isnull((Long1-MatchLong),0) as dblLong,isnull(Sell1-MatchShort,0) as dblShort, isnull(((Sell1-MatchShort)*dblPrice),0) ShortWaitedPrice,  
CASE WHEN Long1 > 0  THEN (Long1 * dblFutCommission1) ELSE (Sell1 * dblFutCommission1) END AS dblFutCommission,
convert(int,isnull((Long1-MatchLong),0)- isnull(Sell1-MatchShort,0)) as  intNet,   
* FROM  
(   
SELECT  intFutOptTransactionId,
  fm.strFutMarketName,  
    om.strFutureMonth,ot.intFutureMonthId,ot.intCommodityId,ot.intFutureMarketId,  
    ot.dtmFilledDate as dtmTradeDate,  
    ot.strInternalTradeNo,  
    e.strName,  
    acc.strAccountNumber,  
    cb.strBook,  
    csb.strSubBook,  
    sp.strSalespersonId,  
    icc.strCommodityCode,  
    sl.strLocationName,     
    ot.intNoOfContract as intOriginalQty,  
    Case WHEN ot.strBuySell='Buy' THEN isnull(ot.intNoOfContract,0) ELSE null end Long1 ,  
    Case WHEN ot.strBuySell='Sell' THEN isnull(ot.intNoOfContract,0) ELSE null end Sell1,   
    ot.intNoOfContract as intNet1,  
    ot.dblPrice as dblActual,  
    null as dblClosing,    
    isnull(ot.dblPrice,0) dblPrice,  
    fm.dblContractSize dblContractSize,0 as intConcurrencyId,  
       CASE WHEN bc.intFuturesRateType= 2 then isnull(bc.dblFutCommission,0) else 0  end as dblFutCommission1,   
   isnull((select sum(dblMatchQty) from tblRKMatchFuturesPSDetail psd WHERE psd.intLFutOptTransactionId=ot.intFutOptTransactionId),0)as MatchLong,  
   isnull((select sum(dblMatchQty) from tblRKMatchFuturesPSDetail psd WHERE psd.intSFutOptTransactionId=ot.intFutOptTransactionId),0)as MatchShort 
 FROM tblRKFutOptTransaction ot   
 JOIN tblRKFuturesMonth om on om.intFutureMonthId=ot.intFutureMonthId   and ot.strStatus='Filled'
 JOIN tblRKBrokerageAccount acc on acc.intBrokerageAccountId=ot.intBrokerageAccountId  
 JOIN tblICCommodity icc on icc.intCommodityId=ot.intCommodityId  
 JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=ot.intLocationId  
 join tblARSalesperson sp on sp.intEntitySalespersonId= ot.intTraderId  
 JOIN tblEntity e on e.intEntityId=ot.intEntityId  
 JOIN tblRKFutureMarket fm on ot.intFutureMarketId=fm.intFutureMarketId  
 JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId=ot.intFutureMarketId AND ot.intBrokerageAccountId=bc.intBrokerageAccountId  AND bc.intFuturesRateType=2  
 JOIN tblRKBrokerageAccount ba on bc.intBrokerageAccountId=ba.intBrokerageAccountId and ot.intInstrumentTypeId in(1) and( ot.dblStrike is null or ot.dblStrike=0)  
 LEFT JOIN tblCTBook cb on cb.intBookId= ot.intBookId  
 LEFT join tblCTSubBook csb on csb.intSubBookId=ot.intSubBookId  
  )t1)t1 WHERE MatchLong = intOriginalQty or MatchShort = intOriginalQty 
    
  

  