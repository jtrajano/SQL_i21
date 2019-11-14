CREATE VIEW [dbo].[vyuIPGetItemMotorFuelTax]
AS
SELECT MU.intItemId 
	,TA.strTaxAuthorityCode 
	,PC.strProductCode 
	,MU.[intSort]
	,MU.intConcurrencyId
	,MU.dtmDateCreated
	,MU.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemMotorFuelTax MU
LEFT JOIN tblTFTaxAuthority TA on TA.intTaxAuthorityId =MU.intTaxAuthorityId
LEFT JOIN tblTFProductCode PC on PC.intProductCodeId =MU.intProductCodeId  
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = MU.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = MU.intModifiedByUserId
