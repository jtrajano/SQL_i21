/*
	Calculate the Line total for the Inventory Receipt. 
*/

CREATE FUNCTION [dbo].[fnCalculateReceiptLineTotal](
	@dblReceiveQty NUMERIC(38,20)
	,@dblNetQty NUMERIC(38, 20) 
	,@dblUnitCost NUMERIC(38,20)
	,@intSubCurrencyCents INT
	,@dblReceiveUOMUnitQty NUMERIC(38,20)
	,@dblGrossNetUnitQty NUMERIC(38,20)
	,@dblCostUOMUnitQty NUMERIC(38,20)
)
RETURNS NUMERIC(38,20)
AS 
BEGIN 
	DECLARE @result AS NUMERIC(38,20) 

	-- Sanitize the sub currency
	SET @intSubCurrencyCents = CASE WHEN @intSubCurrencyCents = 0 THEN 1 ELSE ISNULL(@intSubCurrencyCents, 1) END 
	
	-- Calculate the line total based on the net qty. 
	IF @dblGrossNetUnitQty IS NULL 
	BEGIN 
		-- Sanitize the cost uom. 
		SET @dblCostUOMUnitQty = CASE WHEN @dblCostUOMUnitQty <> 0 THEN @dblCostUOMUnitQty ELSE ISNULL(@dblCostUOMUnitQty, @dblReceiveUOMUnitQty) END 
		SET @dblCostUOMUnitQty = CASE WHEN @dblCostUOMUnitQty <> 0 THEN @dblCostUOMUnitQty ELSE ISNULL(@dblCostUOMUnitQty, 1) END 
		
		-- lineTotal = (qty * (unitCost / costCentsFactor) * (qtyCF / costCF));
		SET @result =	dbo.fnMultiply(
							dbo.fnMultiply(
								@dblReceiveQty 
								,dbo.fnDivide(@dblUnitCost, @intSubCurrencyCents)
							)
							,dbo.fnDivide(
								@dblReceiveUOMUnitQty
								,@dblCostUOMUnitQty
							)
						)
	END 
	ELSE 
	BEGIN 
		-- Sanitize the cost uom. 
		SET @dblCostUOMUnitQty = CASE WHEN @dblCostUOMUnitQty <> 0 THEN @dblCostUOMUnitQty ELSE ISNULL(@dblCostUOMUnitQty, @dblGrossNetUnitQty) END 
		SET @dblCostUOMUnitQty = CASE WHEN @dblCostUOMUnitQty <> 0 THEN @dblCostUOMUnitQty ELSE ISNULL(@dblCostUOMUnitQty, 1) END 
		
		-- lineTotal = (netWgt * (unitCost / costCentsFactor) * (netWgtCF / costCF));
		SET @result =	dbo.fnMultiply(
							dbo.fnMultiply(
								@dblNetQty 
								,dbo.fnDivide(@dblUnitCost, @intSubCurrencyCents)
							)
							,dbo.fnDivide(
								@dblGrossNetUnitQty
								,@dblCostUOMUnitQty
							)
						)
	END 
	
	RETURN @result;	
END
GO

