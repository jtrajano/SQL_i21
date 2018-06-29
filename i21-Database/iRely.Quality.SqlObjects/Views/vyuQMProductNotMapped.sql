CREATE VIEW vyuQMProductNotMapped
AS
SELECT P.intProductId
	,PT.strProductTypeName
	,COALESCE(C.strCategoryCode, I.strItemNo) AS strProductValue
	,COALESCE(C.strDescription, I.strDescription) AS strDescription
	,UOM.strUnitMeasure
	,L1.strSecondaryStatus AS strApprovalLotStatus
	,L2.strSecondaryStatus AS strRejectionLotStatus
	,L3.strSecondaryStatus AS strBondedApprovalLotStatus
	,L4.strSecondaryStatus AS strBondedRejectionLotStatus
FROM tblQMProduct P
JOIN tblQMProductType PT ON PT.intProductTypeId = P.intProductTypeId
LEFT JOIN tblICCategory C ON C.intCategoryId = P.intProductValueId
	AND P.intProductTypeId = 1
LEFT JOIN tblICItem I ON I.intItemId = P.intProductValueId
	AND P.intProductTypeId = 2
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = P.intUnitMeasureId
LEFT JOIN tblICLotStatus L1 ON L1.intLotStatusId = P.intApprovalLotStatusId
LEFT JOIN tblICLotStatus L2 ON L2.intLotStatusId = P.intRejectionLotStatusId
LEFT JOIN tblICLotStatus L3 ON L3.intLotStatusId = P.intBondedApprovalLotStatusId
LEFT JOIN tblICLotStatus L4 ON L4.intLotStatusId = P.intBondedRejectionLotStatusId
