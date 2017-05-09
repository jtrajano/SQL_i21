CREATE VIEW vyuQMProductPropertyNotMapped
AS
SELECT PP.intProductPropertyId
	,T.strTestName
	,P.strPropertyName
	,P.strDescription
	,P.intAnalysisTypeId
	,P.intDataTypeId
	,P.intListId
	,P.intDecimalPlaces
	,P.ysnActive
	,P.ysnNotify
	,A.strAnalysisTypeName
	,D.strDataTypeName
	,L.strListName
FROM tblQMProductProperty PP
JOIN tblQMTest T ON T.intTestId = PP.intTestId
JOIN tblQMProperty P ON P.intPropertyId = PP.intPropertyId
JOIN tblQMAnalysisType A ON A.intAnalysisTypeId = P.intAnalysisTypeId
JOIN tblQMDataType D ON D.intDataTypeId = P.intDataTypeId
LEFT JOIN tblQMList L ON L.intListId = P.intListId
