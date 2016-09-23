CREATE FUNCTION [dbo].[fnARConvertLetterMessage]
(
	@LetterMessage			VARCHAR(MAX)
	,@PlaceHolderTable		PlaceHolderTable	READONLY
)
RETURNS VARBINARY(MAX)
AS
BEGIN

DECLARE @BinMessageOut		VARBINARY(MAX)
		, @newHTMLMessage	VARCHAR(MAX)
		, @intPlaceHolderId	INT
		, @strPlaceHolder		VARCHAR(MAX)
		, @strPlaceValue		NVARCHAR(MAX)

DECLARE @TempPlaceHolderTable TABLE  (
	 intPlaceHolderId	INT
	,strPlaceHolder		VARCHAR(max)
	,intEntityCustomerId	INT
	,strPlaceValue		VARCHAR(max)
);

INSERT INTO @TempPlaceHolderTable
SELECT * FROM @PlaceHolderTable

SET @newHTMLMessage = @LetterMessage

WHILE EXISTS (SELECT NULL FROM @TempPlaceHolderTable)
BEGIN		
	SELECT TOP 1 
		@intPlaceHolderId	= intPlaceHolderId
		, @strPlaceHolder	= strPlaceHolder
		,@strPlaceValue		= strPlaceValue 
	FROM
		@TempPlaceHolderTable

	SET @newHTMLMessage =  (REPLACE(dbo.fnARRemoveWhiteSpace(@newHTMLMessage), dbo.fnARRemoveWhiteSpace(@strPlaceHolder), @strPlaceValue))	
 
	DELETE FROM @TempPlaceHolderTable WHERE intPlaceHolderId = @intPlaceHolderId	
END
	 
RETURN CONVERT(varbinary(max), @newHTMLMessage)

END