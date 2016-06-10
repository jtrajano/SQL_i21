CREATE VIEW vyuLGLoadViewSearch
AS
SELECT L.intLoadId
	,LD.intLoadDetailId
	,L.intGenerateLoadId
	,LD.intVendorEntityId
	,LD.intCustomerEntityId
	,LD.intPContractDetailId
	,LD.intSContractDetailId
	,L.intHaulerEntityId
	,L.strLoadNumber
	,L.strExternalLoadNumber
	,L.strTruckNo
	,L.strBLNumber
	,strSourceType = CASE L.intSourceType
		WHEN 1
			THEN 'None'
		WHEN 2
			THEN 'Contracts'
		WHEN 3
			THEN 'Orders'
		WHEN 4
			THEN 'Allocations'
		WHEN 5
			THEN 'Picked Lots'
		WHEN 6
			THEN 'Pick Lots'
		END COLLATE Latin1_General_CI_AS
	,strType = CASE L.intPurchaseSale
		WHEN 1
			THEN 'Inbound'
		WHEN 2
			THEN 'Outbound'
		WHEN 3
			THEN 'Drop Ship'
		END COLLATE Latin1_General_CI_AS
	,strTransportationMode = CASE intTransportationMode
		WHEN 1 
			THEN 'Truck'
		WHEN 2
			THEN 'Ocean Vessel'
		END COLLATE Latin1_General_CI_AS
	,intGenerateReferenceNumber = GL.intReferenceNumber
	,L.intGenerateSequence
	,intNumberOfLoads = GL.intNumberOfLoads
	,strPLocationName = PCL.strLocationName
	,strVendor = VEN.strName
	,strShipFrom = VEL.strLocationName
	,strPContractNumber = PCH.strContractNumber
	,intPContractSeq = PCD.intContractSeq
	,strCustomer = CEN.strName
	,strShipTo = CEL.strLocationName
	,strSContractNumber = SCH.strContractNumber
	,intSContractSeq = SCD.intContractSeq
	,strSLocationName = SCL.strLocationName
	,strItemNo = I.strDescription
	,L.dtmScheduledDate
	,LD.dblQuantity
	,strHauler = Hauler.strName
	,strDriver = Driver.strName
	,ysnDispatched = CASE 
		WHEN L.ysnDispatched = 1
			THEN CAST(1 AS BIT)
		ELSE CAST(0 AS BIT)
		END
	,strPosition = P.strPosition
	,strWeightUnitMeasure = UM.strUnitMeasure
	,strShipmentStatus = CASE L.intShipmentStatus
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Dispatched'
		WHEN 3
			THEN 'Inbound transit'
		WHEN 4
			THEN 'Received'
		WHEN 5
			THEN 'Outbound transit'
		WHEN 6
			THEN 'Delivered'
		ELSE ''
		END COLLATE Latin1_General_CI_AS
	,strEquipmentType = EQ.strEquipmentType
    ,L.strTrailerNo1
    ,L.strTrailerNo2
    ,L.strTrailerNo3
	,L.strComments
	,L.ysnPosted
    ,ysnInProgress = ISNULL(L.ysnInProgress, 0)
    ,strScaleTicketNo = CASE WHEN IsNull(L.intTicketId, 0) <> 0 
								THEN 
								CAST(ST.strTicketNumber AS VARCHAR(100))
								ELSE 
								CASE WHEN IsNull(L.intTransportLoadId, 0) <> 0 
									THEN 
										TL.strTransaction
									ELSE 
										CASE WHEN IsNull(L.intLoadHeaderId, 0) <> 0 
											THEN 
												TR.strTransaction
											ELSE 
												NULL 
											END 
									END 
								END
	,L.dtmDeliveredDate
	,L.dtmDispatchedDate
	,L.ysnDispatchMailSent
	,L.dtmDispatchMailSent
	,L.dtmCancelDispatchMailSent
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = LD.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WU.intUnitMeasureId
LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = L.intGenerateLoadId
LEFT JOIN tblSMCompanyLocation PCL ON PCL.intCompanyLocationId = LD.intPCompanyLocationId
LEFT JOIN tblSMCompanyLocation SCL ON SCL.intCompanyLocationId = LD.intSCompanyLocationId
LEFT JOIN tblEMEntity VEN ON VEN.intEntityId = LD.intVendorEntityId
LEFT JOIN tblEMEntityLocation VEL ON VEL.intEntityLocationId = LD.intVendorEntityLocationId
LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = LD.intPContractDetailId
LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
LEFT JOIN tblEMEntity CEN ON CEN.intEntityId = LD.intCustomerEntityId
LEFT JOIN tblEMEntityLocation CEL ON CEL.intEntityLocationId = LD.intCustomerEntityLocationId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblCTPosition P ON L.intPositionId = P.intPositionId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = L.intWeightUnitMeasureId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
LEFT JOIN tblTRTransportLoad TL ON TL.intTransportLoadId = L.intTransportLoadId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId