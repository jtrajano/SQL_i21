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
	,E1.strName AS strCreatedUserName
FROM tblQMAttribute A
LEFT JOIN tblQMList L ON L.intListId = A.intListId
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = A.intCreatedUserId
