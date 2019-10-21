CREATE FUNCTION [dbo].[fnICSplitStringToTable]
(
	@List VARCHAR(8000),
	@Delimiter VARCHAR(5) = ','
)
RETURNS @RtnValue TABLE(Id INT IDENTITY(1,1), Value VARCHAR(8000))
AS
BEGIN
	SET @List = (REPLACE(@List, '''', ''))

	IF LTRIM(RTRIM(@List)) = 'emptynull'
	BEGIN
		SET @List = ''
	END

	WHILE (CHARINDEX(@Delimiter, @List) > 0)
	BEGIN

		INSERT INTO @RtnValue (Value)
		SELECT Value = LTRIM(RTRIM(SUBSTRING(@List, 1, CHARINDEX(@Delimiter, @List)-1)))  

		SET @List = SUBSTRING(@List, CHARINDEX(@Delimiter, @List) + LEN(@Delimiter), LEN(@List))

	END

	INSERT INTO @RtnValue (Value)
	SELECT Value = LTRIM(RTRIM(@List))

	RETURN
END