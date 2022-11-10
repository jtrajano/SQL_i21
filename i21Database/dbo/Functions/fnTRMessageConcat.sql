CREATE FUNCTION [dbo].[fnTRMessageConcat]
(
	@strOriginalMsg NVARCHAR(MAX) 
	,@strAddMsg NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @strConcatMsg NVARCHAR(MAX)  = NULL

	IF(@strOriginalMsg IS NULL OR @strOriginalMsg = '')
	BEGIN
		SET @strConcatMsg = @strAddMsg COLLATE Latin1_General_CI_AS
	END
	ELSE
	BEGIN
		SET @strConcatMsg = @strOriginalMsg + ', ' + @strAddMsg COLLATE Latin1_General_CI_AS
	END

	RETURN @strConcatMsg COLLATE Latin1_General_CI_AS
END