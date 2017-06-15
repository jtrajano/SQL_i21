CREATE VIEW vyuRKM2MGetContractDetailView
AS

Select 
CH.intCommodityUOMId intCommodityUnitMeasureId,
CL.strLocationName,
CY.strDescription strCommodityDescription,
CU.intMainCurrencyId,
CU.intCent,
CD.dblQuantity AS	dblDetailQuantity,
CH.intContractTypeId,
CH.intContractHeaderId,
TP.strContractType strContractType,
CH.strContractNumber,
EY.strEntityName strEntityName,
CH.intEntityId,	
CY.strCommodityCode,
CH.intCommodityId,
PO.strPosition strPosition,
CH.dtmContractDate,	
CH.intContractBasisId,
CD.intContractSeq,
CD.dtmStartDate,	
CD.dtmEndDate,
CD.intPricingTypeId,
CD.dblBasis,
CD.dblFutures,
CD.intContractStatusId,	
CD.dblCashPrice,
CD.intContractDetailId,	
CD.intFutureMarketId,
CD.intFutureMonthId,
CD.intItemId,
CD.dblBalance,
CD.intCurrencyId,		
CD.dblRate,
CD.intMarketZoneId,	
CD.dtmPlannedAvailabilityDate,
IM.strItemNo,
PT.strPricingType,
PU.intUnitMeasureId	AS	intPriceUnitMeasureId,	
IU.intUnitMeasureId,
MO.strFutureMonth,
FM.strFutMarketName,
IM.intOriginId,
IM.strLotTracking,
CD.dblNoOfLots
,CAST(ISNULL(CU.intMainCurrencyId,0) AS BIT) AS	ysnSubCurrency,
	CD.intCompanyLocationId,	
	MO.ysnExpired,
CASE	WHEN	CD.intPricingTypeId = 2
		THEN	CASE	WHEN	ISNULL(PF.[dblTotalLots],0) = 0 
						THEN	'Unpriced'
				ELSE
						CASE	WHEN ISNULL(PF.[dblTotalLots],0)-ISNULL([dblLotsFixed],0) = 0
									THEN 'Fully Priced' 
								WHEN ISNULL([dblLotsFixed],0) = 0 
									THEN 'Unpriced'
								ELSE 'Partially Priced' 
						END
				END
					
		WHEN	CD.intPricingTypeId = 1
				THEN	'Priced'
		ELSE	''
END		AS strPricingStatus

FROM	tblCTContractHeader			CH	
	JOIN	tblCTContractDetail				CD	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		and intContractStatusId not in(2,3,6) 
	JOIN	tblICCommodity					CY	ON	CY.intCommodityId					=		CH.intCommodityId	
	JOIN	tblCTContractType				TP	ON	TP.intContractTypeId				=		CH.intContractTypeId
	JOIN	vyuCTEntity						EY	ON	EY.intEntityId						=		CH.intEntityId			AND
														EY.strEntityType					=		(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)	
	JOIN	tblICItem						IM	ON	IM.intItemId				=	CD.intItemId				
	JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId				=	CD.intItemUOMId	
	JOIN	tblSMCompanyLocation			CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId 
	JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId			
	JOIN	tblSMCurrency					CU	ON	CU.intCurrencyID			=	CD.intCurrencyId					
	JOIN	tblICItemUOM					PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId	
	LEFT JOIN	tblCTPosition					PO	ON	PO.intPositionId					=		CH.intPositionId		
	LEFT JOIN	tblRKFutureMarket				FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId		
	LEFT JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId					
	LEFT JOIN	tblCTPriceFixation				PF	ON	PF.intContractDetailId		=	CD.intContractDetailId	

