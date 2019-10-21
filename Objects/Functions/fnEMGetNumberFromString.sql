CREATE FUNCTION [dbo].[fnEMGetNumberFromString]
(
	@AlphaNumeric NVARCHAR(100)
)
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @Alpha INT
	SET @Alpha = PATINDEX('%[^0-9]%', @AlphaNumeric)

	WHILE @Alpha > 0
	BEGIN
		SET @AlphaNumeric = STUFF(@AlphaNumeric, @Alpha, 1, '' )
		SET @Alpha = PATINDEX('%[^0-9]%', @AlphaNumeric )
	END

	RETURN ISNULL(@AlphaNumeric,0)
END