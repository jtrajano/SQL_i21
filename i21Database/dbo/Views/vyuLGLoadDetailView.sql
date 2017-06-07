CREATE VIEW vyuLGLoadDetailView
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
	, SCLSL.strSubLocationName AS strSSubLocationName
	, strWeightItemUOM = WeightUOM.strUnitMeasure
	, LoadDetail.intVendorEntityId
	, dblItemUOMCF = ItemUOM.dblUnitQty
	, intContractTypeId = CASE WHEN Load.intPurchaseSale IN (1,3) THEN 1 ELSE 2 END

-- Vendor Info
	, strVendor = VEN.strName
	, LoadDetail.intVendorEntityLocationId
	, strShipFrom = VEL.strLocationName
	, strShipFromAddress = VEL.strAddress
	, strShipFromCity = VEL.strCity
	, strShipFromCountry = VEL.strCountry
	, strShipFromState = VEL.strState
	, strShipFromZipCode = VEL.strZipCode
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
	, strPCostUOM = AD.strSeqPriceUOM
	, intPCostUOMId = AD.intSeqPriceUOMId
	, dblPCostUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM WHERE ItemUOM.intItemUOMId = PDetail.intPriceItemUOMId),0)
	, ysnPLoad = PHeader.ysnLoad
	, dblPQuantityPerLoad = PDetail.dblQuantityPerLoad
	, intPNoOfLoads = PDetail.intNoOfLoad
	, intPStockUOM = ISNULL((SELECT TOP 1 intItemUOMId FROM tblICItemUOM ItemUOM WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = PDetail.intItemUOMId),0)
	, strPStockUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = PDetail.intItemUOMId)
	, strPStockUOMType = (SELECT TOP 1 strUnitType FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = PDetail.intItemUOMId)
	, dblPStockUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = PDetail.intItemUOMId),0)
	, strPCurrency = AD.strSeqCurrency
	, strPMainCurrency = CY.strCurrency
	, ysnPSubCurrency = AD.ysnSeqSubCurrency
	, dblPMainCashPrice = PDetail.dblCashPrice / CASE WHEN ISNULL(CU.intCent,0) = 0 THEN 1 ELSE CU.intCent END
	, dblPFranchise = CASE WHEN PWG.dblFranchise > 0 THEN PWG.dblFranchise / 100 ELSE 0 END

-- Inbound Company Location
	, LoadDetail.intPCompanyLocationId
	, strPLocationName = PCL.strLocationName
	, strPLocationAddress = PCL.strAddress
	, strPLocationCity = PCL.strCity
	, strPLocationCountry = PCL.strCountry
	, strPLocationState = PCL.strStateProvince
	, strPLocationZipCode = PCL.strZipPostalCode
	, strPLocationMail = PCL.strEmail
	, strPLocationFax = PCL.strFax
	, strPLocationPhone = PCL.strPhone

