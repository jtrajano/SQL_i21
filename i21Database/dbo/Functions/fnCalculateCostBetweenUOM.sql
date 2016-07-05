/*
	This function convert the qty to the stock unit qty. 
	Remember, the unit conversions are taken from the Item UOM table and NOT from the Unit of Measure table. 

	Parameters: 
		@intItemUOMIdFrom
			- The Item UOM id where to start the conversion. 

		@intItemUOMIdTo
			- The target Item UOM. 

		@dblCost
			- The cost in @intItemUOMIdFrom. It will be converted to the cost of @intItemUOMIdTo
	
	Sample:
		Let's say @intItemUOMIdFrom is 25-kg-bag, @intItemUOMIdTo is Pound, and then @dblCost is $10 per bag. 
		Using this function will convert $10/25-kg-bag to Pound. The result is $0.1814368345804092/Lb. 
*/

CREATE FUNCTION [dbo].[fnCalculateCostBetweenUOM](
	@intItemUOMIdFrom INT
	,@intItemUOMIdTo INT 
	,@dblCost NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(38,20) 

	DECLARE @dblUnitQtyFrom AS NUMERIC(38,20)
			,@dblUnitQtyTo AS NUMERIC(38,20)

	-- Optimize the function. If From and To are equal, return the same cost. 
	IF @intItemUOMIdFrom = @intItemUOMIdTo
		RETURN @dblCost 

	SELECT	@dblUnitQtyFrom = ItemUOM.dblUnitQty
	FROM	dbo.tblICItemUOM ItemUOM 
	WHERE	ItemUOM.intItemUOMId = @intItemUOMIdFrom

	SELECT	@dblUnitQtyTo = ItemUOM.dblUnitQty
	FROM	dbo.tblICItemUOM ItemUOM 
	WHERE	ItemUOM.intItemUOMId = @intItemUOMIdTo

	-- Validate if unit qty's are non-zero
	SET @dblUnitQtyFrom = ISNULL(@dblUnitQtyFrom, 0)
	SET @dblUnitQtyTo = ISNULL(@dblUnitQtyTo, 0)

	IF @dblUnitQtyFrom = 0 OR @dblUnitQtyTo = 0 
	BEGIN 
		-- Return null if the unit qty's are invalid. 
		-- Do not continue with the calculation
		RETURN NULL; 
	END 

	-- Calculate the Unit Cost
	SET @result = 
		CASE	WHEN @dblUnitQtyFrom = @dblUnitQtyTo THEN 
					@dblCost
				ELSE 
					CASE	WHEN @dblUnitQtyFrom <> 0 THEN 
								dbo.fnDivide(dbo.fnMultiply(@dblCost, @dblUnitQtyTo), @dblUnitQtyFrom)
							ELSE 
								NULL 
					END
		END 

	RETURN @result;	
END
GO
