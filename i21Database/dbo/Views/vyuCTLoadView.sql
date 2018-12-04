﻿CREATE VIEW vyuCTLoadView 

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
				,LD.intPContractDetailId intContractDetailId
				,LO.intShipmentType
				,'Shipment' COLLATE Latin1_General_CI_AS AS strShipmentType
				,LO.dtmETAPOL
				,LO.dtmETAPOD
				,LO.dtmStuffingDate
				,LO.dtmETSPOL
				,LO.dtmDeadlineCargo
				,CAST(
						CASE	WHEN	ISNULL((SELECT COUNT(1) FROM tblLGLoadDocuments WHERE intLoadId = LO.intLoadId),0) = 0 THEN 0
								WHEN	ISNULL((SELECT COUNT(1) FROM tblLGLoadDocuments WHERE intLoadId = LO.intLoadId),0)	= 
										ISNULL((SELECT COUNT(1) FROM tblLGLoadDocuments WHERE intLoadId = LO.intLoadId AND ysnReceived = 1),0) THEN 1
								ELSE 0
						END
				AS BIT) ysnDocsReceived
				,STUFF(
					(
						SELECT	', ' + CAST(strContainerNumber AS VARCHAR(MAX)) [text()]
						FROM	tblLGLoadContainer 
						WHERE	intLoadId = LO.intLoadId
						FOR XML PATH(''), TYPE)
						.value('.','NVARCHAR(MAX)'
					),1,2,' '
				) COLLATE Latin1_General_CI_AS AS strContainerNumber,
				LO.strBookingReference
				,LO.intLoadId

		FROM	tblLGLoad			LO
		JOIN	tblLGLoadDetail		LD ON LD.intLoadId		=	LO.intLoadId LEFT
		JOIN	tblEMEntity			SL ON SL.intEntityId	=	LO.intShippingLineEntityId
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
				,LD.intPContractDetailId intContractDetailId
				,LO.intShipmentType
				,'Shipping Instructions' COLLATE Latin1_General_CI_AS AS strShipmentType
				,LO.dtmETAPOL
				,LO.dtmETAPOD
				,LO.dtmStuffingDate
				,LO.dtmETSPOL
				,LO.dtmDeadlineCargo
				,CAST(
						CASE	WHEN	ISNULL((SELECT COUNT(1) FROM tblLGLoadDocuments WHERE intLoadId = LO.intLoadId),0) = 0 THEN 0
								WHEN	ISNULL((SELECT COUNT(1) FROM tblLGLoadDocuments WHERE intLoadId = LO.intLoadId),0)	= 
										ISNULL((SELECT COUNT(1) FROM tblLGLoadDocuments WHERE intLoadId = LO.intLoadId AND ysnReceived = 1),0) THEN 1
								ELSE 0
						END
				AS BIT) ysnDocsReceived
				,NULL strContainerNumber
				,LO.strBookingReference
				,LO.intLoadId

		FROM	tblLGLoad			LO
		JOIN	tblLGLoadDetail		LD ON LD.intLoadId		=	LO.intLoadId	LEFT
		JOIN	tblEMEntity			SL ON SL.intEntityId	=	LO.intShippingLineEntityId
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