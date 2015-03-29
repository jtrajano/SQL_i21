
-- This function returns the weight per uom 
CREATE FUNCTION [dbo].[fnCalculateWeightUnitQty] (
	@dblQty AS NUMERIC(18,6)
	,@dblTotalWeight AS NUMERIC(18,6)
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	DECLARE @result AS NUMERIC(38,20)

	-- formula is Total Weight / Qty
	-- If qty is zero, return zero. 
	SET @result = CASE WHEN ISNULL(@dblQty, 0) = 0 THEN 0 ELSE ISNULL(@dblTotalWeight, 0) / @dblQty END 

	RETURN ISNULL(@result, 0);
END