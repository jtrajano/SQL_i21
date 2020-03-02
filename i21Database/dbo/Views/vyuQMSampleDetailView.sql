CREATE VIEW vyuQMSampleDetailView
AS
SELECT SD.intSampleDetailId
	,SD.intConcurrencyId
	,SD.intSampleId
	,SD.intAttributeId
	,SD.strAttributeValue
	,SD.intListItemId
	,SD.ysnIsMandatory
	,SD.intSampleDetailRefId
	,SD.intCreatedUserId
	,SD.dtmCreated
	,SD.intLastModifiedUserId
	,SD.dtmLastModified
	,S.intSampleRefId
	,A.strAttributeName
	,LI.strListItemName
FROM tblQMSample S WITH (NOLOCK)
JOIN tblQMSampleDetail SD WITH (NOLOCK) ON SD.intSampleId = S.intSampleId
JOIN tblQMAttribute A WITH (NOLOCK) ON A.intAttributeId = SD.intAttributeId
LEFT JOIN tblQMListItem LI WITH (NOLOCK) ON LI.intListItemId = SD.intListItemId
