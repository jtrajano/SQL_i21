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

	-- Avoid 'divide by zero' error. Return NULL value. 
	IF ISNULL(@divisor, 0) = 0 
		RETURN NULL;

	-- Divide it and get the raw result as a string. 
	-- Avoid the arithmetic overflow by ensuring the numbers are truncated at the 19th digit from the left. 
	BEGIN 
		DECLARE @NoDecimalDividend AS NUMERIC(19, 0) 
		DECLARE @NoDecimalDivisor AS NUMERIC(19, 0) 

		SET @NoDecimalDividend = 
				LEFT(
					CAST(
						@dividend * 
						POWER(CAST(10 AS NUMERIC(18,10)), 
							LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@dividend, 1), '0', ' '))), ' ', '0'), '@', ''))
						) 
						AS NVARCHAR(100)
					)
					,19
				)
		SET @NoDecimalDivisor = 
				LEFT(
					CAST(
						@divisor * 
						POWER(CAST(10 AS NUMERIC(18,10)), 
							LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@divisor, 1), '0', ' '))), ' ', '0'), '@', '')) 
						)	
						AS NVARCHAR(100)
					)
					,19
				)

		SET @rawResult = @NoDecimalDividend / @NoDecimalDivisor
	END 

	-- Determine where to place the decimal point. 
	BEGIN 
		DECLARE @currentDecimalPosition AS INT = CHARINDEX('.', @rawResult) 
		DECLARE @dividendDecimalPlaces AS INT = (
							LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@dividend, 1), '0', ' '))), ' ', '0'), '@', '')) 
						)					
		DECLARE @divisorDecimalPlaces AS INT = (
							LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@divisor, 1), '0', ' '))), ' ', '0'), '@', '')) 	
						)

		DECLARE @moveDecimalPlaces AS INT = @divisorDecimalPlaces - @dividendDecimalPlaces - (CASE WHEN @divisorDecimalPlaces >= 18 THEN @divisorDecimalPlaces - 17 ELSE 0 END)

		SELECT	@rawResult = REPLICATE('0', @dividendDecimalPlaces - @currentDecimalPosition + 1) + @rawResult
				,@currentDecimalPosition = @currentDecimalPosition + (@dividendDecimalPlaces - @currentDecimalPosition) + 1
		WHERE  @dividendDecimalPlaces >= @currentDecimalPosition

		SET @rawResult = 
			STUFF(
				REPLACE(@rawResult, '.', '') 
				,@currentDecimalPosition + @moveDecimalPlaces
				,0
				,'.'
			)
	END 
	SET @quotient = CAST(@rawResult AS NUMERIC(38, 20)) 
		
	RETURN @quotient
END