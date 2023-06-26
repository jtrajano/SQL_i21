CREATE FUNCTION [dbo].[fnCTConvertPriceToTargetItemUOM]
(
	@intFromItemUOMId	INT,
	@intToItemUOMId	INT,
	@dblPrice				NUMERIC(26,12)
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

	select @dblRet = (@dblPrice/@dblFromUnitQuantity) * @dblToUnitQuantity

	RETURN @dblRet
END
GO