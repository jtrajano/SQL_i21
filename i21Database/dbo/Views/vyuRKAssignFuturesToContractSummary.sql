CREATE VIEW vyuRKAssignFuturesToContractSummary
AS
SELECT 
		cs.intAssignFuturesToContractSummaryId,
		ch.strContractNumber,
		ch.strContractType,  
		cd.intContractSeq,
		m.strFutMarketName CTFutureMarketName,
		mo.strFutureMonth CTFutureMonthName,
		ch.strCommodityCode CTCommodityCode,
		cl.strLocationName CTLocationName,
		b.strBook CTBook,
		sb.strSubBook CTSubBook,
		cs.dtmMatchDate,
		cs.intAssignedLots,
		cs.intHedgedLots,
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
		,sb1.strSubBook,cd.intContractDetailId,ch.intContractHeaderId,
		fot.intFutOptTransactionId,
		cs.ysnIsHedged		
FROM tblRKAssignFuturesToContractSummary cs
JOIN vyuCTContractHeaderView ch on ch.intContractHeaderId= cs.intContractHeaderId
JOIN tblCTContractDetail cd ON ch.intContractHeaderId  = cd.intContractHeaderId and cs.intContractDetailId=cd.intContractDetailId       
JOIN tblRKFutureMarket m on cd.intFutureMarketId=m.intFutureMarketId
JOIN tblRKFuturesMonth mo on cd.intFutureMonthId=mo.intFutureMonthId
JOIN tblSMCompanyLocation   cl ON cl.intCompanyLocationId  = cd.intCompanyLocationId
JOIN tblRKFutOptTransaction fot on fot.intFutOptTransactionId=cs.intFutOptTransactionId 
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=fot.intFutureMarketId
JOIN tblRKFuturesMonth fmh on fot.intFutureMonthId=fmh.intFutureMonthId  
JOIN tblEntity e on fot.intEntityId=e.intEntityId
JOIN tblICCommodity c on fot.intCommodityId=c.intCommodityId
JOIN tblSMCompanyLocation scl on scl.intCompanyLocationId=fot.intLocationId
LEFT JOIN tblCTBook b on cd.intBookId=b.intBookId
LEFT JOIN tblCTSubBook sb on cd.intSubBookId=sb.intSubBookId 
LEFT JOIN tblCTBook b1 on fot.intBookId=b1.intBookId
LEFT JOIN tblCTSubBook sb1 on fot.intSubBookId=sb.intSubBookId 

