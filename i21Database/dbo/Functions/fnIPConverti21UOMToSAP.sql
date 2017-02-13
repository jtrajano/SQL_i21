CREATE FUNCTION [dbo].[fnIPConverti21UOMToSAP]
(
	@stri21UOM NVARCHAR(100)
)
RETURNS NVARCHAR(100)
AS
BEGIN
	Declare @strValue NVARCHAR(100)
	Declare @strSymbol NVARCHAR(100)

	Select TOP 1 @strSymbol=strSymbol From tblICUnitMeasure Where strUnitMeasure=@stri21UOM

	If ISNULL(@strSymbol,'')='' Set @strSymbol=@stri21UOM

	Select TOP 1 @strValue=strSAPUOM From tblIPSAPUOM Where stri21UOM=@strSymbol
	
	If ISNULL(@strValue,'')='' Set @strValue=@stri21UOM

	Return ISNULL(@strValue,'')
END
