CREATE VIEW [dbo].[vyuLGGetLoadData]
AS
SELECT 
	L.intLoadId
    ,L.strLoadNumber
    ,L.intPurchaseSale
    ,L.dtmScheduledDate
    ,L.strCustomerReference
    ,L.strBookingReference
    ,L.intEquipmentTypeId
    ,L.intHaulerEntityId
    ,L.strComments
    ,L.strBOLInstructions
    ,L.intTicketId
    ,L.ysnInProgress
    ,L.dtmDeliveredDate
    ,L.intGenerateLoadId
    ,L.intGenerateSequence
    ,L.strTruckNo
    ,L.strTrailerNo1
    ,L.strTrailerNo2
    ,L.strTrailerNo3
    ,L.strCarNumber
    ,L.strEmbargoNo
    ,L.strEmbargoPermitNo
    ,L.intUserSecurityId
    ,L.strExternalLoadNumber
    ,L.intTransportLoadId
    ,L.intLoadHeaderId
    ,L.intDriverEntityId
    ,L.ysnDispatched
    ,L.dtmDispatchedDate
    ,L.intDispatcherId
    ,L.ysnDispatchMailSent
    ,L.dtmDispatchMailSent
    ,L.dtmCancelDispatchMailSent
    ,L.intSourceType
    ,L.intTransportationMode
    ,L.intShipmentStatus
    ,L.intPositionId
    ,L.intWeightUnitMeasureId
    ,L.intTransUsedBy
    ,L.strBLNumber
    ,L.dtmBLDate
    ,L.strOriginPort
    ,L.strDestinationPort
    ,L.strDestinationCity
    ,L.intTerminalEntityId
    ,L.intShippingLineEntityId
    ,L.strServiceContractNumber
    ,L.strFreightInfo
    ,L.strPackingDescription
    ,L.strMVessel
    ,L.strMVoyageNumber
    ,L.strFVessel
    ,L.strFVoyageNumber
    ,L.strIMONumber
    ,L.intForwardingAgentEntityId
    ,L.strForwardingAgentRef
    ,L.intInsurerEntityId
    ,L.strInsurancePolicyRefNo
    ,L.dblInsuranceValue
    ,L.dblInsurancePremiumPercentage
    ,L.intInsuranceCurrencyId
    ,L.dtmDocsToBroker
    ,L.strMarks
    ,L.strMarkingInstructions
    ,L.strShippingMode
    ,L.intNumberOfContainers
    ,L.intContainerTypeId
    ,L.intBLDraftToBeSentId
    ,L.strBLDraftToBeSentType
    ,L.strDocPresentationType
    ,L.intDocPresentationId
    ,L.ysnPosted
    ,L.dtmPostedDate
    ,L.dtmDocsReceivedDate
    ,L.dtmETAPOL
    ,L.dtmETSPOL
    ,L.dtmETAPOD
    ,L.dtmDeadlineCargo
    ,L.dtmDeadlineBL
    ,L.dtmISFReceivedDate
    ,L.dtmISFFiledDate
    ,L.dtmStuffingDate
    ,L.dtmStartDate
    ,L.dtmEndDate
    ,L.dtmPlannedAvailabilityDate
	,L.dtmCashFlowDate
	,L.ysnCashFlowOverride
    ,L.ysnArrivedInPort
    ,L.ysnDocumentsApproved
    ,L.ysnCustomsReleased
    ,L.dtmArrivedInPort
    ,L.dtmDocumentsApproved
    ,L.dtmCustomsReleased
	,L.dtmLoadExpiration
    ,L.strVessel1
    ,L.strOriginPort1
    ,L.strDestinationPort1
    ,L.dtmETSPOL1
    ,L.dtmETAPOD1
    ,L.strVessel2
    ,L.strOriginPort2
    ,L.strDestinationPort2
    ,L.dtmETSPOL2
    ,L.dtmETAPOD2
    ,L.strVessel3
    ,L.strOriginPort3
    ,L.strDestinationPort3
    ,L.dtmETSPOL3
    ,L.dtmETAPOD3
    ,L.strVessel4
    ,L.strOriginPort4
    ,L.strDestinationPort4
    ,L.dtmETSPOL4
    ,L.dtmETAPOD4
    ,L.dblDemurrage
    ,L.intDemurrageCurrencyId
    ,L.dblDespatch
    ,L.intDespatchCurrencyId
    ,L.dblLoadingRate
    ,L.intLoadingUnitMeasureId
    ,L.strLoadingPerUnit
    ,L.dblDischargeRate
    ,L.intDischargeUnitMeasureId
    ,L.strDischargePerUnit
    ,L.intShipmentType
    ,L.intLoadShippingInstructionId
    ,L.strExternalShipmentNumber
    ,L.ysn4cRegistration
    ,L.ysnInvoice
    ,L.ysnProvisionalInvoice
    ,L.strCourierTrackingNumber
    ,L.str4CLicenseNumber
    ,L.strExternalERPReferenceNumber
    ,L.ysnQuantityFinal
    ,L.ysnCancelled
    ,L.intShippingModeId
    ,L.intETAPOLReasonCodeId
    ,L.intETSPOLReasonCodeId
    ,L.intETAPODReasonCodeId
    ,L.intFreightTermId
    ,L.intCurrencyId
    ,L.strGenerateLoadEquipmentType
    ,L.strGenerateLoadHauler
    ,L.ysnDocumentsReceived
    ,L.ysnSubCurrency
    ,L.intBookId
    ,L.intSubBookId
    ,L.ysnLoadBased
    ,L.intConcurrencyId
	,strType = CASE L.intPurchaseSale
		WHEN 1 THEN 'Inbound'
		WHEN 2 THEN 'Outbound'
		WHEN 3 THEN 'Drop Ship'
		END COLLATE Latin1_General_CI_AS
	,strEquipmentType = EQ.strEquipmentType
	,strPosition = P.strPosition
	,strPositionType = P.strPositionType
	,strHauler = Hauler.strName
	,strWeightUnitMeasure = UM.strUnitMeasure
	,strScaleTicketNo = CASE 
		WHEN IsNull(L.intTicketId, 0) <> 0
			THEN CAST(ST.strTicketNumber AS VARCHAR(100))
		WHEN IsNull(L.intLoadHeaderId, 0) <> 0
			THEN TR.strTransaction
		ELSE NULL END
	,intGenerateReferenceNumber = GL.intReferenceNumber
	,intNumberOfLoads = GL.intNumberOfLoads
	,strDispatcher = SE.strUserName
	,strShippingInstructionNo = SI.strLoadNumber
	,FT.strFreightTerm
	,FT.strFobPoint
	,CU.strCurrency
	,CONT.strContainerType
	,intLeadTime = ISNULL(DPort.intLeadTime, 0)
	,strShippingLine = ShippingLine.strName
	,strServiceContractOwner = SLSC.strOwner
	,strTerminal = Terminal.strName
	,strForwardingAgent = ForwardingAgent.strName
	,strInsurer = Insurer.strName
	,strInsuranceCurrency = Currency.strCurrency
	,strBLDraftToBeSent = BLDraftToBeSent.strName
	,strDocPresentationVal = NP.strName 
	,strETAPODReasonCode = ETAPODRC.strReasonCodeDescription
	,strETAPOLReasonCode = ETAPOLRC.strReasonCodeDescription
	,strETSPOLReasonCode = ETSPOLRC.strReasonCodeDescription
	,strDemurrageCurrency = DemurrageCurrency.strCurrency
	,strDespatchCurrency = DespatchCurrency.strCurrency
	,strLoadingUnitMeasure = LoadingUnit.strUnitMeasure
	,strDischargeUnitMeasure = DischargeUnit.strUnitMeasure
	,strDriver = Driver.strName
	,BO.strBook
	,SB.strSubBook
	,INC.intInsuranceCalculatorId
	,L.ysnAllowReweighs
	,L.dblFreightRate
	,L.dblSurcharge
	,L.intTermId
