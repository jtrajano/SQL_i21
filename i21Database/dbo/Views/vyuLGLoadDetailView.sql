CREATE VIEW vyuLGLoadDetailView
AS
SELECT LoadDetail.intLoadDetailId
		,LoadDetail.intItemId
		,Item.strItemNo
		,Item.strDescription AS strItemDescription
		,LoadDetail.dblQuantity
		,LoadDetail.intItemUOMId
		,strItemUOM = UOM.strUnitMeasure
		,LoadDetail.dblGross
		,LoadDetail.dblTare
		,LoadDetail.dblNet
		,LoadDetail.intWeightItemUOMId
		,LoadDetail.dblDeliveredQuantity
		,LoadDetail.dblDeliveredGross
		,LoadDetail.dblDeliveredTare
		,LoadDetail.dblDeliveredNet
		,LoadDetail.intPSubLocationId
		,PCLSL.strSubLocationName AS strPSubLocationName
		,SCLSL.strSubLocationName AS strSSubLocationName
		,strWeightItemUOM = WeightUOM.strUnitMeasure
		,LoadDetail.intVendorEntityId
		,dblItemUOMCF = ItemUOM.dblUnitQty

-- Vendor Info
        ,strVendor = VEN.strName
		,LoadDetail.intVendorEntityLocationId
        ,strShipFrom = VEL.strLocationName
		,strShipFromAddress = VEL.strAddress
		,strShipFromCity = VEL.strCity
		,strShipFromCountry = VEL.strCountry
		,strShipFromState = VEL.strState
		,strShipFromZipCode = VEL.strZipCode
		,strVendorNo = VEN.strEntityNo
		,strVendorEmail = VEN.strEmail
		,strVendorFax = VEN.strFax
		,strVendorMobile = VEN.strMobile
		,strVendorPhone = VEN.strPhone
		,LoadDetail.intPContractDetailId
		,intPContractHeaderId = PDetail.intContractHeaderId
		,intPCommodityId = PDetail.intCommodityId
        ,strPContractNumber = PDetail.strContractNumber
        ,intPContractSeq = PDetail.intContractSeq
		,intPLifeTime = PDetail.intLifeTime
		,strPLifeTimeType = PDetail.strLifeTimeType
		,strVendorContract = PDetail.strCustomerContract
		,dblPCashPrice = PDetail.dblCashPrice
		,strPCostUOM = PDetail.strPriceUOM
  	    ,intPCostUOMId = PDetail.intPriceItemUOMId
		,dblPCostUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM WHERE ItemUOM.intItemUOMId = PDetail.intPriceItemUOMId),0)
		,ysnPLoad = PDetail.ysnLoad
		,dblPQuantityPerLoad = PDetail.dblQuantityPerLoad
		,intPNoOfLoads = PDetail.intNoOfLoad
		,intPStockUOM = ISNULL((SELECT TOP 1 intItemUOMId FROM tblICItemUOM ItemUOM WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = PDetail.intItemUOMId),0)
        ,strPStockUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = PDetail.intItemUOMId)
		,strPStockUOMType = (SELECT TOP 1 strUnitType FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = PDetail.intItemUOMId)
        ,dblPStockUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = PDetail.intItemUOMId),0)
		,strPCurrency = PDetail.strCurrency
	    ,strPMainCurrency = PDetail.strMainCurrency
	    ,ysnPSubCurrency = PDetail.ysnSubCurrency
	    ,dblPMainCashPrice = PDetail.dblMainCashPrice
	    ,dblPFranchise = CASE WHEN PWG.dblFranchise > 0 THEN PWG.dblFranchise / 100 ELSE 0 END

