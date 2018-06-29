CREATE VIEW vyuLGContarctWithoutShippingAdvice
AS
SELECT 2 intDataSeq
	,CH.intContractHeaderId
	,CH.strContractNumber
	,CD.intContractSeq
	,I.strItemNo
	,CO.strCommodityCode
	,CH.dtmCreated
	,CD.dtmStartDate
	,CD.dtmEndDate
	,L.dtmETAPOL
	,L.dtmETSPOL
	,E.strName strVendor
	,ISNULL(LCI.strCity,L.strOriginPort) AS strLoading
	,ISNULL(DCI.strCity,L.strDestinationPort) AS strDestination
	,intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), L.dtmETSPOL, 101), CONVERT(NVARCHAR(100), GETDATE(), 101))
	,L.dtmETAPOD AS dtmETAPOD
	,dblRemainingQty = NULL
	,'Contracts w/o shipping advice' AS strType
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	AND L.intShipmentType = 2 AND L.intShipmentStatus <> 10
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
LEFT JOIN tblSMCity LCI ON LCI.intCityId = CD.intLoadingPortId
LEFT JOIN tblSMCity DCI ON DCI.intCityId = CD.intDestinationPortId
WHERE L.intLoadId NOT IN (
		SELECT intLoadShippingInstructionId
		FROM tblLGLoad
		WHERE intShipmentType = 1
			AND intLoadShippingInstructionId IS NOT NULL
		)
	AND CH.intContractTypeId = 1
	AND CD.intContractStatusId <> 3
	AND DATEDIFF(DAY, CONVERT(NVARCHAR(100), L.dtmETSPOL, 101), CONVERT(NVARCHAR(100), GETDATE(), 101)) > 10