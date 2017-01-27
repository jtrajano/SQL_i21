CREATE VIEW vyuLGLoadDocumentTrackingSummary
AS
SELECT DT.strContractNumber
	,intContractSeq
	,strLoadNumber
	,strVendorName
	,E.strName AS strProducer
	,DT.dtmScheduledDate
	,DT.dtmETAPOD
	,(
		SELECT COUNT(*)
		FROM vyuLGLoadDocumentTracking T
		WHERE T.intContractHeaderId = DT.intContractHeaderId
		) intDocsCount
	,(
		SELECT COUNT(*)
		FROM vyuLGLoadDocumentTracking T
		WHERE T.intContractHeaderId = DT.intContractHeaderId
			AND ISNULL(T.ysnReceived, 0) = 1
		) intReceivedDocsCount
	,CASE 
		WHEN (
				SELECT COUNT(*)
				FROM vyuLGLoadDocumentTracking T
				WHERE T.intContractHeaderId = DT.intContractHeaderId
				) = (
				SELECT COUNT(*)
				FROM vyuLGLoadDocumentTracking T
				WHERE T.intContractHeaderId = DT.intContractHeaderId
					AND ISNULL(T.ysnReceived, 0) = 1
				)
			THEN 'Y'
		ELSE 'N'
		END strDocumentsReceived
FROM vyuLGLoadDocumentTracking DT
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = DT.intContractHeaderId
LEFT JOIN tblEMEntity E ON E.intEntityId = CH.intProducerId
GROUP BY DT.strContractNumber
	,DT.intContractHeaderId
	,DT.intContractSeq
	,strLoadNumber
	,strVendorName
	,E.strName
	,DT.dtmScheduledDate
	,DT.dtmETAPOD