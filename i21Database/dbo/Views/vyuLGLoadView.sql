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
	,strType = CASE L.intPurchaseSale
		WHEN 1 THEN 'Inbound'
		WHEN 2 THEN 'Outbound'
		WHEN 3 THEN 'Drop Ship'
		END COLLATE Latin1_General_CI_AS
	,strSourceType = CASE L.intSourceType
		WHEN 1 THEN 'None'
		WHEN 2 THEN 'Contracts'
		WHEN 3 THEN 'Orders'
		WHEN 4 THEN 'Allocations'
		WHEN 5 THEN 'Picked Lots'
		WHEN 6 THEN 'Pick Lots'
		WHEN 7 THEN 'Pick Lots w/o Contract'
		END COLLATE Latin1_General_CI_AS
	,strTransportationMode = CASE L.intTransportationMode
		WHEN 1 THEN 'Truck'
		WHEN 2 THEN 'Ocean Vessel'
		WHEN 3 THEN 'Rail'
		END COLLATE Latin1_General_CI_AS
	,L.intTransUsedBy
	,strTransUsedBy = CASE L.intTransUsedBy
		WHEN 1 THEN 'None'
		WHEN 2 THEN 'Scale Ticket'
		WHEN 3 THEN 'Transport Load'
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
		WHEN IsNull(L.intLoadHeaderId, 0) <> 0
			THEN TR.strTransaction
		ELSE NULL END
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
	,L.strBOLInstructions
	,ysnDispatched = CAST(CASE WHEN L.ysnDispatched = 1 THEN 1 ELSE 0 END AS BIT)
	,L.dtmDispatchedDate
	,L.ysnDispatchMailSent
	,L.dtmDispatchMailSent
	,L.dtmCancelDispatchMailSent
	,strShipmentStatus = CASE L.intShipmentStatus
		WHEN 1 THEN 'Scheduled'
		WHEN 2 THEN 'Dispatched'
		WHEN 3 THEN 
			CASE WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnDocumentsApproved = 1) THEN 'Documents Approved'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Inbound Transit' END
		WHEN 4 THEN 'Received'
		WHEN 5 THEN 
			CASE WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnDocumentsApproved = 1) THEN 'Documents Approved'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Outbound Transit' END
		WHEN 6 THEN 
			CASE WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnDocumentsApproved = 1) THEN 'Documents Approved'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Delivered' END
		WHEN 7 THEN 
			CASE WHEN (ISNULL(L.strBookingReference, '') <> '') THEN 'Booked'
					ELSE 'Shipping Instruction Created' END
		WHEN 8 THEN 'Partial Shipment Created'
		WHEN 9 THEN 'Full Shipment Created'
		WHEN 10 THEN 'Cancelled'
		WHEN 11 THEN 'Invoiced'
		ELSE '' END COLLATE Latin1_General_CI_AS
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
			WHEN 1 THEN 'Scheduled'
			WHEN 2 THEN 'Dispatched'
			WHEN 3 THEN 
				CASE WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
						WHEN (L.ysnDocumentsApproved = 1) THEN 'Documents Approved'
						WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
						ELSE 'Inbound Transit' END
			WHEN 4 THEN 'Received'
			WHEN 5 THEN 
				CASE WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
						WHEN (L.ysnDocumentsApproved = 1) THEN 'Documents Approved'
						WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
						ELSE 'Outbound Transit' END
			WHEN 6 THEN 
				CASE WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
						WHEN (L.ysnDocumentsApproved = 1) THEN 'Documents Approved'
						WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
						ELSE 'Delivered' END
			WHEN 7 THEN 
				CASE WHEN (ISNULL(L.strBookingReference, '') <> '') THEN 'Booked'
						ELSE 'Shipping Instruction Created' END
			WHEN 8 THEN 'Partial Shipment Created'
			WHEN 9 THEN 'Full Shipment Created'
			WHEN 10 THEN 'Cancelled'
			WHEN 11 THEN 'Invoiced'
			ELSE '' END 
		+ CASE WHEN ISNULL(L.strExternalLoadNumber, '') <> '' THEN ' - ' + '(S) ' + L.strExternalLoadNumber ELSE '' END 
		+ CASE WHEN ISNULL(L.strCustomerReference, '') <> '' THEN ' - ' + '(C) ' + L.strCustomerReference ELSE '' END COLLATE Latin1_General_CI_AS,
		L.intPositionId,
		L.[intWeightUnitMeasureId],
		strWeightUnitMeasure = [strUnitMeasure],
		[strBLNumber] = ISNULL(L.[strBLNumber],''),
		L.[dtmBLDate],
		L.[strOriginPort],
		L.[strDestinationPort],
		intLeadTime = ISNULL(DPort.intLeadTime, 0),
		L.[strDestinationCity],
		L.[intTerminalEntityId],
		[strTerminal] =  Terminal.strName,
		L.[intShippingLineEntityId],
		[strShippingLine] =  ShippingLine.strName,
		L.[strServiceContractNumber],
		strServiceContractOwner = SLSC.strOwner,
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
		L.[ysnArrivedInPort],
		L.[ysnDocumentsApproved],
		L.[ysnCustomsReleased],
		L.[dtmArrivedInPort],
		L.[dtmDocumentsApproved],
		L.[dtmCustomsReleased],
		L.[strVessel1],
		L.[strOriginPort1],
		L.[strDestinationPort1],
		L.[dtmETSPOL1],
		L.[dtmETAPOD1],
		L.[strVessel2],
		L.[strOriginPort2],
		L.[strDestinationPort2],
		L.[dtmETSPOL2],
		L.[dtmETAPOD2],
		L.[strVessel3],
		L.[strOriginPort3],
		L.[strDestinationPort3],
		L.[dtmETSPOL3],
		L.[dtmETAPOD3],
		L.[strVessel4],
		L.[strOriginPort4],
		L.[strDestinationPort4],
		L.[dtmETSPOL4],
		L.[dtmETAPOD4],
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
		strShippingInstructionNumber = LOADSI.strLoadNumber,
		L.dtmStuffingDate,
		L.intBookId,
		L.intSubBookId
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
OUTER APPLY (SELECT TOP 1 intLeadTime FROM tblSMCity DPort 
						 WHERE DPort.strCity = L.strDestinationPort AND DPort.ysnPort = 1) DPort
OUTER APPLY (SELECT TOP 1 strOwner FROM tblLGShippingLineServiceContractDetail SLSCD
			 INNER JOIN tblLGShippingLineServiceContract SLSC ON SLSCD.intShippingLineServiceContractId = SLSC.intShippingLineServiceContractId
			 WHERE SLSC.intEntityId = L.intShippingLineEntityId AND SLSCD.strServiceContractNumber = L.strServiceContractNumber) SLSC