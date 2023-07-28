--liquibase formatted sql

-- changeset Von:fnCalculateLotQty.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

/*
	This function will calculate the Lot Qty 
*/
CREATE OR ALTER FUNCTION [dbo].[fnCalculateLotQty](
	@intLotItemUOMId INT
	,@intCostingItemUOMId INT 
	,@dblLotQty NUMERIC(38,20)
	,@dblLotWeight NUMERIC(38,20)
	,@dblCostingQty NUMERIC(38,20)
	,@dblLotWeightPerQty NUMERIC(38,20)
)
RETURNS NUMERIC(38, 20)
AS 
BEGIN
	DECLARE @calculatedValue AS NUMERIC(38, 20)

	SET @calculatedValue = 
			CASE	WHEN @intLotItemUOMId = @intCostingItemUOMId THEN 
						-- @dblCostingQty is in Lot UOM. 
						ISNULL(@dblLotQty, 0) 
						+ ISNULL(@dblCostingQty, 0)
					ELSE 
						-- @dblCostingQty is in Weight. Since it is a weight, need to convert it into Qty. 						
						CASE	WHEN ISNULL(@dblLotWeightPerQty, 0) = 0 THEN 
									@dblLotQty
								ELSE 
									ROUND(
										dbo.fnDivide(
											ISNULL(@dblLotWeight, 0) + ISNULL(@dblCostingQty, 0) 
											,@dblLotWeightPerQty 
										) 
										, 2
									) 
						END 
			END

	RETURN @calculatedValue; 
END



