CREATE FUNCTION [dbo].[fnCTConvertQtyToTargetItemUOM]
(
	@IntFromItemUOMId	INT,
	@intToItemUOMId		INT,
	@dblQty				NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE	@result					NUMERIC(38,20),
			@intItemId				INT,
			@IntFromUnitMeasureId	INT,
			@intToUnitMeasureId		INT,
			@dblUnitQtyTo			NUMERIC(38,20)

	SELECT	@intItemId = intItemId,@IntFromUnitMeasureId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @IntFromItemUOMId
	SELECT	@intToUnitMeasureId = intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = @intToItemUOMId
	
	SELECT @result = dbo.fnCTConvertQuantityToTargetItemUOM(@intItemId,@IntFromUnitMeasureId,@intToUnitMeasureId,@dblQty)
	
	RETURN @result;	
END
GO