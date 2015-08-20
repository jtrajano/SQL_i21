print('/*******************  BEGIN Other Charges (Asset) *******************/')
GO

DELETE	CategoryGroup
FROM	dbo.tblGLAccountCategoryGroup CategoryGroup INNER JOIN dbo.tblGLAccountCategory AccntCategory
			ON CategoryGroup.intAccountCategoryId = AccntCategory.intAccountCategoryId
WHERE	AccntCategory.strAccountCategory = 'Other Charge (Asset)'

DELETE	AccntCategory
FROM	dbo.tblGLAccountCategory AccntCategory
WHERE	AccntCategory.strAccountCategory = 'Other Charge (Asset)'


print('/*******************  END Other Charges (Asset) *******************/')
GO
