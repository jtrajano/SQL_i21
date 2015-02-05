CREATE FUNCTION [dbo].[fnGetItemBaseGLAccount]
(
	@intItemId INT 
	,@intItemLocationId INT
	,@strAccountCategory NVARCHAR(255)
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	--Hierarchy:
	--1. Item Account is checked first. 
	--2. If account id is not found in item-account, try the category 
	--3. If account id is not found in category, try the company location. 

	SELECT	@intGLAccountId = ISNULL(ItemLevel.intAccountId, ISNULL(CategoryLevel.intAccountId, CompanyLocationLevel.intAccountId))
	FROM	(
				-- Get the base acccount at the item-level
				SELECT	TOP 1 
						intAccountId
				FROM	dbo.tblICItemAccount ItemAccount 
						INNER JOIN dbo.tblGLAccountCategory AccntCategory
							ON ItemAccount.intAccountCategoryId = AccntCategory.intAccountCategoryId
				WHERE	ItemAccount.intItemId = @intItemId
						AND AccntCategory.strAccountCategory = @strAccountCategory 
			) AS ItemLevel
			FULL JOIN (
				-- Get the base account at the Item-Location level and then at the Category. 
				SELECT	TOP 1 
						CategoryAccounts.intAccountId
				FROM	dbo.tblICItemLocation ItemLocation INNER JOIN dbo.tblICCategory Category
							ON ItemLocation.intCategoryId = Category.intCategoryId
						INNER JOIN tblICCategoryAccount CategoryAccounts
							ON Category.intCategoryId = CategoryAccounts.intCategoryId
						INNER JOIN dbo.tblGLAccountCategory AccntCategory
							ON CategoryAccounts.intAccountCategoryId = AccntCategory.intAccountCategoryId
				WHERE	ItemLocation.intItemId = @intItemId
						AND ItemLocation.intItemLocationId = @intItemLocationId
						AND AccntCategory.strAccountCategory = @strAccountCategory 			
			) AS CategoryLevel
				ON 1 = 1
			FULL JOIN (
				-- Get the base account at the Company Location level
                SELECT	intAccountId = dbo.fnGetGLAccountFromCompanyLocation (tblICItemLocation.intLocationId, @strAccountCategory)
                FROM	tblICItemLocation 
                WHERE	tblICItemLocation.intItemLocationId = @intItemLocationId
						AND tblICItemLocation.intItemId = @intItemId

			) AS CompanyLocationLevel
				ON 1 = 1
	
	RETURN @intGLAccountId
END
GO