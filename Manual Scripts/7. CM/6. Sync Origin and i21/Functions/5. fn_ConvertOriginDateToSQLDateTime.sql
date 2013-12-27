/*
 '====================================================================================================================================='
   SCRIPT CREATED BY: Feb Montefrio	DATE CREATED: December 26, 2013
  -------------------------------------------------------------------------------------------------------------------------------------						
   Script Name         :	fn_ConvertOriginDateToSQLDateTime

   Description		   :	The origin system saves the date as integer and it is formatted as yyyymmdd. 
							This function will convert the integer date values to SQL DateTime. 
							
*/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_id(N'[dbo].fn_ConvertOriginDateToSQLDateTime') AND objectproperty(id, N'ISScalarFUNCTION') = 1)
DROP Function [dbo].fn_ConvertOriginDateToSQLDateTime
GO

CREATE FUNCTION fn_ConvertOriginDateToSQLDateTime(@intDate AS INT)	
RETURNS DATETIME
AS
BEGIN 
	-- Validate if the integer date is valid. 
	-- It must be a positive value
	IF (@intDate <= 0)
		RETURN NULL
	
	-- It must be 8-digits. 
	IF ( LEN(CAST(@intDate AS NVARCHAR(8))) < 8 ) 
		RETURN NULL
		
	-- Validate if the first 4 digits are valid 
	DECLARE @strDate AS NVARCHAR(8) = CAST(@intDate AS NVARCHAR(8)),
			@year AS INT,
			@month AS INT,
			@day AS INT
	
	-- Parse the values into yyyy mm dd. 
	SELECT	@year = CAST(SUBSTRING(@strDate, 1, 4) AS INT)
			,@month = CAST(SUBSTRING(@strDate, 5, 2) AS INT)
			,@day = CAST(SUBSTRING(@strDate, 7, 2) AS INT)
	
	-- Support only the years 1900 and above. Months must be up to 12 months and days must be up to 31 days. 
	IF (@year < 1900 OR @month > 12 OR @day > 31)
		RETURN NULL
	
	-- Validate if the certain months has only 31 days (Jan, Mar, May, Jul, Aug, Oct, and Dec)
	IF (@month IN (1, 3, 5, 7, 8, 10, 12) AND @day > 31 )
		RETURN NULL	
	
	-- Validate the days in months with 30 or less days (Feb, Apr, Jun, Sept, and Nov)
	IF (@month IN (2, 4, 6, 9, 11) AND @day > 30)
		RETURN NULL
	
	-- Validate the days in February
	IF (@month = 2)
	BEGIN
		IF (@day > 29)
			RETURN NULL
	
		-- If year is not a leap year, check if it only has 28 days
		IF (@year % 4 > 0 AND @day > 28)
			RETURN NULL 
	END
	
	-- Convert the integer value to SQL Date
	RETURN CAST(CAST(@intDate AS NVARCHAR(8)) AS DATETIME)
END

GO
