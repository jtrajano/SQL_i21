
-- This function returns the cost per weight. 
CREATE FUNCTION [dbo].[fnCalculateCostPerWeight] (	
	@dblItemOverallValue AS NUMERIC(38,20)
	,@dblWeight AS NUMERIC(18,6)
)
RETURNS NUMERIC(18,6)
AS
BEGIN 
	DECLARE @result AS NUMERIC(18,6)

	-- formula is:
	-- Overall Value / Weight
	SET @result =	CASE	WHEN ISNULL(@dblWeight, 0) = 0 THEN 
								0 
							ELSE 
								ISNULL(@dblItemOverallValue, 0) / ISNULL(@dblWeight, 0) 
					END 
	RETURN ISNULL(@result, 0);
END