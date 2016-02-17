-- This function returns the unit cost. 
CREATE FUNCTION [dbo].[fnCalculateUnitCost] (
	@dblCost AS NUMERIC(38,20)
	,@dblUnitQty AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	DECLARE @result AS FLOAT

	-- formula is cost  / unit qty
	-- If unit qty is zero, return cost. 
	SET @result =	CASE	WHEN ISNULL(@dblUnitQty, 0) = 0 THEN 
								CAST(@dblCost AS FLOAT) 
							ELSE	
								CAST(ISNULL(@dblCost, 0) AS FLOAT) / CAST(@dblUnitQty AS FLOAT) 
					END 

	RETURN dbo.fnConvertFloatToNumeric(ISNULL(@result, 0));
END