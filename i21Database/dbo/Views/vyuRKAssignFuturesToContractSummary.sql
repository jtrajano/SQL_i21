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
		strPricingStatus = CASE WHEN cd.intPricingTypeId = 2
								THEN CASE WHEN ISNULL(PF.dblTotalLots, 0) = 0  THEN 'Unpriced'
									ELSE CASE WHEN ISNULL(PF.dblTotalLots, 0) - ISNULL(AP.dblLotsFixed, 0) = 0 THEN 'Fully Priced' 
										WHEN ISNULL(AP.dblLotsFixed, 0) = 0  THEN 'Unpriced'
										ELSE 'Partially Priced' END END
									WHEN cd.intPricingTypeId = 1 THEN 'Priced' ELSE '' END	
		, dblNoOfLots = CASE WHEN isnull(ch.ysnMultiplePriceFixation,0) = 1 THEN ISNULL(ch.dblNoOfLots, 0) ELSE ISNULL(cd.dblNoOfLots, 0) END
		, dblLotsPriced = CASE WHEN cd.intPricingTypeId IN(1, 6) THEN ISNULL(ISNULL(cd.dblNoOfLots, AP.dblLotsFixed), 0) ELSE ISNULL(PF.dblLotsFixed, 0) END
		, dblLotsUnpriced = CASE WHEN cd.intPricingTypeId IN(1, 6) THEN 0 ELSE ISNULL(cd.dblNoOfLots - ISNULL(PF.dblLotsFixed, 0), 0) END
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
OUTER APPLY (
	SELECT TOP 1 A.intContractHeaderId
		, A.intContractDetailId
		, C.strApprovalStatus
		, A.dblLotsFixed
		FROM tblCTPriceFixation A
		LEFT JOIN tblSMTransaction C ON C.intRecordId = A.intPriceContractId AND C.strApprovalStatus IS NOT NULL 
		WHERE A.intContractHeaderId = ch.intContractHeaderId
			AND ISNULL(A.intContractDetailId, 0) = CASE WHEN ch.ysnMultiplePriceFixation = 1 THEN ISNULL(A.intContractDetailId, 0) ELSE ISNULL(cd.intContractDetailId, 0) END
		ORDER BY C.intTransactionId DESC) AP
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
		, strPricingStatus = CASE WHEN cd.intPricingTypeId = 2
									  THEN CASE WHEN ISNULL(PF.dblTotalLots, 0) = 0  THEN 'Unpriced'
										ELSE CASE WHEN ISNULL(PF.dblTotalLots, 0) - ISNULL(AP.dblLotsFixed, 0) = 0 THEN 'Fully Priced' 
												  WHEN ISNULL(AP.dblLotsFixed, 0) = 0  THEN 'Unpriced'
												  ELSE 'Partially Priced' END END
									  WHEN cd.intPricingTypeId = 1 THEN 'Priced' ELSE '' END	
		, dblNoOfLots = ISNULL(ch.dblNoOfLots, 0)
		, dblLotsPriced = CASE WHEN cd.intPricingTypeId IN(1, 6) THEN ISNULL(ISNULL(ch.dblNoOfLots, AP.dblLotsFixed), 0)
								ELSE ISNULL(PF.dblLotsFixed, 0) END
		, dblLotsUnpriced = CASE WHEN cd.intPricingTypeId IN(1, 6) THEN 0
								ELSE ISNULL(ch.dblNoOfLots - ISNULL(PF.dblLotsFixed, 0), 0) END
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
CROSS APPLY (
	SELECT TOP 1 intContractDetailId, intPricingStatus, intPricingTypeId, dblQuantity  FROM tblCTContractDetail
) cd
LEFT JOIN tblCTBook b on b.intBookId = (select top 1 intBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
LEFT JOIN tblCTSubBook sb on sb.intSubBookId = (select top 1 intSubBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
LEFT JOIN tblCTBook b1 on b1.intBookId = (select top 1 intBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
LEFT JOIN tblCTSubBook sb1 on sb1.intSubBookId = (select top 1 intSubBookId from tblCTContractDetail cd where cd.intContractHeaderId=ch.intContractHeaderId)
LEFT JOIN tblCTPriceFixation PF on PF.intContractDetailId = cd.intContractDetailId
LEFT JOIN tblCTPriceFixationDetail PFD on PFD.intPriceFixationId = PF.intPriceFixationId
OUTER APPLY (
	SELECT TOP 1 A.intContractHeaderId
				, A.intContractDetailId
				, C.strApprovalStatus
				, A.dblLotsFixed
	FROM tblCTPriceFixation A
	LEFT JOIN tblSMTransaction C ON C.intRecordId = A.intPriceContractId AND C.strApprovalStatus IS NOT NULL 
	WHERE A.intContractHeaderId = ch.intContractHeaderId
		AND ISNULL(A.intContractDetailId, 0) = CASE WHEN ch.ysnMultiplePriceFixation = 1 THEN ISNULL(A.intContractDetailId, 0) ELSE ISNULL(cd.intContractDetailId, 0) END
	ORDER BY C.intTransactionId DESC
) AP
where isnull(ch.ysnMultiplePriceFixation,0) = 1


