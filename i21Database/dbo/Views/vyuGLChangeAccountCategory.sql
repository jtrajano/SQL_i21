CREATE VIEW [dbo].[vyuGLChangeAccountCategory]
AS 
SELECT 
	CAC.*
	,A.strAccountId
	,strAccountCategory = CurrentCategory.strAccountCategory
	,strNewAccountCategory = NewCategory.strAccountCategory
	,strEntityName = E.strName
FROM [dbo].[tblGLChangeAccountCategory] CAC
LEFT JOIN [dbo].[tblGLAccount] A
	ON A.intAccountId = CAC.intAccountId
LEFT JOIN [dbo].[tblGLAccountCategory] CurrentCategory
	ON CurrentCategory.intAccountCategoryId = CAC.intAccountCategoryId
LEFT JOIN [dbo].[tblGLAccountCategory] NewCategory
	ON NewCategory.intAccountCategoryId = CAC.intNewAccountCategoryId
LEFT JOIN [dbo].[tblEMEntity] E
	ON E.intEntityId = CAC.intEntityId