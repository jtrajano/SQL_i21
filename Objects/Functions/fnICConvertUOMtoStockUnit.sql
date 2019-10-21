CREATE FUNCTION [dbo].[fnICConvertUOMtoStockUnit]
(
	@ItemId INT,
	@UOM INT,
	@Qty NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN	
	DECLARE @UOMQty NUMERIC(38, 20) = 0
			,@IsStockUnit BIT = 0

	SELECT	@UOMQty = dblUnitQty
			, @IsStockUnit = ysnStockUnit
	FROM	tblICItemUOM 
	WHERE	intItemId = @ItemId 
			AND intItemUOMId = @UOM

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
