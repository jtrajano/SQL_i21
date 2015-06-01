-- This function returns new adjust by quantity. 
CREATE FUNCTION [dbo].[fnCalculateAdjustByQuantity] (
	@dblNewQuantity AS NUMERIC(18,6)
	,@dblOriginalQuantity AS NUMERIC(18,6)
)
RETURNS NUMERIC(18, 6)
AS
BEGIN 
	RETURN (-1 * (ISNULL(@dblNewQuantity, 0) - ISNULL(@dblOriginalQuantity, 0)))
END