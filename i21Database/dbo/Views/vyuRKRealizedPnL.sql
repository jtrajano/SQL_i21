CREATE VIEW vyuRKRealizedPnL  
AS  
SELECT TOP 100 PERCENT convert(int,DENSE_RANK() OVER(ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth))) RowNum, strFutMarketName+ ' - ' + strFutureMonth + ' - ' + strName MonthOrder,* from (
SELECT *,(dblGrossPL1-dblFutCommission1) / case when ysnSubCurrency = 'true' then intCent else 1 end AS dblNetPL,-dblFutCommission1/ case when ComSubCurrency = 'true' then ComCent else 1 end as dblFutCommission FROM(  
SELECT   
((dblSPrice - dblLPrice)*dblMatchQty*dblContractSize) as dblGrossPL1,((dblSPrice - dblLPrice)*dblMatchQty*dblContractSize)/ case when ysnSubCurrency = 'true' then intCent else 1 end as dblGrossPL,* FROM  
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
    CASE WHEN bc.intFuturesRateType= 2 then 0 else  isnull(bc.dblFutCommission,0)* isnull(psd.dblMatchQty,0) end as dblFutCommission1,  
    fm.strFutMarketName,  
    om.strFutureMonth,  
    psh.intMatchNo,  
    psh.dtmMatchDate,  
    e.strName,  
    acc.strAccountNumber,  
    icc.strCommodityCode,  
    sl.strLocationName,ot.intFutureMonthId,ot.intCommodityId,ot.intFutureMarketId,
	c.intCurrencyID as intCurrencyId,c.intCent,c.ysnSubCurrency,ysnExpired,cur.intCent ComCent,cur.ysnSubCurrency ComSubCurrency                  
 FROM tblRKMatchFuturesPSHeader psh  
 JOIN tblRKMatchFuturesPSDetail psd on psd.intMatchFuturesPSHeaderId=psh.intMatchFuturesPSHeaderId   
 JOIN tblRKFutOptTransaction ot on psd.intLFutOptTransactionId= ot.intFutOptTransactionId  
 JOIN tblRKFuturesMonth om on om.intFutureMonthId=ot.intFutureMonthId   
 JOIN tblRKBrokerageAccount acc on acc.intBrokerageAccountId=ot.intBrokerageAccountId  
 JOIN tblICCommodity icc on icc.intCommodityId=ot.intCommodityId  
 JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=ot.intLocationId  
 JOIN tblEMEntity e on e.intEntityId=ot.intEntityId  
 JOIN tblRKFutureMarket fm on ot.intFutureMarketId=fm.intFutureMarketId  
 JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId
 JOIN tblRKFutOptTransaction ot1 on psd.intSFutOptTransactionId= ot1.intFutOptTransactionId  
 JOIN tblRKBrokerageCommission bc on bc.intFutureMarketId=psh.intFutureMarketId AND psh.intBrokerageAccountId=bc.intBrokerageAccountId   
  JOIN tblSMCurrency cur on cur.intCurrencyID=bc.intFutCurrencyId
 JOIN tblRKBrokerageAccount ba on bc.intBrokerageAccountId=ba.intBrokerageAccountId AND ot.intInstrumentTypeId =1
  )t)t1
  )t ORDER BY RowNum ASC