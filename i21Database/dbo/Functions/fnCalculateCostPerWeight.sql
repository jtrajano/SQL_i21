
-- This function returns the cost per weight. 
CREATE FUNCTION [dbo].[fnCalculateCostPerWeight] (	
	@dblItemOverallValue AS NUMERIC(38,20)
	,@dblWeight AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	DECLARE @result AS NUMERIC(38,20)

	-- formula is:
	-- Overall Value / Weight
	SET @result =	CASE	WHEN ISNULL(@dblWeight, 0) = 0 THEN 
								0 
							ELSE 
								ISNULL(@dblItemOverallValue, 0) / ISNULL(@dblWeight, 0) 
					END 
	RETURN ISNULL(@result, 0);
END