CREATE PROCEDURE [dbo].[uspSMConsolidateMenu]
@enable BIT
AS
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = 'Consolidate' AND strModuleName = 'GENERAL LEDGER')
	BEGIN
		UPDATE tblSMUserRoleMenu SET ysnVisible = @enable WHERE intMenuId = (SELECT intMenuID FROM tblSMMasterMenu WHERE strMenuName = 'Consolidate' AND strModuleName = 'GENERAL LEDGER')
	END
END