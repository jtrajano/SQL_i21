-- This will assemble a full address
-- Format used is: 
--		Street Address 
--		City, State Zip Code
CREATE FUNCTION [dbo].[fnConvertToFullAddress](
	@strAddress NVARCHAR(65)
	,@strCity NVARCHAR(85)
	,@strState NVARCHAR(60)
	,@strZipCode NVARCHAR(42)	
	--,@strCountry NVARCHAR(75)
)
RETURNS NVARCHAR(400)
AS
BEGIN 

DECLARE @LINE_FEED AS CHAR = CHAR(10)
DECLARE @CARRIAGE_RETURN AS CHAR = CHAR(13)

DECLARE @LINE_BREAK AS CHAR(2) = @CARRIAGE_RETURN + @LINE_FEED
DECLARE @COMMA AS CHAR(2) = ', '
DECLARE @SPACE AS CHAR(1) = ' ' 
DECLARE @charIndex AS INT 

DECLARE @strFixAddress AS NVARCHAR(100)

-- Sanitize the address field
BEGIN 
	SET @strFixAddress = LTRIM(RTRIM(@strAddress))

	-- If Line feed and carriage return is not the correct sequence, fix it. 
	SET @strFixAddress = REPLACE(@strFixAddress, @LINE_FEED+@CARRIAGE_RETURN, @LINE_BREAK)
		
	-- Use the standard line breaks
	SET @strFixAddress = REPLACE(@strFixAddress, @CARRIAGE_RETURN+@LINE_FEED, '@LineBreak')
	SET @strFixAddress = REPLACE(@strFixAddress, @CARRIAGE_RETURN, @LINE_BREAK)
	SET @strFixAddress = REPLACE(@strFixAddress, @LINE_FEED, @LINE_BREAK)
	SET @strFixAddress = REPLACE(@strFixAddress, '@LineBreak', @LINE_BREAK)

	-- If tail of the string contains one or more line breaks, remove it. 
	SET @strFixAddress = RTRIM(LTRIM(REVERSE(@strFixAddress)))
	WHILE (	CHARINDEX(@LINE_FEED, LTRIM(RTRIM(@strFixAddress))) = 1 OR 
			CHARINDEX(@CARRIAGE_RETURN, LTRIM(RTRIM(@strFixAddress))) = 1
	) BEGIN 
		SET @strFixAddress = RIGHT(LTRIM(RTRIM(@strFixAddress)), LEN(@strFixAddress) - 1)
	END 
	SET @strFixAddress = REVERSE(@strFixAddress)
END 

-- Trim all the carriage returns 
SET @strCity = REPLACE(@strCity, @CARRIAGE_RETURN, '')
SET @strState = REPLACE(@strState, @CARRIAGE_RETURN, '')
SET @strZipCode = REPLACE(@strZipCode, @CARRIAGE_RETURN, '')

-- Trim all the line feeds
SET @strCity = REPLACE(@strCity, @LINE_FEED, '')
SET @strState = REPLACE(@strState, @LINE_FEED, '')
SET @strZipCode = REPLACE(@strZipCode, @LINE_FEED, '')

-- Trim all the blanks 
SET @strFixAddress = LTRIM(RTRIM(@strFixAddress))
SET @strCity = LTRIM(RTRIM(@strCity))
SET @strState = LTRIM(RTRIM(@strState))
SET @strZipCode = LTRIM(RTRIM(@strZipCode))

RETURN	ISNULL(@strFixAddress, '') 
		+ @LINE_BREAK 
		+ ISNULL(@strCity, '')
		+ CASE WHEN ISNULL(@strState, '') <> '' THEN @COMMA ELSE '' END 
		+ ISNULL(@strState, '')
		+ CASE WHEN ISNULL(@strZipCode, '') <> '' THEN @SPACE ELSE '' END 
		+ ISNULL(@strZipCode, '')
END