FROM tblLGLoad L
LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = L.intGenerateLoadId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = L.intTerminalEntityId
LEFT JOIN tblEMEntity ForwardingAgent ON ForwardingAgent.intEntityId = L.intForwardingAgentEntityId
LEFT JOIN tblEMEntity Insurer ON Insurer.intEntityId = L.intInsurerEntityId
LEFT JOIN tblEMEntity BLDraftToBeSent ON BLDraftToBeSent.intEntityId = L.intBLDraftToBeSentId
LEFT JOIN tblCTPosition P ON L.intPositionId = P.intPositionId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = L.intWeightUnitMeasureId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId
LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
LEFT JOIN tblSMUserSecurity SE ON SE.intEntityId = L.intDispatcherId
LEFT JOIN tblLGLoad SI ON SI.intLoadId = L.intLoadShippingInstructionId
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = L.intCurrencyId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = L.intInsuranceCurrencyId
LEFT JOIN tblLGContainerType CONT ON CONT.intContainerTypeId = L.intContainerTypeId
LEFT JOIN vyuLGNotifyParties NP ON NP.intEntityId = L.intDocPresentationId AND NP.strEntity = L.strDocPresentationType
LEFT JOIN tblLGReasonCode ETAPODRC ON ETAPODRC.intReasonCodeId = L.intETAPODReasonCodeId
LEFT JOIN tblLGReasonCode ETAPOLRC ON ETAPOLRC.intReasonCodeId = L.intETAPOLReasonCodeId
LEFT JOIN tblLGReasonCode ETSPOLRC ON ETSPOLRC.intReasonCodeId = L.intETSPOLReasonCodeId
LEFT JOIN tblSMCurrency DemurrageCurrency ON DemurrageCurrency.intCurrencyID = L.intDemurrageCurrencyId
LEFT JOIN tblSMCurrency DespatchCurrency ON DespatchCurrency.intCurrencyID = L.intDespatchCurrencyId
LEFT JOIN tblICUnitMeasure LoadingUnit ON LoadingUnit.intUnitMeasureId = L.intLoadingUnitMeasureId
LEFT JOIN tblICUnitMeasure DischargeUnit ON DischargeUnit.intUnitMeasureId = L.intDischargeUnitMeasureId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
LEFT JOIN tblLGInsuranceCalculator INC ON INC.intLoadId = L.intLoadId
LEFT JOIN tblSMTerm TM ON TM.intTermID = L.intTermId
OUTER APPLY (SELECT TOP 1 intLeadTime FROM tblSMCity DPort 
				WHERE DPort.strCity = L.strDestinationPort AND DPort.ysnPort = 1) DPort
OUTER APPLY (SELECT TOP 1 strOwner FROM tblLGShippingLineServiceContractDetail SLSCD
				INNER JOIN tblLGShippingLineServiceContract SLSC ON SLSCD.intShippingLineServiceContractId = SLSC.intShippingLineServiceContractId
				WHERE SLSC.intEntityId = L.intShippingLineEntityId AND SLSCD.strServiceContractNumber = L.strServiceContractNumber) SLSC

GO