CREATE FUNCTION [dbo].[fnMFCalculateRecipeSubItemQuantity]
(
	@dblRecipeItemCalculatedQty numeric(18,6),
	@dblSubstituteRatio numeric(18,6),
	@dblMaxSubstituteRatio numeric(18,6)
)
RETURNS numeric(18,6)
AS
BEGIN

	return @dblRecipeItemCalculatedQty * (@dblMaxSubstituteRatio/100) * @dblSubstituteRatio

END
