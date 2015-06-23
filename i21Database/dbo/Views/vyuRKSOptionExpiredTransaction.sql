CREATE VIEW vyuRKSOptionExpiredTransaction
AS
SELECT m.intOptionsPnSExpiredId,
	   strTranNo,
	   dtmExpiredDate,
	   intLots,
	   m.intFutOptTransactionId,
	   isnull(t.dblPrice,0)* m.intLots * fm.dblContractSize as dblImpact,
       fm.strFutMarketName,
       om.strOptionMonth, 
       t.dblStrike,
       t.strOptionType,
       t.dblPrice AS dblPremiumRate,
       t.dblPrice*dblContractSize*intLots AS dblPremiumTotal,
	   e.strName,
	   b.strAccountNumber,
	   strCommodityCode,
	   scl.strLocationName,
	   cb.strBook,
	   csb.strSubBook
FROM tblRKOptionsPnSExpired m
Join tblRKFutOptTransaction t on t.intFutOptTransactionId= m.intFutOptTransactionId
Join tblRKFutureMarket fm on fm.intFutureMarketId = t.intFutureMarketId
JOIN tblRKOptionsMonth om on om.intOptionMonthId=t.intOptionMonthId
Join tblEntity e on e.intEntityId=t.intEntityId
Join tblRKBrokerageAccount b on b.intBrokerageAccountId=t.intBrokerageAccountId
join tblICCommodity ic on ic.intCommodityId=t.intCommodityId
JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=t.intLocationId
LEFT JOIN tblCTBook cb on cb.intBookId= t.intBookId
LEFT JOIN tblCTSubBook csb on csb.intSubBookId=t.intSubBookId