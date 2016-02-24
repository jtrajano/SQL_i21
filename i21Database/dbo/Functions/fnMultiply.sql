-- This function returns an accurate result when multiplying high precision/scale numbers in SQL server. 
-- It multiplies the numbers using the whole number part, determine where to place the decimal point in the string, and then return as a numeric with 20 decimal places. 
CREATE FUNCTION [dbo].[fnMultiply] (
	@factor1 AS NUMERIC(38,20)
	,@factor2 AS NUMERIC(38,20)
)
RETURNS NUMERIC(38, 20) 
AS
BEGIN 
	DECLARE @product AS NUMERIC(38, 20)
	DECLARE @rawResult AS NVARCHAR(200)
	DECLARE @decimalSize INT
	 

	-- Raw result is in string. 
	BEGIN 
		DECLARE @NoDecimalFactor1 AS NUMERIC(18, 0) 
		DECLARE @NoDecimalFactor2 AS NUMERIC(18, 0) 

		SET @NoDecimalFactor1 = @factor1 * 
				POWER(CAST(10 AS NUMERIC(18,10)), 
					LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@factor1, 1), '0', ' '))), ' ', '0'), '@', ''))
				) 

		SET @NoDecimalFactor2 = @factor2 * 
				POWER(CAST(10 AS NUMERIC(18,10)), 
					LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@factor2, 1), '0', ' '))), ' ', '0'), '@', '')) 
				)

		SET @rawResult = @NoDecimalFactor1 * @NoDecimalFactor2

	END 

	-- Check if the number is negative. 
	DECLARE @isNegative AS BIT 
	SELECT	@isNegative = 1 
	WHERE	CHARINDEX('-', @rawResult) <> 0 

	-- Determine where to place the decimal point. 
	SET @decimalSize = 
			(
				LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@factor1, 1), '0', ' '))), ' ', '0'), '@', '')) 
			)
			+ 
			(
				LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@factor2, 1), '0', ' '))), ' ', '0'), '@', '')) 	
			)

	SET @rawResult = REPLACE(@rawResult, '-', '')
	SET @rawResult = CASE WHEN @decimalSize - LEN(@rawResult) > 0 THEN REPLICATE('0', @decimalSize - LEN(@rawResult)) + @rawResult ELSE @rawResult END 
	SET @rawResult = 
		STUFF(
			REPLACE(@rawResult, '.', '') 
			,(	
				LEN(@rawResult) - ISNULL(CHARINDEX('.', @rawResult), 0) 
				- @decimalSize
				+ 1
				
			)
			,0
			,'.'
		)

	SET @product = CAST(@rawResult AS NUMERIC(38, 20)) 		
	RETURN @product * CASE WHEN @isNegative = 1 THEN -1 ELSE 1 END 
END