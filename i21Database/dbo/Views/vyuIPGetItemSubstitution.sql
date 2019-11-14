CREATE VIEW dbo.vyuIPGetItemSubstitution
AS
SELECT ISub.intItemId
	,CL.strLocationName
	,ISub.strModification
	,ISub.ysnContracted
	,ISub.strComment
	,ISub.intSort
	,ISub.intConcurrencyId
	,ISub.dtmDateCreated
	,ISub.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemSubstitution ISub
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = ISub.intLocationId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = ISub.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = ISub.intModifiedByUserId
