CREATE VIEW [dbo].[vyuCTCompactContractDetailView]
AS
	SELECT	CD.intContractHeaderId
			,CD.intContractDetailId
			,CH.strContractNumber
			,CH.dtmContractDate
			,U1.strUnitMeasure	AS	strItemUOM
			,CH.ysnLoad
			,CD.intNoOfLoad
			,CD.dblQuantity AS	dblDetailQuantity
			,CAST(ISNULL(CD.intNoOfLoad,0) - ISNULL(CD.dblBalance,0) AS INT) AS	intLoadReceived
			,CD.dblBalance
			,ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0) AS dblAvailableQty
			,PT.strPricingType
			,CD.intContractSeq
			,ISNULL(CD.dblQuantityPerLoad, 0) AS dblQuantityPerLoad
			,CD.strERPPONumber
			,CD.strERPItemNumber
			,strOrigin = ISNULL(RY.strCountry,OG.strCountry)
	FROM	tblCTContractDetail					CD	
	CROSS APPLY tblCTCompanyPreference			CP	
	LEFT JOIN	tblCTContractHeader				CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId				
	LEFT JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId					
	LEFT JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId				=	CD.intItemUOMId				
	LEFT JOIN	tblICUnitMeasure				U1	ON	U1.intUnitMeasureId			=	IU.intUnitMeasureId			
	LEFT JOIN	tblICItem						IM	ON	IM.intItemId				=	CD.intItemId				--strItemNo
	LEFT JOIN	tblICItemContract				IC	ON	IC.intItemContractId		=	CD.intItemContractId		--strContractItemName
	LEFT JOIN	tblSMCountry					RY	ON	RY.intCountryID				=	IC.intCountryId
	LEFT JOIN	tblICCommodityAttribute			CA	ON	CA.intCommodityAttributeId  =	IM.intOriginId												
														AND	CA.strType				=	'Origin'			
	LEFT JOIN	tblSMCountry					OG	ON	OG.intCountryID				=	CA.intCountryID	
