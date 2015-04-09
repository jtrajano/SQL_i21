
-- This function returns the weight per uom 
CREATE FUNCTION [dbo].[fnCalculateWeightUnitQty] (
	@dblQty AS NUMERIC(18,6)
	,@dblTotalWeight AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	-- formula is Total Weight / Qty
	-- If qty is zero, return zero. 
	RETURN CASE		WHEN ISNULL(@dblQty, 0) = 0 THEN 
						0 
					ELSE CAST(ISNULL(@dblTotalWeight, 0) AS FLOAT) / CAST(@dblQty AS FLOAT)
			END 
END