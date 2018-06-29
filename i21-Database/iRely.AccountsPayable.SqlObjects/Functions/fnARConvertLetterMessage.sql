CREATE FUNCTION [dbo].[fnARConvertLetterMessage]
(
	@LetterMessage			VARCHAR(MAX)
	,@CustomerId			INT
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
		, @temp_newHTMLMessage NVARCHAR(MAX)

DECLARE @TempPlaceHolderTable TABLE  (
	 intPlaceHolderId	INT
	,strPlaceHolder		VARCHAR(max)
	,intEntityCustomerId	INT
	,strPlaceValue		VARCHAR(max)
);

INSERT INTO @TempPlaceHolderTable
SELECT * FROM @PlaceHolderTable
WHERE intEntityCustomerId = @CustomerId

SET @newHTMLMessage = @LetterMessage

WHILE EXISTS (SELECT NULL FROM @TempPlaceHolderTable)
BEGIN		
	SELECT TOP 1 
		@intPlaceHolderId	= intPlaceHolderId
		, @strPlaceHolder	= strPlaceHolder
		,@strPlaceValue		= strPlaceValue 
	FROM
		@TempPlaceHolderTable

	SET @temp_newHTMLMessage =  (REPLACE(dbo.fnARRemoveWhiteSpace(@newHTMLMessage), dbo.fnARRemoveWhiteSpace(@strPlaceHolder), ISNULL(@strPlaceValue,'')))
	
	IF	@temp_newHTMLMessage IS NOT NULL AND LEN(LTRIM(RTRIM(@temp_newHTMLMessage))) <> 0
			BEGIN
				SET @newHTMLMessage =  @temp_newHTMLMessage	
			END	
 
	DELETE FROM @TempPlaceHolderTable WHERE intPlaceHolderId = @intPlaceHolderId	
END
	 
RETURN CONVERT(varbinary(max), @newHTMLMessage)

END