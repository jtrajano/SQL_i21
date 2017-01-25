CREATE FUNCTION [dbo].[fnIPConvertSAPUOMToi21]
(
	@strSAPUOM NVARCHAR(100)
)
RETURNS NVARCHAR(100)
AS
BEGIN
	Declare @strValue NVARCHAR(100)

	Select TOP 1 @strValue=stri21UOM From tblIPSAPUOM Where strSAPUOM=@strSAPUOM

	Return ISNULL(@strValue,'')
END
