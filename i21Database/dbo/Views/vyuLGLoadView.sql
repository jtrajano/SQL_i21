CREATE VIEW [vyuLGLoadView]
AS
SELECT -- Load Header
	L.intLoadId
	,L.intConcurrencyId
	,L.[strLoadNumber]
	,L.intPurchaseSale
	,L.intEquipmentTypeId
	,L.intHaulerEntityId
	,L.intTicketId
	,L.intGenerateLoadId
	,L.intUserSecurityId
	,L.intTransportLoadId
	,L.intLoadHeaderId
	,L.intDriverEntityId
	,L.intDispatcherId
	,L.strExternalLoadNumber
	,strType = CASE 
		WHEN L.intPurchaseSale = 1
			THEN 'Inbound'
		ELSE CASE 
				WHEN L.intPurchaseSale = 2
					THEN 'Outbound'
				ELSE 'Drop-Ship'
				END
		END COLLATE Latin1_General_CI_AS
	,strSourceType = CASE 
		WHEN L.intSourceType = 1
			THEN 'None'
		WHEN L.intSourceType = 2
			THEN 'Contracts'
		WHEN L.intSourceType = 3
			THEN 'Orders'
		WHEN L.intSourceType = 4
			THEN 'Allocations'
		WHEN L.intSourceType = 5
			THEN 'Picked Lots'
		WHEN L.intSourceType = 6
			THEN 'Pick Lots'
		WHEN L.intSourceType = 7
			THEN 'Pick Lots w/o Contract'
		END COLLATE Latin1_General_CI_AS
	,strTransportationMode = CASE 
		WHEN L.intTransportationMode = 1 
			THEN 'Truck'
		WHEN L.intTransportationMode = 2
			THEN 'Ocean Vessel'
		WHEN L.intTransportationMode = 3
			THEN 'Rail'
		END COLLATE Latin1_General_CI_AS
	,L.intTransUsedBy
	,strTransUsedBy = CASE 
		WHEN L.intTransUsedBy = 1 
			THEN 'None'
		WHEN L.intTransUsedBy = 2
			THEN 'Scale Ticket'
		WHEN L.intTransUsedBy = 3
			THEN 'Transport Load'
		END COLLATE Latin1_General_CI_AS
	,strPosition = P.strPosition
	,intGenerateReferenceNumber = GLoad.intReferenceNumber
	,intGenerateSequence = L.intGenerateSequence
	,L.ysnLoadBased
	,intNumberOfLoads = GLoad.intNumberOfLoads
	,strHauler = Hauler.strName
	,L.dtmScheduledDate
	,ysnInProgress = IsNull(L.ysnInProgress, 0)
	,strScaleTicketNo = CASE 
		WHEN IsNull(L.intTicketId, 0) <> 0
			THEN CAST(ST.strTicketNumber AS VARCHAR(100))
		ELSE CASE WHEN IsNull(L.intLoadHeaderId, 0) <> 0
				THEN TR.strTransaction
			ELSE NULL
			END
		END
	,L.dtmDeliveredDate
	,strEquipmentType = EQ.strEquipmentType
	,strDriver = Driver.strName
	,strDispatcher = US.strUserName
	,L.strCustomerReference
	,L.strTruckNo
	,L.strTrailerNo1
	,L.strTrailerNo2
	,L.strTrailerNo3
	,L.strCarNumber
	,L.strEmbargoNo
	,L.strEmbargoPermitNo
	,L.strComments
	,ysnDispatched = CASE 
		WHEN L.ysnDispatched = 1
			THEN CAST(1 AS BIT)
		ELSE CAST(0 AS BIT)
		END
	,L.dtmDispatchedDate
	,L.ysnDispatchMailSent
	,L.dtmDispatchMailSent
	,L.dtmCancelDispatchMailSent
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
		WHEN 11
			THEN 'Invoiced'
		ELSE ''
		END COLLATE Latin1_General_CI_AS
	,strCalenderInfo = L.[strLoadNumber] 
		+ CASE L.intTransportationMode 
			WHEN 1 THEN '(T)'
			WHEN 2 THEN '(V)'
			WHEN 3 THEN '(R)' 
			END +  ' - ' 
		+ CASE L.intPurchaseSale 
			WHEN 1 THEN 'Inbound'
			WHEN 2 THEN 'Outbound'
			WHEN 3 THEN 'Drop-Ship'
			END + ' - ' 
		+ CASE L.intShipmentStatus
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
			WHEN 11
				THEN 'Invoiced'
			ELSE ''
			END 
		+ CASE WHEN ISNULL(L.strExternalLoadNumber, '') <> ''
			THEN ' - ' + '(S) ' + L.strExternalLoadNumber
			ELSE ''
			END 
		+ CASE WHEN ISNULL(L.strCustomerReference, '') <> ''
			THEN ' - ' + '(C) ' + L.strCustomerReference
			ELSE ''
			END COLLATE Latin1_General_CI_AS,
		L.intPositionId,
		L.[intWeightUnitMeasureId],
		strWeightUnitMeasure = [strUnitMeasure],
		ISNULL(L.[strBLNumber],'') AS [strBLNumber],
		L.[dtmBLDate],
		L.[strOriginPort],
		L.[strDestinationPort],
		L.[strDestinationCity],
		L.[intTerminalEntityId],
		[strTerminal] =  Terminal.strName,
		L.[intShippingLineEntityId],
		[strShippingLine] =  ShippingLine.strName,
		L.[strServiceContractNumber],
		L.[strPackingDescription],
		L.[strMVessel],
		L.[strMVoyageNumber],
		L.[strFVessel],
		L.[strFVoyageNumber],
		L.[intForwardingAgentEntityId],
		[strForwardingAgent] = ForwardingAgent.strName,
		L.[strForwardingAgentRef],
		L.[intInsurerEntityId],
		[strInsurer] = Insurer.strName,
		L.[dblInsuranceValue],
		L.[intInsuranceCurrencyId],
		[strInsuranceCurrency] = Currency.strCurrency,
		L.[dtmDocsToBroker],
		L.[strMarks],
		L.[strMarkingInstructions],
		L.[strShippingMode],
		L.[intNumberOfContainers],
		L.[intContainerTypeId],
		[strContainerType] = CT.strContainerType,
		L.[intBLDraftToBeSentId],
		L.[strBLDraftToBeSentType],
		[strBLDraftToBeSent] = BLDraftToBeSent.strName,
		L.[strDocPresentationType],
		[strDocPresentationVal] = NP.strName,
		L.[intDocPresentationId],
		L.[ysnPosted],
		L.[dtmPostedDate],
		L.[dtmDocsReceivedDate],
		L.[dtmETAPOL],
		L.[dtmETSPOL],
		L.[dtmETAPOD],
		L.[dtmDeadlineCargo],
		L.[dtmDeadlineBL],
		L.[dtmISFReceivedDate],
		L.[dtmISFFiledDate],
		L.[dblDemurrage],
		L.[intDemurrageCurrencyId],
		L.[dblDespatch],
		L.[intDespatchCurrencyId],
		L.[dblLoadingRate],
		L.[intLoadingUnitMeasureId],
		L.[strLoadingPerUnit],
		L.[dblDischargeRate],
		L.[intDischargeUnitMeasureId],
		L.[strDischargePerUnit],
		L.[intTransportationMode],
		L.[intShipmentStatus],
		L.intShipmentType,
		L.strExternalShipmentNumber,
		LOADSI.strLoadNumber AS strShippingInstructionNumber,
		L.dtmStuffingDate
FROM tblLGLoad L
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = L.intWeightUnitMeasureId
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = L.intGenerateLoadId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = L.intTerminalEntityId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblEMEntity ForwardingAgent ON ForwardingAgent.intEntityId = L.intForwardingAgentEntityId
LEFT JOIN tblEMEntity Insurer ON Insurer.intEntityId = L.intInsurerEntityId
LEFT JOIN tblEMEntity BLDraftToBeSent ON BLDraftToBeSent.intEntityId = L.intBLDraftToBeSentId
LEFT JOIN vyuLGNotifyParties NP ON NP.intEntityId = L.intDocPresentationId AND NP.strEntity = L.strDocPresentationType
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = L.intInsuranceCurrencyId
LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.[intEntityId] = L.intDispatcherId
LEFT JOIN tblCTPosition P ON L.intPositionId = P.intPositionId
LEFT JOIN tblLGLoad LOADSI ON LOADSI.intLoadId = L.intLoadShippingInstructionId