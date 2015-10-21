CREATE FUNCTION [dbo].[fnICConvertUOMtoStockUnit]
(
	@ItemId int,
	@UOM int,
	@Qty NUMERIC(18,6)
)
RETURNS INT
AS
BEGIN
	
	DECLARE @UOMQty NUMERIC(18, 6) = 0,
		@IsStockUnit BIT = 0

	SELECT @UOMQty = dblUnitQty, @IsStockUnit = ysnStockUnit
	FROM tblICItemUOM WHERE intItemId = @ItemId AND intItemUOMId = @UOM


	IF (@IsStockUnit = 1)
	BEGIN
		RETURN @Qty;
	END
	ELSE
	BEGIN
		RETURN @Qty * @UOMQty;
	END

	RETURN 0;

END
