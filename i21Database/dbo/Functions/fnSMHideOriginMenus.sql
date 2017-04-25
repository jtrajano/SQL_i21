CREATE FUNCTION [dbo].[fnSMHideOriginMenus] (@menu NVARCHAR(50), @visible BIT)
RETURNS BIT
AS
BEGIN
	DECLARE @ysnIntegrated BIT
	
	SELECT TOP 1 @ysnIntegrated = ysnLegacyIntegration FROM tblSMCompanyPreference



	IF @ysnIntegrated = 0
	BEGIN
		IF @menu = 'Import GL from Subledger'
			SET @visible = 0
	END
	
	RETURN  @visible
END