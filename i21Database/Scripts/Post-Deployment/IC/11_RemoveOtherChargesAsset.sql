print('/*******************  BEGIN Other Charges (Asset) *******************/')
GO

-- Remove the Other charge (asset) from the Item GL Setup
DELETE	ItemAccount
FROM	dbo.tblICItemAccount ItemAccount INNER JOIN dbo.tblGLAccountCategory AccountCategory
			ON ItemAccount.intAccountCategoryId = AccountCategory.intAccountCategoryId
WHERE	AccountCategory.strAccountCategory = 'Other Charge (Asset)'

print('/*******************  END Other Charges (Asset) *******************/')
GO
