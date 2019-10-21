CREATE FUNCTION [dbo].[fnIPConvertSAPUOMToi21]
(
	@strSAPUOM NVARCHAR(100)
)
RETURNS NVARCHAR(100)
AS
BEGIN
	Declare @strValue NVARCHAR(100)
	Declare @strSymbol NVARCHAR(100)

	Select TOP 1 @strSymbol=stri21UOM From tblIPSAPUOM Where strSAPUOM=@strSAPUOM

	Select TOP 1 @strValue=strUnitMeasure From tblICUnitMeasure Where strSymbol=@strSymbol

	Return ISNULL(@strValue,'')
END
