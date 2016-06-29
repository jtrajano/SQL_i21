CREATE FUNCTION [dbo].[fnMFConvertCostToTargetItemUOM]
(
	@intFromItemUOMId	INT,
	@intToItemUOMId		INT,
	@dblCost		NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN
	Declare @dblUnitQtyFrom NUMERIC(38,20)
	Declare @dblUnitQtyTo NUMERIC(38,20)

	Select @dblUnitQtyFrom=ISNULL(dblUnitQty,1) From tblICItemUOM Where intItemUOMId=@intFromItemUOMId
	Select @dblUnitQtyTo=ISNULL(dblUnitQty,1) From tblICItemUOM Where intItemUOMId=@intToItemUOMId

	return @dblCost / (@dblUnitQtyFrom/@dblUnitQtyTo)
END
