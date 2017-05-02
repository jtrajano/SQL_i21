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

	-- [Item, Qty, Cost]: {Item No}, {Qty}, {Cost}.
	SET @result = FORMATMESSAGE(dbo.fnICGetErrorMessage(80159), @strItemNo, @strQty, @strCost)
	
	RETURN @result;
END