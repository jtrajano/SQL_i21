CREATE VIEW vyuCTLoadView 

AS

	WITH Shipment AS
	(
		SELECT   LO.strLoadNumber
				,SL.strName	AS strLoadShippingLine
				,LO.strOriginPort
				,LO.strDestinationPort
				,LO.strMVessel
				,LO.strMVoyageNumber
				,LO.strFVessel
				,LO.strFVoyageNumber
				,LO.strBLNumber
				,LD.dblQuantity
				,ISNULL(LD.intPContractDetailId,LD.intSContractDetailId) intContractDetailId
				,LO.intShipmentType
				,'Shipment' COLLATE Latin1_General_CI_AS AS strShipmentType
				,LO.dtmETAPOL
				,LO.dtmETAPOD
				,LO.dtmStuffingDate
				,LO.dtmETSPOL
				,LO.dtmDeadlineCargo
				,LO.ysnDocumentsReceived AS ysnDocsReceived
				,LD.strContainerNumbers AS strContainerNumber
				,LO.strBookingReference
				,LO.intLoadId
				,strETAPOLReasonCode = EA.strReasonCode
				,strETSPOLReasonCode = ES.strReasonCode
				,strETAPODReasonCode = PD.strReasonCode
				,strETAPOLReasonCodeDescription = EA.strReasonCodeDescription
				,strETSPOLReasonCodeDescription = ES.strReasonCodeDescription
				,strETAPODReasonCodeDescription = PD.strReasonCodeDescription
				,strForwardingAgentEntity = FA.strName

		FROM	tblLGLoad			LO
		JOIN	tblLGLoadDetail		LD ON LD.intLoadId			=	LO.intLoadId 
LEFT	JOIN	tblEMEntity			SL ON SL.intEntityId		=	LO.intShippingLineEntityId
LEFT	JOIN	tblLGReasonCode		EA ON EA.intReasonCodeId	=	LO.intETAPOLReasonCodeId
LEFT	JOIN	tblLGReasonCode		ES ON ES.intReasonCodeId	=	LO.intETSPOLReasonCodeId
LEFT	JOIN	tblLGReasonCode		PD ON PD.intReasonCodeId	=	LO.intETAPODReasonCodeId
LEFT	JOIN	tblEMEntity FA on FA.intEntityId = LO.intForwardingAgentEntityId
		WHERE	LO.intShipmentType = 1
		AND		LO.intShipmentStatus <> 10
	
	
	)
	SELECT	 strLoadNumber
			,strLoadShippingLine
			,strOriginPort
			,strDestinationPort
			,strMVessel
			,strMVoyageNumber
			,strFVessel
			,strFVoyageNumber
			,strBLNumber
			,SUM(dblQuantity)  dblLoadQuantity
			,intContractDetailId
			,intShipmentType
			,strShipmentType
			,strContainerNumber
			,ysnDocsReceived
			,dtmETAPOL
			,dtmETAPOD
			,dtmStuffingDate
			,dtmETSPOL
			,dtmDeadlineCargo
			,strBookingReference
			,intLoadId
			,strETAPOLReasonCode 
			,strETSPOLReasonCode
			,strETAPODReasonCode
			,strETAPOLReasonCodeDescription
			,strETSPOLReasonCodeDescription
			,strETAPODReasonCodeDescription
			,strForwardingAgentEntity

	FROM
	(
		SELECT * FROM Shipment

		UNION ALL

		SELECT   LO.strLoadNumber
				,SL.strName
				,LO.strOriginPort
				,LO.strDestinationPort
				,LO.strMVessel
				,LO.strMVoyageNumber
				,LO.strFVessel
				,LO.strFVoyageNumber
				,LO.strBLNumber
				,LD.dblQuantity 
				,ISNULL(LD.intPContractDetailId,LD.intSContractDetailId) intContractDetailId
				,LO.intShipmentType
				,'Shipping Instructions' COLLATE Latin1_General_CI_AS AS strShipmentType
				,LO.dtmETAPOL
				,LO.dtmETAPOD
				,LO.dtmStuffingDate
				,LO.dtmETSPOL
				,LO.dtmDeadlineCargo
				,LO.ysnDocumentsReceived AS ysnDocsReceived
				,NULL strContainerNumber
				,LO.strBookingReference
				,LO.intLoadId
				,strETAPOLReasonCode = EA.strReasonCode
				,strETSPOLReasonCode = ES.strReasonCode
				,strETAPODReasonCode = PD.strReasonCode
				,strETAPOLReasonCodeDescription = EA.strReasonCodeDescription
				,strETSPOLReasonCodeDescription = ES.strReasonCodeDescription
				,strETAPODReasonCodeDescription = PD.strReasonCodeDescription
				,strForwardingAgentEntity = FA.strName

		FROM	tblLGLoad			LO
		JOIN	tblLGLoadDetail		LD ON LD.intLoadId			=	LO.intLoadId	
LEFT	JOIN	tblEMEntity			SL ON SL.intEntityId		=	LO.intShippingLineEntityId
LEFT	JOIN	tblLGReasonCode		EA ON EA.intReasonCodeId	=	LO.intETAPOLReasonCodeId
LEFT	JOIN	tblLGReasonCode		ES ON ES.intReasonCodeId	=	LO.intETSPOLReasonCodeId
LEFT	JOIN	tblLGReasonCode		PD ON PD.intReasonCodeId	=	LO.intETAPODReasonCodeId
LEFT	JOIN	tblEMEntity FA on FA.intEntityId = LO.intForwardingAgentEntityId
		WHERE	LD.intPContractDetailId NOT IN (SELECT intContractDetailId FROM Shipment)
		AND		LO.intShipmentType = 2
		AND		LO.intShipmentStatus <> 10
	)t
	GROUP BY strLoadNumber
			,strLoadShippingLine
			,strOriginPort
			,strDestinationPort
			,strMVessel
			,strMVoyageNumber
			,strFVessel
			,strFVoyageNumber
			,strBLNumber
			,intContractDetailId
			,intShipmentType
			,strShipmentType
			,strContainerNumber
			,ysnDocsReceived
			,dtmETAPOL
			,dtmETAPOD
			,dtmStuffingDate
			,dtmETSPOL
			,dtmDeadlineCargo
			,strBookingReference
			,intLoadId
			,strETAPOLReasonCode 
			,strETSPOLReasonCode
			,strETAPODReasonCode
			,strETAPOLReasonCodeDescription
			,strETSPOLReasonCodeDescription
			,strETAPODReasonCodeDescription
			,strForwardingAgentEntity