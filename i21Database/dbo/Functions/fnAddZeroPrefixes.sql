
-- This function add zero prefixes to a numeric string. This is commonly used on check numbers. 
CREATE FUNCTION [dbo].[fnAddZeroPrefixes](@strCheckNumber AS NVARCHAR(MAX))
RETURNS NVARCHAR(20)
AS
BEGIN 

-- As per Joe Kohnen, the acceptable number of check numbers is 8 characters. (March 2014)
-- You can increase @PREFIX_COUNT in case future check number requirement increases. 
DECLARE @PREFIX_COUNT AS INT = 8

-- Check if the parameter is a number field. If non-numeric, return same value. 
IF ISNUMERIC(@strCheckNumber) = 0
BEGIN 
	RETURN @strCheckNumber
END 

-- Check if the parameter is a decimal. If yes, return same value. 
IF FLOOR(@strCheckNumber) <> CEILING(@strCheckNumber)
BEGIN 
	RETURN @strCheckNumber
END 

-- Check if the parameter is more than 20 chars. If yes, return a truncated string (20-chars). 
IF LEN(@strCheckNumber) > 20 
BEGIN 
	RETURN @strCheckNumber
END 

-- Check if parameter is a positive number. 
IF CAST(@strCheckNumber AS NUMERIC(38, 0)) < 0 
BEGIN 
	RETURN @strCheckNumber
END 

-- Convert the value to integer-string. 
SET @strCheckNumber = CAST( CAST(@strCheckNumber AS  NUMERIC(38, 0)) AS NVARCHAR(20))

-- Return a string with zero prefixes. 
RETURN	ISNULL(REPLICATE('0', @PREFIX_COUNT - LEN(@strCheckNumber)), '') + 
		@strCheckNumber
		
END
