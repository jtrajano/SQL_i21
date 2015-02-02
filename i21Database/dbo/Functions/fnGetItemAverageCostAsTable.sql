CREATE FUNCTION [dbo].[fnGetItemAverageCostAsTable]
(
	@intItemId INT
	,@intItemLocationId INT
)
RETURNS TABLE 
RETURN (
	-- Get the average cost of item per location
	SELECT	TOP 1 
			AverageCost = ISNULL(dblAverageCost, 0)
	FROM	dbo.tblICItemStock
	WHERE	intItemId = @intItemId
			AND intItemLocationId = @intItemLocationId
)
