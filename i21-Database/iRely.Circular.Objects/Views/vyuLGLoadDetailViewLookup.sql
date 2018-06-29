CREATE VIEW [dbo].[vyuLGLoadDetailViewLookup]
AS
SELECT LoadDetail.intLoadDetailId 
	, LoadDetail.intItemId 
	, Item.strItemNo 
	, Item.strDescription AS strItemDescription 
	, LoadDetail.dblQuantity 
	, LoadDetail.intItemUOMId 
	, strItemUOM = UOM.strUnitMeasure 
	, LoadDetail.dblGross 	
	, LoadDetail.dblTare 
	, LoadDetail.dblNet 
	, LoadDetail.intWeightItemUOMId 
	, LoadDetail.dblDeliveredQuantity 
	, LoadDetail.dblDeliveredGross
	, LoadDetail.dblDeliveredTare
	, LoadDetail.dblDeliveredNet
	, LoadDetail.intPSubLocationId  
	, PCLSL.strSubLocationName AS strPSubLocationName 
	, strWeightItemUOM = WeightUOM.strUnitMeasure 
	, LoadDetail.intVendorEntityId 
	, dblItemUOMCF = ItemUOM.dblUnitQty  

-- Vendor Info
	, strVendor = VEN.strName 
	, LoadDetail.intVendorEntityLocationId
	, strVendorNo = VEN.strEntityNo
	, strVendorEmail = VEN.strEmail
	, strVendorFax = VEN.strFax
	, strVendorMobile = VEN.strMobile
	, strVendorPhone = VEN.strPhone
	, LoadDetail.intPContractDetailId 
	, intPContractHeaderId = PDetail.intContractHeaderId 
	, intPCommodityId = PHeader.intCommodityId 
	, strPContractNumber = PHeader.strContractNumber 
	, intPContractSeq = PDetail.intContractSeq  
	, intPLifeTime = IM.intLifeTime 
	, strPLifeTimeType = IM.strLifeTimeType 
	, strVendorContract = PHeader.strCustomerContract
	, dblPCashPrice = AD.dblSeqPrice 
	, ysnPLoad = PHeader.ysnLoad
	, dblPQuantityPerLoad = PDetail.dblQuantityPerLoad
	, intPNoOfLoads = PDetail.intNoOfLoad
	, strPCostUOM = AD.strSeqPriceUOM 
	, intPCostUOMId = AD.intSeqPriceUOMId 
	, dblPCostUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM WHERE ItemUOM.intItemUOMId = PDetail.intPriceItemUOMId),0) 
	, intPStockUOM = ISNULL(oPStockUOM.intItemUOMId,0) 
	, strPStockUOM = oPStockUOM.strUnitMeasure 
	, strPStockUOMType = oPStockUOM.strUnitType 
	, dblPStockUOMCF = ISNULL(oPStockUOM.dblUnitQty,0) 
	, strPCurrency = AD.strSeqCurrency 
	, strPMainCurrency = ISNULL(AD.strSeqCurrency,CY.strCurrency) 
	, ysnPSubCurrency = AD.ysnSeqSubCurrency  
	, dblPMainCashPrice = PDetail.dblCashPrice / CASE WHEN ISNULL(CU.intCent,0) = 0 THEN 1 ELSE CU.intCent END 
	, dblPFranchise = CASE WHEN PWG.dblFranchise > 0 THEN PWG.dblFranchise / 100 ELSE 0 END 

-- Inbound Company Location
	, LoadDetail.intPCompanyLocationId

-- Customer Info
	, LoadDetail.intCustomerEntityId
	, LoadDetail.intCustomerEntityLocationId

-- Schedule, Load Directions
	, LoadDetail.strScheduleInfoMsg
	, LoadDetail.ysnUpdateScheduleInfo
	, LoadDetail.ysnPrintScheduleInfo
	, LoadDetail.strLoadDirectionMsg
	, LoadDetail.ysnUpdateLoadDirections
	, LoadDetail.ysnPrintLoadDirections
	, Item.strLotTracking  

