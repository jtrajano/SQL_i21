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
FROM tblQMConditionalProductProperty CPP WITH (NOLOCK)
JOIN tblQMProductProperty PP WITH (NOLOCK) ON PP.intProductPropertyId = CPP.intProductPropertyId
LEFT JOIN tblQMProperty P1 WITH (NOLOCK) ON P1.intPropertyId = CPP.intOnSuccessPropertyId
LEFT JOIN tblQMProperty P2 WITH (NOLOCK) ON P2.intPropertyId = CPP.intOnFailurePropertyId
LEFT JOIN tblQMTest T WITH (NOLOCK) ON T.intTestId = PP.intTestId
LEFT JOIN tblQMProperty P WITH (NOLOCK) ON P.intPropertyId = PP.intPropertyId
