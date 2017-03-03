/*
	This function convert the cost to the stock unit qty. 
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

	IF ISNULL(@dblCost, 0) = 0 
		RETURN @dblCost; 

	SELECT	@result = 
			CASE	WHEN ISNULL(ItemUOMFrom.dblUnitQty, 0) = 0 OR ISNULL(ItemUOMTo.dblUnitQty, 0) = 0 THEN 
						NULL 			
					WHEN ItemUOMFrom.dblUnitQty = ItemUOMTo.dblUnitQty THEN 
						@dblCost 					

					WHEN ItemUOMFrom.dblUnitQty = 1 THEN 
						dbo.fnMultiply(@dblCost, ItemUOMTo.dblUnitQty)

					WHEN ItemUOMTo.dblUnitQty = 1 THEN 
						dbo.fnDivide(@dblCost, ItemUOMFrom.dblUnitQty)

					ELSE 
						dbo.fnDivide(
							dbo.fnMultiply(@dblCost, ItemUOMFrom.dblUnitQty)
							,ItemUOMTo.dblUnitQty 
						)					
			END 
	FROM	(
				SELECT	ItemUOM.dblUnitQty 
				FROM	dbo.tblICItemUOM ItemUOM 
				WHERE	ItemUOM.intItemUOMId = @intItemUOMIdFrom
			) ItemUOMFrom
			, (
				SELECT	ItemUOM.dblUnitQty 
				FROM	dbo.tblICItemUOM ItemUOM 
				WHERE	ItemUOM.intItemUOMId = @intItemUOMIdTo
			) ItemUOMTo

	RETURN @result;	
END