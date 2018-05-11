CREATE VIEW [dbo].[vyuGRGetSettleContracts]
AS
SELECT 
	 intContractTypeId					= CH.intContractTypeId
	,strContractType					= TP.strContractType
	,intContractHeaderId				= CH.intContractHeaderId 
	,intContractDetailId				= CD.intContractDetailId
	,strContractNumber					= CH.strContractNumber
	,intContractSeq						= CD.intContractSeq
	,intEntityId						= CH.intEntityId
	,strEntityName						= EY.strName
	,intItemId							= CD.intItemId
	,strItemNo							= IM.strItemNo
	,intCompanyLocationId				= CD.intCompanyLocationId
	,strLocationName					= CL.strLocationName
	,dblCashPrice						= CD.dblCashPrice
	,dblCashPriceInCommodityStockUOM	= dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,C1.intUnitMeasureId,PU.intUnitMeasureId,CD.dblCashPrice)
	,dblAvailableQty					= ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0)
	,dblAvailableQtyInCommodityStockUOM = dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,C1.intUnitMeasureId,ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0))
	,intPricingTypeId					= CD.intPricingTypeId
	,strPricingType						= PT.strPricingType
	,dtmStartDate						= CD.dtmStartDate
	,intContractStatusId				= CD.intContractStatusId
	,strContractStatus					= CS.strContractStatus
	,ysnUnlimitedQuantity				= CH.ysnUnlimitedQuantity
	,dblFutures							= CD.dblFutures
	,dblBasis							= CD.dblBasis
	,dblBasisInCommodityStockUOM		= dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,C1.intUnitMeasureId,BU.intUnitMeasureId,dblBasis)
	FROM	tblGRSettleContract			SSC
	JOIN    tblCTContractDetail			CD ON CD.intContractDetailId = SSC.intContractDetailId
	CROSS   JOIN	tblCTCompanyPreference			CP	
	JOIN	tblSMCompanyLocation		CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
	JOIN	tblEMEntity					EY	ON	EY.intEntityId				=	CH.intEntityId			
	JOIN	tblCTContractType			TP	ON	TP.intContractTypeId		=	CH.intContractTypeId		LEFT
	JOIN	tblICCommodity				CO	ON	CO.intCommodityId			=	CH.intCommodityId			LEFT			
	JOIN	tblCTContractStatus			CS	ON	CS.intContractStatusId		=	CD.intContractStatusId		LEFT	
	JOIN	tblCTPricingType			PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId			LEFT
	JOIN	tblICItem					IM	ON	IM.intItemId				=	CD.intItemId				LEFT
	JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId				=	CD.intItemUOMId				LEFT
	JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId		LEFT
	JOIN	tblICItemUOM				BU	ON	BU.intItemUOMId				=	CD.intBasisUOMId			LEFT
	JOIN	tblICCommodityUnitMeasure	C1	ON	C1.intCommodityId			=	CH.intCommodityId AND C1.intCommodityId=IM.intCommodityId AND C1.ysnStockUnit=1 
