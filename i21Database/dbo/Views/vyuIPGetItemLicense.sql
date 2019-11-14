CREATE VIEW [dbo].[vyuIPGetItemLicense]
AS
SELECT IL.intItemId
	,LT.strCode
	,IL.intConcurrencyId
	,IL.dtmDateCreated
	,IL.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemLicense IL
Left JOIN tblSMLicenseType LT on LT.intLicenseTypeId=IL.intLicenseTypeId 
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IL.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IL.intModifiedByUserId


