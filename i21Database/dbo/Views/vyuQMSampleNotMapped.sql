CREATE VIEW vyuQMSampleNotMapped
AS
SELECT S.intSampleId
	,ST.intControlPointId
	,I.strDescription
	,IR.strReceiptNumber
	,INVS.strShipmentNumber
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
	,SS1.strSecondaryStatus AS strPreviousSampleStatus
	,CS.strSubLocationName
	,S1.strSampleNumber AS strParentSampleNo
	,SL.strName AS strStorageLocationName
	,CD.strItemSpecification
	,B.strBook
	,SB.strSubBook
	,E1.strName AS strForwardingAgentName
	,CASE 
		WHEN S.strSentBy = 'Self'
			THEN CL1.strLocationName
		ELSE E2.strName
		END AS strSentByValue
	,ST.ysnPartyMandatory
FROM tblQMSample S
JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
LEFT JOIN tblQMSampleStatus SS1 ON SS1.intSampleStatusId = S.intPreviousSampleStatusId
LEFT JOIN tblICItem I ON I.intItemId = S.intItemId
LEFT JOIN tblICItem I1 ON I1.intItemId = S.intItemBundleId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = S.intInventoryReceiptId
LEFT JOIN tblICInventoryShipment INVS ON INVS.intInventoryShipmentId = S.intInventoryShipmentId
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
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = S.intSubBookId
LEFT JOIN tblQMSample S1 ON S1.intSampleId = S.intParentSampleId
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = S.intForwardingAgentId
LEFT JOIN tblEMEntity E2 ON E2.intEntityId = S.intSentById
LEFT JOIN tblSMCompanyLocation CL1 ON CL1.intCompanyLocationId = S.intSentById
