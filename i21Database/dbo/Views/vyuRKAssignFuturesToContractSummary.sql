CREATE VIEW vyuRKAssignFuturesToContractSummary
			
AS
SELECT tbl.*
	, strPricingStatus = CASE WHEN CDD.intPricingStatus = 0 THEN 'Unpriced' WHEN CDD.intPricingStatus = 1 THEN 'Partially Priced' WHEN CDD.intPricingStatus = 2 THEN 'Priced' END
	, dblNoOfLots = ISNULL(CDD.dblNoOfLots, 0)
	, dblLotsPriced = CASE WHEN CDD.intPricingTypeId = 1 THEN (CDD.dblQuantity / M.dblContractSize) ELSE ISNULL(PFD.dblQuantity, 0) / M.dblContractSize END
	, dblLotsUnpriced = CASE WHEN CDD.intPricingTypeId = 1 THEN 0 ELSE ((CDD.dblQuantity - ISNULL(PFD.dblQuantity, 0)) / M.dblContractSize) END
FROM (
SELECT cs.intAssignFuturesToContractSummaryId,
		ch.strContractNumber,
		ct.strContractType,  
		cd.intContractSeq,
		m.strFutMarketName CTFutureMarketName,
		mo.strFutureMonth CTFutureMonthName,
		com.strCommodityCode CTCommodityCode,
		cl.strLocationName CTLocationName,
		b.strBook CTBook,
		sb.strSubBook CTSubBook,
		cs.dtmMatchDate,
		cs.dblAssignedLots,
		cs.dblHedgedLots,
		fot.strBuySell,
		fot.strInternalTradeNo,
		fot.strBrokerTradeNo,
		fot.dtmFilledDate,
		fm.strFutMarketName ,
		fmh.strFutureMonth ,
		fot.dblPrice,
		c.strCommodityCode,
		scl.strLocationName
		,b1.strBook
		,sb1.strSubBook,
		cd.intContractDetailId,
		ch.intContractHeaderId,
		fot.intFutOptTransactionId,
		cs.ysnIsHedged,
		fot.intFutOptTransactionHeaderId,
		fot.dtmCreateDateTime
FROM tblRKAssignFuturesToContractSummary cs
JOIN tblCTContractDetail cd ON  cs.intContractDetailId=cd.intContractDetailId  
join tblCTContractHeader ch on cd.intContractHeaderId = ch.intContractHeaderId
join tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
JOIN tblRKFutureMarket m on cd.intFutureMarketId=m.intFutureMarketId
JOIN tblRKFuturesMonth mo on cd.intFutureMonthId=mo.intFutureMonthId
JOIN tblSMCompanyLocation   cl ON cl.intCompanyLocationId  = cd.intCompanyLocationId
JOIN tblRKFutOptTransaction fot on fot.intFutOptTransactionId=cs.intFutOptTransactionId 
join tblICCommodity com on com.intCommodityId= fot.intCommodityId
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=fot.intFutureMarketId
JOIN tblRKFuturesMonth fmh on fot.intFutureMonthId=fmh.intFutureMonthId  
JOIN tblEMEntity e on fot.intEntityId=e.intEntityId
JOIN tblICCommodity c on fot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=fot.intLocationId
LEFT JOIN tblCTBook b on cd.intBookId=b.intBookId
LEFT JOIN tblCTSubBook sb on cd.intSubBookId=sb.intSubBookId 
LEFT JOIN tblCTBook b1 on fot.intBookId=b1.intBookId
LEFT JOIN tblCTSubBook sb1 on fot.intSubBookId=sb1.intSubBookId  where isnull(ch.ysnMultiplePriceFixation,0) = 0

UNION 

SELECT cs.intAssignFuturesToContractSummaryId,
		ch.strContractNumber,
		ct.strContractType,  
		null as intContractSeq,
		fm.strFutMarketName CTFutureMarketName,
		fmh.strFutureMonth CTFutureMonthName,
		com.strCommodityCode CTCommodityCode,
		cl.strLocationName CTLocationName,
		b.strBook CTBook,
		sb.strSubBook CTSubBook,
		cs.dtmMatchDate,
		cs.dblAssignedLots,
		cs.dblHedgedLots,
		fot.strBuySell,
		fot.strInternalTradeNo,
		fot.strBrokerTradeNo,
		fot.dtmFilledDate,
		fm.strFutMarketName ,
		fmh.strFutureMonth ,
		fot.dblPrice,
		c.strCommodityCode,
		scl.strLocationName
		,b1.strBook
		,sb1.strSubBook,
		null intContractDetailId,
		ch.intContractHeaderId,
		fot.intFutOptTransactionId,
		cs.ysnIsHedged
		,fot.intFutOptTransactionHeaderId,fot.dtmCreateDateTime  	
FROM tblRKAssignFuturesToContractSummary cs
JOIN tblCTContractHeader ch on ch.intContractHeaderId= cs.intContractHeaderId 
join tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
join tblICCommodity com on com.intCommodityId=ch.intCommodityId
--JOIN tblRKFutureMarket m on ch.intFutureMarketId=m.intFutureMarketId
--JOIN tblRKFuturesMonth mo on ch.intFutureMonthId=mo.intFutureMonthId
JOIN tblSMCompanyLocation   cl ON cl.intCompanyLocationId  = (select top 1 intCompanyLocationId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
JOIN tblRKFutOptTransaction fot on fot.intFutOptTransactionId=cs.intFutOptTransactionId 
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=fot.intFutureMarketId
JOIN tblRKFuturesMonth fmh on fot.intFutureMonthId=fmh.intFutureMonthId  
JOIN tblEMEntity e on fot.intEntityId=e.intEntityId
JOIN tblICCommodity c on fot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=fot.intLocationId
LEFT JOIN tblCTBook b on b.intBookId = (select top 1 intBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
LEFT JOIN tblCTSubBook sb on sb.intSubBookId = (select top 1 intSubBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
LEFT JOIN tblCTBook b1 on b1.intBookId = (select top 1 intBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
LEFT JOIN tblCTSubBook sb1 on sb1.intSubBookId = (select top 1 intSubBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
where isnull(ch.ysnMultiplePriceFixation,0) = 1
)tbl
INNER JOIN tblCTContractDetail CDD ON CDD.intContractDetailId = tbl.intContractDetailId
INNER JOIN vyuCTGridContractDetail vCD ON vCD.intContractDetailId = tbl.intContractDetailId
INNER JOIN tblRKFutureMarket M ON M.intFutureMarketId = vCD.intFutureMarketId
INNER JOIN tblCTContractHeader CHD ON CHD.intContractHeaderId = tbl.intContractHeaderId
LEFT JOIN tblCTPriceFixation PF on PF.intContractDetailId = CDD.intContractDetailId
LEFT JOIN tblCTPriceFixationDetail PFD on PFD.intPriceFixationId = PF.intPriceFixationId