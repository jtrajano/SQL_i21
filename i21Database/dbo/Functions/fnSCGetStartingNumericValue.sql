CREATE FUNCTION [dbo].[fnSCGetStartingNumericValue]
(
	 @strAlphaNumeric VARCHAR(256)
)
RETURNS NVARCHAR(256)
AS
BEGIN

	DECLARE @intAlpha INT
	SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)	

	if substring(@strAlphaNumeric, 0, @intAlpha) = '' 
		return @strAlphaNumeric

	return substring(@strAlphaNumeric, 0, @intAlpha)

END
