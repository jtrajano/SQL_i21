CREATE FUNCTION [dbo].[fnSTRemoveCheckDigit] (
	@UPC VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN 
	DECLARE @strUPCCode AS VARCHAR(50)   

	SET @strUPCCode = CASE WHEN LEN(@UPC) = 10 OR (LEN(@UPC) = 11 AND LEFT(@UPC, 1) = '0')
						THEN @UPC
					  WHEN LEN(@UPC) = 11 AND LEFT(@UPC, 1) != '0' AND dbo.fnICValidateCheckDigitIfExists(@UPC) = 1
						THEN SUBSTRING(LEFT(@UPC, LEN(@UPC) - 1), LEN(LEFT(@UPC, LEN(@UPC) - 1)) - 10, 11)  -- Successfully verified that the last digit is a check digit
					  WHEN LEN(@UPC) >= 12 AND dbo.fnICValidateCheckDigitIfExists(@UPC) = 1
						THEN SUBSTRING(LEFT(@UPC, LEN(@UPC) - 1), LEN(LEFT(@UPC, LEN(@UPC) - 1)) - 10, 11) -- Successfully verified that the last digit is a check digit
					  WHEN LEN(@UPC) >= 12 AND dbo.fnICValidateCheckDigitIfExists(@UPC) = 0
						THEN @UPC -- Last digit is not the check digit DEFAULT to NULL
					  ELSE @UPC
					END

	RETURN @strUPCCode
END