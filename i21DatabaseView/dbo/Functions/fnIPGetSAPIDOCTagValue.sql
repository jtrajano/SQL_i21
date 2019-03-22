CREATE FUNCTION [dbo].[fnIPGetSAPIDOCTagValue]
(
	@strMessageType NVARCHAR(100),
	@strTagName NVARCHAR(100)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	Declare @strValue NVARCHAR(100)

	Select TOP 1 @strValue=strValue From tblIPSAPIDOCTag Where strMessageType=@strMessageType AND strTag=@strTagName

	Return ISNULL(@strValue,'')
END
