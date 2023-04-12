CREATE FUNCTION [dbo].[fnRemoveLeadingZero]
(
	@strString NVARCHAR(20)
)
RETURNS NVARCHAR(20)

AS

BEGIN

	IF (ISNULL(@strString, '') <> '')
	BEGIN
		SET @strString = SUBSTRING(@strString, PATINDEX('%[^0]%', @strString), LEN(@strString))
	END
	ELSE
	BEGIN
		SET @strString = ''
	END

	RETURN @strString
END