﻿CREATE VIEW vyuCTLoadView 

AS

	WITH Shipment AS
	(
		SELECT   LO.strLoadNumber
				,LO.strShippingLine	AS strLoadShippingLine
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
				,'Shipment' AS strShipmentType
				,LO.dtmETAPOL
				,LO.dtmETAPOD
				,LO.dtmStuffingDate
				,LO.dtmETSPOL
				,CAST((SELECT COUNT(1) FROM tblLGLoadDocuments WHERE intLoadId = LO.intLoadId) AS BIT) ysnDocsReceived
				,STUFF(
					(
						SELECT	', ' + CAST(strContainerNumber AS VARCHAR(MAX)) [text()]
						FROM	tblLGLoadContainer 
						WHERE	intLoadId = LO.intLoadId
						FOR XML PATH(''), TYPE)
						.value('.','NVARCHAR(MAX)'
					),1,2,' '
				) strContainerNumber,
				LO.strBookingReference

		FROM	vyuLGLoadView		LO
		JOIN	tblLGLoadDetail		LD ON LD.intLoadId = LO.intLoadId
		WHERE	LO.intShipmentType = 1
	
	
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
			,strBookingReference


	FROM
	(
		SELECT * FROM Shipment

		UNION ALL

		SELECT   LO.strLoadNumber
				,LO.strShippingLine
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
				,'Shipping Instructions' AS strShipmentType
				,LO.dtmETAPOL
				,LO.dtmETAPOD
				,LO.dtmStuffingDate
				,LO.dtmETSPOL
				,CAST((SELECT COUNT(1) FROM tblLGLoadDocuments WHERE intLoadId = LO.intLoadId) AS BIT) ysnDocsReceived
				,NULL strContainerNumber
				,LO.strBookingReference

		FROM	vyuLGLoadView		LO
		JOIN	tblLGLoadDetail		LD ON LD.intLoadId = LO.intLoadId
		WHERE	LD.intPContractDetailId NOT IN (SELECT intContractDetailId FROM Shipment)
		AND		LO.intShipmentType = 2
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
			,strBookingReference