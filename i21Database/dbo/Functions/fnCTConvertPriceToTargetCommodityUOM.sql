
CREATE FUNCTION [dbo].[fnCTConvertPriceToTargetCommodityUOM]
(
	@intFromCommodityUOMId	INT,
	@intToCommodityUOMId	INT,
	@dblPrice				NUMERIC(26,12)
)
RETURNS NUMERIC(26,12)
AS 
BEGIN 
	declare
		@dblFromUnitQuantity numeric(18,6),
		@dblToUnitQuantity numeric(18,6),
		@dblRet numeric(18,6);

	select @dblFromUnitQuantity = dblUnitQty from tblICCommodityUnitMeasure where intCommodityUnitMeasureId = @intFromCommodityUOMId;
	select @dblToUnitQuantity = dblUnitQty from tblICCommodityUnitMeasure where intCommodityUnitMeasureId = @intToCommodityUOMId;

	select @dblRet = (@dblPrice/@dblFromUnitQuantity) * @dblToUnitQuantity

	RETURN @dblRet
END
GO