CREATE VIEW vyuIPGetConditionalProductProperty
AS
SELECT CPP.intConditionalProductPropertyId
	,CPP.intProductPropertyId
	,CPP.intConcurrencyId
	,CPP.intOnSuccessPropertyId
	,CPP.intOnFailurePropertyId
	,CPP.intCreatedUserId
	,CPP.dtmCreated
	,CPP.intLastModifiedUserId
	,CPP.dtmLastModified
	,CPP.intConditionalProductPropertyRefId
	,P1.strPropertyName AS strSuccessPropertyName
	,P2.strPropertyName AS strFailurePropertyName
	,T.strTestName
	,P.strPropertyName
	,PP.intProductId
FROM tblQMConditionalProductProperty CPP
JOIN tblQMProductProperty PP ON PP.intProductPropertyId = CPP.intProductPropertyId
LEFT JOIN tblQMProperty P1 ON P1.intPropertyId = CPP.intOnSuccessPropertyId
LEFT JOIN tblQMProperty P2 ON P2.intPropertyId = CPP.intOnFailurePropertyId
LEFT JOIN tblQMTest T ON T.intTestId = PP.intTestId
LEFT JOIN tblQMProperty P ON P.intPropertyId = PP.intPropertyId
