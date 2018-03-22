CREATE VIEW [dbo].[vyuRKPositionByPeriodContDetView]
AS
SELECT
PT.strPricingType,CH.strContractType,	CH.strContractBasis,CD.dtmEndDate,	CD.dblBalance,MZ.strMarketZoneCode,CD.intCurrencyId,					
CH.intCommodityId,CD.intItemId,	PU.intUnitMeasureId AS	intPriceUnitMeasureId,CD.dblFutures,CD.dblCashPrice,CD.dblConvertedBasis dblBasis,CD.dblRate,				
CD.intContractDetailId,CD.intContractSeq,CD.intCompanyLocationId,IU.intUnitMeasureId,CD.intContractStatusId,CH.intContractHeaderId,CD.intPricingTypeId,CH.strCommodityCode,CL.strLocationName,CH.strContractNumber,IM.strItemNo	
,intCurrencyExchangeRateId			
FROM	tblCTContractDetail				CD	
JOIN	vyuCTContractHeaderView			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		
JOIN	tblSMCompanyLocation			CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId     LEFT		
JOIN	tblCTContractStatus				CS	ON	CS.intContractStatusId		=	CD.intContractStatusId		LEFT	
JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId			LEFT	
JOIN	tblARMarketZone					MZ	ON	MZ.intMarketZoneId			=	CD.intMarketZoneId			LEFT
JOIN	tblICItem						IM	ON	IM.intItemId				=	CD.intItemId				LEFT
JOIN	tblICItemUOM					PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId		LEFT	
JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId				=	CD.intItemUOMId	
WHERE CD.dblQuantity > isnull(CD.dblInvoicedQty,0)			