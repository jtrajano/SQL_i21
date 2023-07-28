--liquibase formatted sql

-- changeset Von:fnCTConvertQuantityToTargetItemUOM.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTConvertQuantityToTargetItemUOM]
(
	@intItemId INT,
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
		,@intItemUOMIdFrom = ItemUOM.intItemUOMId
	FROM dbo.tblICItemUOM ItemUOM 
	WHERE intUnitMeasureId =  @IntFromUnitMeasureId AND intItemId = @intItemId

	SELECT @dblUnitQtyTo = ItemUOM.dblUnitQty
		,@intItemUOMIdTo = ItemUOM.intItemUOMId
	FROM dbo.tblICItemUOM ItemUOM 
	WHERE intUnitMeasureId =  @intToUnitMeasureId AND intItemId = @intItemId

	-- SELECT	@dblUnitQtyFrom = ISNULL(@dblUnitQtyFrom, 0)
	-- SELECT	@dblUnitQtyTo = ISNULL(@dblUnitQtyTo, 0)
	-- SELECT	@dblQty = ISNULL(@dblQty, 0)

	-- IF @dblUnitQtyFrom = 0 OR @dblUnitQtyTo = 0 
	-- BEGIN 
	-- 	RETURN NULL; 
	-- END 

	-- SET @result = 
	-- 	CASE	WHEN @dblUnitQtyFrom = @dblUnitQtyTo THEN 
	-- 				@dblQty
	-- 			ELSE 
	-- 				CASE	WHEN @dblUnitQtyTo <> 0 THEN 
	-- 							CASE	WHEN	@dblQty = 1 
	-- 									THEN	@dblUnitQtyFrom  / @dblUnitQtyTo 
	-- 									ELSE	CAST(@dblQty * (@dblUnitQtyFrom  / @dblUnitQtyTo) AS NUMERIC(26, 12))		
	-- 							END					
	-- 						ELSE NULL 
	-- 				END
	-- 	END 
	SET @result = dbo.fnCalculateQtyBetweenUOM(@intItemUOMIdFrom,@intItemUOMIdTo,@dblQty)
	RETURN @result;	
END



