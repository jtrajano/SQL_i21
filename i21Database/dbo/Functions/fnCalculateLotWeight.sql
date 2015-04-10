/*
	This function will calculate the Lot Weight
*/
CREATE FUNCTION [dbo].[fnCalculateLotWeight](
	@intLotItemUOMId INT
	,@intLotWeightUOMId INT
	,@intCostingItemUOMId INT 
	,@dblLotWeight NUMERIC(18,6)
	,@dblCostingQty NUMERIC(18,6)
	,@dblLotWeightPerQty NUMERIC(38,20)
)
RETURNS NUMERIC(18,6)
AS 
BEGIN
	RETURN	CASE	WHEN ISNULL(@intLotWeightUOMId, 0) = @intCostingItemUOMId AND @intLotItemUOMId <> @intCostingItemUOMId THEN
						-- @dblCostingQty is in Weight 
						ISNULL(@dblLotWeight, 0) + @dblCostingQty
					ELSE 
						-- @dblCostingQty is in Lot UOM. Need to convert the Qty into weight value. 
						ISNULL(@dblLotWeight, 0) 
						+ ( 
							@dblCostingQty 
							* ISNULL(@dblLotWeightPerQty, 0)
						) 
			END
END