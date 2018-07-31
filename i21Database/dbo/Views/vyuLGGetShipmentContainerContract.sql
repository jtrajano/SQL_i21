CREATE VIEW vyuLGGetShipmentContainerContract
AS
SELECT L.strLoadNumber
	,L.intLoadId
	,LD.intLoadDetailId
	,strContainerNumber
	,ISNULL(LC.intLoadContainerId, - 1) AS intLoadContainerId
	,ISNULL(LDCL.intLoadDetailContainerLinkId, - 1) AS intLoadDetailContainerLinkId
	,CH.intContractTypeId
	,CH.intContractHeaderId AS intPContractHeaderId 
	,CD.intContractDetailId AS intPContractDetailId 
	,CH.strContractNumber AS strPContractNumber 
	,CD.intContractSeq AS intPContractSeq 
	,CLSL.intCompanyLocationSubLocationId AS intPSubLocationId 
	,CLSL.strSubLocationName AS strPSubLocationName 
	,LD.intItemId
	,I.strItemNo AS strItemNo
	,I.strDescription AS strItemDescription
	,LD.dblQuantity
	,IU.intItemUOMId
	,UM.strUnitMeasure
	,LC.strMarks
	,L.dtmScheduledDate
	,L.dtmPostedDate
	,E.intEntityId
	,E.strName AS strEntityName
	,'Inbound' AS strShipmentType
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem I ON I.intItemId = LD.intItemId
JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblEMEntity E ON E.intEntityId = LD.intVendorEntityId
LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CASE WHEN LD.intPSubLocationId IS NULL THEN CD.intSubLocationId ELSE LD.intPSubLocationId END
WHERE L.intPurchaseSale IN (
		1
		,3
		)

UNION ALL

SELECT L.strLoadNumber
	,L.intLoadId
	,LD.intLoadDetailId
	,strContainerNumber
	,ISNULL(LC.intLoadContainerId, - 1) AS intLoadContainerId
	,ISNULL(LDCL.intLoadDetailContainerLinkId, - 1) AS intLoadDetailContainerLinkId
	,CH.intContractTypeId
	,CH.intContractHeaderId AS intPContractHeaderId 
	,CD.intContractDetailId AS intPContractDetailId 
	,CH.strContractNumber AS strPContractNumber 
	,CD.intContractSeq AS intPContractSeq 
	,CLSL.intCompanyLocationSubLocationId AS intPSubLocationId 
	,CLSL.strSubLocationName AS strPSubLocationName 
	,LD.intItemId
	,I.strItemNo AS strItemNo
	,I.strDescription AS strItemDescription
	,LD.dblQuantity
	,IU.intItemUOMId
	,UM.strUnitMeasure
	,LC.strMarks
	,L.dtmScheduledDate
	,L.dtmPostedDate
	,E.intEntityId
	,E.strName AS strEntityName
	,'Outbound' AS strShipmentType
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem I ON I.intItemId = LD.intItemId
JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblEMEntity E ON E.intEntityId = LD.intCustomerEntityId
LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CASE WHEN LD.intSSubLocationId IS NULL THEN CD.intSubLocationId ELSE LD.intSSubLocationId END
WHERE L.intPurchaseSale IN (2,3)