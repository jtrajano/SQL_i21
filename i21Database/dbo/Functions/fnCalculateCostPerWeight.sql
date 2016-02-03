
-- This function returns the cost per weight. 
CREATE FUNCTION [dbo].[fnCalculateCostPerWeight] (	
	@dblItemOverallValue AS NUMERIC(38,20)
	,@dblWeight AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	DECLARE @result AS FLOAT

	-- formula is:
	-- Overall Value / Weight
	SET @result =	CASE	WHEN ISNULL(@dblWeight, 0) = 0 THEN 
								0 
							ELSE 
								CAST(ISNULL(@dblItemOverallValue, 0) AS FLOAT) / CAST(ISNULL(@dblWeight, 0)  AS FLOAT) 
					END 
	RETURN dbo.fnConvertFloatToNumeric(ISNULL(@result, 0));
END