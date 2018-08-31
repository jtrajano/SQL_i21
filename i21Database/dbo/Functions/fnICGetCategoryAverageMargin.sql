CREATE FUNCTION [dbo].[fnICGetCategoryAverageMargin](
	@intCategoryId AS INT,
	@intItemLocationId AS INT
)
RETURNS NUMERIC(32,20)
AS
BEGIN

	DECLARE @dblAverageMargin NUMERIC(38,20);
	DECLARE @intLocationId INT;

	-- GET THE LOCATION 
	SELECT @intLocationId = intLocationId FROM tblICItemLocation
	WHERE intItemLocationId = @intItemLocationId;


	SELECT	@dblAverageMargin = dbo.fnDivide(SUM(ISNULL(dblTotalRetailValue, 0)) - SUM(ISNULL(dblTotalCostValue,0)), SUM(ISNULL(dblTotalRetailValue, 0)))
		FROM	tblICCategoryPricing CategoryPricing 
		INNER JOIN tblICItemLocation ItemLocation
			ON ItemLocation.intItemLocationId = CategoryPricing.intItemLocationId
		WHERE	CategoryPricing.intCategoryId = @intCategoryId
				AND ItemLocation.intLocationId = @intLocationId

	RETURN @dblAverageMargin

END