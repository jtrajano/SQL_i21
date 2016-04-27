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
	,CH.strContractNumber
	,SC.strContainerNumber
	,ISNULL(L.intLotId,PL.intParentLotId) AS intLotId
	,ISNULL(L.strLotNumber,PL.strParentLotNumber) AS strLotNumber
	,S.strSampleNumber
	,E.strName
	,SS.strStatus
	,S.intSampleId
	,(SELECT strShipperCode from dbo.fnQMGetShipperName(S.strMarks)) AS strShipperCode
	,(SELECT strShipperName from dbo.fnQMGetShipperName(S.strMarks)) AS strShipperName
FROM dbo.tblQMTestResult AS TR
JOIN dbo.tblQMSample AS S ON S.intSampleId = TR.intSampleId
JOIN dbo.tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
JOIN dbo.tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
JOIN dbo.tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
JOIN dbo.tblQMTest AS T ON T.intTestId = TR.intTestId
JOIN dbo.tblICItem AS I ON I.intItemId = S.intItemId
LEFT JOIN dbo.tblICItem AS I1 ON I1.intItemId = S.intItemBundleId
JOIN dbo.tblICCategory AS C ON C.intCategoryId = I.intCategoryId
LEFT JOIN dbo.tblEMEntity AS E ON E.intEntityId = S.intEntityId
LEFT JOIN dbo.tblICLot AS L ON L.intLotId = S.intProductValueId
	AND S.intProductTypeId = 6
LEFT JOIN dbo.tblICParentLot AS PL ON PL.intParentLotId = S.intProductValueId
	AND S.intProductTypeId = 11
LEFT JOIN dbo.tblCTContractDetail AS CD ON CD.intContractDetailId = S.intProductValueId
	AND S.intProductTypeId = 8
LEFT JOIN dbo.tblCTContractHeader AS CH ON CH.intContractHeaderId = CD.intContractHeaderId
--LEFT JOIN dbo.tblLGShipmentBLContainerContract AS SCC ON SCC.intShipmentBLContainerContractId = S.intProductValueId
--	AND S.intProductTypeId = 9
--LEFT JOIN dbo.tblLGShipmentBLContainer AS SC ON SC.intShipmentBLContainerId = SCC.intShipmentBLContainerId
LEFT JOIN dbo.tblLGLoadDetailContainerLink AS SCC ON SCC.intLoadDetailContainerLinkId = S.intProductValueId
	AND S.intProductTypeId = 9
LEFT JOIN dbo.tblLGLoadContainer AS SC ON SC.intLoadContainerId = SCC.intLoadContainerId
