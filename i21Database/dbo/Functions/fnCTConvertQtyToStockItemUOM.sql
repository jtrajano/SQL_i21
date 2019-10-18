CREATE FUNCTION [dbo].[fnCTConvertQtyToStockItemUOM]
(
	@intFromItemUOMId	INT,
	@dblQty				NUMERIC(26,12)
)
RETURNS NUMERIC(26,12)
AS 
BEGIN 
	DECLARE	@result					NUMERIC(26,12),
			@intItemId				INT,
			@IntFromUnitMeasureId	INT,
			@dblUnitQtyTo			NUMERIC(26,12)

	SELECT	@intItemId = intItemId, @IntFromUnitMeasureId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @intFromItemUOMId

	DECLARE @dblUnitQtyFrom AS NUMERIC(26,12)

	SELECT @dblUnitQtyFrom = ItemUOM.dblUnitQty
	FROM dbo.tblICItemUOM ItemUOM 
	WHERE intUnitMeasureId =  @IntFromUnitMeasureId AND intItemId = @intItemId

	SET @result = CAST((@dblQty * @dblUnitQtyFrom) AS NUMERIC(26,3))

	RETURN @result
END
GO