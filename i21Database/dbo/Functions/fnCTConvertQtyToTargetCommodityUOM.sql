CREATE FUNCTION [dbo].[fnCTConvertQtyToTargetCommodityUOM]
(
	@intCommodityId INT,
	@IntFromUnitMeasureId INT,
	@intToUnitMeasureId INT,
	@dblQty NUMERIC(26,12)
)
RETURNS NUMERIC(26,12)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(26,12),
			@intItemUOMIdFrom INT,
			@intItemUOMIdTo INT,
			@dblUnitQtyFrom AS NUMERIC(26,12),
			@dblUnitQtyTo AS NUMERIC(26,12)

	SELECT @dblUnitQtyFrom = ItemUOM.dblUnitQty
	FROM dbo.tblICCommodityUnitMeasure ItemUOM 
	WHERE intUnitMeasureId =  @IntFromUnitMeasureId AND intCommodityId = @intCommodityId

	SELECT @dblUnitQtyTo = ItemUOM.dblUnitQty
	FROM dbo.tblICCommodityUnitMeasure ItemUOM 
	WHERE intUnitMeasureId =  @intToUnitMeasureId AND intCommodityId = @intCommodityId

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
					CASE	WHEN @dblUnitQtyTo <> 0 THEN CAST((@dblQty * @dblUnitQtyFrom) AS  NUMERIC(26,12)) / CAST(@dblUnitQtyTo AS NUMERIC(26,12))							
							ELSE NULL 
					END
		END 

	RETURN @result;	
END