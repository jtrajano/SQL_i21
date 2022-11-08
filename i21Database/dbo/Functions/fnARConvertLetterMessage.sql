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
		, @PlaceHolderStartPosition	INT
		, @PlaceHolderLen	INT
		, @temp_PlaceHolder NVARCHAR(MAX)

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

	IF CHARINDEX(dbo.fnARRemoveWhiteSpace(@strPlaceHolder), dbo.fnARRemoveWhiteSpace(@newHTMLMessage)) <> 0 AND @strPlaceHolder LIKE '%</table>%'
	BEGIN
		SET @PlaceHolderStartPosition = CHARINDEX (SUBSTRING((@strPlaceHolder), 1, 25), (@newHTMLMessage))
		SET @PlaceHolderLen = LEN(@strPlaceHolder)
		SET @temp_PlaceHolder = SUBSTRING(@newHTMLMessage, @PlaceHolderStartPosition, @PlaceHolderLen)
		SET @temp_newHTMLMessage =  (REPLACE(LTRIM(RTRIM(@newHTMLMessage)), LTRIM(RTRIM(@temp_PlaceHolder)), ISNULL(@strPlaceValue,'')))
	END
	ELSE
	BEGIN
		SET @temp_newHTMLMessage =  (REPLACE(LTRIM(RTRIM(@newHTMLMessage)), LTRIM(RTRIM(@strPlaceHolder)), ISNULL(@strPlaceValue,'')))
	END
	
	IF	@temp_newHTMLMessage IS NOT NULL AND LEN(LTRIM(RTRIM(@temp_newHTMLMessage))) <> 0
			BEGIN
				SET @newHTMLMessage =  @temp_newHTMLMessage	
			END	
 
	DELETE FROM @TempPlaceHolderTable WHERE intPlaceHolderId = @intPlaceHolderId	
END
	 
RETURN CONVERT(varbinary(max), @newHTMLMessage)

END