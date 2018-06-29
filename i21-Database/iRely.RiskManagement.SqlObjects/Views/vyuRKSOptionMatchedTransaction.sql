CREATE VIEW vyuRKSOptionMatchedTransaction
AS
SELECT top 100 percent *,((isnull(dblSPrice,0)-isnull(dblLPrice,0))*intMatchQty*dblContractSize)/ case when ysnSubCurrency = 'true' then intCent else 1 end as dblImpact FROM(
SELECT m.intMatchOptionsPnSId,convert(int,strTranNo) strTranNo,dtmMatchDate,intMatchQty,e.strName,b.strAccountNumber,t.strInternalTradeNo,scl.strLocationName,t.dblPrice as dblLPrice,
	   fm.strFutMarketName,om.strOptionMonth,t.dblStrike,t.strOptionType,fm.dblContractSize
	   ,strCommodityCode,t.dtmFilledDate as dtmMLTransactionDate,t.strInternalTradeNo as strMLInternalTradeNo,cb.strBook as strMLBook,csb.strSubBook as strMLSubBook,
	   (SELECT TOP 1 dtmFilledDate FROM tblRKOptionsMatchPnS om
	    JOIN tblRKFutOptTransaction t1 on m.intSFutOptTransactionId= t1.intFutOptTransactionId) as  dtmMSTransactionDate,
	    (SELECT TOP 1 strInternalTradeNo FROM tblRKOptionsMatchPnS om
	    JOIN tblRKFutOptTransaction t1 on m.intSFutOptTransactionId= t1.intFutOptTransactionId) as  strMSInternalTradeNo,
	    (SELECT TOP 1 strBook FROM tblRKOptionsMatchPnS om
	    JOIN tblRKFutOptTransaction t1 on m.intSFutOptTransactionId= t1.intFutOptTransactionId
	    JOIN tblCTBook cb on cb.intBookId= t1.intBookId ) as  strMSBook,
	    (SELECT TOP 1 strSubBook FROM tblRKOptionsMatchPnS om
	    JOIN tblRKFutOptTransaction t1 on m.intSFutOptTransactionId= t1.intFutOptTransactionId
	    JOIN tblCTSubBook scb on scb.intBookId= t1.intBookId ) as  strMSSubBook,
	    (SELECT TOP 1 dblPrice FROM tblRKOptionsMatchPnS om
	    JOIN tblRKFutOptTransaction t1 on m.intSFutOptTransactionId= t1.intFutOptTransactionId) as  dblSPrice
		,c.intCurrencyID as intCurrencyId,c.intCent,ysnSubCurrency,
		(select Top 1 intFutOptTransactionHeaderId from tblRKFutOptTransaction fft where fft.intFutOptTransactionId=m.intLFutOptTransactionId) intLFutOptTransactionHeaderId,
		(select Top 1 intFutOptTransactionHeaderId from tblRKFutOptTransaction fft where fft.intFutOptTransactionId=m.intSFutOptTransactionId) intSFutOptTransactionHeaderId
FROM tblRKOptionsMatchPnS m
join tblRKFutOptTransaction t on m.intLFutOptTransactionId= t.intFutOptTransactionId
Join tblEMEntity e on e.intEntityId=t.intEntityId
Join tblRKBrokerageAccount b on b.intBrokerageAccountId=t.intBrokerageAccountId
Join tblRKFutureMarket fm on fm.intFutureMarketId = t.intFutureMarketId
JOIN tblSMCurrency c on c.intCurrencyID=fm.intCurrencyId  
JOIN tblRKOptionsMonth om on om.intOptionMonthId=t.intOptionMonthId
join tblICCommodity ic on ic.intCommodityId=t.intCommodityId
JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=t.intLocationId
LEFT JOIN tblCTBook cb on cb.intBookId= t.intBookId
LEFT join tblCTSubBook csb on csb.intSubBookId=t.intSubBookId)t order by convert(int,strTranNo) Asc