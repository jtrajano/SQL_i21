--liquibase formatted sql

-- changeset Von:fnARGetItemGLAccount.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARGetItemGLAccount]
(
	  @intItemId 			INT
	, @intItemLocationId	INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	--Hierarchy:
	--If the item on the invoice has a Sales GL account attributed to it, that is the GL account that should be passed to the ledger.
        --Inventory --> Item --> GL Acct tab
    --If the item on the invoice has a General GL account attributed to it, that is the GL account that should be passed to the ledger.
         --Inventory --> Item --> GL Acct tab
    --If the item on the invoice does not have a Sales or General GL account attributed to it, but it is in a category with a Sales GL account attributed to it, that GL account should be passed to the ledger.
         --Inventory --> Catagory --> GL Acct tab
    --If the item on the invoice does not have a Sales or General GL account attributed to it, but it is in a category with a General GL account attributed to it, that GL account should be passed to the ledger.
        --Inventory --> Catagory --> GL Acct tab
	--Company Location Sales Account


			SELECT @intGLAccountId = ISNULL(ItemSaleAccount.intAccountId,
									 ISNULL(ItemGeneralAccount.intAccountId,
										ISNULL(CategorySaleAccount.intAccountId,
											ISNULL(CategoryGeneralAccount.intAccountId, 
												ISNULL(CompanyLocationSalesAccount.intAccountId, NULL)
											)
										)
									)
								 ) 
			FROM (
				SELECT strDescription = 'Non-Inventory and Inventory Sale Accounts'
			) N
			OUTER APPLY (
				SELECT intAccountId = ItemAccount.intAccountId
				FROM dbo.tblICItemAccount ItemAccount 
				INNER JOIN dbo.tblGLAccountCategory AccntCategory ON ItemAccount.intAccountCategoryId = AccntCategory.intAccountCategoryId
				WHERE ItemAccount.intItemId = @intItemId AND (strAccountCategory = 'Sales Account')
			) ItemSaleAccount
			OUTER APPLY (
				SELECT intAccountId = ItemAccount.intAccountId
				FROM dbo.tblICItemAccount ItemAccount 
				INNER JOIN dbo.tblGLAccountCategory AccntCategory ON ItemAccount.intAccountCategoryId = AccntCategory.intAccountCategoryId
				WHERE ItemAccount.intItemId = @intItemId AND (strAccountCategory = 'General')
			) ItemGeneralAccount
			OUTER APPLY (
				SELECT TOP 1 intAccountId = CategoryAccounts.intAccountId
				FROM dbo.tblICItem Item 
				INNER JOIN dbo.tblICCategory Category ON Item.intCategoryId = Category.intCategoryId
				INNER JOIN tblICCategoryAccount CategoryAccounts ON Category.intCategoryId = CategoryAccounts.intCategoryId
				INNER JOIN dbo.tblGLAccountCategory AccntCategory ON CategoryAccounts.intAccountCategoryId = AccntCategory.intAccountCategoryId
				WHERE Item.intItemId = @intItemId
				  AND AccntCategory.strAccountCategory = 'Sales Account' 		
				  AND Item.strType <> 'Commodity'
			) CategorySaleAccount
			OUTER APPLY (
				SELECT TOP 1 intAccountId = CategoryAccounts.intAccountId
				FROM dbo.tblICItem Item 
				INNER JOIN dbo.tblICCategory Category ON Item.intCategoryId = Category.intCategoryId
				INNER JOIN tblICCategoryAccount CategoryAccounts ON Category.intCategoryId = CategoryAccounts.intCategoryId
				INNER JOIN dbo.tblGLAccountCategory AccntCategory ON CategoryAccounts.intAccountCategoryId = AccntCategory.intAccountCategoryId
				WHERE Item.intItemId = @intItemId
				  AND AccntCategory.strAccountCategory = 'General' 		
				  AND Item.strType <> 'Commodity'
			) CategoryGeneralAccount
			OUTER APPLY (
				SELECT TOP 1 intAccountId = dbo.fnGetGLAccountFromCompanyLocation (IL.intLocationId, 'Sales Account')
                FROM tblICItemLocation IL
                WHERE IL.intItemLocationId = @intItemLocationId
				  AND IL.intItemId = @intItemId
			) CompanyLocationSalesAccount
	
	RETURN @intGLAccountId
END



