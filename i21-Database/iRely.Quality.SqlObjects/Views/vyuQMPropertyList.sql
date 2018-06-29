CREATE VIEW vyuQMPropertyList
AS
SELECT P.intPropertyId
	,P.strPropertyName
	,AT.strAnalysisTypeName
	,P.strDescription
	,DT.strDataTypeName
	,L.strListName
	,P.intDecimalPlaces
	,P.ysnActive
	,P.strIsMandatory
	,P.ysnNotify
	,dbo.fnQMGetTestNames(P.intPropertyId) AS strTestNames
	,I.strItemNo
FROM tblQMProperty AS P
JOIN tblQMAnalysisType AS AT ON AT.intAnalysisTypeId = P.intAnalysisTypeId
JOIN tblQMDataType AS DT ON DT.intDataTypeId = P.intDataTypeId
LEFT JOIN tblQMList AS L ON L.intListId = P.intListId
LEFT JOIN tblICItem I ON I.intItemId = P.intItemId
WHERE ISNULL(strFormula, '') = ''
