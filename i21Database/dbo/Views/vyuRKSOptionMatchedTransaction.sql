CREATE VIEW vyuRKSOptionMatchedTransaction
AS
SELECT m.intMatchOptionsPnSId,strTranNo,dtmMatchDate,intMatchQty,e.strName,b.strAccountNumber,t.strInternalTradeNo,scl.strLocationName,
	   fm.strFutMarketName,om.strOptionMonth,t.dblStrike,t.strOptionType
	   ,strCommodityCode,t.dtmTransactionDate as dtmMLTransactionDate,t.strInternalTradeNo as strMLInternalTradeNo,cb.strBook as strMLBook,csb.strSubBook as strMLSubBook,
	   (SELECT TOP 1 dtmTransactionDate FROM tblRKOptionsMatchPnS om
	    JOIN tblRKFutOptTransaction t1 on m.intSFutOptTransactionId= t1.intFutOptTransactionId) as  dtmMSTransactionDate,
	    (SELECT TOP 1 strInternalTradeNo FROM tblRKOptionsMatchPnS om
	    JOIN tblRKFutOptTransaction t1 on m.intSFutOptTransactionId= t1.intFutOptTransactionId) as  strMSInternalTradeNo,
	    (SELECT TOP 1 strBook FROM tblRKOptionsMatchPnS om
	    JOIN tblRKFutOptTransaction t1 on m.intSFutOptTransactionId= t1.intFutOptTransactionId
	    JOIN tblCTBook cb on cb.intBookId= t1.intBookId ) as  strMSBook,
	    (SELECT TOP 1 strSubBook FROM tblRKOptionsMatchPnS om
	    JOIN tblRKFutOptTransaction t1 on m.intSFutOptTransactionId= t1.intFutOptTransactionId
	    JOIN tblCTSubBook scb on scb.intBookId= t1.intBookId ) as  strMSSubBook
FROM tblRKOptionsMatchPnS m
join tblRKFutOptTransaction t on m.intLFutOptTransactionId= t.intFutOptTransactionId
Join tblEntity e on e.intEntityId=t.intEntityId
Join tblRKBrokerageAccount b on b.intBrokerageAccountId=t.intBrokerageAccountId
Join tblRKFutureMarket fm on fm.intFutureMarketId = t.intFutureMarketId
JOIN tblRKOptionsMonth om on om.intOptionMonthId=t.intOptionMonthId
join tblICCommodity ic on ic.intCommodityId=t.intCommodityId
JOIN tblCTBook cb on cb.intBookId= t.intBookId
join tblCTSubBook csb on csb.intSubBookId=t.intSubBookId
JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=t.intLocationId

