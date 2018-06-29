CREATE VIEW vyuQMSampleList
AS
SELECT S.intSampleId
	,S.strSampleNumber
	,S.strSampleRefNo
	,ST.strSampleTypeName
	,CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) AS strContractNumber
	,CY.strCommodityCode
	,CY.strDescription AS strCommodityDescription
	,CH.strCustomerContract
	,IC.strContractItemName
	,I1.strItemNo AS strBundleItemNo
	,I.strItemNo
	,I.strDescription
	,S.strContainerNumber
	,SH.strLoadNumber
	,S.strLotNumber
	,SS.strStatus
	,S.dtmSampleReceivedDate
	,S.strSampleNote
	,E.strName AS strPartyName
	,S.strRefNo
	,S.strSamplingMethod
	,S.dtmTestedOn
	,U.strUserName AS strTestedUserName
	,LS.strSecondaryStatus AS strLotStatus
	,S.strCountry
	,S.dblSampleQty
	,UM.strUnitMeasure AS strSampleUOM
	,S.dblRepresentingQty
	,UM1.strUnitMeasure AS strRepresentingUOM
	,S.strMarks
	,CS.strSubLocationName
	,S.dtmTestingStartDate
	,S.dtmTestingEndDate
	,S.dtmSamplingEndDate
	,S.intContractDetailId
	,ST.intSampleTypeId
	,CH.intContractHeaderId
	,I.intItemId
	,S.intItemBundleId
	,SH.intLoadId
	,C.intLoadContainerId
	,S.intCompanyLocationSubLocationId
	,ISNULL(L.intLotId, (
			SELECT TOP 1 intLotId
			FROM tblICLot
			WHERE intParentLotId = PL.intParentLotId
			)) AS intLotId
	,S.intSampleUOMId
	,S.intRepresentingUOMId
	,S.intLocationId
	,CL.strLocationName
	,IR.strReceiptNumber
	,INVS.strShipmentNumber AS strInvShipmentNumber
	,WO.strWorkOrderNo
	,S.strComment
	,ISNULL(ito1.intOwnerId, ito2.intOwnerId) AS intEntityId
	,S1.strSampleNumber AS strParentSampleNo
	,CD.strItemSpecification
	,SL.strName AS strStorageLocationName
	,B.strBook
	,SB.strSubBook
FROM dbo.tblQMSample S
JOIN dbo.tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
	AND S.ysnIsContractCompleted <> 1
JOIN dbo.tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
LEFT JOIN dbo.tblCTContractDetail AS CD ON CD.intContractDetailId = S.intContractDetailId
LEFT JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN dbo.tblICItemContract IC ON IC.intItemContractId = S.intItemContractId
LEFT JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
LEFT JOIN dbo.tblICItem I1 ON I1.intItemId = S.intItemBundleId
LEFT JOIN dbo.tblLGLoadContainer C ON C.intLoadContainerId = S.intLoadContainerId
LEFT JOIN dbo.tblLGLoad SH ON SH.intLoadId = S.intLoadId
LEFT JOIN dbo.tblSMUserSecurity U ON U.[intEntityId] = S.intTestedById
LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = S.intEntityId
LEFT JOIN dbo.tblICLot L ON L.intLotId = S.intProductValueId
	AND S.intProductTypeId = 6
LEFT JOIN dbo.tblICParentLot PL ON PL.intParentLotId = S.intProductValueId
	AND S.intProductTypeId = 11
LEFT JOIN tblICItemOwner ito1 ON ito1.intItemOwnerId = L.intItemOwnerId
LEFT JOIN tblICItemOwner ito2 ON ito2.intItemId = S.intItemId
	AND ito2.ysnDefault = 1
LEFT JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = S.intLotStatusId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
LEFT JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intSampleUOMId
LEFT JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = S.intRepresentingUOMId
LEFT JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = S.intSubBookId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = S.intInventoryReceiptId
LEFT JOIN tblICInventoryShipment INVS ON INVS.intInventoryShipmentId = S.intInventoryShipmentId
LEFT JOIN tblMFWorkOrder WO ON WO.intWorkOrderId = S.intWorkOrderId
LEFT JOIN tblICCommodity CY ON CY.intCommodityId = CH.intCommodityId
LEFT JOIN tblQMSample S1 ON S1.intSampleId = S.intParentSampleId
