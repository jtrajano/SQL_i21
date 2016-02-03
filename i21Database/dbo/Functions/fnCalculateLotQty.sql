/*
	This function will calculate the Lot Qty 
*/
CREATE FUNCTION [dbo].[fnCalculateLotQty](
	@intLotItemUOMId INT
	,@intCostingItemUOMId INT 
	,@dblLotQty NUMERIC(38,20)
	,@dblLotWeight NUMERIC(38,20)
	,@dblCostingQty NUMERIC(38,20)
	,@dblLotWeightPerQty NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN
	DECLARE @calculatedValue AS FLOAT

	SET @calculatedValue = 
			CASE	WHEN @intLotItemUOMId = @intCostingItemUOMId THEN 
						-- @dblCostingQty is in Lot UOM. 
						CAST(ISNULL(@dblLotQty, 0)  AS FLOAT) 
						+ CAST(ISNULL(@dblCostingQty, 0) AS FLOAT) 
					ELSE 
						-- @dblCostingQty is in Weight. Since it is a weight, need to convert it into Qty. 						
						CASE	WHEN ISNULL(@dblLotWeightPerQty, 0) = 0 THEN 
									@dblLotQty
								ELSE 
									(
										CAST(ISNULL(@dblLotWeight, 0) AS FLOAT)
										+ CAST(ISNULL(@dblCostingQty, 0) AS FLOAT)
									) 
									/ CAST(@dblLotWeightPerQty AS FLOAT) 
						END 
			END

	RETURN dbo.fnConvertFloatToNumeric(@calculatedValue) 	
END
