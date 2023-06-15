﻿CREATE VIEW vyuLGLoadDocumentTracking
AS
SELECT CH.strContractNumber
	,CH.intContractHeaderId
	,CD.intContractSeq
	,CDJ.strOrigin AS strOrigin
	,CDJ.strERPPONumber AS strERPPONumber
	,CDJ.strDestinationPoint AS strDestinationPoint
	,CDJ.strShipper AS strVesselShipper
	,CDJ.strCertificationName AS strCertificationName
	,strVendorName = Vendor.strName 
	,strCustomerName = Customer.strName
	,I.strItemNo
	,L.intLoadId
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
		WHEN 4 THEN 'Transfer'
		END COLLATE Latin1_General_CI_AS
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
	,strTransportationMode = CASE L.intTransportationMode
		WHEN 1 THEN 'Truck'
		WHEN 2 THEN 'Ocean Vessel'
		WHEN 3 THEN 'Rail'
		WHEN 4 THEN 'Multimodal'
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
	,intNumberOfLoads = GLoad.intNumberOfLoads
	,strHauler = Hauler.strName
	,L.dtmScheduledDate
	,ysnInProgress = IsNull(L.ysnInProgress, 0)
	,L.dtmDeliveredDate
	,strEquipmentType = EQ.strEquipmentType
	,strDriver = Driver.strName
	,strDispatcher = US.strUserName
	,L.strCustomerReference
	,strTruckNo = CASE WHEN (L.intTransUsedBy = 2) THEN L.strTruckNo ELSE SVT.strTruckNumber END
	,L.strTrailerNo1
	,L.strTrailerNo2
	,L.strTrailerNo3
	,L.strCarNumber
	,L.strEmbargoNo
	,L.strEmbargoPermitNo
	,L.strComments
	,ysnDispatched = CAST(CASE WHEN L.ysnDispatched = 1 THEN 1 ELSE 0 END AS BIT)
	,L.dtmDispatchedDate
	,L.ysnDispatchMailSent
	,L.dtmDispatchMailSent
	,L.dtmCancelDispatchMailSent
	,strShipmentStatus = LSS.strShipmentStatus
	,strCalenderInfo = L.[strLoadNumber] + ' - ' + LSS.strShipmentStatus + 
		CASE WHEN ISNULL(L.strExternalLoadNumber, '') <> ''
			THEN ' - ' + '(S) ' + L.strExternalLoadNumber
		ELSE ''
		END + CASE 
		WHEN ISNULL(L.strCustomerReference, '') <> ''
			THEN ' - ' + '(C) ' + L.strCustomerReference
		ELSE ''
		END COLLATE Latin1_General_CI_AS
	,L.intPositionId
	,L.[intWeightUnitMeasureId]
	,strWeightUnitMeasure = [strUnitMeasure]
	,[strBLNumber] = ISNULL([strBLNumber], '') 
	,[dtmBLDate]
	,[strOriginPort]
	,[strDestinationPort]
	,[strDestinationCity]
	,[intTerminalEntityId]
	,[strTerminal] = Terminal.strName
	,[intShippingLineEntityId]
	,[strShippingLine] = ShippingLine.strName
	,[strServiceContractNumber]
	,L.[strPackingDescription]
	,[strMVessel]
	,[strMVoyageNumber]
	,[strFVessel]
	,[strFVoyageNumber]
	,[intForwardingAgentEntityId]
	,[strForwardingAgent] = ForwardingAgent.strName
	,[strForwardingAgentRef]
	,[intShipperEntityId]
	,[strShipper] = Shipper.strName
	,[intInsurerEntityId]
	,[strInsurer] = Insurer.strName
	,[dblInsuranceValue]
	,[intInsuranceCurrencyId]
	,[strInsuranceCurrency] = Currency.strCurrency
	,[dtmDocsToBroker]
	,[strMarks]
	,[strMarkingInstructions]
	,[strShippingMode]
	,L.[intNumberOfContainers]
	,L.[intContainerTypeId]
	,[strContainerType] = CT.strContainerType
	,[intBLDraftToBeSentId]
	,[strBLDraftToBeSentType]
	,[strBLDraftToBeSent] = BLDraftToBeSent.strName
	,[strDocPresentationType]
	,[strDocPresentationVal] = NP.strName
	,[intDocPresentationId]
	,L.[ysnPosted]
	,L.[dtmPostedDate]
	,[dtmDocsReceivedDate]
	,[dtmETAPOL]
	,[dtmETSPOL]
	,[dtmETAPOD]
	,intDaysToETAPOD = DATEDIFF(DAY, CONVERT(NVARCHAR(100), dtmETAPOD, 101), CONVERT(NVARCHAR(100), GETDATE(), 101))
	,intDaysToETAPOL = DATEDIFF(DAY, CONVERT(NVARCHAR(100), dtmETAPOL, 101), CONVERT(NVARCHAR(100), GETDATE(), 101))
	,intDaysToETSPOL = DATEDIFF(DAY, CONVERT(NVARCHAR(100), dtmETSPOL, 101), CONVERT(NVARCHAR(100), GETDATE(), 101))
	,[dtmDeadlineCargo]
	,[dtmDeadlineBL]
	,[dtmISFReceivedDate]
	,[dtmISFFiledDate]
	,[dblDemurrage]
	,[intDemurrageCurrencyId]
	,[dblDespatch]
	,[intDespatchCurrencyId]
	,[dblLoadingRate]
	,[intLoadingUnitMeasureId]
	,[strLoadingPerUnit]
	,[dblDischargeRate]
	,[intDischargeUnitMeasureId]
	,[strDischargePerUnit]
	,L.[intTransportationMode]
	,[intShipmentStatus]
	,LDOC.intLoadDocumentId
	,LDOC.intDocumentId
	,LDOC.strDocumentType
	,LDOC.intOriginal
	,LDOC.intCopies
	,LDOC.ysnSent
	,LDOC.dtmSentDate
	,LDOC.ysnReceived
	,LDOC.dtmReceivedDate
	,LDOC.ysnReceivedCopy
	,LDOC.dtmCopyReceivedDate
	,DOC.strDocumentName
	,LDOC.strDocumentNo
	,LD.dblQuantity
	,L.ysnInvoice
	,L.ysn4cRegistration
	,L.ysnProvisionalInvoice
	,L.ysnQuantityFinal
	,L.intBookId
	,BO.strBook
	,L.intSubBookId
	,SB.strSubBook
