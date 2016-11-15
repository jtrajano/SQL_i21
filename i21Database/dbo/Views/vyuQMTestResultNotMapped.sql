CREATE VIEW vyuQMTestResultNotMapped
AS
SELECT TR.intTestResultId
	,T.strTestName
	,T.intReplications
	,P.strPropertyName
	,P.strDescription
	,L.strListName
	,UOM.strUnitMeasure
	,P1.strPropertyName AS strParentPropertyName
	,P.intDataTypeId
	,P.intDecimalPlaces
	,P.intListId
	,LI.strListItemName
FROM tblQMTestResult TR
JOIN tblQMTest T ON T.intTestId = TR.intTestId
JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
LEFT JOIN tblQMList L ON L.intListId = P.intListId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = TR.intUnitMeasureId
LEFT JOIN tblQMProperty P1 ON P1.intPropertyId = TR.intParentPropertyId
LEFT JOIN tblQMListItem LI ON LI.intListItemId = TR.intListItemId
