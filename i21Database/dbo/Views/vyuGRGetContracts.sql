CREATE VIEW [dbo].[vyuGRGetContracts]
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
	,dblPartialCashPrice				= AD.dblSeqPartialPrice
	,dblCashPriceInItemStockUOM			= dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM.intItemUOMId, CD.intPriceItemUOMId, AD.dblSeqPrice)
	,dblAvailableQty					= ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0)
	,dblAvailableQtyInItemStockUOM		= dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, ItemUOM.intItemUOMId, (ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0)))
	,dblFutures							= CD.dblFutures
	,dblBasis							= CD.dblBasis
	,dblBasisInItemStockUOM				= dbo.fnCTConvertQtyToTargetItemUOM(ItemUOM.intItemUOMId, CD.intBasisUOMId, CD.dblBasis)
	,intPricingTypeId					= CD.intPricingTypeId
	,strPricingType						= PT.strPricingType
	,dtmStartDate						= CD.dtmStartDate
	,intContractStatusId				= CD.intContractStatusId
	,strContractStatus					= CS.strContractStatus
	,ysnUnlimitedQuantity				= CH.ysnUnlimitedQuantity	
	,intContractUOMId					= AD.intSeqPriceUOMId
	,dblCostUnitQty						= dbo.fnCTConvertQtyToTargetItemUOM(CD.intPriceItemUOMId, ItemUOM.intItemUOMId, 1)
	,ysnIsAllowedToShow					= CAST(CASE WHEN CD.intContractStatusId IN (1,4) THEN 1 ELSE 0 END AS BIT)
	,ysnIsPricedOrBasis					= CAST(CASE 
													WHEN (SELECT ysnApplyScaleToBasis FROM tblCTCompanyPreference ) = 0 THEN 
														CASE 
															WHEN CD.intPricingTypeId IN (1,6) THEN 1 
															ELSE 0 
														END 
													ELSE
														CASE 
															WHEN CD.intPricingTypeId IN (1,2,6) THEN 1 
															ELSE 0 
														END
												END 
										AS BIT) --added Cash pricing type (GRN-1336)
	,ysnIsAvailable						= CAST(
												CASE 
													WHEN (ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0) > 0) THEN 1
													WHEN CH.ysnUnlimitedQuantity = 1 THEN 1 
													ELSE 0 
												END 
												AS BIT
											)
	,ysnEarlyDayPassed					= CAST(
												CASE
													WHEN DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) >= DATEADD(dd,-ISNULL(CP.intEarlyDaysPurchase,0),CD.dtmStartDate) AND CH.intContractTypeId = 1 THEN 1
													WHEN DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) >= DATEADD(dd,-ISNULL(CP.intEarlyDaysSales,0),CD.dtmStartDate) AND CH.intContractTypeId = 2 THEN 1
													ELSE 0
												END 
												AS BIT
											)
	,FT.strFreightTerm
	,CD.dtmEndDate
	,intGetContractDetailFutureMonthId = CD.intFutureMonthId
	,ysnLoad = ISNULL(CH.ysnLoad,0)
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
LEFT JOIN tblCTContractStatus CS
	ON CS.intContractStatusId = CD.intContractStatusId
LEFT JOIN tblCTPricingType PT
	ON PT.intPricingTypeId = CD.intPricingTypeId			
LEFT JOIN tblICItem Item 
	ON Item.intItemId =	CD.intItemId
LEFT JOIN tblICItemUOM ItemUOM
	ON ItemUOM.intItemId = Item.intItemId
		AND ItemUOM.ysnStockUnit = 1
LEFT JOIN tblSMFreightTerms FT
	ON FT.intFreightTermId = ISNULL(CD.intFreightTermId,CH.intFreightTermId)
CROSS APPLY fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD

