CREATE FUNCTION [dbo].[fnEMPhoneFormat]
(
	@Value		NVARCHAR(200),
	@Format		NVARCHAR(200)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @RetValue NVARCHAR(400)
	SET @Format = LOWER(@Format)

	IF @Format = 'dash' 
	BEGIN
		SET @RetValue = @Value + '-'
	END
	ELSE IF @Format = 'space' 
	BEGIN
		SET @RetValue = @Value + ' '
	END
	ELSE IF @Format = 'parentheses' 
	BEGIN
		SET @RetValue = '(' + @Value + ')'
	END
	ELSE IF @Format = 'parentheses + space' 
	BEGIN
		SET @RetValue = '(' + @Value + ') '
	END
	ELSE IF @Format = 'period' 
	BEGIN
		SET @RetValue = @Value + '.'
	END
	ELSE IF @Format = '3 + dash' and LEN(@Value) > 3
	BEGIN
		SET @RetValue = SUBSTRING(@Value, 1, 3) + '-' + SUBSTRING(@Value, 4, LEN(@Value)) 
	END
	ELSE IF @Format = '4 + dash' and LEN(@Value) > 4
	BEGIN
		SET @RetValue = SUBSTRING(@Value, 1, 4) + '-' + SUBSTRING(@Value, 5, LEN(@Value)) 
	END
	ELSE IF @Format = '3 + space' and LEN(@Value) > 3
	BEGIN
		SET @RetValue = SUBSTRING(@Value, 1, 3) + ' ' + SUBSTRING(@Value, 4, LEN(@Value)) 
	END
	ELSE IF @Format = '4 + space' and LEN(@Value) > 4
	BEGIN
		SET @RetValue = SUBSTRING(@Value, 1, 4) + ' ' + SUBSTRING(@Value, 5, LEN(@Value)) 
	END
	ELSE IF @Format = '3 + period' and LEN(@Value) > 3
	BEGIN
		SET @RetValue = SUBSTRING(@Value, 1, 3) + '.' + SUBSTRING(@Value, 4, LEN(@Value)) 
	END
	ELSE IF @Format = '4 + period' and LEN(@Value) > 4
	BEGIN
		SET @RetValue = SUBSTRING(@Value, 1, 4) + '.' + SUBSTRING(@Value, 5, LEN(@Value)) 
	END
	ELSE  
	BEGIN
		SET @RetValue = @Value 
	END
	
	
	RETURN @RetValue
END

GO 