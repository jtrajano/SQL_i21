CREATE FUNCTION [dbo].[fnIPGetSAPIDOCHeader]
(
	@strMessageType NVARCHAR(100)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	Declare @strXml NVARCHAR(MAX)

	Select @strXml=COALESCE(@strXml, '') +  '<' + strTag + '>' + ISNULL(strValue,'') + '</' + strTag + '>'
	From tblIPSAPIDOCTag Where strMessageType=@strMessageType AND strTagType='EDI_DC40'

	RETURN ISNULL(@strXml,'')
END
