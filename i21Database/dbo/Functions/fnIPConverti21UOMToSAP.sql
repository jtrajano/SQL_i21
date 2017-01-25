CREATE FUNCTION [dbo].[fnIPConverti21UOMToSAP]
(
	@stri21UOM NVARCHAR(100)
)
RETURNS NVARCHAR(100)
AS
BEGIN
	Declare @strValue NVARCHAR(100)

	Select TOP 1 @strValue=strSAPUOM From tblIPSAPUOM Where stri21UOM=@stri21UOM
	
	If ISNULL(@strValue,'')='' Set @strValue=@stri21UOM

	Return ISNULL(@strValue,'')
END
