﻿CREATE VIEW vyuLGLoadVesselViewSearch
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
		WHEN 1
			THEN 'Shipment'
		WHEN 2
			THEN 'Shipping Instructions'
		WHEN 3
			THEN 'Vessel Nomination'
		ELSE ''
		END COLLATE Latin1_General_CI_AS
FROM tblLGLoad L
LEFT JOIN tblEMEntity Terminal ON Terminal.intEntityId = L.intTerminalEntityId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblEMEntity ForwardingAgent ON ForwardingAgent.intEntityId = L.intForwardingAgentEntityId
LEFT JOIN tblEMEntity Insurer ON Insurer.intEntityId = L.intInsurerEntityId
LEFT JOIN tblSMCurrency Currency ON Currency.intCurrencyID = L.intInsuranceCurrencyId
LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = L.intContainerTypeId
LEFT JOIN tblLGLoad LSI ON LSI.intLoadId = L.intLoadShippingInstructionId
WHERE ISNULL(L.strBLNumber,'') <> ''