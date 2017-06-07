CREATE VIEW vyuQMSampleNotMapped
AS
SELECT S.intSampleId
	,ST.intControlPointId
	,I.strDescription
	,IR.strReceiptNumber
	,CH.intContractTypeId
	,ST.strSampleTypeName
	,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strSequenceNumber
	,L.strLoadNumber
	,IC.strContractItemName
	,I.strItemNo
	,I1.strItemNo AS strBundleItemNo
	,E.strName AS strPartyName
	,W.strWorkOrderNo
	,LS.strSecondaryStatus AS strLotStatus
	,UOM.strUnitMeasure AS strSampleUOM
	,UOM1.strUnitMeasure AS strRepresentingUOM
	,SS.strSecondaryStatus AS strSampleStatus
	,CS.strSubLocationName
FROM tblQMSample S
JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
LEFT JOIN tblICItem I ON I.intItemId = S.intItemId
LEFT JOIN tblICItem I1 ON I1.intItemId = S.intItemBundleId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = S.intInventoryReceiptId
LEFT JOIN tblCTContractDetail AS CD ON CD.intContractDetailId = S.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblLGLoad L ON L.intLoadId = S.intLoadId
LEFT JOIN tblICItemContract IC ON IC.intItemContractId = S.intItemContractId
LEFT JOIN tblEMEntity E ON E.intEntityId = S.intEntityId
LEFT JOIN tblMFWorkOrder W ON W.intWorkOrderId = S.intWorkOrderId
LEFT JOIN tblICLotStatus LS ON LS.intLotStatusId = S.intLotStatusId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = S.intSampleUOMId
LEFT JOIN tblICUnitMeasure UOM1 ON UOM1.intUnitMeasureId = S.intRepresentingUOMId
LEFT JOIN tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
