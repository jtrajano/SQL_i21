CREATE FUNCTION [dbo].[fnICValidateCheckDigit] (
	@UPC VARCHAR(50)
)
RETURNS VARCHAR(1)
AS
BEGIN 
	DECLARE @intCheckDigit AS VARCHAR(1)   

	SET @intCheckDigit = CASE WHEN LEN(@UPC) = 10 OR (LEN(@UPC) = 11 AND LEFT(@UPC, 1) = '0')
							THEN dbo.fnICCalculateCheckDigit(@UPC)
						WHEN LEN(@UPC) = 11 AND LEFT(@UPC, 1) != '0'
							THEN dbo.fnICCalculateCheckDigit(@UPC) -- Successfully verified that the last digit is a check digit
						WHEN LEN(@UPC) >= 12 AND dbo.fnICValidateCheckDigitIfExists(@UPC) = 1
							THEN RIGHT(@UPC, 1) -- Successfully verified that the last digit is a check digit
						WHEN LEN(@UPC) >= 12 AND dbo.fnICValidateCheckDigitIfExists(@UPC) = 0
							THEN NULL -- Last digit is not the check digit DEFAULT to NULL
						ELSE NULL
						END

	RETURN @intCheckDigit
END