-- This function returns the weight per uom 
CREATE FUNCTION [dbo].[fnCalculateWeightUnitQty] (
	@dblQty AS NUMERIC(18,6)
	,@dblTotalWeight AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	-- The formula is Total Weight / Qty
	-- If Qty is zero or null, return zero. 
	RETURN CASE		WHEN ISNULL(@dblQty, 0) = 0 THEN 
						0 
					ELSE
						ISNULL(@dblTotalWeight, 0.00) / @dblQty
			END 
END