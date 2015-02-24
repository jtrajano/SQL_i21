
-- This function returns the unit cost. 
CREATE FUNCTION [dbo].[fnCalculateUnitCost] (
	@dblCost AS NUMERIC(18,6)
	,@dblUnitQty AS NUMERIC(18,6)
)
RETURNS NUMERIC(18,6)
AS
BEGIN 
	DECLARE @result AS NUMERIC(18,6)

	-- formula is cost  / unit qty
	-- If unit qty is zero, return cost. 
	SET @result = CASE WHEN ISNULL(@dblUnitQty, 0) = 0 THEN @dblCost ELSE ISNULL(@dblCost, 0) / @dblUnitQty END 

	RETURN ISNULL(@result, 0);
END