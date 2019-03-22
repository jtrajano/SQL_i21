-- This function returns new adjust by quantity. 
CREATE FUNCTION [dbo].[fnCalculateAdjustByQuantity] (
	@dblNewQuantity AS NUMERIC(38,20)
	,@dblOriginalQuantity AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	RETURN (-1 * (ISNULL(@dblNewQuantity, 0) - ISNULL(@dblOriginalQuantity, 0)))
END