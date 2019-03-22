CREATE FUNCTION [dbo].[fnMFCalculateRecipeSubItemUpperTolerance]
(
	@dblRecipeItemCalculatedQty numeric(18,6),
	@dblUpperTolerance numeric(18,6)
)
RETURNS numeric(18,6)
AS
BEGIN
	return (@dblRecipeItemCalculatedQty + ((@dblUpperTolerance / 100) * @dblRecipeItemCalculatedQty));
END
