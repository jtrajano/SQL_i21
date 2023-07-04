CREATE FUNCTION [dbo].[fnCTConvertPriceToTargetItemUOM]
(
	@intFromItemUOMId	INT,
	@intToItemUOMId	INT,
	@dblPrice				NUMERIC(26,12),
	@ysnPrice bit = null
)
RETURNS NUMERIC(26,12)
AS 
BEGIN 
	declare
		@dblFromUnitQuantity numeric(18,6),
		@dblToUnitQuantity numeric(18,6),
		@dblRet numeric(18,6);

	select @dblFromUnitQuantity = dblUnitQty from tblICItemUOM where intItemUOMId = @intFromItemUOMId;
	select @dblToUnitQuantity = dblUnitQty from tblICItemUOM where intItemUOMId = @intToItemUOMId;

	if (@ysnPrice = 1)
	begin
		select @dblRet = (@dblPrice/@dblFromUnitQuantity) * @dblToUnitQuantity;
	end
	else
	begin
		select @dblRet = (@dblFromUnitQuantity / @dblToUnitQuantity) * @dblPrice;
	end

	RETURN @dblRet
END
GO