-- Inbound Company Location
		,LoadDetail.intPCompanyLocationId
        ,strPLocationName = PCL.strLocationName
		,strPLocationAddress = PCL.strAddress
		,strPLocationCity = PCL.strCity
		,strPLocationCountry = PCL.strCountry
		,strPLocationState = PCL.strStateProvince
		,strPLocationZipCode = PCL.strZipPostalCode
		,strPLocationMail = PCL.strEmail
		,strPLocationFax = PCL.strFax
		,strPLocationPhone = PCL.strPhone

-- Customer Info
		,LoadDetail.intCustomerEntityId
        ,strCustomer = CEN.strName
		,LoadDetail.intCustomerEntityLocationId
        ,strShipTo = CEL.strLocationName
		,strShipToAddress = CEL.strAddress
		,strShipToCity = CEL.strCity
		,strShipToCountry = CEL.strCountry
		,strShipToState = CEL.strState
		,strShipToZipCode = CEL.strZipCode
		,strCustomerNo = CEN.strEntityNo
		,strCustomerEmail = CEN.strEmail
		,strCustomerFax = CEN.strFax
		,strCustomerMobile = CEN.strMobile
		,strCustomerPhone = CEN.strPhone

		,LoadDetail.intSContractDetailId
		,intSContractHeaderId = SDetail.intContractHeaderId
        ,strSContractNumber = SDetail.strContractNumber
        ,intSContractSeq = SDetail.intContractSeq
		,intSCommodityId = SDetail.intCommodityId
		,intSLifeTime = SDetail.intLifeTime
		,strSLifeTimeType = SDetail.strLifeTimeType
		,strCustomerContract = SDetail.strCustomerContract
		,dblSCashPrice = SDetail.dblCashPrice
		,strSCostUOM = SDetail.strPriceUOM
  	    ,intSCostUOMId = SDetail.intPriceItemUOMId
		,dblSCostUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM WHERE ItemUOM.intItemUOMId = SDetail.intPriceItemUOMId),0)
		,ysnSLoad = SDetail.ysnLoad
		,dblSQuantityPerLoad = SDetail.dblQuantityPerLoad
		,intSNoOfLoads = SDetail.intNoOfLoad
		,intSStockUOM = ISNULL((SELECT TOP 1 intItemUOMId FROM tblICItemUOM ItemUOM WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = SDetail.intItemUOMId),0)
        ,strSStockUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = SDetail.intItemUOMId)
		,strSStockUOMType = (SELECT TOP 1 strUnitType FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = SDetail.intItemUOMId)
        ,dblSStockUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = SDetail.intItemUOMId),0)
		,strSCurrency = SDetail.strCurrency
	    ,strSMainCurrency = SDetail.strMainCurrency
	    ,ysnSSubCurrency = SDetail.ysnSubCurrency
	    ,dblSMainCashPrice = SDetail.dblMainCashPrice
	    ,dblSFranchise = CASE WHEN SWG.dblFranchise > 0 THEN SWG.dblFranchise / 100 ELSE 0 END

-- Outbound Company Location
		,LoadDetail.intSCompanyLocationId
        ,strSLocationName = SCL.strLocationName
		,strSLocationAddress = SCL.strAddress
		,strSLocationCity = SCL.strCity
		,strSLocationCountry = SCL.strCountry
		,strSLocationState = SCL.strStateProvince
		,strSLocationZipCode = SCL.strZipPostalCode
		,strSLocationMail = SCL.strEmail
		,strSLocationFax = SCL.strFax
		,strSLocationPhone = SCL.strPhone

-- Schedule, Load Directions
		,LoadDetail.strScheduleInfoMsg
		,LoadDetail.ysnUpdateScheduleInfo
		,LoadDetail.ysnPrintScheduleInfo
		,LoadDetail.strLoadDirectionMsg
		,LoadDetail.ysnUpdateLoadDirections
		,LoadDetail.ysnPrintLoadDirections
		,Item.strLotTracking

