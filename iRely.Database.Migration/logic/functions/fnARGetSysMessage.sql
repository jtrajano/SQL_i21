--liquibase formatted sql

-- changeset Von:fnARGetSysMessage.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARGetSysMessage]
(
	 @messageId	INT
    ,@params	VARCHAR(MAX)
    ,@separator	CHAR(1) = ','
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
DECLARE @Message NVARCHAR(MAX)
		,@ErrorMessage NVARCHAR(MAX)
SET @Message = ISNULL((SELECT [text] FROM sys.messages WHERE [message_id] = @messageId),'')

SET @ErrorMessage = [dbo].[fnARFormatMessage](@Message, @params, DEFAULT)

RETURN @ErrorMessage

END



