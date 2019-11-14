CREATE VIEW [dbo].[vyuIPGetItemCertification]
AS
SELECT IC.intItemId 
	,C.strCertificationName 
	,IC.[intSort]
	,IC.intConcurrencyId
	,IC.dtmDateCreated
	,IC.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemCertification IC
LEFT JOIN tblICCertification C on C.intCertificationId=IC.intCertificationId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IC.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IC.intModifiedByUserId
