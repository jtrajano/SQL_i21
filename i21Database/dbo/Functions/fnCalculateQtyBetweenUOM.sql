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
	,@dblQty NUMERIC(38, 20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(38,20)

	IF @dblQty = 0 
		RETURN @dblQty; 

	SELECT	@result = 
			CASE	WHEN ISNULL(ItemUOMFrom.dblUnitQty, 0) = 0 OR ISNULL(ItemUOMTo.dblUnitQty, 0) = 0 THEN 
						NULL 			
					WHEN ItemUOMFrom.dblUnitQty = ItemUOMTo.dblUnitQty THEN 
						@dblQty 					
					ELSE 
						dbo.fnDivide(
							dbo.fnMultiply(@dblQty, ItemUOMFrom.dblUnitQty)
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