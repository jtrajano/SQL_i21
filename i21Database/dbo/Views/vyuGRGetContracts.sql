﻿CREATE VIEW [dbo].[vyuGRGetContracts]
AS
SELECT 
	 intContractTypeId					= CH.intContractTypeId
	,strContractType					= CT.strContractType
	,intContractHeaderId				= CH.intContractHeaderId 
	,intContractDetailId				= CD.intContractDetailId
	,strContractNumber					= CH.strContractNumber
	,intContractSeq						= CD.intContractSeq
	,intEntityId						= CH.intEntityId
	,strEntityName						= EM.strName
	,intItemId							= CD.intItemId
	,strItemNo							= Item.strItemNo
	,intCompanyLocationId				= CD.intCompanyLocationId
	,strLocationName					= CL.strLocationName
	,dblCashPrice						= AD.dblSeqPrice
	,dblCashPriceInCommodityStockUOM	= dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CUM.intUnitMeasureId,ItemUOM2.intUnitMeasureId,AD.dblSeqPrice)
	,dblAvailableQty					= ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0)
	,dblAvailableQtyInCommodityStockUOM = dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,ItemUOM1.intUnitMeasureId,CUM.intUnitMeasureId,ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0))
	,intPricingTypeId					= CD.intPricingTypeId
	,strPricingType						= PT.strPricingType
	,dtmStartDate						= CD.dtmStartDate
	,intContractStatusId				= CD.intContractStatusId
	,strContractStatus					= CS.strContractStatus
	,ysnUnlimitedQuantity				= CH.ysnUnlimitedQuantity
	,dblFutures							= CD.dblFutures
	,dblBasis							= CD.dblBasis
	,dblBasisInCommodityStockUOM		= dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CUM.intUnitMeasureId,ItemUOM3.intUnitMeasureId,dblBasis)
	,intContractUOMId					= AD.intSeqPriceUOMId
	,dblCostUnitQty						= ItemUOM2.dblUnitQty
	FROM tblCTContractDetail CD
	CROSS JOIN tblCTCompanyPreference CP	
	JOIN tblSMCompanyLocation CL 
		ON CL.intCompanyLocationId = CD.intCompanyLocationId
	JOIN tblCTContractHeader CH	
		ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblEMEntity EM	
		ON EM.intEntityId =	CH.intEntityId
	JOIN tblCTContractType CT
		ON CT.intContractTypeId	= CH.intContractTypeId 
	LEFT JOIN tblICCommodity CO	
		ON CO.intCommodityId = CH.intCommodityId
	LEFT JOIN tblCTContractStatus CS
		ON CS.intContractStatusId = CD.intContractStatusId
	LEFT JOIN tblCTPricingType PT
		ON PT.intPricingTypeId = CD.intPricingTypeId			
	LEFT JOIN tblICItem Item 
		ON Item.intItemId =	CD.intItemId
	LEFT JOIN tblICItemUOM ItemUOM1
		ON ItemUOM1.intItemUOMId = CD.intItemUOMId				
	LEFT JOIN tblICItemUOM ItemUOM2 
		ON ItemUOM2.intItemUOMId = CD.intPriceItemUOMId		
	LEFT JOIN tblICItemUOM ItemUOM3 
		ON ItemUOM3.intItemUOMId = CD.intBasisUOMId		
	LEFT JOIN tblICCommodityUnitMeasure	CUM	
		ON CUM.intCommodityId =	CH.intCommodityId
			AND CUM.intCommodityId = Item.intCommodityId 
			AND CUM.ysnStockUnit = 1
	CROSS APPLY fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
   WHERE CD.intPricingTypeId IN (1,2) 
     AND CD.intContractStatusId IN (1,4) 
	 AND ((ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0) > 0) OR CH.ysnUnlimitedQuantity = 1)
	 AND ((DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) >= DATEADD(dd,-ISNULL(CP.intEarlyDaysPurchase,0),CD.dtmStartDate) AND CH.intContractTypeId = 1) OR (DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) >= DATEADD(dd,-ISNULL(CP.intEarlyDaysSales,0),CD.dtmStartDate) AND CH.intContractTypeId = 2))