CREATE VIEW [dbo].[vyuAPGetItemGLAccount]
AS 
SELECT 
	ISNULL(ItemLevel.intItemId, CategoryLevel.intItemId) AS intItemId,
    ISNULL(ItemLevel.intAccountId, CategoryLevel.intAccountId) AS intAccountId,
	ISNULL(ItemLevel.strAccountId, CategoryLevel.strAccountId) AS strAccountId,
	ISNULL(ItemLevel.strDescription, CategoryLevel.strDescription) AS strDescription,
	ISNULL(ItemLevel.strAccountCategory, CategoryLevel.strAccountCategory) AS strAccountCategory
FROM(
		SELECT * FROM [dbo].[vyuICGetItemAccount] 
		WHERE 
			strAccountCategory = 'Other Charge Expense'
	) AS ItemLevel
	FULL JOIN 
	(
		SELECT	 
			Item.intItemId,
			CategoryAccounts.intAccountId,
			GLAccnt.strAccountId,
			GLAccnt.strDescription,
			AccntCategory.strAccountCategory
		FROM	
			dbo.tblICItem Item INNER JOIN dbo.tblICCategory Category
				ON Item.intCategoryId = Category.intCategoryId
			INNER JOIN tblICCategoryAccount CategoryAccounts
				ON Category.intCategoryId = CategoryAccounts.intCategoryId
			INNER JOIN dbo.tblGLAccountCategory AccntCategory
				ON CategoryAccounts.intAccountCategoryId = AccntCategory.intAccountCategoryId
			INNER JOIN dbo.tblGLAccount GLAccnt
				ON CategoryAccounts.intAccountId = GLAccnt.intAccountId
		WHERE	
			AccntCategory.strAccountCategory = 'Other Charge Expense'	
	) AS CategoryLevel
	ON ItemLevel.intItemId = CategoryLevel.intItemId 
