CREATE VIEW [vyuLGLoadView]
AS
SELECT -- Load Header
	LOAD.intLoadId
	,LOAD.intConcurrencyId
	,LOAD.[strLoadNumber]
	,LOAD.intPurchaseSale
	,LOAD.intEquipmentTypeId
	,LOAD.intHaulerEntityId
	,LOAD.intTicketId
	,LOAD.intGenerateLoadId
	,LOAD.intUserSecurityId
	,LOAD.intTransportLoadId
	,LOAD.intLoadHeaderId
	,LOAD.intDriverEntityId
	,LOAD.intDispatcherId
	,LOAD.strExternalLoadNumber
	,strType = CASE 
		WHEN LOAD.intPurchaseSale = 1
			THEN 'Inbound'
		ELSE CASE 
				WHEN LOAD.intPurchaseSale = 2
					THEN 'Outbound'
				ELSE 'Drop-Ship'
				END
		END COLLATE Latin1_General_CI_AS
	,strSourceType = CASE 
		WHEN LOAD.intSourceType = 1
			THEN 'None'
		WHEN LOAD.intSourceType = 2
			THEN 'Contracts'
		WHEN LOAD.intSourceType = 3
			THEN 'Orders'
		WHEN LOAD.intSourceType = 4
			THEN 'Allocations'
		WHEN LOAD.intSourceType = 5
			THEN 'Picked Lots'
		WHEN LOAD.intSourceType = 6
			THEN 'Pick Lots'
		END
	,strTransportationMode = CASE 
		WHEN LOAD.intTransportationMode = 1 
			THEN 'Truck'
		WHEN LOAD.intTransportationMode = 2
			THEN 'Ocean Vessel'
		END
	,LOAD.intTransUsedBy
	,strTransUsedBy = CASE 
		WHEN LOAD.intTransUsedBy = 1 
			THEN 'None'
		WHEN LOAD.intTransUsedBy = 2
			THEN 'Scale Ticket'
		WHEN LOAD.intTransUsedBy = 3
			THEN 'Transport Load'
		END
	,strPosition = P.strPosition
	,intGenerateReferenceNumber = GLoad.intReferenceNumber
	,intGenerateSequence = LOAD.intGenerateSequence
	,intNumberOfLoads = GLoad.intNumberOfLoads
	,strHauler = Hauler.strName
	,LOAD.dtmScheduledDate
	,ysnInProgress = IsNull(LOAD.ysnInProgress, 0)
	,strScaleTicketNo = CASE 
		WHEN IsNull(LOAD.intTicketId, 0) <> 0
			THEN CAST(ST.strTicketNumber AS VARCHAR(100))
		ELSE CASE WHEN IsNull(LOAD.intLoadHeaderId, 0) <> 0
				THEN TR.strTransaction
			ELSE NULL
			END
		END
	,LOAD.dtmDeliveredDate
	,strEquipmentType = EQ.strEquipmentType
	,strDriver = Driver.strName
	,strDispatcher = US.strUserName
	,LOAD.strCustomerReference
	,LOAD.strTruckNo
	,LOAD.strTrailerNo1
	,LOAD.strTrailerNo2
	,LOAD.strTrailerNo3
	,LOAD.strComments
	,ysnDispatched = CASE 
		WHEN LOAD.ysnDispatched = 1
			THEN CAST(1 AS BIT)
		ELSE CAST(0 AS BIT)
		END
	,LOAD.dtmDispatchedDate
	,LOAD.ysnDispatchMailSent
	,LOAD.dtmDispatchMailSent
	,LOAD.dtmCancelDispatchMailSent
	,strShipmentStatus = CASE LOAD.intShipmentStatus
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
	,strCalenderInfo = LOAD.[strLoadNumber] + ' - ' + CASE 
		WHEN LOAD.intPurchaseSale = 1
			THEN 'Inbound'
		ELSE CASE 
				WHEN LOAD.intPurchaseSale = 2
					THEN 'Outbound'
				ELSE 'Drop-Ship'
				END
		END + ' - ' + CASE LOAD.intShipmentStatus
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
		END + CASE 
		WHEN ISNULL(LOAD.strExternalLoadNumber, '') <> ''
			THEN ' - ' + '(S) ' + LOAD.strExternalLoadNumber
		ELSE ''
		END + CASE 
		WHEN ISNULL(LOAD.strCustomerReference, '') <> ''
			THEN ' - ' + '(C) ' + LOAD.strCustomerReference
		ELSE ''
		END COLLATE Latin1_General_CI_AS,
		LOAD.intPositionId,
		LOAD.[intWeightUnitMeasureId],
		strWeightUnitMeasure = [strUnitMeasure],
		ISNULL(LOAD.[strBLNumber],'') AS [strBLNumber],
		LOAD.[dtmBLDate],
		LOAD.[strOriginPort],
		LOAD.[strDestinationPort],
		LOAD.[strDestinationCity],
		LOAD.[intTerminalEntityId],
		[strTerminal] =  Terminal.strName,
		LOAD.[intShippingLineEntityId],
		[strShippingLine] =  ShippingLine.strName,
		LOAD.[strServiceContractNumber],
		LOAD.[strPackingDescription],
		LOAD.[strMVessel],
		LOAD.[strMVoyageNumber],
		LOAD.[strFVessel],
		LOAD.[strFVoyageNumber],
		LOAD.[intForwardingAgentEntityId],
		[strForwardingAgent] = ForwardingAgent.strName,
		LOAD.[strForwardingAgentRef],
		LOAD.[intInsurerEntityId],
		[strInsurer] = Insurer.strName,
		LOAD.[dblInsuranceValue],
		LOAD.[intInsuranceCurrencyId],
		[strInsuranceCurrency] = Currency.strCurrency,
		LOAD.[dtmDocsToBroker],
		LOAD.[strMarks],
		LOAD.[strMarkingInstructions],
		LOAD.[strShippingMode],
		LOAD.[intNumberOfContainers],
		LOAD.[intContainerTypeId],
		[strContainerType] = CT.strContainerType,
		LOAD.[intBLDraftToBeSentId],
		LOAD.[strBLDraftToBeSentType],
		[strBLDraftToBeSent] = BLDraftToBeSent.strName,
		LOAD.[strDocPresentationType],
		[strDocPresentationVal] = NP.strName,
		LOAD.[intDocPresentationId],
		LOAD.[ysnPosted],
		LOAD.[dtmPostedDate],
		LOAD.[dtmDocsReceivedDate],
		LOAD.[dtmETAPOL],
		LOAD.[dtmETSPOL],
		LOAD.[dtmETAPOD],
		LOAD.[dtmDeadlineCargo],
		LOAD.[dtmDeadlineBL],
		LOAD.[dtmISFReceivedDate],
		LOAD.[dtmISFFiledDate],
		LOAD.[dblDemurrage],
		LOAD.[intDemurrageCurrencyId],
		LOAD.[dblDespatch],
		LOAD.[intDespatchCurrencyId],
		LOAD.[dblLoadingRate],
		LOAD.[intLoadingUnitMeasureId],
		LOAD.[strLoadingPerUnit],
		LOAD.[dblDischargeRate],
		LOAD.[intDischargeUnitMeasureId],
		LOAD.[strDischargePerUnit],
		LOAD.[intTransportationMode],
		LOAD.[intShipmentStatus],
		LOAD.intShipmentType,
		LOAD.strExternalShipmentNumber,
		LOADSI.strLoadNumber AS strShippingInstructionNumber
