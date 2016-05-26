-- This function returns an accurate result when dividing numbers in SQL server. 
-- It divides the number using the whole number part, determine where to place the decimal point in the string, and then return as a numeric with 20 decimal places. 
CREATE FUNCTION [dbo].[fnDivide] (
	@dividend AS NUMERIC(38,20)
	,@divisor AS NUMERIC(38,20)
)
RETURNS NUMERIC(38, 20) 
AS
BEGIN 
	DECLARE @quotient AS NUMERIC(38, 20)
	DECLARE @rawResult AS NVARCHAR(200) 
	DECLARE @valueSign AS INT
	DECLARE @sign AS INT 

	-- Avoid 'divide by zero' error. Return NULL value. 
	IF ISNULL(@divisor, 0) = 0 
		RETURN NULL;

	IF @dividend IS NULL 
		RETURN NULL;

	IF @divisor IS NULL
		RETURN NULL; 

	-- Return same dividend value if divisor is 1. 
	IF @divisor = 1 
		RETURN @dividend; 

	SELECT @sign = SIGN(@dividend) * SIGN(@divisor) 

	-- Divide it and process the raw result as a string. 
	-- Avoid the arithmetic overflow by ensuring the numbers are truncated at the 17th digit from the left. 
	BEGIN 
		DECLARE @NoDecimalDividend AS NUMERIC(19, 0) 
		DECLARE @NoDecimalDivisor AS NUMERIC(19, 0) 

		DECLARE @dividendDecimalPlaces AS INT = (
							LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@dividend, 1), '0', ' '))), ' ', '0'), '@', '')) 
						)					
		DECLARE @divisorDecimalPlaces AS INT = (
							LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@divisor, 1), '0', ' '))), ' ', '0'), '@', '')) 	
						)

		SET @NoDecimalDividend = 
				LEFT(
					CAST(
						@dividend * 
						POWER(CAST(10 AS NUMERIC(18,10)), @dividendDecimalPlaces) 
						AS NVARCHAR(100)
					)
					,17
				)
		SET @NoDecimalDivisor = 
				LEFT(
					CAST(
						@divisor * 
						POWER(CAST(10 AS NUMERIC(18,10)), @divisorDecimalPlaces)	
						AS NVARCHAR(100)
					)
					,17
				)

		SET @rawResult = @NoDecimalDividend / @NoDecimalDivisor
		SET @rawResult = REPLACE(LTRIM(REPLACE(REPLACE(REPLACE(@rawResult, '-', ''), '.', ''), '0', ' ')), ' ', 0)		
	END 

	-- Pad zeroes to the raw value. 
	BEGIN 
		DECLARE @stringFactor1 AS NVARCHAR(40) = CAST(@dividend AS NVARCHAR(40)) 
				,@stringFactor2 AS NVARCHAR(40) = CAST(@divisor AS NVARCHAR(40)) 

		DECLARE	@shortenFactor1 AS NUMERIC(38, 20) = LEFT(@stringFactor1, CHARINDEX('.', @stringFactor1) + 6)
				,@shortenFactor2 AS NUMERIC(38, 20)	= LEFT(@stringFactor2, CHARINDEX('.', @stringFactor2) + 6)

		DECLARE @shortenDivide AS NUMERIC(38,20) = @dividend / @divisor

		SET @rawResult = REPLICATE('0',PATINDEX('%[^0]%', REPLACE(REPLACE(@shortenDivide, '.', ''), '-', '')) - 1) + @rawResult 
	END 	

	-- Determine where to place the decimal point. 
	BEGIN 
		SET @rawResult = 
			STUFF(
				@rawResult
				,CHARINDEX('.', @shortenDivide) + CASE WHEN SIGN(@shortenDivide) = -1 THEN -1 ELSE 0 END 
				,0
				,'.' 
			)
	END

	-- Determine if there is a need to append a negative sign. 
	BEGIN 
		SET @rawResult = CASE WHEN SIGN(@sign) = -1 THEN '-' ELSE '' END + @rawResult
	END 

	-- Finalize the return value by converting the string to numeric. 
	SET @quotient = ISNULL(CAST(LEFT(@rawResult, 38) AS NUMERIC(38, 20)), 0)
	RETURN @quotient
END