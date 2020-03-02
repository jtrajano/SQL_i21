CREATE VIEW vyuIPGetAttribute
AS
SELECT A.intAttributeId
	,A.intConcurrencyId
	,A.strAttributeName
	,A.strDescription
	,A.intDataTypeId
	,A.intListId
	,A.strAttributeValue
	,A.intListItemId
	,A.intCreatedUserId
	,A.dtmCreated
	,A.intLastModifiedUserId
	,A.dtmLastModified
	,A.intAttributeRefId
	,L.strListName
FROM tblQMAttribute A WITH (NOLOCK)
LEFT JOIN tblQMList L WITH (NOLOCK) ON L.intListId = A.intListId