-- Customer Info
	, LoadDetail.intCustomerEntityId
	, strCustomer = CEN.strName
	, LoadDetail.intCustomerEntityLocationId
	, strShipTo = CEL.strLocationName
	, strShipToAddress = CEL.strAddress
	, strShipToCity = CEL.strCity
	, strShipToCountry = CEL.strCountry
	, strShipToState = CEL.strState
	, strShipToZipCode = CEL.strZipCode
	, strCustomerNo = CEN.strEntityNo
	, strCustomerEmail = CEN.strEmail
	, strCustomerFax = CEN.strFax
	, strCustomerMobile = CEN.strMobile
	, strCustomerPhone = CEN.strPhone
	, LoadDetail.intSContractDetailId
	, intSContractHeaderId = SDetail.intContractHeaderId
	, strSContractNumber = SHeader.strContractNumber
	, intSContractSeq = SDetail.intContractSeq
	, intSCommodityId = SHeader.intCommodityId
	, intSLifeTime = IMS.intLifeTime
	, strSLifeTimeType = IMS.strLifeTimeType
	, strCustomerContract = SHeader.strCustomerContract
	, dblSCashPrice = ADS.dblSeqPrice
	, strSCostUOM = ADS.strSeqPriceUOM
	, intSCostUOMId = SDetail.intPriceItemUOMId
	, dblSCostUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM WHERE ItemUOM.intItemUOMId = SDetail.intPriceItemUOMId),0)
	, ysnSLoad = SHeader.ysnLoad
	, dblSQuantityPerLoad = SDetail.dblQuantityPerLoad
	, intSNoOfLoads = SDetail.intNoOfLoad
	, intSStockUOM = ISNULL((SELECT TOP 1 intItemUOMId FROM tblICItemUOM ItemUOM WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = SDetail.intItemUOMId),0)
	, strSStockUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = SDetail.intItemUOMId)
	, strSStockUOMType = (SELECT TOP 1 strUnitType FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = SDetail.intItemUOMId)
	, dblSStockUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = SDetail.intItemUOMId),0)
	, strSCurrency = CUS.strCurrency
	, strSMainCurrency = CUS.strCurrency
	, ysnSSubCurrency = ADS.ysnSeqSubCurrency
	, dblSMainCashPrice = SDetail.dblCashPrice / CASE WHEN ISNULL(CUS.intCent,0) = 0 THEN 1 ELSE CUS.intCent END
	, dblSFranchise = CASE WHEN SWG.dblFranchise > 0 THEN SWG.dblFranchise / 100 ELSE 0 END

-- Outbound Company Location
	, LoadDetail.intSCompanyLocationId
	, strSLocationName = SCL.strLocationName
	, strSLocationAddress = SCL.strAddress
	, strSLocationCity = SCL.strCity
	, strSLocationCountry = SCL.strCountry
	, strSLocationState = SCL.strStateProvince
	, strSLocationZipCode = SCL.strZipPostalCode
	, strSLocationMail = SCL.strEmail
	, strSLocationFax = SCL.strFax
	, strSLocationPhone = SCL.strPhone

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
	, intGenerateReferenceNumber = GLoad.intReferenceNumber
	, intGenerateSequence = Load.intGenerateSequence
	, intNumberOfLoads = GLoad.intNumberOfLoads
	, strHauler = Hauler.strName
	, Load.dtmScheduledDate
	, ysnInProgress = IsNull(Load.ysnInProgress, 0)
	, strScaleTicketNo = CASE WHEN IsNull(Load.intTicketId, 0) <> 0 THEN CAST(ST.strTicketNumber AS VARCHAR(100))
								ELSE CASE WHEN IsNull(Load.intLoadHeaderId, 0) <> 0 THEN TR.strTransaction
											ELSE NULL END END
	, Load.dtmDeliveredDate
	, strEquipmentType = EQ.strEquipmentType
	, strDriver = Driver.strName
	, strDispatcher = US.strUserName
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
	, intInboundTaxGroupId = VendorTax.intTaxGroupId
	, strInboundTaxGroup = VendorTax.strTaxGroup
	, intOutboundTaxGroupId = CustomerTax.intTaxGroupId
	, strOutboundTaxGroup = CustomerTax.strTaxGroup
	, strZipCode = VEL.strZipCode
	, strInboundPricingType = PPricingType.strPricingType
	, strOutboundPricingType = SPricingType.strPricingType
	, dblInboundAdjustment = ISNULL(PDetail.dblAdjustment, 0.000000)
	, dblOutboundAdjustment = ISNULL(SDetail.dblAdjustment, 0.000000)
	, strInboundIndexType = PIndex.strIndexType
	, strOutboundIndexType = SIndex.strIndexType
	, intInboundIndexRackPriceSupplyPointId = CASE WHEN ISNULL(PIndex.strIndexType, 0) = 'Fixed'
													THEN ISNULL(PSP.intRackPriceSupplyPointId, PSP.intSupplyPointId)
												WHEN ISNULL(PIndex.strIndexType, 0) != 'Fixed'
													THEN NULL
												END
	, intOutboundIndexRackPriceSupplyPointId  = CASE WHEN ISNULL(SIndex.strIndexType, 0) = 'Fixed'
														THEN ISNULL(SSP.intRackPriceSupplyPointId, SSP.intSupplyPointId)
													WHEN ISNULL(SIndex.strIndexType, 0) != 'Fixed'
														THEN NULL
													END
	, LoadDetail.intNumberOfContainers
