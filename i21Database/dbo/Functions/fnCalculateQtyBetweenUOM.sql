/*
	This function convert the qty to the stock unit qty. 
	Remember, the unit conversions are taken from the Item UOM table and NOT from the Unit of Measure table. 

	Parameters: 
		@intItemUOMIdFrom
			- The Item UOM id where to start the conversion. 

		@intItemUOMIdTo
			- The target Item UOM. 

		@dblQty
			- The quantity of the @intItemUOMIdFrom. 
	
	Sample:
		Let's say @intItemUOMIdFrom is 25 kg bags, @intItemUOMIdTo is Pound, and then @dblQty is 10. 
		Using this function will convert 10 bags, in 25 kg bag, to Pounds. 
*/

CREATE FUNCTION [dbo].[fnCalculateQtyBetweenUOM](
	@intItemUOMIdFrom INT
	,@intItemUOMIdTo INT 
	,@dblQty NUMERIC(18,6)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(38,20)

	DECLARE @dblUnitQtyFrom AS NUMERIC(38,20)
			,@dblUnitQtyTo AS NUMERIC(38,20)

	SELECT	@dblUnitQtyFrom = ItemUOM.dblUnitQty
	FROM	dbo.tblICItemUOM ItemUOM 
	WHERE	ItemUOM.intItemUOMId = @intItemUOMIdFrom

	SELECT	@dblUnitQtyTo = ItemUOM.dblUnitQty
	FROM	dbo.tblICItemUOM ItemUOM 
	WHERE	ItemUOM.intItemUOMId = @intItemUOMIdTo

	-- Validate if unit qty's are non-zero
	SET @dblUnitQtyFrom = ISNULL(@dblUnitQtyFrom, 0)
	SET @dblUnitQtyTo = ISNULL(@dblUnitQtyTo, 0)
	SET @dblQty = ISNULL(@dblQty, 0)

	IF @dblUnitQtyFrom = 0 OR @dblUnitQtyTo = 0 
	BEGIN 
		-- Return null if the unit qty's are invalid. 
		-- Do not continue with the calculation
		RETURN NULL; 
	END 

	-- Calculate the Unit Qty
	SET @result = 
			CASE	WHEN @dblUnitQtyFrom = @dblUnitQtyTo THEN 
						@dblQty

					WHEN @dblUnitQtyFrom = 1 THEN 
						CASE	WHEN FLOOR(@dblUnitQtyTo) = 0 AND @dblUnitQtyTo > 0.1 THEN 
									@dblQty * @dblUnitQtyTo
								ELSE 
									@dblQty / @dblUnitQtyTo
						END

					WHEN @dblUnitQtyTo = 1 THEN 
						CASE	WHEN FLOOR(@dblUnitQtyFrom) = 0 AND @dblUnitQtyFrom > 0.1 THEN 
									@dblQty / @dblUnitQtyFrom
								ELSE
									@dblQty * @dblUnitQtyFrom
						END

					WHEN @dblUnitQtyFrom <> 1 AND @dblUnitQtyTo <> 1 THEN
						CASE	WHEN FLOOR(@dblUnitQtyFrom) > 0  AND FLOOR(@dblUnitQtyTo) = 0 THEN 
									@dblQty * @dblUnitQtyFrom * @dblUnitQtyTo
								ELSE 
									@dblQty * @dblUnitQtyFrom / @dblUnitQtyTo
						END 						
					ELSE @dblQty
			END 

	RETURN @result;	
END
GO
