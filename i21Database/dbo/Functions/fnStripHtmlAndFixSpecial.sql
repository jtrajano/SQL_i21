-- http://stackoverflow.com/questions/457701/best-way-to-strip-html-tags-from-a-string-in-sql-server
CREATE FUNCTION [dbo].[fnStripHtmlAndFixSpecial] (@HTMLText VARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
    DECLARE @Start  int
	DECLARE @End    int
	DECLARE @Length int

	set @HTMLText = replace(@HTMLText, '<br>',CHAR(13) + CHAR(10))
	set @HTMLText = replace(@HTMLText, '<br/>',CHAR(13) + CHAR(10))
	set @HTMLText = replace(@HTMLText, '<br />',CHAR(13) + CHAR(10))
	set @HTMLText = replace(@HTMLText, '<li>','- ')
	set @HTMLText = replace(@HTMLText, '</li>',CHAR(13) + CHAR(10))

	set @HTMLText = replace(@HTMLText, '&rsquo;' collate Latin1_General_CS_AS, ''''  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&quot;' collate Latin1_General_CS_AS, '"'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&amp;' collate Latin1_General_CS_AS, '&'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&euro;' collate Latin1_General_CS_AS, '€'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&lt;' collate Latin1_General_CS_AS, '<'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&gt;' collate Latin1_General_CS_AS, '>'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&oelig;' collate Latin1_General_CS_AS, 'oe'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&nbsp;' collate Latin1_General_CS_AS, ' '  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&copy;' collate Latin1_General_CS_AS, '©'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&laquo;' collate Latin1_General_CS_AS, '«'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&reg;' collate Latin1_General_CS_AS, '®'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&plusmn;' collate Latin1_General_CS_AS, '±'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&sup2;' collate Latin1_General_CS_AS, '²'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&sup3;' collate Latin1_General_CS_AS, '³'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&micro;' collate Latin1_General_CS_AS, 'µ'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&middot;' collate Latin1_General_CS_AS, '·'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&ordm;' collate Latin1_General_CS_AS, 'º'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&raquo;' collate Latin1_General_CS_AS, '»'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&frac14;' collate Latin1_General_CS_AS, '¼'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&frac12;' collate Latin1_General_CS_AS, '½'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&frac34;' collate Latin1_General_CS_AS, '¾'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&Aelig' collate Latin1_General_CS_AS, 'Æ'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&Ccedil;' collate Latin1_General_CS_AS, 'Ç'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&Egrave;' collate Latin1_General_CS_AS, 'È'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&Eacute;' collate Latin1_General_CS_AS, 'É'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&Ecirc;' collate Latin1_General_CS_AS, 'Ê'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&Ouml;' collate Latin1_General_CS_AS, 'Ö'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&agrave;' collate Latin1_General_CS_AS, 'à'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&acirc;' collate Latin1_General_CS_AS, 'â'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&auml;' collate Latin1_General_CS_AS, 'ä'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&aelig;' collate Latin1_General_CS_AS, 'æ'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&ccedil;' collate Latin1_General_CS_AS, 'ç'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&egrave;' collate Latin1_General_CS_AS, 'è'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&eacute;' collate Latin1_General_CS_AS, 'é'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&ecirc;' collate Latin1_General_CS_AS, 'ê'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&euml;' collate Latin1_General_CS_AS, 'ë'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&icirc;' collate Latin1_General_CS_AS, 'î'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&ocirc;' collate Latin1_General_CS_AS, 'ô'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&ouml;' collate Latin1_General_CS_AS, 'ö'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&divide;' collate Latin1_General_CS_AS, '÷'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&oslash;' collate Latin1_General_CS_AS, 'ø'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&ugrave;' collate Latin1_General_CS_AS, 'ù'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&uacute;' collate Latin1_General_CS_AS, 'ú'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&ucirc;' collate Latin1_General_CS_AS, 'û'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&uuml;' collate Latin1_General_CS_AS, 'ü'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&quot;' collate Latin1_General_CS_AS, '"'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&amp;' collate Latin1_General_CS_AS, '&'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&lsaquo;' collate Latin1_General_CS_AS, '<'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&rsaquo;' collate Latin1_General_CS_AS, '>'  collate Latin1_General_CS_AS)
	set @HTMLText = replace(@HTMLText, '&#39;' collate Latin1_General_CS_AS, ''''  collate Latin1_General_CS_AS)


	-- Remove anything between <STYLE> tags
	SET @Start = CHARINDEX('<STYLE', @HTMLText)
	SET @End = CHARINDEX('</STYLE>', @HTMLText, CHARINDEX('<', @HTMLText)) + 7
	SET @Length = (@End - @Start) + 1

	WHILE (@Start > 0 AND @End > 0 AND @Length > 0) BEGIN
	SET @HTMLText = STUFF(@HTMLText, @Start, @Length, '')
	SET @Start = CHARINDEX('<STYLE', @HTMLText)
	SET @End = CHARINDEX('</STYLE>', @HTMLText, CHARINDEX('</STYLE>', @HTMLText)) + 7
	SET @Length = (@End - @Start) + 1
	END

	-- Remove anything between <whatever> tags
	SET @Start = CHARINDEX('<', @HTMLText)
	SET @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
	SET @Length = (@End - @Start) + 1

	WHILE (@Start > 0 AND @End > 0 AND @Length > 0) BEGIN
	SET @HTMLText = STUFF(@HTMLText, @Start, @Length, '')
	SET @Start = CHARINDEX('<', @HTMLText)
	SET @End = CHARINDEX('>', @HTMLText, CHARINDEX('<', @HTMLText))
	SET @Length = (@End - @Start) + 1
	END

	RETURN LTRIM(RTRIM(@HTMLText))
END
GO