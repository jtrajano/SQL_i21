-- This function returns the weight per uom 
CREATE FUNCTION [dbo].[fnCalculateWeightUnitQty] (
	@dblQty AS NUMERIC(38,20)
	,@dblTotalWeight AS NUMERIC(38,20)
)
RETURNS NUMERIC(38, 20) 
AS
BEGIN 
	DECLARE @result AS NUMERIC(38, 20)
			,@calculatedValue AS NUMERIC(38, 20)

	-- The formula is Total Weight / Qty
	-- If Qty is zero or null, return zero. 
	SET @calculatedValue = 
			CASE		WHEN ISNULL(@dblQty, 0) = 0 THEN 
						0.0
					ELSE
						dbo.fnDivide(@dblTotalWeight, @dblQty) 
			END

	RETURN @calculatedValue
END