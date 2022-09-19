CREATE FUNCTION [dbo].[fnICConvertUOMtoStockUnit]
(
	@ItemId INT,
	@UOM INT,
	@Qty NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN	
	DECLARE @stockUOM INT 
	
	SELECT	TOP 1 
			@stockUOM = intItemUOMId
	FROM	tblICItemUOM 
	WHERE	intItemId = @ItemId 
			AND ysnStockUnit = 1

	RETURN dbo.fnCalculateQtyBetweenUOM(@UOM, @stockUOM, @Qty)
END
