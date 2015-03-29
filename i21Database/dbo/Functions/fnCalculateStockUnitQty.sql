
-- This function returns the unit cost. 
CREATE FUNCTION [dbo].[fnCalculateStockUnitQty] (
	@dblQty AS NUMERIC(18,6)
	,@dblUnitQty AS NUMERIC(18,6)
)
RETURNS NUMERIC(18,6)
AS
BEGIN 
	DECLARE @result AS NUMERIC(18,6)

	-- Formula is qty x unit qty 
	SET @result = ISNULL(@dblQty, 0) * ISNULL(@dblUnitQty, 0)

	RETURN ISNULL(@result, 0);
END