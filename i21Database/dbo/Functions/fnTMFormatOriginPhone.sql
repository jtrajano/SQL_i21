CREATE FUNCTION [dbo].[fnTMFormatOriginPhone]
(
	@Value		NVARCHAR(200)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE @RetValue NVARCHAR(400)

	SET @Value = RTRIM(@Value)

	IF LEN(@Value) > 3
	BEGIN
		SET @RetValue = SUBSTRING(@Value, 1, 3) + '-'

		IF LEN(@Value) > 6
		BEGIN
			SET @RetValue = @RetValue + SUBSTRING(@Value, 4, 3) + '-' + SUBSTRING(@Value, 7, LEN(@Value) - 6)
		END
		ELSE
		BEGIN
			SET @RetValue = @RetValue + SUBSTRING(@Value, 4, LEN(@Value) - 3)
		END
	END
	ELSE
	BEGIN
		SET @RetValue = @Value
	END
	
	
	RETURN @RetValue
END

GO 