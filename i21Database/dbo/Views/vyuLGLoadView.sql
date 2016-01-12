CREATE VIEW vyuLGLoadView
AS
SELECT LoadDetail.intLoadDetailId
		,LoadDetail.intItemId
		,strItemNo = Item.strDescription
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
		,strWeightItemUOM = WeightUOM.strUnitMeasure
		,LoadDetail.intVendorEntityId
        ,strVendor = VEN.strName
		,LoadDetail.intVendorEntityLocationId
        ,strShipFrom = VEL.strLocationName
		,strShipFromAddress = VEL.strAddress
		,LoadDetail.intPContractDetailId
        ,strPContractNumber = PDetail.strContractNumber
        ,intPContractSeq = PDetail.intContractSeq
		,strVendorContract = PDetail.strCustomerContract
		,dblPCashPrice = PDetail.dblCashPrice
		,LoadDetail.intPCompanyLocationId
        ,strPLocationName = PCL.strLocationName
		,LoadDetail.intCustomerEntityId
        ,strCustomer = CEN.strName
		,LoadDetail.intCustomerEntityLocationId
        ,strShipTo = CEL.strLocationName
		,strShipToAddress = CEL.strAddress
		,LoadDetail.intSContractDetailId
        ,strSContractNumber = SDetail.strContractNumber
        ,intSContractSeq = SDetail.intContractSeq
		,strCustomerContract = SDetail.strCustomerContract
		,dblSCashPrice = PDetail.dblCashPrice
		,LoadDetail.intSCompanyLocationId
        ,strSLocationName = SCL.strLocationName
		,LoadDetail.strScheduleInfoMsg
		,LoadDetail.ysnUpdateScheduleInfo
		,LoadDetail.ysnPrintScheduleInfo
		,LoadDetail.strLoadDirectionMsg
		,LoadDetail.ysnUpdateLoadDirections
		,LoadDetail.ysnPrintLoadDirections

		,Load.intLoadId
		,Load.intConcurrencyId
		,Load.intLoadNumber
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
FROM tblLGLoadDetail LoadDetail
JOIN tblLGLoad Load ON Load.intLoadId = LoadDetail.intLoadId
LEFT JOIN tblICItem Item On Item.intItemId = LoadDetail.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = LoadDetail.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = Load.intGenerateLoadId
LEFT JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = LoadDetail.intPCompanyLocationId
LEFT JOIN tblSMCompanyLocation SCL ON SCL.intCompanyLocationId = LoadDetail.intSCompanyLocationId
LEFT JOIN tblEntity VEN ON VEN.intEntityId = LoadDetail.intVendorEntityId
LEFT JOIN tblEntityLocation VEL ON VEL.intEntityLocationId = LoadDetail.intVendorEntityLocationId
LEFT JOIN tblEntity CEN ON CEN.intEntityId = LoadDetail.intCustomerEntityId
LEFT JOIN tblEntityLocation CEL ON CEL.intEntityLocationId = LoadDetail.intCustomerEntityLocationId
LEFT JOIN tblEntity Hauler ON Hauler.intEntityId = Load.intHaulerEntityId
LEFT JOIN tblEntity Driver ON Driver.intEntityId = Load.intDriverEntityId
LEFT JOIN vyuCTContractDetailView PDetail ON PDetail.intContractDetailId = LoadDetail.intPContractDetailId
LEFT JOIN vyuCTContractDetailView SDetail ON SDetail.intContractDetailId = LoadDetail.intSContractDetailId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = Load.intTicketId
LEFT JOIN tblTRTransportLoad TL ON TL.intTransportLoadId = Load.intTransportLoadId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = Load.intLoadHeaderId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = Load.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.[intEntityUserSecurityId]	= Load.intDispatcherId
