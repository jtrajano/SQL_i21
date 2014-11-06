CREATE FUNCTION [dbo].[fnGetItemAverageCost]
(
	@intItemId INT
	,@intItemLocationId INT
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE @AverageCost AS NUMERIC(18,6)

	-- Get the average cost of item per location
	SELECT	@AverageCost = dblAverageCost
	FROM	[dbo].[tblICItemStock]
	WHERE	intItemId = @intItemId
			AND intLocationId = @intItemLocationId

	RETURN ISNULL(@AverageCost, 0)
END
GO