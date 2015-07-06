CREATE FUNCTION [dbo].[fnCTConvertQuantityToTargetItemUOM]
(
	@intItemId INT,
	@IntFromUnitMeasureId INT,
	@intToUnitMeasureId INT,
	@dblQty NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(38,20),
			@intItemUOMIdFrom INT,
			@intItemUOMIdTo INT,
			@dblUnitQtyFrom AS NUMERIC(38,20),
			@dblUnitQtyTo AS NUMERIC(38,20)

	SELECT	@intItemUOMIdFrom = intItemUOMId
	FROM	tblICItemUOM  
	WHERE	intUnitMeasureId =  @IntFromUnitMeasureId AND intItemId = @intItemId
	
	SELECT	@intItemUOMIdTo = intItemUOMId
	FROM	tblICItemUOM  
	WHERE	intUnitMeasureId =  @intToUnitMeasureId AND intItemId = @intItemId

	SELECT	@dblUnitQtyFrom = ItemUOM.dblUnitQty
	FROM	dbo.tblICItemUOM ItemUOM 
	WHERE	ItemUOM.intItemUOMId = @intItemUOMIdFrom

	SELECT	@dblUnitQtyTo = ItemUOM.dblUnitQty
	FROM	dbo.tblICItemUOM ItemUOM 
	WHERE	ItemUOM.intItemUOMId = @intItemUOMIdTo

	SELECT	@dblUnitQtyFrom = ISNULL(@dblUnitQtyFrom, 0)
	SELECT	@dblUnitQtyTo = ISNULL(@dblUnitQtyTo, 0)
	SELECT	@dblQty = ISNULL(@dblQty, 0)

	IF @dblUnitQtyFrom = 0 OR @dblUnitQtyTo = 0 
	BEGIN 
		RETURN NULL; 
	END 

	SET @result = 
		CASE	WHEN @dblUnitQtyFrom = @dblUnitQtyTo THEN 
					@dblQty
				ELSE 
					CASE	WHEN @dblUnitQtyTo <> 0 THEN (@dblQty * @dblUnitQtyFrom) / @dblUnitQtyTo							
							ELSE NULL 
					END
		END 

	RETURN @result;	
END
GO