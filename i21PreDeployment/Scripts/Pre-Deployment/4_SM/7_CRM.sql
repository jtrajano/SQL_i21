IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.COLUMNS WHERE UPPER(TABLE_NAME) = 'TBLSMMASTERMENU')
BEGIN

EXEC
('
	IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strMenuName = ''CRM'' AND strModuleName = ''Help Desk'' AND intParentMenuID = 0)
	BEGIN
		UPDATE tblSMMasterMenu SET strModuleName = ''CRM'' WHERE strMenuName = ''CRM'' AND strModuleName = ''Help Desk'' AND intParentMenuID = 0

		DECLARE @CRMParentMenuId INT
		SELECT @CRMParentMenuId = intMenuID FROM tblSMMasterMenu WHERE strMenuName = ''CRM'' AND strModuleName = ''CRM'' AND intParentMenuID = 0

		UPDATE tblSMMasterMenu SET strModuleName = ''CRM'' WHERE intParentMenuID = @CRMParentMenuId
	END
')

END