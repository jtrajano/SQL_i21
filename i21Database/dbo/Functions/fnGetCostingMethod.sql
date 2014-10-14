
-- This function will retrieve the costing method configured in an item (and per location).
CREATE FUNCTION [dbo].[fnGetCostingMethod](
	@intItemId INT
	,@intLocationId INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE @costingMethod AS INT

	-- Get the costing method in the item-location table. 
	SELECT	@costingMethod = intCostingMethod
	FROM	tblICItemLocationStore
	WHERE	intItemId = @intItemId
			AND intLocationId = @intLocationId

	-- If costing method is not found at item-Location level, get the costing method in the category level. 
	IF @costingMethod IS NULL
	BEGIN 
		SELECT	@costingMethod = intCostingMethod
		FROM	tblICCategory
		WHERE	intCategoryId = (SELECT TOP 1 intTrackingId FROM tblICItem WHERE intItemId = @intItemId)
	END

	RETURN @costingMethod;	
END
GO