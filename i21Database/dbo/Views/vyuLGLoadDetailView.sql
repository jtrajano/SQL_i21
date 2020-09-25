CREATE VIEW vyuLGLoadDetailView
AS
SELECT LD.intLoadDetailId
	, LD.intItemId
	, Item.strItemNo
	, Item.strDescription AS strItemDescription
	, LD.dblQuantity
	, LD.intItemUOMId
	, strItemUOM = UOM.strUnitMeasure
	, LD.dblGross
	, LD.dblTare
	, LD.dblNet
	, LD.intWeightItemUOMId
	, LD.dblDeliveredQuantity
	, LD.dblDeliveredGross
	, LD.dblDeliveredTare
	, LD.dblDeliveredNet
	, LD.intPSubLocationId
	, PCLSL.strSubLocationName AS strPSubLocationName
	, SCLSL.strSubLocationName AS strSSubLocationName
	, strWeightItemUOM = WeightUOM.strUnitMeasure
	, LD.intVendorEntityId
	, dblItemUOMCF = ItemUOM.dblUnitQty
	, intContractTypeId = CASE WHEN L.intPurchaseSale IN (1,3) THEN 1 ELSE 2 END

-- Vendor Info
	, strVendor = VEN.strName
	, LD.intVendorEntityLocationId
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
	, LD.intPContractDetailId
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
	, LD.intPCompanyLocationId
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
	, LD.intCustomerEntityId
	, strCustomer = CEN.strName
	, LD.intCustomerEntityLocationId
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
	, LD.intSContractDetailId
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
	, LD.intSCompanyLocationId
	, strSLocationName = SCL.strLocationName
	, strSLocationAddress = SCL.strAddress
	, strSLocationCity = SCL.strCity
	, strSLocationCountry = SCL.strCountry
	, strSLocationState = SCL.strStateProvince
	, strSLocationZipCode = SCL.strZipPostalCode
	, strSLocationMail = SCL.strEmail
	, strSLocationFax = SCL.strFax
	, strSLocationPhone = SCL.strPhone

-- Schedule, L Directions
	, LD.strScheduleInfoMsg
	, LD.ysnUpdateScheduleInfo
	, LD.ysnPrintScheduleInfo
	, LD.strLoadDirectionMsg
	, LD.ysnUpdateLoadDirections
	, LD.ysnPrintLoadDirections
	, Item.strLotTracking

-- Load Header
	, L.intLoadId
	, L.intConcurrencyId
	, L.strLoadNumber
	, L.intPurchaseSale
	, L.intEquipmentTypeId
	, L.intHaulerEntityId
	, L.intTicketId
	, L.intGenerateLoadId
	, L.intUserSecurityId
	, L.intTransportLoadId
	, L.intLoadHeaderId
	, L.intDriverEntityId
	, L.intDispatcherId
	, L.strExternalLoadNumber
	, strType = CASE WHEN L.intPurchaseSale = 1 THEN 'Inbound'
					ELSE CASE WHEN L.intPurchaseSale = 2 THEN 'Outbound' 
							ELSE 'Drop Ship' END END COLLATE Latin1_General_CI_AS
	, intGenerateReferenceNumber = GLoad.intReferenceNumber
	, intGenerateSequence = L.intGenerateSequence
	, intNumberOfLoads = GLoad.intNumberOfLoads
	, strHauler = Hauler.strName
	, L.dtmScheduledDate
	, ysnInProgress = IsNull(L.ysnInProgress, 0)
	, strScaleTicketNo = CASE WHEN IsNull(L.intTicketId, 0) <> 0 THEN CAST(ST.strTicketNumber AS VARCHAR(100))
								ELSE CASE WHEN IsNull(L.intLoadHeaderId, 0) <> 0 THEN TR.strTransaction
											ELSE NULL END END
	, L.dtmDeliveredDate
	, strEquipmentType = EQ.strEquipmentType
	, strDriver = Driver.strName
	, strDispatcher = US.strUserName
	, L.strCustomerReference
	, L.strTruckNo
	, L.strTrailerNo1
	, L.strTrailerNo2
	, L.strTrailerNo3
	, L.strCarNumber
	, L.strEmbargoNo
	, L.strEmbargoPermitNo
	, L.strComments
	, L.strBOLInstructions
	, ysnDispatched = CASE WHEN L.ysnDispatched = 1 THEN CAST(1 AS bit) ELSE CAST(0 AS Bit) END
	, L.dtmDispatchedDate
	, L.ysnDispatchMailSent
	, L.dtmDispatchMailSent
	, L.dtmCancelDispatchMailSent
	, L.intCompanyLocationId
	, L.intTransUsedBy
	, strTransUsedBy = CASE WHEN L.intTransUsedBy = 1 THEN 'None'
							WHEN L.intTransUsedBy = 2 THEN 'Scale Ticket'
							WHEN L.intTransUsedBy = 3 THEN 'Transport L' END COLLATE Latin1_General_CI_AS
	, L.intSourceType
	, L.ysnPosted
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
	, LD.intNumberOfContainers
	, strDetailVendorReference = LD.strVendorReference 
	, strDetailCustomerReference = LD.strCustomerReference

