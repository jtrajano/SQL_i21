﻿CREATE VIEW vyuRKSOptionExpiredTransaction
AS
SELECT m.intOptionsPnSExpiredId,
	   strTranNo,
	   dtmExpiredDate,
	   t.strInternalTradeNo,
	   intLots,
	   m.intFutOptTransactionId,
	   (case when t.strBuySell='Buy' THEN -isnull(t.dblPrice,0)* m.intLots * fm.dblContractSize else isnull(t.dblPrice,0)* m.intLots * fm.dblContractSize end)/ case when ysnSubCurrency = 'true' then intCent else 1 end as dblImpact,
       fm.strFutMarketName,
       om.strOptionMonth, 
       t.dblStrike,
       t.strOptionType,
       t.dblPrice AS dblPremiumRate,
       (Case WHEN t.strBuySell='Buy' THEN -isnull(t.dblPrice*dblContractSize*intLots,0) else isnull(t.dblPrice*dblContractSize*intLots,0) end)/ case when ysnSubCurrency = 'true' then intCent else 1 end AS dblPremiumTotal,
	   e.strName,
	   b.strAccountNumber,
	   strCommodityCode,
	   scl.strLocationName,
	   cb.strBook,
	   csb.strSubBook,t.intFutOptTransactionHeaderId
FROM tblRKOptionsPnSExpired m
Join tblRKFutOptTransaction t on t.intFutOptTransactionId= m.intFutOptTransactionId
Join tblRKFutureMarket fm on fm.intFutureMarketId = t.intFutureMarketId
JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId  
JOIN tblRKOptionsMonth om on om.intOptionMonthId=t.intOptionMonthId
Join tblEntity e on e.intEntityId=t.intEntityId
Join tblRKBrokerageAccount b on b.intBrokerageAccountId=t.intBrokerageAccountId
join tblICCommodity ic on ic.intCommodityId=t.intCommodityId
JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=t.intLocationId
LEFT JOIN tblCTBook cb on cb.intBookId= t.intBookId
LEFT JOIN tblCTSubBook csb on csb.intSubBookId=t.intSubBookId