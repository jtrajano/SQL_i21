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

CREATE FUNCTION [dbo].[fnCalculateCostFromNetWgt](
	@dblLineTotal NUMERIC(38,20)
	,@dblReceiveQty NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE @result AS NUMERIC(38,20) 
	
	SET @result = dbo.fnDivide(@dblLineTotal, @dblReceiveQty) 
	
	RETURN @result;	
END
GO
