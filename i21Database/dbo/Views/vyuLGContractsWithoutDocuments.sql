CREATE VIEW vyuLGContractsWithoutDocuments
AS
SELECT * FROM (
	SELECT L.strLoadNumber
		,CH.intContractHeaderId
		,CH.strContractNumber
		,CD.intContractSeq
		,I.strItemNo
		,CO.strCommodityCode
		,CH.dtmCreated
		,CD.dtmStartDate
		,CD.dtmEndDate
		,E.strName strVendor
		,ISNULL(LCI.strCity, L.strOriginPort) AS strLoading
		,ISNULL(DCI.strCity, L.strDestinationPort) AS strDestination
		,intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), GETDATE(), 101), CONVERT(NVARCHAR(100), L.dtmETSPOL, 101))
		,L.dtmETAPOD AS dtmETAPOD
		,L.dtmETAPOL AS dtmETAPOL
		,L.dtmETSPOL AS dtmETSPOL
		,'Contracts w/o shipping advice' AS strType
	FROM tblCTContractHeader CH
	JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
	JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
	JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
	JOIN tblLGLoadDocuments LGD ON LGD.intLoadId = L.intLoadId
	JOIN tblICDocument DOC ON LGD.intDocumentId = DOC.intDocumentId
		AND UPPER(DOC.strDocumentName) LIKE '%SHIPPING%ADVICE%' 
		AND ISNULL(ysnReceived,0) = 0
	LEFT JOIN tblSMCity LCI ON LCI.intCityId = CD.intLoadingPortId
	LEFT JOIN tblSMCity DCI ON DCI.intCityId = CD.intDestinationPortId
	WHERE CH.intContractTypeId = 1
	) tbl
WHERE tbl.intDayToShipment < - 5
UNION ALL
SELECT *
FROM (
	SELECT L.strLoadNumber
		,CH.intContractHeaderId
		,CH.strContractNumber
		,CD.intContractSeq
		,I.strItemNo
		,CO.strCommodityCode
		,CH.dtmCreated
		,CD.dtmStartDate
		,CD.dtmEndDate
		,E.strName strVendor
		,ISNULL(LCI.strCity, L.strOriginPort) AS strLoading
		,ISNULL(DCI.strCity, L.strDestinationPort) AS strDestination
		,intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), GETDATE(), 101), CONVERT(NVARCHAR(100), L.dtmETAPOD, 101))
		,L.dtmETAPOD AS dtmETAPOD
		,L.dtmETAPOL AS dtmETAPOL
		,L.dtmETSPOL AS dtmETSPOL
		,'Contracts w/o document' AS strType
	FROM tblCTContractHeader CH
	JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
	JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
	JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
	JOIN tblLGLoadDocuments LGD ON LGD.intLoadId = L.intLoadId
	JOIN tblICDocument DOC ON LGD.intDocumentId = DOC.intDocumentId
		AND UPPER(DOC.strDocumentName) NOT LIKE '%SHIPPING%ADVICE%'
		AND ISNULL(ysnReceived, 0) = 0
	LEFT JOIN tblSMCity LCI ON LCI.intCityId = CD.intLoadingPortId
	LEFT JOIN tblSMCity DCI ON DCI.intCityId = CD.intDestinationPortId
	) tbl
WHERE intDayToShipment < -7