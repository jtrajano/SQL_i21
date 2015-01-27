CREATE VIEW [dbo].[vyuICGetItemAccount]
	AS 

SELECT 
intAccountKey = CAST(ROW_NUMBER() OVER(ORDER BY Item.intKey, ItemAccount.intItemAccountId) AS INT),
Item.intKey,
intItemAccountId,
ItemAccount.intItemId,
ItemAccount.intAccountId,
GLAccount.strAccountId,
GLAccount.intAccountGroupId,
GLAccountGroup.strAccountGroup,
GLAccountGroup.strAccountType,
ItemAccount.strAccountDescription AS strAccountCategory,
ItemAccount.intSort
FROM vyuICGetItemStock Item
INNER JOIN tblICItemAccount ItemAccount ON ItemAccount.intItemId = Item.intItemId
LEFT JOIN tblGLAccount GLAccount ON GLAccount.intAccountId = ItemAccount.intAccountId
LEFT JOIN tblGLAccountGroup GLAccountGroup ON GLAccountGroup.intAccountGroupId = GLAccount.intAccountGroupId
