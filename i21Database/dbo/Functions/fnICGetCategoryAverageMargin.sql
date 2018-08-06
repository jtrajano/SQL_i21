CREATE FUNCTION [dbo].[fnICGetCategoryAverageMargin](
	@intCategoryId AS INT,
	@intItemLocationId AS INT
)
RETURNS NUMERIC(32,20)
AS
BEGIN

	DECLARE @dblAverageMargin AS NUMERIC(38,20);

	SELECT	@dblAverageMargin = ISNULL(dblAverageMargin, 0)
		FROM	tblICCategoryPricing CategoryPricing 
		WHERE	CategoryPricing.intCategoryId = @intCategoryId
				AND CategoryPricing.intItemLocationId = @intItemLocationId


	RETURN @dblAverageMargin

END