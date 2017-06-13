CREATE PROCEDURE [dbo].[uspSMSetMenuAvailability]
@menus NVARCHAR(MAX),
@module NVARCHAR(50),
@enable BIT
AS
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName IN (SELECT Item COLLATE Latin1_General_CI_AS FROM dbo.fnSplitString(@menus, ',')) AND strModuleName = @module)
	BEGIN
		UPDATE tblSMUserRoleMenu SET ysnVisible = @enable WHERE intMenuId IN (SELECT intMenuID FROM tblSMMasterMenu WHERE strMenuName IN (SELECT Item COLLATE Latin1_General_CI_AS FROM dbo.fnSplitString(@menus, ',')) AND strModuleName = @module)
	END
END
