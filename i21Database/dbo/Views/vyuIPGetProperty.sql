CREATE VIEW vyuIPGetProperty
AS
SELECT P.intPropertyId
	,P.intAnalysisTypeId
	,P.intConcurrencyId
	,P.strPropertyName
	,P.strDescription
	,P.intDataTypeId
	,P.intListId
	,P.intDecimalPlaces
	,P.strIsMandatory
	,P.ysnActive
	,P.strFormula
	,P.strFormulaParser
	,P.strDefaultValue
	,P.ysnNotify
	,P.intItemId
	,P.intCreatedUserId
	,P.dtmCreated
	,P.intLastModifiedUserId
	,P.dtmLastModified
	,P.intPropertyRefId
	,L.strListName
	,I.strItemNo
FROM tblQMProperty P
LEFT JOIN tblQMList L ON L.intListId = P.intListId
LEFT JOIN tblICItem I ON I.intItemId = P.intItemId
