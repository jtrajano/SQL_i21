CREATE FUNCTION [dbo].[fnEscapeXML]
(
	@strValue nvarchar(Max)
)
RETURNS nvarchar(Max)
AS
BEGIN
        If isnull(@strValue,'')='' Return ''
        Declare @strTemp nvarchar(Max)
        Set @strTemp = @strValue
        Set @strTemp = Replace(@strTemp,'&', '&amp;')
        Set @strTemp = Replace(@strTemp,'>', '&gt;')
        Set @strTemp = Replace(@strTemp,'<', '&lt;')
        Set @strTemp = Replace(@strTemp,'''', '&apos;')
        Set @strTemp = Replace(@strTemp,'"', '&quot;')
        Return @strTemp
END
