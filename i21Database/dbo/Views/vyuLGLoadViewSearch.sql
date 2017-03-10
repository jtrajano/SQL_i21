CREATE VIEW vyuLGLoadViewSearch
AS
SELECT L.intLoadId
	,L.intGenerateLoadId
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
	,strTransportationMode = CASE L.intTransportationMode
		WHEN 1 
			THEN 'Truck'
		WHEN 2
			THEN 'Ocean Vessel'
		END COLLATE Latin1_General_CI_AS
	,intGenerateReferenceNumber = GL.intReferenceNumber
	,L.intGenerateSequence
	,intNumberOfLoads = GL.intNumberOfLoads
	,L.dtmScheduledDate
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
		WHEN 7
			THEN 'Instruction created'
		WHEN 8
			THEN 'Partial Shipment Created'
		WHEN 9
			THEN 'Full Shipment Created'
		WHEN 10
			THEN 'Cancelled'
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
									CASE WHEN IsNull(L.intLoadHeaderId, 0) <> 0 
										THEN 
											TR.strTransaction
										ELSE 
											NULL 
										END 
								END
	,L.dtmDeliveredDate
	,L.dtmDispatchedDate
	,L.ysnDispatchMailSent
	,L.dtmDispatchMailSent
	,L.dtmCancelDispatchMailSent
	,L.intLoadShippingInstructionId
	,L.intShipmentType
	,LSI.strLoadNumber AS strShippingInstructionNo
	,strShipmentType = CASE L.intShipmentType
		WHEN 1
			THEN 'Shipment'
		WHEN 2
			THEN 'Shipping Instructions'
		WHEN 3
			THEN 'Vessel Nomination'
		ELSE ''
		END COLLATE Latin1_General_CI_AS
FROM tblLGLoad L
LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = L.intGenerateLoadId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblCTPosition P ON L.intPositionId = P.intPositionId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = L.intWeightUnitMeasureId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId
LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId