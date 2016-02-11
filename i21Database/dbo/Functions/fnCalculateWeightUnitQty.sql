-- This function returns the weight per uom 
CREATE FUNCTION [dbo].[fnCalculateWeightUnitQty] (
	@dblQty AS NUMERIC(38,20)
	,@dblTotalWeight AS NUMERIC(38,20)
)
RETURNS NUMERIC(38, 20) 
AS
BEGIN 
	DECLARE @result AS NUMERIC(38, 20)
			,@calculatedValue AS FLOAT

	-- The formula is Total Weight / Qty
	-- If Qty is zero or null, return zero. 
	SET @calculatedValue = 
			CASE		WHEN ISNULL(@dblQty, 0) = 0 THEN 
						0.0
					ELSE
						CAST(ISNULL(@dblTotalWeight, 0.00) AS FLOAT) / CAST(@dblQty AS FLOAT) 
			END

	RETURN dbo.fnConvertFloatToNumeric(@calculatedValue) 			
END