-- Load Header
	, Load.intLoadId 
	, Load.intConcurrencyId
	, Load.strLoadNumber 
	, Load.intPurchaseSale 
	, Load.intEquipmentTypeId
	, Load.intHaulerEntityId
	, Load.intTicketId
	, Load.intGenerateLoadId
	, Load.intUserSecurityId
	, Load.intTransportLoadId
	, Load.intLoadHeaderId
	, Load.intDriverEntityId
	, Load.intDispatcherId
	, Load.strExternalLoadNumber
	, strType = CASE WHEN Load.intPurchaseSale = 1 THEN 'Inbound'
					ELSE CASE WHEN Load.intPurchaseSale = 2 THEN 'Outbound' 
							ELSE 'Drop Ship' END END 
	, intGenerateSequence = Load.intGenerateSequence
	, Load.dtmScheduledDate 
	, ysnInProgress = IsNull(Load.ysnInProgress, 0)
	, Load.dtmDeliveredDate
	, Load.strCustomerReference
	, Load.strTruckNo
	, Load.strTrailerNo1
	, Load.strTrailerNo2
	, Load.strTrailerNo3
	, Load.strComments
	, ysnDispatched = CASE WHEN Load.ysnDispatched = 1 THEN CAST(1 AS bit) ELSE CAST(0 AS Bit) END
	, Load.dtmDispatchedDate
	, Load.ysnDispatchMailSent
	, Load.dtmDispatchMailSent
	, Load.dtmCancelDispatchMailSent
	, Load.intCompanyLocationId 
	, Load.intTransUsedBy  
	, strTransUsedBy = CASE WHEN Load.intTransUsedBy = 1 THEN 'None'
							WHEN Load.intTransUsedBy = 2 THEN 'Scale Ticket'
							WHEN Load.intTransUsedBy = 3 THEN 'Transport Load' END
	, Load.intSourceType 
	, Load.ysnPosted 
	, LoadDetail.intNumberOfContainers

	,intForexRateTypeId		= PDetail.intRateTypeId 
	,strForexRateType		= RT.strCurrencyExchangeRateType 
	,dblForexRate			= PDetail.dblRate 
	,FreightTerms.intFreightTermId 
	,FreightTerms.strFreightTerm 

FROM tblLGLoadDetail LoadDetail
	JOIN tblLGLoad [Load] ON [Load].intLoadId = LoadDetail.intLoadId
	LEFT JOIN tblICItem Item On Item.intItemId = LoadDetail.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = LoadDetail.intWeightItemUOMId
	LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = WeightItemUOM.intUnitMeasureId
	LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = LoadDetail.intVendorEntityId
	LEFT JOIN tblCTContractDetail PDetail ON PDetail.intContractDetailId = LoadDetail.intPContractDetailId
	LEFT JOIN tblCTContractHeader PHeader ON PHeader.intContractHeaderId = PDetail.intContractHeaderId
	LEFT JOIN tblICItem	IM ON IM.intItemId = PDetail.intItemId
	CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(PDetail.intContractDetailId) AD
	LEFT JOIN tblSMCurrency	CU ON CU.intCurrencyID = PDetail.intCurrencyId			
	LEFT JOIN tblSMCurrency	CY ON CY.intCurrencyID = CU.intMainCurrencyId		
	LEFT JOIN tblSMUserSecurity US ON US.[intEntityId]	= Load.intDispatcherId
	LEFT JOIN tblCTWeightGrade PWG ON PWG.intWeightGradeId = PHeader.intWeightId
	LEFT JOIN tblSMCompanyLocationSubLocation PCLSL ON PCLSL.intCompanyLocationSubLocationId = LoadDetail.intPSubLocationId
	LEFT JOIN tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=	PDetail.intRateTypeId	
	OUTER APPLY (
		SELECT TOP 1 intItemUOMId, strUnitMeasure, strUnitType, dblUnitQty
		FROM tblICItemUOM ItemUOM 
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = PDetail.intItemUOMId
	) oPStockUOM
	LEFT JOIN tblSMFreightTerms FreightTerms
		ON FreightTerms.intFreightTermId = [Load].intFreightTermId