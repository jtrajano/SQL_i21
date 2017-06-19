CREATE VIEW vyuRKRiskPositionContractDetail

as

SELECT	CT.strContractType,	CD.dblBalance,	CD.dblQuantity	AS	dblDetailQuantity,	CH.strContractNumber,
			CD.intContractSeq,	CD.dtmStartDate, 	EY.strEntityName,	CD.dblNoOfLots,		CH.intContractHeaderId, CD.intPricingTypeId,	
			CH.intCommodityId,	CD.intCompanyLocationId,	CD.intFutureMarketId, CD.intFutureMonthId,CD.intItemUOMId, CD.intItemId,IU.intUnitMeasureId,
			 MO.strFutureMonth,	CD.intContractStatusId,CD.intContractDetailId
			 ,CH.dblNoOfLots dblHeaderNoOfLots	,CH.ysnMultiplePriceFixation,CD.dblNoOfLots dblDetailNoOfLots,CT.intContractTypeId			
	FROM	tblCTContractHeader				CH	
	JOIN	tblCTContractDetail				CD	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		
	join	tblCTContractType				CT  ON  CT.intContractTypeId		=	CH.intContractTypeId		
	JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId				=	CD.intItemUOMId
	JOIN	vyuCTEntity						EY	ON	EY.intEntityId				=	CH.intEntityId			AND
										EY.strEntityType						=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	LEFT JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId		=	CD.intFutureMonthId			