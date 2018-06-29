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
			,CAST(ISNULL(CD.intNoOfLoad,0) - ISNULL(CD.dblBalanceLoad,0) AS INT) AS	intLoadReceived
			,CD.dblBalance
			,ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0) AS dblAvailableQty
			,PT.strPricingType
			,CD.intContractSeq
			,ISNULL(CD.dblQuantityPerLoad, 0) AS dblQuantityPerLoad
	FROM	tblCTContractDetail				CD	
	CROSS APPLY tblCTCompanyPreference			CP	
	LEFT JOIN	vyuCTContractHeaderView			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId				
	LEFT JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId					
	LEFT JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId				=	CD.intItemUOMId				
	LEFT JOIN	tblICUnitMeasure				U1	ON	U1.intUnitMeasureId			=	IU.intUnitMeasureId			
