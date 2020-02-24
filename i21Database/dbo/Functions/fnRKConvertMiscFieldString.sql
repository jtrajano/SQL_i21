CREATE FUNCTION [dbo].[fnRKConvertMiscFieldString]
(
	@MiscFields RKMiscField READONLY
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @FinalString NVARCHAR(MAX) = ''
		, @FieldName NVARCHAR(100)
		, @Value NVARCHAR(100)
		, @Max INT
		, @ctr INT = 1

	SELECT @Max = MAX(intRowId) FROM @MiscFields

	WHILE (@Max >= @ctr)
	BEGIN
		SELECT TOP 1 @FieldName = strFieldName
			, @Value = strValue
		FROM @MiscFields WHERE intRowId = @ctr

		IF (ISNULL(@FieldName, '') != '' AND ISNULL(@Value, '') != '')
		BEGIN
			SET @FinalString += ' { ' + @FieldName + ' = "' + @Value + '" } '
		END

		SET @ctr += 1
	END

	RETURN @FinalString
END
