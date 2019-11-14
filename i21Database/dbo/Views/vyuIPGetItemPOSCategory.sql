CREATE VIEW [dbo].[vyuIPGetItemPOSCategory]
AS
SELECT POSCategory.intItemId 
	,C.strCategoryCode  
	,POSCategory.[intSort]
	,POSCategory.intConcurrencyId
	,POSCategory.dtmDateCreated
	,POSCategory.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemPOSCategory POSCategory
LEFT JOIN tblICCategory C on C.intCategoryId =POSCategory.intCategoryId 
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = POSCategory.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = POSCategory.intModifiedByUserId
