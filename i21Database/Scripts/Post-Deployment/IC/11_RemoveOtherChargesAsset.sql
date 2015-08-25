print('/*******************  BEGIN Other Charges (Asset) *******************/')
GO

UPDATE	dbo.tblGLAccount
SET		intAccountCategoryId = NULL 
WHERE	intAccountCategoryId IN (
			SELECT	intAccountCategoryId 
			FROM	tblGLAccountCategory 
			WHERE	strAccountCategory = 'Other Charge (Asset)'
		)

DELETE	CategoryGroup
FROM	dbo.tblGLAccountCategoryGroup CategoryGroup INNER JOIN dbo.tblGLAccountCategory AccntCategory
			ON CategoryGroup.intAccountCategoryId = AccntCategory.intAccountCategoryId
WHERE	AccntCategory.strAccountCategory = 'Other Charge (Asset)'

DELETE	AccntCategory
FROM	dbo.tblGLAccountCategory AccntCategory
WHERE	AccntCategory.strAccountCategory = 'Other Charge (Asset)'


print('/*******************  END Other Charges (Asset) *******************/')
GO
