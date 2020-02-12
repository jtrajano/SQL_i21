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
FROM tblQMProductProperty PP
LEFT JOIN tblQMTest T ON T.intTestId = PP.intTestId
LEFT JOIN tblQMProperty P ON P.intPropertyId = PP.intPropertyId