-- Load Header
		,Load.intLoadId
		,Load.intConcurrencyId
		,Load.[strLoadNumber]
		,Load.intPurchaseSale
		,Load.intEquipmentTypeId
		,Load.intHaulerEntityId
		,Load.intTicketId
		,Load.intGenerateLoadId
		,Load.intUserSecurityId
		,Load.intTransportLoadId
		,Load.intLoadHeaderId
		,Load.intDriverEntityId
		,Load.intDispatcherId
        ,Load.strExternalLoadNumber
        ,strType = CASE WHEN Load.intPurchaseSale = 1 THEN 
						'Inbound' 
						ELSE 
							CASE WHEN Load.intPurchaseSale = 2 THEN 
							'Outbound' 
							ELSE
							'Drop Ship'
							END
						END
        ,intGenerateReferenceNumber = GLoad.intReferenceNumber
        ,intGenerateSequence = Load.intGenerateSequence
        ,intNumberOfLoads = GLoad.intNumberOfLoads
        ,strHauler = Hauler.strName
        ,Load.dtmScheduledDate
        ,ysnInProgress = IsNull(Load.ysnInProgress, 0)
        ,strScaleTicketNo = CASE WHEN IsNull(Load.intTicketId, 0) <> 0 
								 THEN 
									CAST(ST.strTicketNumber AS VARCHAR(100))
								 ELSE 
									CASE WHEN IsNull(Load.intTransportLoadId, 0) <> 0 
										THEN 
											TL.strTransaction
										ELSE 
											CASE WHEN IsNull(Load.intLoadHeaderId, 0) <> 0 
												THEN 
													TR.strTransaction
												ELSE 
													NULL 
												END 
										END 
								 END
        ,Load.dtmDeliveredDate
        ,strEquipmentType = EQ.strEquipmentType
        ,strDriver = Driver.strName
		,strDispatcher = US.strUserName 
        ,Load.strCustomerReference
        ,Load.strTruckNo
        ,Load.strTrailerNo1
        ,Load.strTrailerNo2
        ,Load.strTrailerNo3
        ,Load.strComments
        ,ysnDispatched = CASE WHEN Load.ysnDispatched = 1 THEN CAST(1 AS bit) ELSE CAST(0 AS Bit) END
		,Load.dtmDispatchedDate
		,Load.ysnDispatchMailSent
		,Load.dtmDispatchMailSent
		,Load.dtmCancelDispatchMailSent
		,Load.intCompanyLocationId
		,Load.intTransUsedBy
		,strTransUsedBy = CASE 
			WHEN Load.intTransUsedBy = 1 
				THEN 'None'
			WHEN Load.intTransUsedBy = 2
				THEN 'Scale Ticket'
			WHEN Load.intTransUsedBy = 3
				THEN 'Transport Load'
			END
		,Load.intSourceType
		,Load.ysnPosted
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
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LoadDetail.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LoadDetail.intCustomerEntityLocationId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = Load.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = Load.intDriverEntityId
LEFT JOIN vyuCTContractDetailView PDetail ON PDetail.intContractDetailId = LoadDetail.intPContractDetailId
LEFT JOIN vyuCTContractDetailView SDetail ON SDetail.intContractDetailId = LoadDetail.intSContractDetailId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = Load.intTicketId
LEFT JOIN tblTRTransportLoad TL ON TL.intTransportLoadId = Load.intTransportLoadId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = Load.intLoadHeaderId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = Load.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.[intEntityUserSecurityId]	= Load.intDispatcherId
LEFT JOIN tblCTWeightGrade PWG ON PWG.intWeightGradeId = PDetail.intWeightId
LEFT JOIN tblCTWeightGrade SWG ON SWG.intWeightGradeId = SDetail.intWeightId
LEFT JOIN tblSMCompanyLocationSubLocation PCLSL ON PCLSL.intCompanyLocationSubLocationId = LoadDetail.intPSubLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SCLSL ON SCLSL.intCompanyLocationSubLocationId = LoadDetail.intSSubLocationId