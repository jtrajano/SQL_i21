CREATE VIEW vyuQMPropertyNotMapped
AS
SELECT P.intPropertyId
	,A.strAnalysisTypeName
	,D.strDataTypeName
	,L.strListName
	,I.strItemNo
FROM tblQMProperty P
JOIN tblQMAnalysisType A ON A.intAnalysisTypeId = P.intAnalysisTypeId
JOIN tblQMDataType D ON D.intDataTypeId = P.intDataTypeId
LEFT JOIN tblQMList L ON L.intListId = P.intListId
LEFT JOIN tblICItem I ON I.intItemId = P.intItemId
