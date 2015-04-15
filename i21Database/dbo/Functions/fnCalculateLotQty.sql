/*
	This function will calculate the Lot Qty 
*/
CREATE FUNCTION [dbo].[fnCalculateLotQty](
	@intLotItemUOMId INT
	,@intCostingItemUOMId INT 
	,@dblLotQty NUMERIC(18,6)
	,@dblLotWeight NUMERIC(18,6)
	,@dblCostingQty NUMERIC(18,6)
	,@dblLotWeightPerQty NUMERIC(38,20)
)
RETURNS NUMERIC(18,6)
AS 
BEGIN
	RETURN	CASE	WHEN @intLotItemUOMId = @intCostingItemUOMId THEN 
						-- @dblCostingQty is in Lot UOM. 
						ISNULL(@dblLotQty, 0) 
						+ ISNULL(@dblCostingQty, 0)
					ELSE 
						-- @dblCostingQty is in Weight. Since it is a weight, need to convert it into Qty. 						
						CASE	WHEN ISNULL(@dblLotWeightPerQty, 0) = 0 THEN 
									@dblLotQty
								ELSE 
									(
										ISNULL(@dblLotWeight, 0)
										+ ISNULL(@dblCostingQty, 0)
									) 
									/ @dblLotWeightPerQty 
						END 
			END
END
