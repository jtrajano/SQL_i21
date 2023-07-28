--liquibase formatted sql

-- changeset Von:vyuICCategoryAccount.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICCategoryAccount]
AS 

SELECT 
	Category.intCategoryId, 
	Category.strCategoryCode, 
	AccountCategory.strAccountCategory,
	AccountCategory.intAccountCategoryId,
	Account.*
FROM tblICCategory Category
INNER JOIN tblICCategoryAccount CategoryAccount
ON Category.intCategoryId = CategoryAccount.intCategoryId
INNER JOIN tblGLAccount Account
ON CategoryAccount.intAccountId = Account.intAccountId
INNER JOIN tblGLAccountCategory AccountCategory
ON CategoryAccount.intAccountCategoryId = AccountCategory.intAccountCategoryId



