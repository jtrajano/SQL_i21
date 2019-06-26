CREATE VIEW vyuQMSampleHeaderView
AS
SELECT S.intSampleId
	,S.intConcurrencyId
	--,S.intCompanyId
	,S.intSampleTypeId
	,S.strSampleNumber
	--,S.intParentSampleId
	,S.strSampleRefNo
	,S.intProductTypeId
	,S.intProductValueId
	,S.intSampleStatusId
	,S.intPreviousSampleStatusId
	,S.intItemId
	,S.intItemContractId
	,S.intContractHeaderId
	,S.intContractDetailId
	,S.intShipmentBLContainerId
	,S.intShipmentBLContainerContractId
	,S.intShipmentId
	,S.intShipmentContractQtyId
	,S.intCountryID
	,S.ysnIsContractCompleted
	,S.intLotStatusId
	,S.intEntityId
	--,S.intShipperEntityId
	,S.strShipmentNumber
	,S.strLotNumber
	,S.strSampleNote
	,S.dtmSampleReceivedDate
	,S.dtmTestedOn
	,S.intTestedById
	,S.dblSampleQty
	,S.intSampleUOMId
	,S.dblRepresentingQty
	,S.intRepresentingUOMId
	,S.strRefNo
	,S.dtmTestingStartDate
	,S.dtmTestingEndDate
	,S.dtmSamplingEndDate
	,S.strSamplingMethod
	,S.strContainerNumber
	,S.strMarks
	,S.intCompanyLocationSubLocationId
	,S.strCountry
	,S.intItemBundleId
	,S.intLoadContainerId
	,S.intLoadDetailContainerLinkId
	,S.intLoadId
	,S.intLoadDetailId
	,S.dtmBusinessDate
	,S.intShiftId
	,S.intLocationId
	,S.intInventoryReceiptId
	,S.intInventoryShipmentId
	,S.intWorkOrderId
	,S.strComment
	,S.ysnAdjustInventoryQtyBySampleQty
	,S.intStorageLocationId
	,S.intBookId
	,S.intSubBookId
	,S.strChildLotNumber
	,S.strCourier
	,S.strCourierRef
	,S.intForwardingAgentId
	,S.strForwardingAgentRef
	,S.strSentBy
	,S.intSentById
	,S.intSampleRefId
	,S.ysnParent
	,S.intCreatedUserId
	,S.dtmCreated
	,S.intLastModifiedUserId
	,S.dtmLastModified
	,ST.strSampleTypeName
	,CASE 
		WHEN S.intProductTypeId = 2
			THEN I.strItemNo
		WHEN S.intProductTypeId = 3
			THEN IR.strReceiptNumber
		WHEN S.intProductTypeId = 4
			THEN INVS.strShipmentNumber
		WHEN S.intProductTypeId = 6
			THEN S.strLotNumber
		WHEN S.intProductTypeId = 8
			THEN CASE 
					WHEN S.ysnParent = 1
						THEN LTRIM(CD.intContractDetailRefId)
					ELSE LTRIM(CD1.intContractDetailRefId)
					END
		WHEN S.intProductTypeId = 9
			THEN LTRIM(LCL.intLoadDetailContainerLinkRefId)
		WHEN S.intProductTypeId = 10
			THEN LTRIM(LD.intLoadDetailRefId)
		WHEN S.intProductTypeId = 11
			THEN PL.strParentLotNumber
		WHEN S.intProductTypeId = 12
			THEN W.strWorkOrderNo
		END AS strProductValue
	,SS.strSecondaryStatus AS strSampleStatus
	,SS1.strSecondaryStatus AS strPreviousSampleStatus
	,I.strItemNo
	,IC.strContractItemName
	,CASE 
		WHEN S.ysnParent = 1
			THEN CD.intContractDetailRefId
		ELSE CD1.intContractDetailRefId
		END AS intContractDetailRefId
	,LS.strSecondaryStatus AS strLotStatus
	,E.strName AS strPartyName
	,E3.strName AS strTestedByName
	,UOM.strUnitMeasure AS strSampleUOM
	,UOM1.strUnitMeasure AS strRepresentingUOM
	,CS.strSubLocationName
	,I1.strItemNo AS strBundleItemNo
	,LCL.intLoadDetailContainerLinkRefId
	--,LC.intLoadContainerRefId
	--,L.intLoadRefId
	,LD.intLoadDetailRefId
	,SHIFT1.strShiftName
	,CL.strLocationName
	,IR.strReceiptNumber
	,INVS.strShipmentNumber AS strInvShipmentNumber
	,W.strWorkOrderNo
	,SL.strName AS strStorageLocationName
	,B.strBook
	,SB.strSubBook
	,E1.strName AS strForwardingAgentName
	,CASE 
		WHEN S.strSentBy = 'Self'
			THEN CL1.strLocationName
		ELSE E2.strName
		END AS strSentByValue
	,E4.strName AS strCreatedUser
	,E5.strName AS strLastModifiedUser
FROM tblQMSample S
JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
LEFT JOIN tblQMSampleStatus SS1 ON SS1.intSampleStatusId = S.intPreviousSampleStatusId
LEFT JOIN tblICItem I ON I.intItemId = S.intItemId
LEFT JOIN tblICItem I1 ON I1.intItemId = S.intItemBundleId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = S.intInventoryReceiptId
LEFT JOIN tblICInventoryShipment INVS ON INVS.intInventoryShipmentId = S.intInventoryShipmentId
LEFT JOIN tblLGAllocationDetail AD ON AD.intPContractDetailId = S.intContractDetailId
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = AD.intSContractDetailId
LEFT JOIN tblCTContractDetail CD1 ON CD1.intContractDetailId = S.intContractDetailId
LEFT JOIN tblLGLoad L ON L.intLoadId = S.intLoadId
LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = S.intLoadDetailId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = S.intLoadContainerId
LEFT JOIN tblLGLoadDetailContainerLink LCL ON LCL.intLoadDetailContainerLinkId = S.intLoadDetailContainerLinkId
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
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = S.intForwardingAgentId
LEFT JOIN tblEMEntity E2 ON E2.intEntityId = S.intSentById
LEFT JOIN tblEMEntity E3 ON E3.intEntityId = S.intTestedById
LEFT JOIN tblEMEntity E4 ON E4.intEntityId = S.intCreatedUserId
LEFT JOIN tblEMEntity E5 ON E5.intEntityId = S.intLastModifiedUserId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
LEFT JOIN tblSMCompanyLocation CL1 ON CL1.intCompanyLocationId = S.intSentById
LEFT JOIN tblMFShift SHIFT1 ON SHIFT1.intShiftId = S.intShiftId
LEFT JOIN tblICParentLot PL ON PL.intParentLotId = S.intProductValueId
	AND S.intProductTypeId = 11
