﻿CREATE VIEW vyuLGLoadViewSearch
AS
SELECT L.intLoadId
	,L.intGenerateLoadId
	,L.intHaulerEntityId
	,L.strLoadNumber
	,L.strExternalLoadNumber
	,L.strExternalShipmentNumber
	,strTruckNo = CASE WHEN (L.intTransUsedBy = 2) THEN L.strTruckNo ELSE SVT.strTruckNumber END
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
		WHEN 8 THEN 'TM Orders'
		END COLLATE Latin1_General_CI_AS
	,strType = CASE L.intPurchaseSale 
		WHEN 1 THEN 'Inbound'
		WHEN 2 THEN 'Outbound'
		WHEN 3 THEN 'Drop Ship'
		WHEN 4 THEN 'Transfer'
		END COLLATE Latin1_General_CI_AS
	,strTransportationMode = CASE L.intTransportationMode
		WHEN 1 THEN 'Truck'
		WHEN 2 THEN 'Ocean Vessel'
		WHEN 3 THEN 'Rail'
		WHEN 4 THEN 'Multimodal'
		END COLLATE Latin1_General_CI_AS
	,intGenerateReferenceNumber = GL.intReferenceNumber
	,L.intGenerateSequence
	,L.ysnLoadBased
	,intNumberOfLoads = GL.intNumberOfLoads
	,L.dtmScheduledDate
	,strHauler = Hauler.strName
	,strDriver = Driver.strName
	,ysnDispatched = ISNULL(L.ysnDispatched, 0)
	,strPosition = P.strPosition
	,strPositionType = P.strPositionType
	,strWeightUnitMeasure = UM.strUnitMeasure
	,strShipmentStatus = LSS.strShipmentStatus
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
		WHEN 2 THEN 'Scale Ticket'
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
	,strShippingInstructionNo = LSI.strLoadNumber
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
	,L.ysnAllowReweighs
	,L.ysnShowOptionality
	,L.ysnCancelled
FROM tblLGLoad L
JOIN vyuLGShipmentStatus LSS ON LSS.intLoadId = L.intLoadId
LEFT JOIN tblLGGenerateLoad GL ON GL.intGenerateLoadId = L.intGenerateLoadId
OUTER APPLY (SELECT TOP 1 strName FROM tblEMEntityType ET
			INNER JOIN tblEMEntity EM ON EM.intEntityId = ET.intEntityId 
			WHERE strType = 'Hauler'
			and ET.intEntityId = L.intHaulerEntityId) Hauler
OUTER APPLY (SELECT TOP 1 strName FROM tblEMEntityType ET
			INNER JOIN tblEMEntity EM ON EM.intEntityId = ET.intEntityId 
			WHERE strType = 'Salesperson'
			and ET.intEntityId = L.intDriverEntityId) Driver
OUTER APPLY (SELECT TOP 1 strName FROM tblEMEntityType ET
			INNER JOIN tblEMEntity EM ON EM.intEntityId = ET.intEntityId 
			WHERE strType = 'Shipping Line'
			and ET.intEntityId = L.intShippingLineEntityId) ShippingLine
OUTER APPLY (SELECT TOP 1 strName FROM tblEMEntityType ET
			INNER JOIN tblEMEntity EM ON EM.intEntityId = ET.intEntityId 
			WHERE strType = 'Forwarding Agent'
			and ET.intEntityId = L.intForwardingAgentEntityId) ForwardingAgent
OUTER APPLY (SELECT TOP 1 strName FROM tblEMEntityType ET
			INNER JOIN tblEMEntity EM ON EM.intEntityId = ET.intEntityId 
			WHERE strType = 'Insurer'
			and ET.intEntityId = L.intInsurerEntityId) Insurer
OUTER APPLY (SELECT TOP 1 strName FROM tblEMEntityType ET
			INNER JOIN tblEMEntity EM ON EM.intEntityId = ET.intEntityId 
			WHERE strType = 'Terminal'
			and ET.intEntityId = L.intTerminalEntityId) Terminal
OUTER APPLY (SELECT TOP 1 strName FROM tblEMEntityType ET
			INNER JOIN tblEMEntity EM ON EM.intEntityId = ET.intEntityId 
			WHERE strType IN ('Shipping Line', 'Forwarding Agent')
			and ET.intEntityId = L.intShippingLineEntityId) BLDraftToBeSent
OUTER APPLY (SELECT TOP 1 strName FROM tblEMEntityType ET
			INNER JOIN tblEMEntity EM ON EM.intEntityId = ET.intEntityId 
			WHERE strType IN ('Vendor', 'Customer','Forwarding Agent','Shipping Line','Terminal')
			and ET.intEntityId = L.intDocPresentationId) DocPresentation
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
LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = L.intTruckId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
