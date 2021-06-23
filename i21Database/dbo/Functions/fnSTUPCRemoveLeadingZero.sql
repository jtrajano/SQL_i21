CREATE FUNCTION [dbo].[fnSTUPCRemoveLeadingZero]
(
  @strUpcCode AS VARCHAR(14)
)

-- To validate check here https://www.gs1.org/services/check-digit-calculator

RETURNS VARCHAR(14)
AS BEGIN
	SET @strUpcCode = SUBSTRING(@strUpcCode, PATINDEX('%[^0]%', @strUpcCode+'.'), LEN(@strUpcCode))
	DECLARE @strResultUPC AS VARCHAR(14)

	IF LEN(@strUpcCode) > 5
	BEGIN
		SET @strResultUPC =  RIGHT('000000' + CAST(@strUpcCode AS VARCHAR(12)), 12)
	END
	ELSE 
		SET @strResultUPC = @strUpcCode

    RETURN @strResultUPC
END