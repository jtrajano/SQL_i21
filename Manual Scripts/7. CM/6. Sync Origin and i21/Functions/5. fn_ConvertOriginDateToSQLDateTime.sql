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
	IF ( LEN(CAST(@intDate AS NVARCHAR(8))) < 8 ) 
		RETURN NULL
		
	-- Validate if the 1st 4 digits are valid 
	DECLARE @strDate AS NVARCHAR(8) = CAST(@intDate AS NVARCHAR(8)),
			@year AS NVARCHAR(4),
			@month AS NVARCHAR(2),
			@day AS NVARCHAR(2)
	
	SELECT	@year = SUBSTRING(@strDate, 1, 4)
			,@month = SUBSTRING(@strDate, 5, 2)
			,@day = SUBSTRING(@strDate, 7, 2)
			
	IF NOT (CAST(@year AS INT) > 1900 AND (CAST(@month AS INT) BETWEEN 1 AND 12) AND (CAST(@day AS INT) BETWEEN 1 AND 31))
		RETURN NULL
	
	-- TODO: Check if date is a valid leap year
	--IF NOT ( CAST(@year AS INT) % 4 = 0 CAST(@month AS INT) = 2 AND CAST(@day AS INT) < 29 ) 
	--	RETURN NULL

	-- TODO: Check if a valid end day of a month
	--IF NOT ( CAST(@year AS INT) % 4 = 0 CAST(@month AS INT) = 2 AND CAST(@day AS INT) < 29 ) 
	--	RETURN NULL		
		
	RETURN CAST(CAST(@intDate AS NVARCHAR(8)) AS DATETIME)

END

GO
