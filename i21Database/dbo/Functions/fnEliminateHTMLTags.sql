CREATE FUNCTION [dbo].[fnEliminateHTMLTags]
(
	@strHTMLText		NVARCHAR(MAX),
	@ysnPrintAsHTML		BIT = 0
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	IF @ysnPrintAsHTML = 1
		RETURN '<html>' + @strHTMLText + '</html>'
	
    DECLARE @intStart	INT
		  , @intEnd		INT
		  , @intLength	INT
	--added the </p> replace, what it does is that p is a single line and the redactor treat this one as a one liner then the succedding should be in a new line?
    --MDG    
    set @strHTMLText = REPLACE(@strHTMLText, '</p>',  CHAR(13) + CHAR(10))
    SET @intStart = CHARINDEX('<', @strHTMLText)
    SET @intEnd = CHARINDEX('>', @strHTMLText, CHARINDEX('<', @strHTMLText))
    SET @intLength = (@intEnd - @intStart) + 1
    WHILE @intStart > 0 AND @intEnd > 0 AND @intLength > 0
    BEGIN
        SET @strHTMLText = STUFF(@strHTMLText, @intStart, @intLength,'')
        SET @intStart = CHARINDEX('<', @strHTMLText)
        SET @intEnd = CHARINDEX('>', @strHTMLText, CHARINDEX('<', @strHTMLText))
        SET @intLength = (@intEnd - @intStart) + 1
    END
    
    set @strHTMLText = REPLACE(@strHTMLText, '&nbsp;', '')

    RETURN LTRIM(RTRIM(@strHTMLText))
END