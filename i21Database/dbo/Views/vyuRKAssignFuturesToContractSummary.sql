CREATE VIEW vyuRKAssignFuturesToContractSummary
			
AS

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
		fot.dtmCreateDateTime,
		strPricingStatus = CASE WHEN cd.intPricingStatus = 0 THEN 'Unpriced' WHEN cd.intPricingStatus = 1 THEN 'Partially Priced' WHEN cd.intPricingStatus = 2 THEN 'Priced' END
		, dblNoOfLots = CASE WHEN isnull(ch.ysnMultiplePriceFixation,0) = 1 THEN ISNULL(ch.dblNoOfLots, 0) ELSE ISNULL(cd.dblNoOfLots, 0) END
		, dblLotsPriced = CASE WHEN cd.intPricingTypeId = 1 THEN (cd.dblQuantity / m.dblContractSize) ELSE ISNULL(PFD.dblQuantity, 0) / m.dblContractSize END
		, dblLotsUnpriced = CASE WHEN cd.intPricingTypeId = 1 THEN 0 ELSE ((cd.dblQuantity - ISNULL(PFD.dblQuantity, 0)) / m.dblContractSize) END
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
LEFT JOIN tblCTSubBook sb1 on fot.intSubBookId=sb1.intSubBookId  
LEFT JOIN tblCTPriceFixation PF on PF.intContractDetailId = cd.intContractDetailId
LEFT JOIN tblCTPriceFixationDetail PFD on PFD.intPriceFixationId = PF.intPriceFixationId
where isnull(ch.ysnMultiplePriceFixation,0) = 0

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
		, strPricingStatus = CASE WHEN cd.intPricingStatus = 0 THEN 'Unpriced' WHEN cd.intPricingStatus = 1 THEN 'Partially Priced' WHEN cd.intPricingStatus = 2 THEN 'Priced' END
		, dblNoOfLots = ISNULL(ch.dblNoOfLots, 0)
		, dblLotsPriced = CASE WHEN cd.intPricingTypeId = 1 THEN (cd.dblQuantity / fm.dblContractSize) ELSE ISNULL(PFD.dblQuantity, 0) / fm.dblContractSize END
		, dblLotsUnpriced = CASE WHEN cd.intPricingTypeId = 1 THEN 0 ELSE ((cd.dblQuantity - ISNULL(PFD.dblQuantity, 0)) / fm.dblContractSize) END
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
JOIN tblCTContractDetail cd ON  cs.intContractDetailId=cd.intContractDetailId  
LEFT JOIN tblCTBook b on b.intBookId = (select top 1 intBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
LEFT JOIN tblCTSubBook sb on sb.intSubBookId = (select top 1 intSubBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
LEFT JOIN tblCTBook b1 on b1.intBookId = (select top 1 intBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
LEFT JOIN tblCTSubBook sb1 on sb1.intSubBookId = (select top 1 intSubBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
LEFT JOIN tblCTPriceFixation PF on PF.intContractDetailId = cd.intContractDetailId
LEFT JOIN tblCTPriceFixationDetail PFD on PFD.intPriceFixationId = PF.intPriceFixationId
where isnull(ch.ysnMultiplePriceFixation,0) = 1


