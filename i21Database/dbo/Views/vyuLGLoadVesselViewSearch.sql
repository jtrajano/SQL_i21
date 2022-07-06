CREATE VIEW vyuLGLoadVesselViewSearch
AS
SELECT  L.intLoadId
	   ,L.intGenerateLoadId
	   ,L.strLoadNumber
	   ,L.strBookingReference
	   ,L.strBLNumber
	   ,L.dtmBLDate
	   ,L.strOriginPort
	   ,L.strDestinationPort
	   ,L.strDestinationCity
	   ,L.strServiceContractNumber
	   ,L.strPackingDescription
	   ,L.strMVessel
	   ,L.strMVoyageNumber
	   ,L.strFVessel
	   ,L.strFVoyageNumber
	   ,L.strIMONumber
	   ,L.dblInsuranceValue
	   ,L.strShippingMode
	   ,L.intNumberOfContainers
	   ,L.strDocPresentationType
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
	   ,L.dtmDocsToBroker
	   ,L.ysnArrivedInPort
	   ,L.ysnDocumentsApproved
	   ,L.ysnCustomsReleased
	   ,L.dtmArrivedInPort
	   ,L.dtmDocumentsApproved
	   ,L.dtmCustomsReleased
	   ,L.strForwardingAgentRef
	   ,strTerminal =  Terminal.strName
	   ,[strShippingLine] =  ShippingLine.strName
	   ,[strForwardingAgent] = ForwardingAgent.strName
	   ,[strInsurer] = Insurer.strName
	   ,[strInsuranceCurrency] = Currency.strCurrency
	   ,[strContainerType] = CT.strContainerType
	   ,L.intLoadShippingInstructionId
	   ,L.intShipmentType
	   ,LSI.strLoadNumber AS strShippingInstructionNo
	   ,strShipmentType = CASE L.intShipmentType
			WHEN 1 THEN 'Shipment'
			WHEN 2 THEN 'Shipping Instructions'
			WHEN 3 THEN 'Vessel Nomination'
			ELSE '' END COLLATE Latin1_General_CI_AS
		,strShipmentStatus = CASE L.intShipmentStatus
			WHEN 1 THEN 
				CASE WHEN (L.dtmLoadExpiration IS NOT NULL AND GETDATE() > L.dtmLoadExpiration AND L.intShipmentType = 1
						AND L.intTicketId IS NULL AND L.intLoadHeaderId IS NULL)
				THEN 'Expired'
				ELSE 'Scheduled' END
			WHEN 2 THEN 'Dispatched'
			WHEN 3 THEN 
				CASE WHEN (L.ysnDocumentsApproved = 1 
						AND L.dtmDocumentsApproved IS NOT NULL
						AND ((L.dtmDocumentsApproved > L.dtmArrivedInPort OR L.dtmArrivedInPort IS NULL)
						AND (L.dtmDocumentsApproved > L.dtmCustomsReleased OR L.dtmCustomsReleased IS NULL))) 
						THEN 'Documents Approved'
					WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Inbound Transit' END
			WHEN 4 THEN 'Received'
			WHEN 5 THEN 
				CASE WHEN (L.ysnDocumentsApproved = 1 
						AND L.dtmDocumentsApproved IS NOT NULL
						AND ((L.dtmDocumentsApproved > L.dtmArrivedInPort OR L.dtmArrivedInPort IS NULL)
						AND (L.dtmDocumentsApproved > L.dtmCustomsReleased OR L.dtmCustomsReleased IS NULL))) 
						THEN 'Documents Approved'
					WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Outbound Transit' END
			WHEN 6 THEN 
				CASE WHEN (L.ysnDocumentsApproved = 1 
						AND L.dtmDocumentsApproved IS NOT NULL
						AND ((L.dtmDocumentsApproved > L.dtmArrivedInPort OR L.dtmArrivedInPort IS NULL)
						AND (L.dtmDocumentsApproved > L.dtmCustomsReleased OR L.dtmCustomsReleased IS NULL))) 
						THEN 'Documents Approved'
					WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
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
	   ,L.intBookId
	   ,BO.strBook
	   ,L.intSubBookId
	   ,SB.strSubBook
FROM tblLGLoad L
LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = L.intTerminalEntityId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblEMEntity ForwardingAgent ON ForwardingAgent.intEntityId = L.intForwardingAgentEntityId
LEFT JOIN tblEMEntity Insurer ON Insurer.intEntityId = L.intInsurerEntityId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = L.intInsuranceCurrencyId
LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
WHERE ISNULL(L.strBLNumber,'') <> ''