CREATE PROCEDURE [dbo].[uspSTCSSetDefaultDepartmentSetup]
	@intStoreId		INT,
	@strRegisterClassOut VARCHAR(250) OUTPUT
AS
BEGIN
	DECLARE @intRegisterId INT = (SELECT intRegisterId FROM tblSTStore WHERE intStoreId = @intStoreId)
	DECLARE @strRegisterClass VARCHAR(250) = (SELECT strRegisterClass FROM tblSTRegister WHERE intRegisterId = @intRegisterId)

	IF @strRegisterClass = 'PASSPORT'
	BEGIN
		UPDATE tblSTStore SET strDepartmentOrCategory='D', strCategoriesOrSubcategories='C' WHERE intStoreId=1
	END

	SET @strRegisterClassOut = @strRegisterClass;
END