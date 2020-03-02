CREATE VIEW vyuIPGetProductProperty
AS
SELECT PP.intProductPropertyId
	,PP.intConcurrencyId
	,PP.intProductId
	,PP.intTestId
	,PP.intPropertyId
	,PP.strFormulaParser
	,PP.strComputationMethod
	,PP.intSequenceNo
	,PP.intComputationTypeId
	,PP.strFormulaField
	,PP.strIsMandatory
	,PP.ysnPrintInLabel
	,PP.intCreatedUserId
	,PP.dtmCreated
	,PP.intLastModifiedUserId
	,PP.dtmLastModified
	,PP.intProductPropertyRefId
	,T.strTestName
	,P.strPropertyName
FROM tblQMProductProperty PP WITH (NOLOCK)
LEFT JOIN tblQMTest T WITH (NOLOCK) ON T.intTestId = PP.intTestId
LEFT JOIN tblQMProperty P WITH (NOLOCK) ON P.intPropertyId = PP.intPropertyId
