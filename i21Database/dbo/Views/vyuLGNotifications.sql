CREATE VIEW vyuLGNotifications
AS
SELECT CONVERT(INT, ROW_NUMBER() OVER (
			ORDER BY strType
				,intContractHeaderId
			)) AS intUniqueId
	,*
FROM (
	SELECT t.*
		,EV.intEventId
	FROM (
		SELECT 1 intDataSeq
			,CH.intContractHeaderId
			,CH.strContractNumber
			,CD.intContractSeq
			,I.strItemNo
			,CO.strCommodityCode
			,CH.dtmCreated
			,CD.dtmStartDate
			,CD.dtmEndDate
			,E.strName strVendor
			,LCI.strCity AS strLoading
			,DCI.strCity AS strDestination
			,intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), GETDATE(), 101), CONVERT(NVARCHAR(100), CD.dtmStartDate, 101))
			,NULL AS dtmETAPOD
			,CD.dblQuantity - ISNULL((
					SELECT SUM(dblQuantity)
					FROM tblLGLoadDetail LOADDetail
					WHERE LOADDetail.intPContractDetailId = CD.intContractDetailId
					), 0) AS dblRemainingQty
			,CL.strLocationName 
			,IC.strContractItemNo
			,IC.strContractItemName
			,PT.strDescription AS strProductType
			,'Contracts w/o shipping instruction' AS strType
		FROM tblCTContractHeader CH
		JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblICItem I ON I.intItemId = CD.intItemId
		JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
		JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
		LEFT JOIN tblICCommodityAttribute PT ON PT.intCommodityAttributeId = I.intProductTypeId
		LEFT JOIN tblSMCity LCI ON LCI.intCityId = CD.intLoadingPortId
		LEFT JOIN tblSMCity DCI ON DCI.intCityId = CD.intDestinationPortId
		WHERE CD.dblQuantity - (
				ISNULL((
						SELECT SUM(ISNULL(LOADDetail.dblQuantity,0))
						FROM tblLGLoadDetail LOADDetail 
						JOIN tblLGLoad LOAD ON LOAD.intLoadId = LOADDetail.intLoadId
						WHERE LOADDetail.intPContractDetailId = CD.intContractDetailId
						AND LOAD.intShipmentType = 2
						), 0)
				) > 0
			AND CH.intContractTypeId = 1
			AND CD.intContractStatusId <> 3
			AND CD.intContractDetailId NOT IN ((SELECT COD.intContractDetailId FROM tblLGLoad L
												JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
												JOIN tblCTContractDetail COD ON COD.intContractDetailId = LD.intPContractDetailId
												WHERE L.intShipmentType = 1))
		) t
		,tblCTEvent EV
	WHERE t.intDayToShipment < EV.intDaysToRemind
		AND EV.strEventName = 'Contract without Shipping Instruction'
	
	UNION ALL
	
	SELECT t.*
		,EV.intEventId
	FROM (
		SELECT 2 intDataSeq
			,CH.intContractHeaderId
			,CH.strContractNumber
			,CD.intContractSeq
			,I.strItemNo
			,CO.strCommodityCode
			,CH.dtmCreated
			,CD.dtmStartDate
			,CD.dtmEndDate
			,E.strName strVendor
			,ISNULL(LCI.strCity,L.strOriginPort) AS strLoading
			,ISNULL(DCI.strCity,L.strDestinationPort) AS strDestination
			,intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), L.dtmETSPOL, 101), CONVERT(NVARCHAR(100), GETDATE(), 101))
			,L.dtmETAPOD AS dtmETAPOD
			,dblRemainingQty = NULL
			,CL.strLocationName 
			,IC.strContractItemNo
			,IC.strContractItemName
			,PT.strDescription AS strProductType
			,'Contracts w/o shipping advice' AS strType
		FROM tblCTContractHeader CH
		JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			AND L.intShipmentType = 2 AND L.intShipmentStatus <> 10
		JOIN tblICItem I ON I.intItemId = CD.intItemId
		JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
		JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
		LEFT JOIN tblICCommodityAttribute PT ON PT.intCommodityAttributeId = I.intProductTypeId
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
		) t
		,tblCTEvent EV
	WHERE t.intDayToShipment > EV.intDaysToRemind
		AND EV.strEventName = 'Contract without Shipping Advice'
	
	UNION ALL
	
	SELECT t.*
		,EV.intEventId
	FROM (
		SELECT 3 intDataSeq
			,CH.intContractHeaderId
			,CH.strContractNumber
			,CD.intContractSeq
			,I.strItemNo
			,CO.strCommodityCode
			,CH.dtmCreated
			,CD.dtmStartDate
			,CD.dtmEndDate
			,E.strName strVendor
			,ISNULL(LCI.strCity,L.strOriginPort) AS strLoading
			,ISNULL(DCI.strCity,L.strDestinationPort) AS strDestination
			,intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), GETDATE(), 101), CONVERT(NVARCHAR(100), L.dtmETAPOD, 101))
			,L.dtmETAPOD AS dtmETAPOD
			,dblRemainingQty = NULL
			,CL.strLocationName 
			,IC.strContractItemNo
			,IC.strContractItemName
			,PT.strDescription AS strProductType
			,'Contracts w/o document' AS strType
		FROM tblCTContractHeader CH
		JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			AND L.intShipmentType = 1 AND L.intShipmentStatus <> 10
		JOIN tblICItem I ON I.intItemId = CD.intItemId
		JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
		JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
		LEFT JOIN tblICCommodityAttribute PT ON PT.intCommodityAttributeId = I.intProductTypeId
		LEFT JOIN tblSMCity LCI ON LCI.intCityId = CD.intLoadingPortId
		LEFT JOIN tblSMCity DCI ON DCI.intCityId = CD.intDestinationPortId
		WHERE L.intLoadId NOT IN (
				SELECT intLoadId
				FROM tblLGLoadDocuments WHERE ISNULL(ysnReceived,0) = 1
				)
			AND CH.intContractTypeId = 1
			AND CD.intContractStatusId <> 3
		) t
		,tblCTEvent EV
	WHERE t.intDayToShipment < EV.intDaysToRemind
		AND EV.strEventName = 'Contract Without Document'
	
	UNION ALL
	
	SELECT t.*
		,EV.intEventId
	FROM (
		SELECT 4 intDataSeq
			,CH.intContractHeaderId
			,CH.strContractNumber
			,CD.intContractSeq
			,I.strItemNo
			,CO.strCommodityCode
			,CH.dtmCreated
			,CD.dtmStartDate
			,CD.dtmEndDate
			,E.strName strVendor
			,ISNULL(LCI.strCity,L.strOriginPort) AS strLoading
			,ISNULL(DCI.strCity,L.strDestinationPort) AS strDestination
			,intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), L.dtmETAPOD, 101), CONVERT(NVARCHAR(100), GETDATE(), 101))
			,L.dtmETAPOD AS dtmETAPOD
			,dblRemainingQty = NULL
			,CL.strLocationName 
			,IC.strContractItemNo
			,IC.strContractItemName
			,PT.strDescription AS strProductType
			,'Contracts w/o weight claim' AS strType
		FROM tblCTContractHeader CH
		JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			AND L.intShipmentType = 1 AND L.intShipmentStatus <> 10
		JOIN tblICItem I ON I.intItemId = CD.intItemId
		JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
		JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
		LEFT JOIN tblICCommodityAttribute PT ON PT.intCommodityAttributeId = I.intProductTypeId
		LEFT JOIN tblSMCity LCI ON LCI.intCityId = CD.intLoadingPortId
		LEFT JOIN tblSMCity DCI ON DCI.intCityId = CD.intDestinationPortId
		WHERE L.intLoadId NOT IN (
				SELECT WC.intLoadId
				FROM tblLGWeightClaim WC
				JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
				)
			AND CH.intContractTypeId = 1
			AND CD.intContractStatusId <> 3
		) t
		,tblCTEvent EV
	WHERE t.intDayToShipment >= EV.intDaysToRemind
		AND EV.strEventName = 'Contract Without Weight Claim'
	
	UNION ALL
	
	SELECT DISTINCT t.*
		,EV.intEventId
	FROM (
		SELECT 5 intDataSeq
			,CH.intContractHeaderId
			,CH.strContractNumber
			,CD.intContractSeq
			,I.strItemNo
			,CO.strCommodityCode
			,CH.dtmCreated
			,CD.dtmStartDate
			,CD.dtmEndDate
			,E.strName strVendor
			,ISNULL(LCI.strCity,L.strOriginPort) AS strLoading
			,ISNULL(DCI.strCity,L.strDestinationPort) AS strDestination
			,intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), WC.dtmActualWeighingDate, 101), CONVERT(NVARCHAR(100), GETDATE(), 101))
			,L.dtmETAPOD AS dtmETAPOD
			,dblRemainingQty = NULL
			,CL.strLocationName 
			,IC.strContractItemNo
			,IC.strContractItemName
			,PT.strDescription AS strProductType
			,'Weight claims w/o debit note' AS strType
		FROM tblCTContractHeader CH
		JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			AND L.intShipmentType = 1 AND L.intShipmentStatus <> 10
		JOIN tblLGWeightClaim WC ON L.intLoadId = WC.intLoadId
		JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
		JOIN tblICItem I ON I.intItemId = CD.intItemId
		JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
		JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
		LEFT JOIN tblICCommodityAttribute PT ON PT.intCommodityAttributeId = I.intProductTypeId
		LEFT JOIN tblSMCity LCI ON LCI.intCityId = CD.intLoadingPortId
		LEFT JOIN tblSMCity DCI ON DCI.intCityId = CD.intDestinationPortId
		WHERE ISNULL(WCD.intBillId, 0) = 0
			AND CH.intContractTypeId = 1
			AND CD.intContractStatusId <> 3
		) t
		,tblCTEvent EV
	WHERE t.intDayToShipment > EV.intDaysToRemind
		AND EV.strEventName = 'Weight Claims w/o Debit Note'

	UNION ALL

	SELECT t.*
		,EV.intEventId
	FROM (
		SELECT 6 intDataSeq
			,CH.intContractHeaderId
			,CH.strContractNumber
			,CD.intContractSeq
			,I.strItemNo
			,CO.strCommodityCode
			,CH.dtmCreated
			,CD.dtmStartDate
			,CD.dtmEndDate
			,E.strName strVendor
			,ISNULL(LCI.strCity,L.strOriginPort) AS strLoading
			,ISNULL(DCI.strCity,L.strDestinationPort) AS strDestination
			,intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), L.dtmETSPOL, 101), CONVERT(NVARCHAR(100), GETDATE(), 101))
			,L.dtmETAPOD AS dtmETAPOD
			,dblRemainingQty = NULL
			,CL.strLocationName 
			,IC.strContractItemNo
			,IC.strContractItemName
			,PT.strDescription AS strProductType
			,'Contracts w/o 4C' AS strType
		FROM tblCTContractHeader CH
		JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			AND L.intShipmentType = 1 AND L.intShipmentStatus <> 10
		JOIN tblICItem I ON I.intItemId = CD.intItemId
		JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
		JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
		LEFT JOIN tblICCommodityAttribute PT ON PT.intCommodityAttributeId = I.intProductTypeId
		LEFT JOIN tblSMCity LCI ON LCI.intCityId = CD.intLoadingPortId
		LEFT JOIN tblSMCity DCI ON DCI.intCityId = CD.intDestinationPortId
		WHERE L.intLoadId IN (SELECT DISTINCT intLoadId FROM tblLGLoadDocuments WHERE ysnReceived = 1)
			AND CH.intContractTypeId = 1 
			AND ISNULL(L.ysn4cRegistration,0) =0 
			AND CD.intContractStatusId <> 3
		) t
		,tblCTEvent EV
	WHERE EV.strEventName = 'Contracts w/o 4C'

	UNION ALL

	SELECT t.*
		,EV.intEventId
	FROM (
		SELECT 7 intDataSeq
			,CH.intContractHeaderId
			,CH.strContractNumber
			,CD.intContractSeq
			,I.strItemNo
			,CO.strCommodityCode
			,CH.dtmCreated
			,CD.dtmStartDate
			,CD.dtmEndDate
			,E.strName strVendor
			,ISNULL(LCI.strCity,L.strOriginPort) AS strLoading
			,ISNULL(DCI.strCity,L.strDestinationPort) AS strDestination
			,intDayToShipment = DATEDIFF(DAY, CONVERT(NVARCHAR(100), L.dtmETSPOL, 101), CONVERT(NVARCHAR(100), GETDATE(), 101))
			,L.dtmETAPOD AS dtmETAPOD
			,dblRemainingQty = NULL
			,CL.strLocationName 
			,IC.strContractItemNo
			,IC.strContractItemName
			,PT.strDescription AS strProductType
			,'Contracts w/o TC' AS strType
		FROM tblCTContractHeader CH
		JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			AND L.intShipmentType = 1 AND L.intShipmentStatus <> 10
		JOIN tblICItem I ON I.intItemId = CD.intItemId
		JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
		JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
		LEFT JOIN tblICCommodityAttribute PT ON PT.intCommodityAttributeId = I.intProductTypeId
		LEFT JOIN tblSMCity LCI ON LCI.intCityId = CD.intLoadingPortId
		LEFT JOIN tblSMCity DCI ON DCI.intCityId = CD.intDestinationPortId
		WHERE L.intLoadId IN (SELECT DISTINCT intLoadId FROM tblLGLoadDocuments WHERE ysnReceived = 0)
			AND CH.intContractTypeId = 1 
			AND L.dtmBLDate IS NOT NULL
			AND CD.intContractStatusId <> 3
		) t
		,tblCTEvent EV
	WHERE EV.strEventName = 'Contracts w/o TC'
) tbl
