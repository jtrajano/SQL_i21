CREATE VIEW vyuIPGetProductPropertyFormulaProperty
AS
SELECT PPFP.intProductPropertyFormulaPropertyId
	,PPFP.intProductPropertyId
	,PPFP.intConcurrencyId
	,PPFP.intTestId
	,PPFP.intPropertyId
	,PPFP.intCreatedUserId
	,PPFP.dtmCreated
	,PPFP.intLastModifiedUserId
	,PPFP.dtmLastModified
	,PPFP.intProductPropertyFormulaPropertyRefId
	,T1.strTestName AS strFormulaTestName
	,P1.strPropertyName AS strFormulaPropertyName
	,T.strTestName
	,P.strPropertyName
	,PP.intProductId
FROM tblQMProductPropertyFormulaProperty PPFP
JOIN tblQMProductProperty PP ON PP.intProductPropertyId = PPFP.intProductPropertyId
LEFT JOIN tblQMTest T1 ON T1.intTestId = PPFP.intTestId
LEFT JOIN tblQMProperty P1 ON P1.intPropertyId = PPFP.intPropertyId
LEFT JOIN tblQMTest T ON T.intTestId = PP.intTestId
LEFT JOIN tblQMProperty P ON P.intPropertyId = PP.intPropertyId
