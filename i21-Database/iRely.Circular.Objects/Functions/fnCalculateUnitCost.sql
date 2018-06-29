-- This function returns the unit cost. 
CREATE FUNCTION [dbo].[fnCalculateUnitCost] (
	@dblCost AS NUMERIC(38,20)
	,@dblUnitQty AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	DECLARE @result AS NUMERIC(38,20)

	-- formula is cost  / unit qty
	-- If unit qty is zero, return cost. 
	SET @result =	CASE	WHEN ISNULL(@dblUnitQty, 0) = 0 THEN 
								@dblCost
							ELSE	
								dbo.fnDivide(@dblCost, @dblUnitQty) 
					END 

	RETURN ISNULL(@result, 0);
END