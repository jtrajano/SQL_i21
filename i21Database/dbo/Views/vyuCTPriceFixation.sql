CREATE VIEW vyuCTPriceFixation

AS

		SELECT	P.intPriceFixationId,
				D.intContractDetailId, 
				D.dblDetailQuantity,
				D.intItemUOMId,
				D.dtmStartDate,
				D.dtmEndDate,
				D.dblFutures,
				D.dblBasis,
				D.dblCashPrice,
				D.intFutureMarketId,
				D.intFutureMonthId,
				D.intContractOptHeaderId,
				D.intContractSeq,
				D.strContractType,
				D.strCommodityCode,
				D.strEntityName,
				D.intContractNumber,
				D.strLocationName,
				D.strPricingType,
				D.strFutureMonth,
				D.dblBalance
				
	FROM		tblCTPriceFixation P
	JOIN		vyuCTContractDetailView D ON D.intContractDetailId = P.intContractDetailId			