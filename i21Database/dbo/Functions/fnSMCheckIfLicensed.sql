CREATE FUNCTION [dbo].[fnSMCheckIfLicensed]
(
	@strModuleName NVARCHAR(100)
)
RETURNS BIT
AS
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblSMLicenseModule WHERE strModuleName = @strModuleName)
	BEGIN
		RETURN 1
	END

	RETURN 0
END