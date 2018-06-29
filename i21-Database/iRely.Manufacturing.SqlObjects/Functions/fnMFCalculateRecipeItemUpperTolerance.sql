CREATE FUNCTION [dbo].[fnMFCalculateRecipeItemUpperTolerance]
(
	@intRecipeTypeId int,
	@dblQuantity numeric(18,6),
	@dblShrinkage numeric(18,6),
	@dblUpperTolerance numeric(18,6)
)
RETURNS numeric(18,6)
AS
BEGIN
	Declare @dblCalculatedQty numeric(18,6)

    if (@intRecipeTypeId=1) --By Quantity
       Set @dblCalculatedQty= @dblQuantity + ((@dblShrinkage / 100) * @dblQuantity)
    else --By Percentage
        Set @dblCalculatedQty= (@dblQuantity/100) + ((@dblShrinkage / 100) * @dblQuantity)

	return (@dblCalculatedQty + ((@dblUpperTolerance / 100) * @dblCalculatedQty));
END
