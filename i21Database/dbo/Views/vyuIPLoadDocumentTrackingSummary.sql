CREATE VIEW vyuIPLoadDocumentTrackingSummary
AS
SELECT intKeyColumn = Convert(INT, ROW_NUMBER() OVER (
			ORDER BY L.intLoadId
			))
	,DT.strContractNumber
	,intContractSeq
	,DT.strLoadNumber
	,strVendorName
	,strProducer = E.strName
	,DT.dtmScheduledDate
	,dtmETAPODSA = DT.dtmETAPOD
	,dtmETAPODSI = SI.dtmETAPOD
	,intDaysToETAPOD
	,intDocsCount = (
		SELECT COUNT(*)
		FROM vyuLGLoadDocumentTracking T
		JOIN tblLGLoad LO ON LO.intLoadId = T.intLoadId
		WHERE T.intContractHeaderId = DT.intContractHeaderId
			AND LO.intShipmentType = 1
			AND L.intLoadId = LO.intLoadId
		)
	,intReceivedDocsCount = (
		SELECT COUNT(*)
		FROM vyuLGLoadDocumentTracking T
		JOIN tblLGLoad LO ON LO.intLoadId = T.intLoadId
		WHERE T.intContractHeaderId = DT.intContractHeaderId
			AND LO.intShipmentType = 1
			AND ISNULL(T.ysnReceived, 0) = 1
			AND L.intLoadId = LO.intLoadId
		)
	,intReceivedCopyDocsCount = (
		SELECT COUNT(*)
		FROM vyuLGLoadDocumentTracking T
		JOIN tblLGLoad LO ON LO.intLoadId = T.intLoadId
		WHERE T.intContractHeaderId = DT.intContractHeaderId
			AND LO.intShipmentType = 1
			AND ISNULL(T.ysnReceivedCopy, 0) = 1
			AND L.intLoadId = LO.intLoadId
		)
	,dtmStartDate = (
		SELECT MAX(dtmStartDate)
		FROM tblCTContractDetail
		WHERE intContractHeaderId = CH.intContractHeaderId
		)
	,dtmEndDate = (
		SELECT MAX(dtmEndDate)
		FROM tblCTContractDetail
		WHERE intContractHeaderId = CH.intContractHeaderId
		)
	,strDocumentsReceived = CASE 
		WHEN (ISNULL(L.ysnDocumentsReceived, 0) = 1)
			THEN 'Y'
		ELSE 'N'
		END COLLATE Latin1_General_CI_AS
	,DT.dblQuantity
	,DT.ysnInvoice
	,strInvoice = CASE 
		WHEN ISNULL(DT.ysnInvoice, 0) = 0
			THEN 'No'
		ELSE 'Yes'
		END COLLATE Latin1_General_CI_AS
	,L.intBookId
	,BO.strBook
	,L.intSubBookId
	,SB.strSubBook
	,L.intLoadId
FROM vyuLGLoadDocumentTracking DT
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = DT.intContractHeaderId
JOIN tblLGLoad L ON L.intLoadId = DT.intLoadId
LEFT JOIN tblLGLoad SI ON SI.intLoadId = L.intLoadShippingInstructionId
LEFT JOIN tblEMEntity E ON E.intEntityId = CH.intProducerId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
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
	,L.ysnDocumentsReceived
	,DT.dblQuantity
	,DT.ysnInvoice
	,intDaysToETAPOD
	,L.intBookId
	,BO.strBook
	,L.intSubBookId
	,SB.strSubBook

