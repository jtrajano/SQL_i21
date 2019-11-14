CREATE VIEW [dbo].[vyuIPGetItemKit]
AS
SELECT IK.intItemId
	,[strComponent]
	,[strInputType]
	,IK.[intSort]
	,IK.intConcurrencyId
	,IK.dtmDateCreated
	,IK.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemKit IK
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IK.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IK.intModifiedByUserId
