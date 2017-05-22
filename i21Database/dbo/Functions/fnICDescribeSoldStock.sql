CREATE FUNCTION [dbo].[fnICDescribeSoldStock] (
	@strItemNo AS NVARCHAR(50)
	,@dblQty AS NUMERIC(18, 6)
	,@dblCost AS NUMERIC(18, 6)
)
RETURNS NVARCHAR(100)
AS
BEGIN 
	DECLARE @result AS NVARCHAR(100) 

	-- If Qty and cost are both zero, then item name only. 
	IF ISNULL(@dblQty, 0) = 0 AND ISNULL(@dblCost, 0) = 0 
	BEGIN 
		-- Item: %s
		SET @result = dbo.fnFormatMessage(
						dbo.fnICGetErrorMessage(80179)
						, @strItemNo
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
					)	
		RETURN @result;	
	END 

	ELSE 
	BEGIN 
		DECLARE @strQty AS NVARCHAR(50) = CONVERT(NVARCHAR, CAST(@dblQty AS MONEY), 1)
		DECLARE @strCost AS NVARCHAR(50) = CONVERT(NVARCHAR, CAST(@dblCost AS MONEY), 1)

		-- 'Item: %s, Qty: %s, Cost: %s'
		SET @result = dbo.fnFormatMessage(
						dbo.fnICGetErrorMessage(80159)
						, @strItemNo
						, @strQty
						, @strCost
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
					)	
	END 
	RETURN @result;
END