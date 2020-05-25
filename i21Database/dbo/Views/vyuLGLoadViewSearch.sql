CREATE VIEW vyuLGLoadViewSearch
AS
SELECT L.intLoadId
	,L.intGenerateLoadId
	,L.intHaulerEntityId
	,L.strLoadNumber
	,L.strExternalLoadNumber
	,L.strExternalShipmentNumber
	,L.strTruckNo
	,L.strBLNumber
	,L.dtmETAPOD
	,L.dtmETAPOL
	,L.dtmETSPOL
	,strSourceType = CASE L.intSourceType
		WHEN 1 THEN 'None'
		WHEN 2 THEN 'Contracts'
		WHEN 3 THEN 'Orders'
		WHEN 4 THEN 'Allocations'
		WHEN 5 THEN 'Picked Lots'
		WHEN 6 THEN 'Pick Lots'
		WHEN 7 THEN 'Pick Lots w/o Contract'
		END COLLATE Latin1_General_CI_AS
	,strType = CASE L.intPurchaseSale
		WHEN 1 THEN 'Inbound'
		WHEN 2 THEN 'Outbound'
		WHEN 3 THEN 'Drop Ship'
		END COLLATE Latin1_General_CI_AS
	,strTransportationMode = CASE L.intTransportationMode
		WHEN 1 THEN 'Truck'
		WHEN 2 THEN 'Ocean Vessel'
		WHEN 3 THEN 'Rail'
		END COLLATE Latin1_General_CI_AS
	,intGenerateReferenceNumber = GL.intReferenceNumber
	,L.intGenerateSequence
	,L.ysnLoadBased
	,intNumberOfLoads = GL.intNumberOfLoads
	,L.dtmScheduledDate
	,strHauler = Hauler.strName
	,strDriver = Driver.strName
	,ysnDispatched = CASE WHEN L.ysnDispatched = 1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	,strPosition = P.strPosition
	,strPositionType = P.strPositionType
	,strWeightUnitMeasure = UM.strUnitMeasure
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
	,strEquipmentType = EQ.strEquipmentType
    ,L.strTrailerNo1
    ,L.strTrailerNo2
    ,L.strTrailerNo3
	,L.strCarNumber
    ,L.strEmbargoNo
    ,L.strEmbargoPermitNo
	,L.strComments
	,L.strBOLInstructions
	,L.ysnPosted
    ,ysnInProgress = ISNULL(L.ysnInProgress, 0)
	,strTransUsedBy = CASE L.intTransUsedBy
		WHEN 2 THEN 'Scale'
		WHEN 3 THEN 'Transport Load'
		ELSE 'None' END COLLATE Latin1_General_CI_AS
    ,strScaleTicketNo = CASE WHEN IsNull(L.intTicketId, 0) <> 0 THEN CAST(ST.strTicketNumber AS VARCHAR(100))
							WHEN IsNull(L.intLoadHeaderId, 0) <> 0 THEN TR.strTransaction
							ELSE NULL END 
	,L.dtmDeliveredDate
	,L.dtmDispatchedDate
	,L.ysnDispatchMailSent
	,L.dtmDispatchMailSent
	,L.dtmCancelDispatchMailSent
	,L.intLoadShippingInstructionId
	,L.intShipmentType
	,LSI.strLoadNumber AS strShippingInstructionNo
	,strShipmentType = CASE L.intShipmentType
		WHEN 1 THEN 'Shipment'
		WHEN 2 THEN 'Shipping Instructions'
		WHEN 3 THEN 'Vessel Nomination'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,CT.strContainerType
	,strForwardingAgent = ForwardingAgent.strName
	,strShippingLine = ShippingLine.strName
	,strInsurer = Insurer.strName
	,strTerminal = Terminal.strName
	,L.strCourierTrackingNumber
	,L.str4CLicenseNumber
	,L.strExternalERPReferenceNumber
	,strBLDraftToBeSent = BLDraftToBeSent.strName
	,strDocPresentationVal = DocPresentation.strName
	,strInsuranceCurrency = Currency.strCurrency
	,strDemurrangeCurrency = DemurrangeCurrency.strCurrency
	,strDespatchCurrency = DespatchCurrency.strCurrency
	,strLoadingUnitMeasure = LoadingUnitMeasure.strUnitMeasure
	,strDischargeUnitMeasure = DischargeUnitMeasure.strUnitMeasure
	,strETAPOLReasonCode = ETAPOLRC.strReasonCode
	,strETSPOLReasonCode = ETSPOLRC.strReasonCode
	,strETAPODReasonCode = ETAPODRC.strReasonCode
	,strETAPOLReasonCodeDescription = ETAPOLRC.strReasonCodeDescription
	,strETSPOLReasonCodeDescription = ETSPOLRC.strReasonCodeDescription
	,strETAPODReasonCodeDescription = ETAPODRC.strReasonCodeDescription
	,L.ysnArrivedInPort
	,L.dtmArrivedInPort
	,L.ysnDocumentsApproved
	,L.dtmDocumentsApproved
	,L.ysnCustomsReleased
	,L.dtmCustomsReleased
	,L.intFreightTermId
	,FT.strFreightTerm
	,L.intCurrencyId
	,HeaderCurrency.strCurrency
	,L.intBookId
	,BO.strBook
	,L.intSubBookId
	,SB.strSubBook
FROM tblLGLoad L
LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = L.intGenerateLoadId
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblEMEntity ForwardingAgent ON ForwardingAgent.intEntityId = L.intForwardingAgentEntityId
LEFT JOIN tblEMEntity Insurer ON Insurer.intEntityId = L.intInsurerEntityId
LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = L.intTerminalEntityId
LEFT JOIN tblEMEntity BLDraftToBeSent ON BLDraftToBeSent.intEntityId = L.intBLDraftToBeSentId
LEFT JOIN tblEMEntity DocPresentation ON DocPresentation.intEntityId = L.intDocPresentationId
LEFT JOIN tblCTPosition P ON L.intPositionId = P.intPositionId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = L.intWeightUnitMeasureId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSCTicket ST ON ST.intTicketId = L.intTicketId
LEFT JOIN tblTRLoadHeader TR ON TR.intLoadHeaderId = L.intLoadHeaderId
LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
LEFT JOIN tblSMCurrency HeaderCurrency ON HeaderCurrency .intCurrencyID = L.intCurrencyId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = L.intInsuranceCurrencyId
LEFT JOIN tblSMCurrency DemurrangeCurrency ON DemurrangeCurrency.intCurrencyID = L.intDemurrageCurrencyId
LEFT JOIN tblSMCurrency DespatchCurrency ON DespatchCurrency.intCurrencyID = L.intDespatchCurrencyId
LEFT JOIN tblICUnitMeasure LoadingUnitMeasure ON LoadingUnitMeasure.intUnitMeasureId = L.intLoadingUnitMeasureId
LEFT JOIN tblICUnitMeasure DischargeUnitMeasure ON DischargeUnitMeasure .intUnitMeasureId = L.intDischargeUnitMeasureId
LEFT JOIN tblLGReasonCode ETAPOLRC ON ETAPOLRC.intReasonCodeId = L.intETAPOLReasonCodeId
LEFT JOIN tblLGReasonCode ETSPOLRC ON ETSPOLRC.intReasonCodeId = L.intETSPOLReasonCodeId
LEFT JOIN tblLGReasonCode ETAPODRC ON ETAPODRC.intReasonCodeId = L.intETAPODReasonCodeId
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId