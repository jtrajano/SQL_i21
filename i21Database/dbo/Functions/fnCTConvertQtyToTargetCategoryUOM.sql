CREATE FUNCTION [dbo].[fnCTConvertQtyToTargetCategoryUOM]
(
	@intCategoryUOMIdFrom INT,
	@intCategoryUOMIdTo INT,
	@dblQty NUMERIC(18,6)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(38,20),
			@dblUnitQtyFrom AS NUMERIC(18,6),
			@dblUnitQtyTo AS NUMERIC(18,6)


	SELECT	@dblUnitQtyFrom = CategoryUOM.dblUnitQty
	FROM	dbo.tblICCategoryUOM CategoryUOM 
	WHERE	CategoryUOM.intCategoryUOMId = @intCategoryUOMIdFrom

	SELECT	@dblUnitQtyTo = CategoryUOM.dblUnitQty
	FROM	dbo.tblICCategoryUOM CategoryUOM 
	WHERE	CategoryUOM.intCategoryUOMId = @intCategoryUOMIdTo

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
					CASE	WHEN @dblUnitQtyTo <> 0 THEN CAST((@dblQty * @dblUnitQtyFrom)AS NUMERIC(18,6)) / @dblUnitQtyTo							
							ELSE NULL 
					END
		END 

	RETURN @result;	
END