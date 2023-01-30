CREATE VIEW [dbo].[vyuGLChangeAccountCategoryDetail]
AS 
SELECT
	CACD.*
	,A.strAccountId
	,strAccountCategory = CurrentCategory.strAccountCategory
	,strNewAccountCategory = NewCategory.strAccountCategory
	,strEntityName = E.strName
FROM [dbo].[tblGLChangeAccountCategoryDetail] CACD
LEFT JOIN [dbo].[tblGLAccount] A
	ON A.intAccountId = CACD.intAccountId
LEFT JOIN [dbo].[tblGLAccountCategory] CurrentCategory
	ON CurrentCategory.intAccountCategoryId = CACD.intAccountCategoryId
LEFT JOIN [dbo].[tblGLAccountCategory] NewCategory
	ON NewCategory.intAccountCategoryId = CACD.intNewAccountCategoryId
LEFT JOIN [dbo].[tblEMEntity] E
	ON E.intEntityId = CACD.intEntityId