/*
	This function convert the qty to the stock unit qty. 

	Formula used:

	If dblUnitQtyFrom is one (1), then divide dblQty by dblUnitQtyTo
		Sample 1. From LB (1) to KG (0.453592)
		Sample 2. From LB (1) to 50-LB-Bag (50)
		Formula is: dblQty / dblUnitQtyTo	
	
	If dblUnitQtyTo is one (1), then multiply dblQty with dblUnitQtyFrom 
		Sample 1. From KG (0.453592) to LB (1) 
		Sample 2. From 50-LB-Bag (50) to LB (1)
		Formula is: dblQty * dblUnitQtyFrom 

	If dblUnitQtyFrom is not one (1) and dblUnitQtyTo is not one (1), then multiply dblQty with dblUnitQtyFrom first and then:
		If FLOOR(dblUnitQtyTo) = 0 then multiply with dblUnitQtyTo
		ELSE divide by dblUnitQtyTo

		Sample 1. From 50-LB-Bag (50) to KG (0.453592). Qty is 10. 	FLOOR of 0.453592 is 0.
		Using this formula: dblQty x dblUnitQtyFrom x dblUnitQtyTo
		10 x 50 = 500 lb
		500 lb x 0.453592 = 226.796 kg

		Sample 2: From 50-LB bag (50) to 20-KG bag (44.0925). Qty is 10. FLOOR of 44.0925 is 44.
		Using this formula: dblQty x dblUnitQtyFrom / dblUnitQtyTo
		10 x 50 = 500 lb
		500 lb / 44.0925 = 11.339797 20-kg bag
*/

CREATE FUNCTION [dbo].[fnCalculateQtyBetweenUOM](
	@intItemUOMIdFrom INT
	,@intItemUOMIdTo INT 
	,@dblQty NUMERIC(18,6)
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(18,6)

	DECLARE @dblUnitQtyFrom AS NUMERIC(18,6)
			,@dblUnitQtyTo AS NUMERIC(18,6)

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
			CASE	WHEN @dblUnitQtyFrom = 1 THEN 
						CASE	WHEN FLOOR(@dblUnitQtyTo) = 0 THEN 
									@dblQty * @dblUnitQtyTo
								ELSE 
									@dblQty / @dblUnitQtyTo
						END
					WHEN @dblUnitQtyTo = 1 THEN 
						CASE	WHEN FLOOR(@dblUnitQtyFrom) = 0 THEN 
									@dblQty / @dblUnitQtyFrom
								ELSE 
									@dblQty * @dblUnitQtyFrom			
						END

					WHEN @dblUnitQtyFrom <> 1 AND @dblUnitQtyTo <> 1 THEN
						CASE	WHEN FLOOR(@dblUnitQtyTo) = 0 THEN 
									@dblQty * @dblUnitQtyFrom * @dblUnitQtyTo
								ELSE 
									@dblQty * @dblUnitQtyFrom / @dblUnitQtyTo
						END 						
					ELSE @dblQty
			END 

	RETURN @result;	
END
GO
