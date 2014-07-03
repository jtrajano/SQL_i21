GO
IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnGetVendorLastName]') AND type IN (N'FN'))
  DROP FUNCTION [dbo].[fnGetVendorLastName]

GO 
CREATE FUNCTION [dbo].[fnGetVendorLastName]
(
	@name VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN

	DECLARE @return VARCHAR(50)
	DECLARE @position INT

	--Start position where we found the first space
	SET @position = CHARINDEX(' ', @name, 0)

	WHILE @position <= DATALENGTH(@name)
	BEGIN
		IF ASCII(SUBSTRING(@name, @position, 1)) = 32
		BEGIN
			SET @position = @position + 1
		END
		ELSE
		BEGIN
			SELECT @return = LEFT(@name, @position - 1)
			GOTO ExitFunction
		END
	END 

ExitFunction:
RETURN @return;

END
GO