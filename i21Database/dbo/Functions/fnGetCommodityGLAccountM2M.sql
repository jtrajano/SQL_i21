CREATE FUNCTION [dbo].[fnGetCommodityGLAccountM2M] (
	@intItemId INT = NULL
	,@intCommodityId INT = NULL
	,@strAccountDescription NVARCHAR(255)
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intGLAccountId AS INT

	SELECT @intCommodityId = i.intCommodityId
	FROM 
		tblICItem i
	WHERE
		i.intItemId = @intItemId
		AND @intItemId IS NOT NULL 
		AND (i.intCommodityId = @intCommodityId OR @intCommodityId IS NULL) 
	
	SELECT 
		@intGLAccountId = c.intAccountId
	FROM
		tblICCommodityAccountM2M c INNER JOIN tblGLAccountCategory cat
			ON c.intAccountCategoryId = cat.intAccountCategoryId
	WHERE
		c.intCommodityId = @intCommodityId
		AND @intCommodityId IS NOT NULL 
		AND cat.strAccountCategory = @strAccountDescription

	RETURN @intGLAccountId
END 