FROM tblLGLoad L
JOIN vyuLGShipmentStatus LSS ON LSS.intLoadId = L.intLoadId
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = (
		CASE 
			WHEN L.intPurchaseSale = 1
				THEN LD.intPContractDetailId
			ELSE LD.intSContractDetailId
			END
		)
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem I ON I.intItemId = LD.intItemId
JOIN tblLGLoadDocuments LDOC ON LDOC.intLoadId = L.intLoadId
JOIN tblICDocument DOC ON DOC.intDocumentId = LDOC.intDocumentId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = L.intWeightUnitMeasureId
OUTER APPLY (SELECT TOP 1 strName FROM tblEMEntity Customer WHERE Customer.intEntityId = LD.intCustomerEntityId) Customer
OUTER APPLY (SELECT TOP 1 strName FROM tblEMEntity Vendor WHERE Vendor.intEntityId = LD.intVendorEntityId) Vendor
LEFT JOIN tblEMEntity Hauler ON Hauler.intEntityId = L.intHaulerEntityId
LEFT JOIN tblEMEntity Driver ON Driver.intEntityId = L.intDriverEntityId
LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = L.intTerminalEntityId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblEMEntity ForwardingAgent ON ForwardingAgent.intEntityId = L.intForwardingAgentEntityId
LEFT JOIN tblEMEntity Shipper ON Shipper.intEntityId = L.intShipperEntityId
LEFT JOIN tblEMEntity Insurer ON Insurer.intEntityId = L.intInsurerEntityId
LEFT JOIN tblEMEntity BLDraftToBeSent ON BLDraftToBeSent.intEntityId = L.intBLDraftToBeSentId
LEFT JOIN vyuLGNotifyParties NP ON NP.intEntityId = L.intDocPresentationId
	AND NP.strEntity = L.strDocPresentationType
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = L.intInsuranceCurrencyId
LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
LEFT JOIN tblLGEquipmentType EQ ON EQ.intEquipmentTypeId = L.intEquipmentTypeId
LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = L.intTruckId
LEFT JOIN tblSMUserSecurity US ON US.[intEntityId] = L.intDispatcherId
LEFT JOIN tblCTPosition P ON L.intPositionId = P.intPositionId
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = L.intGenerateLoadId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
LEFT JOIN tblSMCity DP WITH(NOLOCK) ON DP.intCityId = CD.intDestinationPortId
LEFT JOIN tblEMEntity EP WITH(NOLOCK) ON EP.intEntityId = CD.intShipperId
LEFT JOIN  (
	SELECT
	strContractNumber
	,strOrigin
	,strERPPONumber
	,strDestinationPoint
	,strShipper
	,strCertificationName
	FROM vyuCTDashboardJDE) AS CDJ on CDJ.strContractNumber = CH.strContractNumber
WHERE L.intShipmentType = 1