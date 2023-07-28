--liquibase formatted sql

-- changeset Von:fnARFormatMessage.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARFormatMessage]
(
	 @message	VARCHAR(MAX)
    ,@params	VARCHAR(MAX)
    ,@separator	CHAR(1) = ','
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
DECLARE @p VARCHAR(MAX)
DECLARE @paramlen INT

SET @params = @params + @separator
SET @paramlen = LEN(@params)

WHILE not @params = ''
BEGIN
    SET @p = LEFT(@params + @separator, CHARINDEX(@separator, @params) - 1)
    SET @message = STUFF(@message, CHARINDEX('%s', @message), 2, @p)
    SET @params = SUBSTRING(@params, LEN(@p)+2, @paramlen)
END

RETURN @message

END



