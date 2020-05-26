/*
	Create a common function for calculating the IR's unit cost.  
*/

CREATE FUNCTION [dbo].[fnCalculateReceiptUnitCost](	
	@intItemId AS INT 
	,@intItemUOMId AS INT		
	,@intCostUOMId AS INT
	,@intGrossUOMId AS INT
	,@dblUnitCost AS NUMERIC(38,20)
	,@dblItemNetWgtVolume AS NUMERIC(38,20)
	,@intLotId AS INT
	,@intLotUOMId AS INT
	,@dblLotNetWgtVolume AS NUMERIC(38,20)
	,@ysnSubCurrency AS BIT
	,@intSubCurrencyCents AS INT 	
	,@intStockUOMId AS INT
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE	@result AS NUMERIC(38,20) 

	SELECT @result = 
		/*
		--------------------------------------------------------------------------------------------------------
		How unit cost is calculated in Inventory Receipt
		--------------------------------------------------------------------------------------------------------

			1. If there is a Gross/Net UOM, convert the cost from Cost UOM to Gross/Net UOM. 
			2. If Gross/Net UOM is not specified, then: 
				2.1. If it is not a Lot, convert the cost from Cost UOM to Receive UOM. 
				2.2. If it is a Lot, convert the cost from Cost UOM to Lot UOM. 
			3. If sub-currency exists, then convert it to sub-currency. 
		
		Illustration:
		A = Calculated unit cost. 
		C = Sub Currency cents. 

		If Sub-Currency, return A / C
		Else, return A
		
		*/
		CASE	
				WHEN @intGrossUOMId IS NOT NULL THEN 
					-- Convert the Cost UOM to Gross/Net UOM. 

					CASE	-- When item is NOT a Lot, use the unit cost from the line item. 
							WHEN @intLotId IS NULL AND dbo.fnGetItemLotType(@intItemId) = 0 THEN 
								dbo.fnCalculateCostBetweenUOM(
									ISNULL(@intCostUOMId, @intItemUOMId)
									, ISNULL(@intStockUOMId, @intGrossUOMId)
									, @dblUnitCost
								) 
													
							WHEN @intLotId IS NOT NULL AND ISNULL(@dblItemNetWgtVolume, 0) <> ISNULL(@dblLotNetWgtVolume, 0) THEN 
								/*
								--------------------------------------------------------------------------------------------------------
								-- Cleaned weight scenario. 
								--------------------------------------------------------------------------------------------------------
								When item is a LOT, recalculate the cost. 
								Below is an example: 
									1. Receive a stock at $1/LB. Net weight received is 100lb. So this means line total is $100. $1 x $100 = $100. 
									2. Lot can be cleaned. So after a lot is cleaned, net weight on lot level is reduced to 80 lb. 
									3. Value of the line total will still remain at $100. 
									4. So this means, cost needs to be changed from $1/LB to $1.25/LB.
									5. Receiving 80lbs @ $1.25/lb is $100. This will match the value of the line item with the lot item. 
								*/
								dbo.fnDivide(
									dbo.fnMultiply(
										dbo.fnCalculateCostBetweenUOM(ISNULL(@intCostUOMId, @intItemUOMId), @intGrossUOMId, @dblUnitCost) 
										, ISNULL(@dblItemNetWgtVolume, 0)
									)
									,ISNULL(@dblLotNetWgtVolume, 1) 
								)
							ELSE
								dbo.fnCalculateCostBetweenUOM(
									ISNULL(@intCostUOMId, @intItemUOMId)
									, ISNULL(@intStockUOMId, @intGrossUOMId)
									, @dblUnitCost
								) 

					END 

				-- If Gross/Net UOM is missing, 
				ELSE 
						CASE	
							-- If non-lot, convert the unit cost from Cost UOM to Receive UOM
							WHEN @intLotId IS NULL AND dbo.fnGetItemLotType(@intItemId) = 0 THEN 
								-- Convert from Cost UOM to Item UOM. 
								dbo.fnCalculateCostBetweenUOM(
									ISNULL(@intCostUOMId, @intItemUOMId)
									, ISNULL(@intStockUOMId, @intItemUOMId)
									, @dblUnitCost
								) 
													
							-- If lot, convert from Cost UOM to Lot UOM
							ELSE 														
								dbo.fnCalculateCostBetweenUOM(ISNULL(@intCostUOMId, @intItemUOMId), @intLotUOMId, @dblUnitCost) 
						END 
		END

	SET @result = 
		-- Then convert the cost to the sub-currency value. 
		CASE	WHEN ISNULL(@ysnSubCurrency, 0) = 1 AND ISNULL(@intSubCurrencyCents, 1) NOT IN (0, 1) THEN 
					--@result / @intSubCurrencyCents 
					ROUND(dbo.fnDivide(@result, @intSubCurrencyCents), 2)
				ELSE 
					@result
		END

	RETURN @result;	
END