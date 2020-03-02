CREATE VIEW vyuIPGetSampleTypeDetail
AS
SELECT STD.intSampleTypeDetailId
	,STD.intSampleTypeId
	,STD.intAttributeId
	,STD.intConcurrencyId
	,STD.ysnIsMandatory
	,STD.intCreatedUserId
	,STD.dtmCreated
	,STD.intLastModifiedUserId
	,STD.dtmLastModified
	,STD.intSampleTypeDetailRefId
	,A.strAttributeName
FROM tblQMSampleTypeDetail STD WITH (NOLOCK)
LEFT JOIN tblQMAttribute A WITH (NOLOCK) ON A.intAttributeId = STD.intAttributeId
