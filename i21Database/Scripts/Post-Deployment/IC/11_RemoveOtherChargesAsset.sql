print('/*******************  BEGIN Other Charges (Asset) *******************/')
GO

-- Remove other charge (asset) in the GL Account setup. 
UPDATE	dbo.tblGLAccount
SET		intAccountCategoryId = NULL 
WHERE	intAccountCategoryId IN (
			SELECT	intAccountCategoryId 
			FROM	tblGLAccountCategory 
			WHERE	strAccountCategory = 'Other Charge (Asset)'
		)

-- Remove the Other charge (asset) from the Item GL Setup
DELETE	ItemAccount
FROM	dbo.tblICItemAccount ItemAccount INNER JOIN dbo.tblGLAccountCategory AccountCategory
			ON ItemAccount.intAccountCategoryId = AccountCategory.intAccountCategoryId
WHERE	AccountCategory.strAccountCategory = 'Other Charge (Asset)'

-- Remove the Other charge (asset) from the category group
DELETE	CategoryGroup
FROM	dbo.tblGLAccountCategoryGroup CategoryGroup INNER JOIN dbo.tblGLAccountCategory AccntCategory
			ON CategoryGroup.intAccountCategoryId = AccntCategory.intAccountCategoryId
WHERE	AccntCategory.strAccountCategory = 'Other Charge (Asset)'

-- Remove the Other charge (asset) from the category table. 
DELETE	AccntCategory
FROM	dbo.tblGLAccountCategory AccntCategory
WHERE	AccntCategory.strAccountCategory = 'Other Charge (Asset)'

print('/*******************  END Other Charges (Asset) *******************/')
GO
