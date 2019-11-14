CREATE VIEW dbo.vyuIPGetItemSubLocation
AS
SELECT IL.intItemId
	,CL.strLocationName
	,CSL.strSubLocationName
	,ISL.intConcurrencyId
	,ISL.dtmDateCreated
	,ISL.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemSubLocation ISL
LEFT JOIN tblICItemLocation IL ON IL.intItemLocationId = ISL.intItemLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblSMCompanyLocationSubLocation CSL ON CSL.intCompanyLocationSubLocationId = ISL.intSubLocationId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = ISL.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = ISL.intModifiedByUserId
