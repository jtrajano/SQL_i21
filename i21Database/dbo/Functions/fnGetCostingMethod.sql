
-- This function will retrieve the costing method configured in an item (and per location).
CREATE FUNCTION [dbo].[fnGetCostingMethod](
	@intItemId INT
	,@intLocationId INT
)
RETURNS NVARCHAR(40)
AS 
BEGIN 
	DECLARE @strCostingMethod AS INT

	-- TODO: Change "strCostingMethod" to "intCostingMethod"
	-- See this comment. http://www.inet.irelyserver.com/display/INV/Location+Tab?focusedCommentId=38209014#comment-38209014
	SELECT	@strCostingMethod = strCostingMethod
	FROM	tblICItemLocationStore
	WHERE	intItemId = @intItemId
			AND intLocationId = @intLocationId

	RETURN @strCostingMethod;
END
GO