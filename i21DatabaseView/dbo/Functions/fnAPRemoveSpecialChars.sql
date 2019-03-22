CREATE FUNCTION dbo.fnAPRemoveSpecialChars(@data NVARCHAR(max)) 
RETURNS NVARCHAR(MAX)
BEGIN

IF @data IS NULL
    RETURN NULL

DECLARE @result NVARCHAR(MAX)
DECLARE @length INT
DECLARE @charounter INT

SET @result = ''
SET @length = LEN(@data)
SET @charounter = 1

WHILE @charounter <= @length BEGIN
	DECLARE @char INT
	SET @char = ASCII(SUBSTRING(@data, @charounter, 1))
	IF	@char BETWEEN 48 AND 57 
		OR @char BETWEEN 65 AND 90 
		OR @char BETWEEN 97 AND 122 
		OR @char IN (32, 44) --46 is the period character, we want to remove the period on this function
		SET @result = @result + CHAR(@char)
	SET @charounter = @charounter + 1
END

IF LEN(@result) = 0
    RETURN NULL
RETURN @result
END