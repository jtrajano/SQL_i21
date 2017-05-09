CREATE VIEW vyuQMPropertyNotMapped
AS
SELECT P.intPropertyId
	,A.strAnalysisTypeName
	,D.strDataTypeName
	,L.strListName
FROM tblQMProperty P
JOIN tblQMAnalysisType A ON A.intAnalysisTypeId = P.intAnalysisTypeId
JOIN tblQMDataType D ON D.intDataTypeId = P.intDataTypeId
LEFT JOIN tblQMList L ON L.intListId = P.intListId
