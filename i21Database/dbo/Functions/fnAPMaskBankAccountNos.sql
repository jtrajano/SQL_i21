CREATE FUNCTION [dbo].[fnAPMaskBankAccountNos](@encryptedText AS VARCHAR(MAX))
RETURNS VARCHAR(max)
WITH SCHEMABINDING
AS
BEGIN

DECLARE @decryptedText AS VARCHAR(MAX)	

	SELECT @decryptedText = REPLICATE('*', DATALENGTH(@encryptedText) - 4) + RIGHT(@encryptedText, 4)

	RETURN @decryptedText
END