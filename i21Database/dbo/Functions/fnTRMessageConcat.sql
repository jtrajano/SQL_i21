CREATE FUNCTION [dbo].[fnTRMessageConcat]
(
	@strOriginalMsg NVARCHAR(MAX)
	,@strAddMsg NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @strConcatMsg NVARCHAR(MAX) = NULL

	IF(@strOriginalMsg IS NULL OR @strOriginalMsg = '')
	BEGIN
		SET @strConcatMsg = @strAddMsg
	END
	ELSE
	BEGIN
		SET @strConcatMsg = @strOriginalMsg + ', ' + @strAddMsg
	END

	RETURN @strConcatMsg
END