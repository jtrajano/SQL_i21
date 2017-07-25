CREATE VIEW [dbo].[vyuGRGetContracts]
AS
SELECT 
	 CH.intContractTypeId
	,TP.strContractType
	,CH.intContractHeaderId 
	,CD.intContractDetailId
	,CH.strContractNumber
	,CD.intContractSeq
	,CH.intEntityId
	,EY.strName AS strEntityName
	,CD.intItemId
	,IM.strItemNo
	,CD.intCompanyLocationId
	,CL.strLocationName
	,CD.dblCashPrice
	,dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,PU.intUnitMeasureId,CD.dblCashPrice) AS dblCashPriceInCommodityStockUOM
	,ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0) AS dblAvailableQty
	,dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,C1.intUnitMeasureId,ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0)) AS dblAvailableQtyInCommodityStockUOM	
	,CD.intPricingTypeId
	,PT.strPricingType
	,CD.dtmStartDate
	,CD.intContractStatusId
	,CS.strContractStatus
	,CH.ysnUnlimitedQuantity
	,CD.dblFutures
	,CD.dblBasis
	,dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,QU.intUnitMeasureId,BU.intUnitMeasureId,dblBasis) AS dblBasisInCommodityStockUOM
	FROM	tblCTContractDetail			CD
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
	JOIN	tblICItemUOM				BU	ON	BU.intItemUOMId				=	CD.intBasisUOMId		LEFT
	JOIN	tblICCommodityUnitMeasure	C1	ON	C1.intCommodityId			=	CH.intCommodityId
			AND C1.intCommodityId=IM.intCommodityId AND C1.ysnStockUnit=1    
   WHERE CD.intPricingTypeId IN (1,2) 
     AND CD.intContractStatusId IN (1,4) 
	 AND ((ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0)>0) OR CH.ysnUnlimitedQuantity=1)
	 AND ((DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) >= DATEADD(dd,-ISNULL(CP.intEarlyDaysPurchase,0),CD.dtmStartDate) AND CH.intContractTypeId = 1) OR (DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) >= DATEADD(dd,-ISNULL(CP.intEarlyDaysSales,0),CD.dtmStartDate) AND CH.intContractTypeId = 2))

