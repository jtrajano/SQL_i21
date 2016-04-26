﻿-- This function returns an accurate result when multiplying high precision/scale numbers in SQL server. 
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
	DECLARE @sign AS INT 

	IF @factor1 IS NULL 
		RETURN NULL;

	IF @factor2 IS NULL
		RETURN NULL; 

	SELECT @sign = SIGN(@factor1) * SIGN(@factor2) 

	-- Raw result is in string. 
	BEGIN 
		DECLARE @NoDecimalFactor1 AS NUMERIC(19, 0) 
		DECLARE @NoDecimalFactor2 AS NUMERIC(19, 0) 

		DECLARE @factor1DecimalPlaces AS INT = (
							LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@factor1, 1), '0', ' '))), ' ', '0'), '@', '')) 
						)					
		DECLARE @factor2DecimalPlaces AS INT = (
							LEN(REPLACE(REPLACE(RTRIM(LTRIM(REPLACE('@' + PARSENAME(@factor2, 1), '0', ' '))), ' ', '0'), '@', '')) 	
						)

		SET @NoDecimalFactor1 = 
				LEFT(
					CAST(
						@factor1 * POWER(CAST(10 AS NUMERIC(18,10)), @factor1DecimalPlaces) 
						AS NVARCHAR(100)
					)
					,17
				)
		SET @NoDecimalFactor2 = 
				LEFT(
					CAST(
						@factor2 * POWER(CAST(10 AS NUMERIC(18,10)), @factor2DecimalPlaces)	
						AS NVARCHAR(100)
					)
					,17
				)

		SET @rawResult = @NoDecimalFactor1 * @NoDecimalFactor2
		SET @rawResult = REPLACE(LTRIM(REPLACE(REPLACE(REPLACE(@rawResult, '-', ''), '.', ''), '0', ' ')), ' ', 0)		
	END 

	-- Pad zeroes to the left 
	BEGIN 
		DECLARE @stringFactor1 AS NVARCHAR(40) = CAST(@factor1 AS NVARCHAR(40)) 
				,@stringFactor2 AS NVARCHAR(40) = CAST(@factor2 AS NVARCHAR(40)) 

		DECLARE	@shortenFactor1 AS NUMERIC(38, 20) = LEFT(@stringFactor1, CHARINDEX('.', @stringFactor1) + 6)
				,@shortenFactor2 AS NUMERIC(38, 20)	= LEFT(@stringFactor2, CHARINDEX('.', @stringFactor2) + 6)

		DECLARE @shortenMultiply AS NUMERIC(38,20) = @shortenFactor1 * @shortenFactor2

		SET @rawResult = REPLICATE('0',PATINDEX('%[^0]%', REPLACE(REPLACE(@shortenMultiply, '.', ''), '-', '')) - 1) + @rawResult +  REPLICATE('0', 5) 
	END 	
	
	-- Determine where to place the decimal point. 
	BEGIN 	
		SET @rawResult = 
			STUFF(
				@rawResult
				,CHARINDEX('.', @shortenMultiply) + CASE WHEN SIGN(@shortenMultiply) = -1 THEN -1 ELSE 0 END 
				,0
				,'.'
			)
	END 

	-- Determine if there is a need to append a negative sign. 
	BEGIN 
		SET @rawResult = CASE WHEN SIGN(@sign) = -1 THEN '-' ELSE '' END + @rawResult
	END 

	SET @product = ISNULL(CAST(LEFT(@rawResult, 38) AS NUMERIC(38, 20)), 0) 
	
	RETURN @product
END