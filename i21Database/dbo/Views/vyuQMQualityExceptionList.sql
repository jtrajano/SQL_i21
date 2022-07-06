CREATE VIEW vyuQMQualityExceptionList
AS
SELECT TR.intTestResultId
	,ST.strSampleTypeName
	,I1.strItemNo AS strBundleItemNo
	,I.strItemNo
	,I.strDescription
	,C.strCategoryCode
	,P.strPropertyName
	,T.strTestName
	,TR.dblMinValue
	,TR.dblMaxValue
	,TR.strPropertyValue
	,TR.strResult
	,TR.strIsMandatory
	--,CH.strContractNumber
	--,SC.strContainerNumber
	,COALESCE(CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq), CH1.strContractNumber + ' - ' + LTRIM(CD1.intContractSeq), CH2.strContractNumber + ' - ' + LTRIM(CD2.intContractSeq)) AS strContractNumber
	,CY.strCommodityCode
	,CY.strDescription AS strCommodityDescription
	,S.dblRepresentingQty
	,UM1.strUnitMeasure AS strRepresentingUOM
	,COALESCE(SC.strContainerNumber, S.strContainerNumber) AS strContainerNumber
	,L.intLotId
	,ISNULL(L.strLotNumber, S.strChildLotNumber) AS strLotNumber
	,ISNULL(LPL.intParentLotId, PL.intParentLotId) AS intParentLotId
	,ISNULL(LPL.strParentLotNumber, PL.strParentLotNumber) AS strParentLotNumber
	,S.strSampleNumber
	,S.strSampleRefNo
	,E.strName
	,SS.strStatus
	,S.intSampleId
	,S.intLocationId
	,(
		SELECT strShipperCode
		FROM dbo.fnQMGetShipperName(S.strMarks)
		) COLLATE Latin1_General_CI_AS AS strShipperCode
	,(
		SELECT strShipperName
		FROM dbo.fnQMGetShipperName(S.strMarks)
		) COLLATE Latin1_General_CI_AS AS strShipperName
	,S.strComment
	,ISNULL(ito1.intOwnerId, ito2.intOwnerId) AS intEntityId
	,S.intSampleTypeId
	,TR.dtmLastModified
	,S.dtmBusinessDate
	,SHI.strShiftName
	,WO.strWorkOrderNo
	,TR.intSequenceNo
	,B.strBook
	,SB.strSubBook
	,CH.intContractHeaderId
	,S.intItemId
	,S.dtmCreated
	,CE.strName AS strCreatedUserName
	,S.dtmLastModified AS dtmLastUpdated
	,UE.strName AS strUpdatedUserName
	,I.strOrigin 
	,I.strProductType
	,I.strGrade,strRegion
	,I.strSeason
	,I.strClass
	,I.strProductLine
FROM dbo.tblQMTestResult AS TR
JOIN dbo.tblQMSample AS S ON S.intSampleId = TR.intSampleId
JOIN dbo.tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
JOIN dbo.tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
JOIN dbo.tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
JOIN dbo.tblQMTest AS T ON T.intTestId = TR.intTestId
LEFT JOIN dbo.vyuICSearchItem AS I ON I.intItemId = S.intItemId
LEFT JOIN dbo.tblICItem AS I1 ON I1.intItemId = S.intItemBundleId
LEFT JOIN dbo.tblICCategory AS C ON C.intCategoryId = I.intCategoryId
LEFT JOIN dbo.tblEMEntity AS E ON E.intEntityId = S.intEntityId
LEFT JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = S.intRepresentingUOMId
LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = S.intSubBookId
LEFT JOIN dbo.tblICLot AS L ON L.intLotId = S.intProductValueId
	AND S.intProductTypeId = 6
LEFT JOIN tblICParentLot AS LPL ON LPL.intParentLotId = L.intParentLotId
LEFT JOIN dbo.tblICParentLot AS PL ON PL.intParentLotId = S.intProductValueId
	AND S.intProductTypeId = 11
LEFT JOIN tblICItemOwner ito1 ON ito1.intItemOwnerId = L.intItemOwnerId
LEFT JOIN tblICItemOwner ito2 ON ito2.intItemId = S.intItemId
	AND ito2.ysnDefault = 1
LEFT JOIN tblMFShift SHI ON SHI.intShiftId = S.intShiftId
LEFT JOIN tblMFWorkOrder WO ON WO.intWorkOrderId = S.intWorkOrderId
LEFT JOIN dbo.tblCTContractDetail AS CD ON CD.intContractDetailId = S.intProductValueId
	AND S.intProductTypeId = 8
LEFT JOIN dbo.tblCTContractHeader AS CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblICCommodity CY ON CY.intCommodityId = ISNULL(CH.intCommodityId, I.intCommodityId)
LEFT JOIN dbo.tblLGLoadDetail AS LD ON LD.intLoadDetailId = S.intProductValueId
	AND S.intProductTypeId = 10
LEFT JOIN dbo.tblLGLoad AS LL ON LL.intLoadId = LD.intLoadId
LEFT JOIN dbo.tblCTContractDetail AS CD1 ON CD1.intContractDetailId = LD.intPContractDetailId
LEFT JOIN dbo.tblCTContractHeader AS CH1 ON CH1.intContractHeaderId = CD1.intContractHeaderId
--LEFT JOIN dbo.tblLGShipmentBLContainerContract AS SCC ON SCC.intShipmentBLContainerContractId = S.intProductValueId
--	AND S.intProductTypeId = 9
--LEFT JOIN dbo.tblLGShipmentBLContainer AS SC ON SC.intShipmentBLContainerId = SCC.intShipmentBLContainerId
LEFT JOIN dbo.tblLGLoadDetailContainerLink AS SCC ON SCC.intLoadDetailContainerLinkId = S.intProductValueId
	AND S.intProductTypeId = 9
LEFT JOIN dbo.tblLGLoadContainer AS SC ON SC.intLoadContainerId = SCC.intLoadContainerId
LEFT JOIN dbo.tblLGLoadDetail AS LD2 ON LD2.intLoadDetailId = SCC.intLoadDetailId
LEFT JOIN dbo.tblLGLoad AS LL2 ON LL2.intLoadId = LD2.intLoadId
LEFT JOIN dbo.tblCTContractDetail AS CD2 ON CD2.intContractDetailId = LD2.intPContractDetailId
LEFT JOIN dbo.tblCTContractHeader AS CH2 ON CH2.intContractHeaderId = CD2.intContractHeaderId
LEFT JOIN tblEMEntity CE ON CE.intEntityId = S.intCreatedUserId
LEFT JOIN tblEMEntity UE ON UE.intEntityId = S.intLastModifiedUserId
WHERE S.intTypeId = 1
