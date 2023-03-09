CREATE FUNCTION [dbo].[fnICValidateUPCCode] (
	@UPC VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN 
	DECLARE @strUPCCode AS VARCHAR(50)   

	SET @strUPCCode = CASE WHEN LEN(@UPC) = 10 OR (LEN(@UPC) IN (11, 13) AND dbo.fnICValidateCheckDigitIfExists('0' + @UPC) = 0) 
						THEN @UPC + CAST(dbo.fnICCalculateCheckDigit(@UPC) AS VARCHAR(1))
					  WHEN LEN(@UPC) = 12 AND dbo.fnICValidateCheckDigitIfExists(@UPC) = 0
						THEN LEFT(@UPC, 11) + CAST(dbo.fnICCalculateCheckDigit(LEFT(@UPC, 11)) AS VARCHAR(1))
					  WHEN LEN(@UPC) = 14 AND dbo.fnICValidateCheckDigitIfExists(@UPC) = 0
						THEN LEFT(@UPC, 13) + CAST(dbo.fnICCalculateCheckDigit(LEFT(@UPC, 13)) AS VARCHAR(1))
					  ELSE @UPC
					END

	RETURN @strUPCCode
END