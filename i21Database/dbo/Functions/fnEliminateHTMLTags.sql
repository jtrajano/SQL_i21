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
    RETURN LTRIM(RTRIM(@strHTMLText))
END