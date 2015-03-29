
-- This function returns the cost per weight. 
CREATE FUNCTION [dbo].[fnCalculateCostPerWeight] (
	@dblQty AS NUMERIC(18,6)
	,@dblCost AS NUMERIC(18,6)
	,@dblWeight AS NUMERIC(18,6)
)
RETURNS NUMERIC(18,6)
AS
BEGIN 
	DECLARE @result AS NUMERIC(18,6)

	-- formula is:
	-- Qty x Cost / Weight
	SET @result = CASE WHEN ISNULL(@dblWeight, 0) = 0 THEN 0 ELSE ISNULL(@dblQty, 0) * ISNULL(@dblCost, 0) / ISNULL(@dblWeight, 0) END 

	RETURN ISNULL(@result, 0);
END