FROM tblLGLoadDetail LoadDetail
JOIN tblLGLoad Load ON Load.intLoadId = LoadDetail.intLoadId
LEFT JOIN tblICItem Item On Item.intItemId = LoadDetail.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = LoadDetail.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = WeightItemUOM.intUnitMeasureId
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = Load.intGenerateLoadId
LEFT JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = LoadDetail.intPCompanyLocationId
LEFT JOIN tblSMCompanyLocation SCL ON SCL.intCompanyLocationId = LoadDetail.intSCompanyLocationId
LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = LoadDetail.intVendorEntityId
LEFT JOIN tblEMEntityLocation VEL ON VEL.intEntityLocationId = LoadDetail.intVendorEntityLocationId
LEFT JOIN tblSMTaxGroup VendorTax ON VendorTax.intTaxGroupId = VEL.intTaxGroupId
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LoadDetail.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LoadDetail.intCustomerEntityLocationId
LEFT JOIN tblSMTaxGroup CustomerTax ON CustomerTax.intTaxGroupId = CEL.intTaxGroupId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = Load.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = Load.intDriverEntityId
LEFT JOIN tblCTContractDetail PDetail ON PDetail.intContractDetailId = LoadDetail.intPContractDetailId
LEFT JOIN tblCTContractHeader PHeader ON PHeader.intContractHeaderId = PDetail.intContractHeaderId
LEFT JOIN tblCTPricingType PPricingType ON PPricingType.intPricingTypeId = PDetail.intPricingTypeId
LEFT JOIN tblCTIndex PIndex ON PIndex.intIndexId = PDetail.intIndexId
LEFT JOIN tblTRSupplyPoint PSP ON PSP.intEntityVendorId = PIndex.intVendorId AND PSP.intEntityLocationId = PIndex.intVendorLocationId
LEFT JOIN tblICItem	IM ON IM.intItemId = PDetail.intItemId
CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(PDetail.intContractDetailId) AD
LEFT JOIN tblSMCurrency	CU ON CU.intCurrencyID = PDetail.intCurrencyId			
LEFT JOIN tblSMCurrency	CY ON CY.intCurrencyID = CU.intMainCurrencyId		
LEFT JOIN tblCTContractDetail SDetail ON SDetail.intContractDetailId = LoadDetail.intSContractDetailId
LEFT JOIN tblCTContractHeader SHeader ON SHeader.intContractHeaderId = SDetail.intContractHeaderId
LEFT JOIN tblCTPricingType SPricingType ON SPricingType.intPricingTypeId = SDetail.intPricingTypeId
LEFT JOIN tblCTIndex SIndex ON SIndex.intIndexId = SDetail.intIndexId
LEFT JOIN tblTRSupplyPoint SSP ON SSP.intEntityVendorId = SIndex.intVendorId AND SSP.intEntityLocationId = SIndex.intVendorLocationId
LEFT JOIN tblICItem	IMS ON IMS.intItemId = SDetail.intItemId
CROSS APPLY	dbo.fnCTGetAdditionalColumnForDetailView(SDetail.intContractDetailId) ADS
LEFT JOIN tblSMCurrency	CUS ON CUS.intCurrencyID = SDetail.intCurrencyId			
LEFT JOIN tblSMCurrency	CYS ON CYS.intCurrencyID = CUS.intMainCurrencyId		
LEFT JOIN tblSCTicket ST ON ST.intTicketId = Load.intTicketId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = Load.intLoadHeaderId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = Load.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId	= Load.intDispatcherId
LEFT JOIN tblCTWeightGrade PWG ON PWG.intWeightGradeId = PHeader.intWeightId
LEFT JOIN tblCTWeightGrade SWG ON SWG.intWeightGradeId = SHeader.intWeightId
LEFT JOIN tblSMCompanyLocationSubLocation PCLSL ON PCLSL.intCompanyLocationSubLocationId = LoadDetail.intPSubLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SCLSL ON SCLSL.intCompanyLocationSubLocationId = LoadDetail.intSSubLocationId