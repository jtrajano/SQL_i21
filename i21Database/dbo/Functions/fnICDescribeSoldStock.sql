﻿CREATE FUNCTION [dbo].[fnICDescribeSoldStock] (
	@strItemNo AS NVARCHAR(50)
	,@dblQty AS NUMERIC(18, 6)
	,@dblCost AS NUMERIC(18, 6)
	,@strLotNumber AS NVARCHAR(50) = NULL 
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
						, @strLotNumber
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
					) COLLATE Latin1_General_CI_AS
		RETURN @result;	
	END 

	ELSE 
	BEGIN 
		DECLARE @strQty AS NVARCHAR(50) = dbo.fnFormatNumber(@dblQty) COLLATE Latin1_General_CI_AS
		DECLARE @strCost AS NVARCHAR(50) = dbo.fnFormatNumber(@dblCost) COLLATE Latin1_General_CI_AS
		
		-- 'Item: %s, Qty: %s, Cost: %s'
		SET @result = dbo.fnFormatMessage(
						dbo.fnICGetErrorMessage(80159)
						, @strItemNo
						, @strLotNumber
						, @strQty
						, @strCost						
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
						, DEFAULT
					) COLLATE Latin1_General_CI_AS	
	END 
	RETURN @result COLLATE Latin1_General_CI_AS;
END