UPDATE itemAccount
SET itemAccount.intAccountCategoryId = (SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Other Charge Expense')
FROM tblICItemAccount itemAccount
	INNER JOIN tblICItem item ON item.intItemId = itemAccount.intItemId
WHERE itemAccount.intAccountCategoryId = (SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'General')
	AND item.strType = 'Non-Inventory'
	AND NOT EXISTS(SELECT * FROM tblICItemAccount a INNER JOIN tblICItem i ON i.intItemId = a.intItemId WHERE i.strType = 'Non-Inventory' AND a.intItemId = item.intItemId AND a.intAccountCategoryId = (SELECT intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Other Charge Expense'))