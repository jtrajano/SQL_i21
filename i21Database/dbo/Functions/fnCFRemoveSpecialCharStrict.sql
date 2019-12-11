
CREATE FUNCTION [dbo].[fnCFRemoveSpecialCharStrict](@value nvarchar(max),@replacement nvarchar(max))
RETURNS nvarchar(max) 
AS 
BEGIN
	
    DECLARE @returnData	NVARCHAR(MAX) = ''
	DECLARE @i INT = 0
	DECLARE @chr nvarchar(1) = ''

	SET @value = ISNULL(@value,'')

	WHILE @i < len(@value)
	BEGIN
		SET @i = @i + 1
		SET @chr = SUBSTRING(@value, @i, 1)
		IF((@chr >= '0' AND @chr <= '9') OR (@chr >= 'A' AND @chr <= 'Z') OR (@chr >= 'a' AND @chr <= 'z') OR (@chr >= '.' AND @chr <= '_'))
		BEGIN
			SET @returnData = @returnData + @chr
		END
		ELSE
		BEGIN
			SET @returnData = @returnData + @replacement
		END
	END

	RETURN @returnData
END;