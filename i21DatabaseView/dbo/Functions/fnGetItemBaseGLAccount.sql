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
	--2. If account id is not found in item-account and item type is 'commodity', then try the commodity gl-setup. 
	--3. If account id is not found in commodity-account, then try the item category. 
	--3. If account id is not found in item category, try the company location. 

	SELECT	@intGLAccountId = ISNULL(ItemLevel.intAccountId, ISNULL(CommodityLevel.intAccountId, ISNULL(CategoryLevel.intAccountId, CompanyLocationLevel.intAccountId)))
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
				-- Get the base account at the Commodity level. 
				SELECT	TOP 1 
						CommodityAccounts.intAccountId
				FROM	dbo.tblICItem Item INNER JOIN dbo.tblICCommodity Commodity
							ON Item.intCommodityId = Commodity.intCommodityId
						INNER JOIN dbo.tblICCommodityAccount CommodityAccounts
							ON Commodity.intCommodityId = CommodityAccounts.intCommodityId
						INNER JOIN dbo.tblGLAccountCategory AccntCategory
							ON CommodityAccounts.intAccountCategoryId = AccntCategory.intAccountCategoryId
				WHERE	Item.intItemId = @intItemId
						AND AccntCategory.strAccountCategory = @strAccountCategory
						-- AND Item.strType = 'Commodity'
			) AS CommodityLevel
				ON 1 = 1
			FULL JOIN (
				-- Get the base account at the Category level. 
				SELECT	TOP 1 
						CategoryAccounts.intAccountId
				FROM	dbo.tblICItem Item INNER JOIN dbo.tblICCategory Category
							ON Item.intCategoryId = Category.intCategoryId
						INNER JOIN tblICCategoryAccount CategoryAccounts
							ON Category.intCategoryId = CategoryAccounts.intCategoryId
						INNER JOIN dbo.tblGLAccountCategory AccntCategory
							ON CategoryAccounts.intAccountCategoryId = AccntCategory.intAccountCategoryId
				WHERE	Item.intItemId = @intItemId
						AND AccntCategory.strAccountCategory = @strAccountCategory 		
						AND Item.strType <> 'Commodity'
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