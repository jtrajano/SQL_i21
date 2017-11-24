/*
	Formats a number (in varchar data type) by adding the comma separators and 
	making sure it has 2 decimal place values. See the following sample input and result. 
	
	INPUT				RESULT
	------------------	-----------------------
	1049.505965000		1,049.505965
	1049.505965			1,049.505965
	049.505965			49.505965
	49.505965			49.505965
	9.505965			9.505965
	0.505965			0.505965
	0.50				0.50
	0.5					0.50
	0.0					0.00
	NULL				NULL
	0					0.00
	10					10.00
	100					100.00
	1000				1,000.00

*/
CREATE FUNCTION fnFormatNumber(@NumStr VARCHAR(50)) 
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @Result VARCHAR(50)
	DECLARE @i INT
	DECLARE @run INT	

	SELECT @i = CHARINDEX('.',@NumStr)
	IF @i = 0 
	BEGIN
		SET @i = LEN(@NumStr)
		SET @Result = ''
	END
	ELSE
	BEGIN   
		SET @Result = SUBSTRING(@NumStr, @i , 50)
		SET @i = @i - 1
	END 

	SET @Result = dbo.fnRTrim(@Result, '0') 
	SET @Result = 
			CASE	WHEN ISNULL(@Result, '') = '' AND @NumStr IS NOT NULL THEN '.00'
					WHEN LEN(@Result) = 1 AND @Result = '.' THEN '.00' 
					WHEN LEN(@Result) = 2 THEN @Result + '0'
					ELSE @Result
			END 

	SET @run = 0
	WHILE @i > 0
	BEGIN
		IF @run = 3
		BEGIN
			SET @Result = ',' + @Result
			SET @run=0
		END
		SET @Result = SUBSTRING(@NumStr, @i, 1) + @Result  
		SET @i = @i - 1
		SET @run = @run + 1     
	END

	RETURN @Result
END