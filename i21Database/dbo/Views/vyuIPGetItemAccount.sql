CREATE VIEW [dbo].[vyuIPGetItemAccount]
AS
SELECT IA.intItemId 
	,AC.strAccountCategory
	,A.strAccountId
	,IA.intSort
	,IA.intConcurrencyId
	,IA.dtmDateCreated
	,IA.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemAccount IA
LEFT JOIN tblGLAccountCategory AC ON AC.intAccountCategoryId = IA.intAccountCategoryId
LEFT JOIN tblGLAccount A ON A.intAccountId = IA.intAccountId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IA.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IA.intModifiedByUserId



