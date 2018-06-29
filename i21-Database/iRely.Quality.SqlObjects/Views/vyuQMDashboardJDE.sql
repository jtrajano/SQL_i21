CREATE VIEW vyuQMDashboardJDE
AS
SELECT TR.intTestResultId
	,ST.strSampleTypeName
	,I.strItemNo
	,I.strDescription
	,C.strCategoryCode
	,(CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq)) AS strContractNumber
	,CH.strCustomerContract AS strVendorReference
	,COM.strCommodityCode AS strCommodity
	,IC.strContractItemName
	,ISNULL(RY.strCountry, OG.strCountry) AS strOrigin
	,CD.strGarden
	,CD.dblQuantity
	,UOM.strUnitMeasure
	,CD.strERPPONumber
	,CD.strERPItemNumber
	,CD.strERPBatchNumber
	,S.strSampleNumber
	,P.strPropertyName
	,T.strTestName
	,TR.dblMinValue
	,TR.dblMaxValue
	,TR.strPropertyValue
	,TR.strResult
	,TR.strIsMandatory
	,S.strContainerNumber
	,E.strName
	,SS.strStatus
	,S.intSampleId
	,S.intLocationId
	,S.strComment
	,S.dtmSampleReceivedDate
	,TR.dtmLastModified
FROM tblQMTestResult AS TR
JOIN tblQMSample AS S ON S.intSampleId = TR.intSampleId
JOIN tblQMSampleType AS ST ON ST.intSampleTypeId = S.intSampleTypeId
JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
JOIN tblQMProperty AS P ON P.intPropertyId = TR.intPropertyId
JOIN tblQMTest AS T ON T.intTestId = TR.intTestId
JOIN tblCTContractDetail AS CD ON CD.intContractDetailId = S.intProductValueId
	AND S.intProductTypeId = 8
JOIN tblCTContractHeader AS CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem AS I ON I.intItemId = CD.intItemId
JOIN tblICCategory AS C ON C.intCategoryId = I.intCategoryId
LEFT JOIN tblICCommodity COM ON COM.intCommodityId = CH.intCommodityId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = CD.intUnitMeasureId
LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
LEFT JOIN tblSMCountry RY ON RY.intCountryID = IC.intCountryId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	AND CA.strType = 'Origin'
LEFT JOIN tblSMCountry OG ON OG.intCountryID = CA.intCountryID
LEFT JOIN tblEMEntity AS E ON E.intEntityId = S.intEntityId
