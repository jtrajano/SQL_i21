CREATE FUNCTION [dbo].[fnMFCalculateRecipeSubItemLowerTolerance]
(
	@dblRecipeItemCalculatedQty numeric(18,6),
	@dblLowerTolerance numeric(18,6)
)
RETURNS numeric(18,6)
AS
BEGIN
	return (@dblRecipeItemCalculatedQty - ((@dblLowerTolerance / 100) * @dblRecipeItemCalculatedQty));
END
