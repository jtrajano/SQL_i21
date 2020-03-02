CREATE VIEW vyuIPGetProductTest
AS
SELECT PT.intProductTestId
	,PT.intConcurrencyId
	,PT.intProductId
	,PT.intTestId
	,PT.intCreatedUserId
	,PT.dtmCreated
	,PT.intLastModifiedUserId
	,PT.dtmLastModified
	,PT.intProductTestRefId
	,T.strTestName
FROM tblQMProductTest PT WITH (NOLOCK)
LEFT JOIN tblQMTest T WITH (NOLOCK) ON T.intTestId = PT.intTestId
