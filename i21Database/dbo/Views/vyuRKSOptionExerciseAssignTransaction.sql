CREATE VIEW vyuRKSOptionExerciseAssignTransaction
AS
SELECT m.intOptionsPnSExercisedAssignedId,
	   convert(int,strTranNo) strTranNo,
	   dtmTranDate,
	   t.strInternalTradeNo,
	   t.dtmFilledDate as dtmTransactionDate,
	   case when t.strBuySell = 'Buy' Then 'B' else 'S' End strBuySell,
	   m.intLots,
	   om.strOptionMonth, 
	   fm.strFutMarketName,
	   t.dblStrike,
       t.strOptionType,
       t.dblPrice AS dblPremiumRate,
       (t.dblPrice*dblContractSize*intLots)/ case when ysnSubCurrency = 'true' then intCent else 1 end AS dblPremiumTotal,
	   e.strName,
	   b.strAccountNumber,
	   strCommodityCode,
	   scl.strLocationName,
	   cb.strBook,
	   csb.strSubBook
	   ,t.intFutOptTransactionHeaderId
FROM tblRKOptionsPnSExercisedAssigned m
Join tblRKFutOptTransaction t on t.intFutOptTransactionId= m.intFutOptTransactionId
Join tblRKFutureMarket fm on fm.intFutureMarketId = t.intFutureMarketId
JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId  
JOIN tblRKOptionsMonth om on om.intOptionMonthId=t.intOptionMonthId
Join tblEMEntity e on e.intEntityId=t.intEntityId
Join tblRKBrokerageAccount b on b.intBrokerageAccountId=t.intBrokerageAccountId
join tblICCommodity ic on ic.intCommodityId=t.intCommodityId
JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=t.intLocationId
LEFT JOIN tblCTBook cb on cb.intBookId= t.intBookId
LEFT JOIN tblCTSubBook csb on csb.intSubBookId=t.intSubBookId