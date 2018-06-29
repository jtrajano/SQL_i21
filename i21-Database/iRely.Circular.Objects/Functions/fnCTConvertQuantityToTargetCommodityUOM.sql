CREATE FUNCTION [dbo].[fnCTConvertQuantityToTargetCommodityUOM]
(
	@intCommodityUOMIdFrom INT,
	@intCommodityUOMIdTo INT,
	@dblQty NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(38,20),
			@dblUnitQtyFrom AS NUMERIC(38,20),
			@dblUnitQtyTo AS NUMERIC(38,20)


	SELECT	@dblUnitQtyFrom = CommodityUOM.dblUnitQty
	FROM	dbo.tblICCommodityUnitMeasure CommodityUOM 
	WHERE	CommodityUOM.intCommodityUnitMeasureId = @intCommodityUOMIdFrom

	SELECT	@dblUnitQtyTo = CommodityUOM.dblUnitQty
	FROM	dbo.tblICCommodityUnitMeasure CommodityUOM 
	WHERE	CommodityUOM.intCommodityUnitMeasureId = @intCommodityUOMIdTo

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
					CASE	WHEN @dblUnitQtyTo <> 0 THEN CAST((@dblQty * @dblUnitQtyFrom)AS NUMERIC(38,20)) / @dblUnitQtyTo							
							ELSE NULL 
					END
		END 

	RETURN @result;	
END
GO