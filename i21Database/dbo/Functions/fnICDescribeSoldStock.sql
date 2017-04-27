CREATE FUNCTION [dbo].[fnICDescribeSoldStock] (
	@strItemNo AS NVARCHAR(50)
	,@dblQty AS NUMERIC(18, 6)
	,@dblCost AS NUMERIC(18, 6)
)
RETURNS NVARCHAR(100)
AS
BEGIN 
	DECLARE @result AS NVARCHAR(100) 
	
	DECLARE @strQty AS NVARCHAR(50) = CONVERT(NVARCHAR, CAST(@dblQty AS MONEY), 1)
	DECLARE @strCost AS NVARCHAR(50) = CONVERT(NVARCHAR, CAST(@dblCost AS MONEY), 1)

	-- ## Begin Note: This code does not work on SQL2008R2. It works on a higher version.  
	-- SET @result = FORMATMESSAGE('Item: %s, Qty: %s, Cost: %s', @strItemNo, @strQty, @strCost)
	-- ## End Note. 

	-- [Item, Qty, Cost]: {Item No}, {Qty}, {Cost}.
	SET @result = FORMATMESSAGE('Item: %s, Qty: %s, Cost: %s', @strItemNo, @strQty, @strCost)
	
	RETURN @result;
END