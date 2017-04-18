CREATE FUNCTION [dbo].[fnEliminateHTMLTags]
(
	@HTMLText NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX) AS
BEGIN
    DECLARE @intStart	INT
		  , @intEnd		INT
		  , @intLength	INT
	
    SET @intStart = CHARINDEX('<', @HTMLText)
    SET @intEnd = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
    SET @intLength = (@intEnd - @intStart) + 1
    WHILE @intStart > 0 AND @intEnd > 0 AND @intLength > 0
    BEGIN
        SET @HTMLText = STUFF(@HTMLText, @intStart, @intLength,'')
        SET @intStart = CHARINDEX('<', @HTMLText)
        SET @intEnd = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
        SET @intLength = (@intEnd - @intStart) + 1
    END
    RETURN LTRIM(RTRIM(@HTMLText))
END