FROM tblLGLoadDetail LD
JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
LEFT JOIN tblICItem Item On Item.intItemId = LD.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = LD.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = WeightItemUOM.intUnitMeasureId
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = L.intGenerateLoadId
LEFT JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = LD.intPCompanyLocationId
LEFT JOIN tblSMCompanyLocation SCL ON SCL.intCompanyLocationId = LD.intSCompanyLocationId
LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = LD.intVendorEntityId
LEFT JOIN tblEMEntityLocation VEL ON VEL.intEntityLocationId = LD.intVendorEntityLocationId
LEFT JOIN tblSMTaxGroup VendorTax ON VendorTax.intTaxGroupId = VEL.intTaxGroupId
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LD.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LD.intCustomerEntityLocationId
LEFT JOIN tblSMTaxGroup CustomerTax ON CustomerTax.intTaxGroupId = CEL.intTaxGroupId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblCTContractDetail PDetail ON PDetail.intContractDetailId = LD.intPContractDetailId
LEFT JOIN tblCTContractHeader PHeader ON PHeader.intContractHeaderId = PDetail.intContractHeaderId
LEFT JOIN tblCTPricingType PPricingType ON PPricingType.intPricingTypeId = PDetail.intPricingTypeId
LEFT JOIN tblCTIndex PIndex ON PIndex.intIndexId = PDetail.intIndexId
LEFT JOIN tblTRSupplyPoint PSP ON PSP.intEntityVendorId = PIndex.intVendorId AND PSP.intEntityLocationId = PIndex.intVendorLocationId
LEFT JOIN tblICItem	IM ON IM.intItemId = PDetail.intItemId
LEFT JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = PDetail.intContractDetailId
LEFT JOIN tblSMCurrency	CU ON CU.intCurrencyID = PDetail.intCurrencyId			
LEFT JOIN tblSMCurrency	CY ON CY.intCurrencyID = CU.intMainCurrencyId		
LEFT JOIN tblCTContractDetail SDetail ON SDetail.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblCTContractHeader SHeader ON SHeader.intContractHeaderId = SDetail.intContractHeaderId
LEFT JOIN tblCTPricingType SPricingType ON SPricingType.intPricingTypeId = SDetail.intPricingTypeId
LEFT JOIN tblCTIndex SIndex ON SIndex.intIndexId = SDetail.intIndexId
LEFT JOIN tblTRSupplyPoint SSP ON SSP.intEntityVendorId = SIndex.intVendorId AND SSP.intEntityLocationId = SIndex.intVendorLocationId
LEFT JOIN tblICItem	IMS ON IMS.intItemId = SDetail.intItemId
LEFT JOIN vyuLGAdditionalColumnForContractDetailView ADS ON AD.intContractDetailId = SDetail.intContractDetailId
LEFT JOIN tblSMCurrency	CUS ON CUS.intCurrencyID = SDetail.intCurrencyId			
LEFT JOIN tblSMCurrency	CYS ON CYS.intCurrencyID = CUS.intMainCurrencyId		
LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId	= L.intDispatcherId
LEFT JOIN tblCTWeightGrade PWG ON PWG.intWeightGradeId = PHeader.intWeightId
LEFT JOIN tblCTWeightGrade SWG ON SWG.intWeightGradeId = SHeader.intWeightId
LEFT JOIN tblSMCompanyLocationSubLocation PCLSL ON PCLSL.intCompanyLocationSubLocationId = LD.intPSubLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SCLSL ON SCLSL.intCompanyLocationSubLocationId = LD.intSSubLocationId