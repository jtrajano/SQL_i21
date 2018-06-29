
-- This function returns the unit cost. 
CREATE FUNCTION [dbo].[fnCalculateStockUnitQty] (
	@dblQty AS NUMERIC(38,20)
	,@dblUnitQty AS NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS
BEGIN 
	-- Formula is qty x unit qty 
	RETURN dbo.fnMultiply (
		ISNULL(@dblQty, 0)
		,ISNULL(@dblUnitQty, 0) 
	)

END