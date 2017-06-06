CREATE VIEW vyuLGLoadDocumentTrackingSummary 
AS
SELECT DT.strContractNumber
	,intContractSeq
	,DT.strLoadNumber
	,strVendorName
	,E.strName AS strProducer
	,DT.dtmScheduledDate
	,DT.dtmETAPOD AS dtmETAPODSA
	,SI.dtmETAPOD AS dtmETAPODSI
	,intDaysToETAPOD
	,(
		SELECT COUNT(*)
		FROM vyuLGLoadDocumentTracking T
		JOIN tblLGLoad LO ON LO.intLoadId = T.intLoadId
		WHERE T.intContractHeaderId = DT.intContractHeaderId AND LO.intShipmentType = 1 AND L.intLoadId = LO.intLoadId
		) intDocsCount
	,(
		SELECT COUNT(*)
		FROM vyuLGLoadDocumentTracking T
		JOIN tblLGLoad LO ON LO.intLoadId = T.intLoadId
		WHERE T.intContractHeaderId = DT.intContractHeaderId
			AND LO.intShipmentType = 1
			AND ISNULL(T.ysnReceived, 0) = 1
			AND L.intLoadId = LO.intLoadId
		) intReceivedDocsCount
	,(SELECT MAX(dtmStartDate) FROM tblCTContractDetail WHERE intContractHeaderId = CH.intContractHeaderId) AS dtmStartDate
	,(SELECT MAX(dtmEndDate) FROM tblCTContractDetail WHERE intContractHeaderId = CH.intContractHeaderId) AS dtmEndDate
	,CASE 
		WHEN (
				SELECT COUNT(*)
				FROM vyuLGLoadDocumentTracking T
				JOIN tblLGLoad L ON L.intLoadId = T.intLoadId
				WHERE T.intContractHeaderId = DT.intContractHeaderId
					AND L.intShipmentType = 1
				) = (
				SELECT COUNT(*)
				FROM vyuLGLoadDocumentTracking T
				JOIN tblLGLoad L ON L.intLoadId = T.intLoadId
				WHERE T.intContractHeaderId = DT.intContractHeaderId
					AND L.intShipmentType = 1
					AND ISNULL(T.ysnReceived, 0) = 1
				)
			THEN 'Y'
		ELSE 'N'
		END strDocumentsReceived
	,DT.dblQuantity
	,DT.ysnInvoice
	,CASE WHEN ISNULL(DT.ysnInvoice,0) = 0 THEN 'No' ELSE 'Yes' END strInvoice
FROM vyuLGLoadDocumentTracking DT
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = DT.intContractHeaderId
JOIN tblLGLoad L ON L.intLoadId = DT.intLoadId
LEFT JOIN tblLGLoad SI ON SI.intLoadId = L.intLoadShippingInstructionId
LEFT JOIN tblEMEntity E ON E.intEntityId = CH.intProducerId
WHERE L.intShipmentType = 1	
GROUP BY DT.strContractNumber
	,DT.intContractHeaderId
	,CH.intContractHeaderId
	,DT.intContractSeq
	,DT.strLoadNumber
	,strVendorName
	,E.strName
	,DT.dtmScheduledDate
	,DT.dtmETAPOD
	,SI.dtmETAPOD
	,L.intLoadId
	,DT.dblQuantity
	,DT.ysnInvoice
	,intDaysToETAPOD