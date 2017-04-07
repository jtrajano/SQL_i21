CREATE VIEW vyuRKRiskPositionContractDetail

as

	SELECT	CH.strContractType,	CD.dblBalance,	CD.dblQuantity	AS	dblDetailQuantity,	CH.strContractNumber,
			CD.intContractSeq,	CD.dtmStartDate, 	CH.strEntityName,	CD.dblNoOfLots,		CH.intContractHeaderId, CD.intPricingTypeId,	
			CH.intCommodityId,	CD.intCompanyLocationId,	CD.intFutureMarketId, CD.intFutureMonthId,CD.intItemUOMId, CD.intItemId,IU.intUnitMeasureId,
			 MO.strFutureMonth,	CD.intContractStatusId,CD.intContractDetailId				
	FROM	tblCTContractDetail				CD		
	JOIN	vyuCTContractHeaderView			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		
	JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId			
	JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId				=	CD.intItemUOMId	