FROM tblLGLoad LOAD
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = LOAD.intWeightUnitMeasureId
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = LOAD.intGenerateLoadId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = LOAD.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = LOAD.intDriverEntityId
LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = LOAD.intTerminalEntityId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = LOAD.intShippingLineEntityId
LEFT JOIN tblEMEntity ForwardingAgent ON ForwardingAgent.intEntityId = LOAD.intForwardingAgentEntityId
LEFT JOIN tblEMEntity Insurer ON Insurer.intEntityId = LOAD.intInsurerEntityId
LEFT JOIN tblEMEntity BLDraftToBeSent ON BLDraftToBeSent.intEntityId = LOAD.intBLDraftToBeSentId
LEFT JOIN vyuLGNotifyParties NP ON NP.intEntityId = LOAD.intDocPresentationId AND NP.strEntity = LOAD.strDocPresentationType
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = LOAD.intInsuranceCurrencyId
LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = LOAD.intContainerTypeId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = LOAD.intTicketId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = LOAD.intLoadHeaderId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = LOAD.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.[intEntityId] = LOAD.intDispatcherId
LEFT JOIN tblCTPosition P ON LOAD.intPositionId = P.intPositionId
LEFT JOIN tblLGLoad LOADSI ON LOADSI.intLoadId = LOAD.intLoadShippingInstructionId