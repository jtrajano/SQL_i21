CREATE FUNCTION [dbo].[fnICValidateCheckDigitIfExists] (
	@UPC NVARCHAR(50)
)
RETURNS BIT 
AS
BEGIN 
	DECLARE @intCheckDigitValid AS BIT 
	DECLARE @intLastDigit AS INT 
	DECLARE @intCheckDigit AS INT 
	DECLARE @strUPCWithoutCheckDigit AS VARCHAR(50) 

	IF (LEN(@UPC) = 10 AND ISNUMERIC(@UPC) = 1)
	BEGIN 
		SET @intCheckDigitValid = 0
	END 

    IF (LEN(@UPC) >= 11 AND ISNUMERIC(@UPC) = 1)
    BEGIN
		SET @intLastDigit = RIGHT(@UPC, 1)
		SET @strUPCWithoutCheckDigit = LEFT(@UPC, LEN(@UPC) - 1) 
		SET @intCheckDigit = dbo.fnICCalculateCheckDigit(@strUPCWithoutCheckDigit)

		IF @intLastDigit = @intCheckDigit
		BEGIN 
			SET @intCheckDigitValid = 1
		END
		ELSE
			SET @intCheckDigitValid = 0

    END

	RETURN @intCheckDigitValid
END