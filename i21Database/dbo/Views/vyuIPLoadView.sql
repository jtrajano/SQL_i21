CREATE VIEW [vyuIPLoadView]
AS
SELECT -- Load Header
	L.intLoadId
	,L.[strLoadNumber]
	,L.strExternalLoadNumber
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
		WHEN 7
			THEN 'Pick Lots w/o Contract'
		WHEN 8
			THEN 'TM Orders'
		END COLLATE Latin1_General_CI_AS
		,strPosition = P.strPosition
	,L.ysnLoadBased
	,intNumberOfLoads = GLoad.intNumberOfLoads
	,strHauler = Hauler.strName
	,L.dtmScheduledDate
	,ysnInProgress = IsNull(L.ysnInProgress, 0)
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
	,ysnDispatched = CAST(CASE 
			WHEN L.ysnDispatched = 1
				THEN 1
			ELSE 0
			END AS BIT)
	,L.dtmDispatchedDate
	,L.ysnDispatchMailSent
	,L.dtmDispatchMailSent
	,L.dtmCancelDispatchMailSent
	,strWeightUnitMeasure = [strUnitMeasure]
	,[strBLNumber] = ISNULL(L.[strBLNumber], '')
	,L.[dtmBLDate]
	,L.[strOriginPort]
	,L.[strDestinationPort]
	,L.[strDestinationCity]
	,[strTerminal] = Terminal.strName
	,[strShippingLine] = ShippingLine.strName
	,L.[strServiceContractNumber]
	,L.[strPackingDescription]
	,L.[strMVessel]
	,L.[strMVoyageNumber]
	,L.[strFVessel]
	,L.[strFVoyageNumber]
	,[strForwardingAgent] = ForwardingAgent.strName
	,L.[strForwardingAgentRef]
	,[strInsurer] = Insurer.strName
	,L.[dblInsuranceValue]
	,[strInsuranceCurrency] = Currency.strCurrency
	,L.[dtmDocsToBroker]
	,L.[strMarks]
	,L.[strMarkingInstructions]
	,L.[strShippingMode]
	,L.[intNumberOfContainers]
	,[strContainerType] = CT.strContainerType
	,L.[strBLDraftToBeSentType]
	,[strBLDraftToBeSent] = BLDraftToBeSent.strName
	,L.[strDocPresentationType]
	,[strDocPresentationVal] = NP.strName
	,L.[ysnPosted]
	,L.[dtmPostedDate]
	,L.[dtmDocsReceivedDate]
	,L.[dtmETAPOL]
	,L.[dtmETSPOL]
	,L.[dtmETAPOD]
	,L.[dtmDeadlineCargo]
	,L.[dtmDeadlineBL]
	,L.[dtmISFReceivedDate]
	,L.[dtmISFFiledDate]
	,L.[ysnArrivedInPort]
	,L.[ysnDocumentsApproved]
	,L.[ysnCustomsReleased]
	,L.[dtmArrivedInPort]
	,L.[dtmDocumentsApproved]
	,L.[dtmCustomsReleased]
	,L.[strVessel1]
	,L.[strOriginPort1]
	,L.[strDestinationPort1]
	,L.[dtmETSPOL1]
	,L.[dtmETAPOD1]
	,L.[strVessel2]
	,L.[strOriginPort2]
	,L.[strDestinationPort2]
	,L.[dtmETSPOL2]
	,L.[dtmETAPOD2]
	,L.[strVessel3]
	,L.[strOriginPort3]
	,L.[strDestinationPort3]
	,L.[dtmETSPOL3]
	,L.[dtmETAPOD3]
	,L.[strVessel4]
	,L.[strOriginPort4]
	,L.[strDestinationPort4]
	,L.[dtmETSPOL4]
	,L.[dtmETAPOD4]
	,L.[dblDemurrage]
	,L.[dblDespatch]
	,L.[dblLoadingRate]
	,L.[strLoadingPerUnit]
	,L.[dblDischargeRate]
	,L.[strDischargePerUnit]
	,L.[intTransportationMode]
	,L.[intShipmentStatus]
	,L.intShipmentType
	,L.strExternalShipmentNumber
	,strShippingInstructionNumber = LOADSI.strLoadNumber
	,L.dtmStuffingDate
	,C.strCurrency
	,FT.strFreightTerm
	,B.strBook
	,SB.strSubBook
	,L.strBookingReference
	,L.intLoadRefId
	,US1.strUserName
	,L.dblInsurancePremiumPercentage
	,L.[ysn4cRegistration]
	,L.[ysnInvoice]
	,L.[ysnProvisionalInvoice]
	,L.[ysnQuantityFinal]
	,IsNULL(L.intTransUsedBy,1) intTransUsedBy
	,ETAPOD.strReasonCode AS strETAPODReasonCode
	,ETAPOL.strReasonCode AS strETAPOLReasonCode
	,ETSPOL.strReasonCode AS strETSPOLReasonCode
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
LEFT JOIN vyuLGNotifyParties NP ON NP.intEntityId = L.intDocPresentationId
	AND NP.strEntity = L.strDocPresentationType
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = L.intInsuranceCurrencyId
LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSMUserSecurity US ON US.[intEntityId] = L.intDispatcherId
LEFT JOIN tblCTPosition P ON L.intPositionId = P.intPositionId
LEFT JOIN tblLGLoad LOADSI ON LOADSI.intLoadId = L.intLoadShippingInstructionId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = L.intCurrencyId
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
LEFT JOIN tblCTBook B ON B.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
LEFT JOIN tblSMUserSecurity US1 ON US1.[intEntityId] = L.intUserSecurityId
Left JOIN dbo.tblLGReasonCode ETAPOD on ETAPOD.intReasonCodeId=L.intETAPODReasonCodeId
Left JOIN dbo.tblLGReasonCode ETAPOL on ETAPOL.intReasonCodeId=L.intETAPOLReasonCodeId
Left JOIN dbo.tblLGReasonCode ETSPOL on ETSPOL.intReasonCodeId=L.intETSPOLReasonCodeId

