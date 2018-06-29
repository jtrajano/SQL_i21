CREATE FUNCTION [dbo].[fnCommaSeparatedValueToTable]
(
	@param nvarchar(max)
)
RETURNS @returntable TABLE
(
	value nvarchar(max)
)
AS
BEGIN
	DECLARE @Position INT

	WHILE Len(Ltrim(Rtrim(@param))) > 0
	BEGIN
		SET @Position = CharIndex(',', @param)

		IF @Position = 0
		BEGIN
			INSERT @returntable (value)
			VALUES (@param)

			RETURN
		END

		INSERT @returntable (value)
		VALUES (Ltrim(Rtrim(Left(@param, @Position - 1))))

		SET @param = Right(@param, Len(@param) - @Position)
	END

	RETURN
END
