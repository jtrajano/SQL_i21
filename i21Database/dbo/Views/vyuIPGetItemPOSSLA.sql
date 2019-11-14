CREATE VIEW [dbo].[vyuIPGetItemPOSSLA]
AS
SELECT POSSLA.intItemId
	,POSSLA.[strSLAContract]
	,POSSLA.[dblContractPrice]
	,POSSLA.[ysnServiceWarranty]
	,POSSLA.intConcurrencyId
	,POSSLA.dtmDateCreated
	,POSSLA.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemPOSSLA POSSLA
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = POSSLA.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = POSSLA.intModifiedByUserId
