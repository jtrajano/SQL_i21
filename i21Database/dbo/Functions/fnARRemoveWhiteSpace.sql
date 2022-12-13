﻿CREATE FUNCTION dbo.fnARRemoveWhiteSpace(@data NVARCHAR(max)) 
RETURNS NVARCHAR(MAX)
BEGIN
	IF @data IS NULL OR @data LIKE '%<img src%'
		RETURN NULL

	DECLARE @result		NVARCHAR(MAX)
		, @length		INT
		, @charounter	INT

	SET @result = ''
	SET @length = LEN(@data)
	SET @charounter = 1

	WHILE @charounter <= @length 
	BEGIN
		DECLARE @char INT
		SET @char = ASCII(SUBSTRING(@data, @charounter, 1))
		IF @char BETWEEN 33 AND 127 
			SET @result = @result + CHAR(@char)
			SET @charounter = @charounter + 1
	END

	IF LEN(@result) = 0
		RETURN NULL
	RETURN @result
END