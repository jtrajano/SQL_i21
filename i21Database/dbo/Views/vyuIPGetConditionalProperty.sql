CREATE VIEW vyuIPGetConditionalProperty
AS
SELECT CP.intConditionalPropertyId
	,CP.intPropertyId
	,CP.intConcurrencyId
	,CP.intOnSuccessPropertyId
	,CP.intOnFailurePropertyId
	,CP.intCreatedUserId
	,CP.dtmCreated
	,CP.intLastModifiedUserId
	,CP.dtmLastModified
	,CP.intConditionalPropertyRefId
	,P1.strPropertyName AS strSuccessPropertyName
	,P2.strPropertyName AS strFailurePropertyName
FROM tblQMConditionalProperty CP WITH (NOLOCK)
LEFT JOIN tblQMProperty P1 WITH (NOLOCK) ON P1.intPropertyId = CP.intOnSuccessPropertyId
LEFT JOIN tblQMProperty P2 WITH (NOLOCK) ON P2.intPropertyId = CP.intOnFailurePropertyId
