CREATE PROCEDURE [dbo].[uspSMSortOriginMenus]
AS
BEGIN
	UPDATE tblSMMasterMenu SET intSort = 32, intParentMenuID = 0 WHERE strMenuName = 'PT Customer Inquiry' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 33, intParentMenuID = 0 WHERE strMenuName = 'Ag Customer Inquiry' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 34, intParentMenuID = 0 WHERE strMenuName = 'Grain Customer Inquiry' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 35, intParentMenuID = 0 WHERE strMenuName = 'Print/View Reports' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 36, intParentMenuID = 0 WHERE strMenuName = 'Company Setup' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 37, intParentMenuID = 0 WHERE strMenuName = 'General Ledger' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 38, intParentMenuID = 0 WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 39, intParentMenuID = 0 WHERE strMenuName = 'Accounts Payable' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 40, intParentMenuID = 0 WHERE strMenuName = 'Payroll' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 41, intParentMenuID = 0 WHERE strMenuName = 'Time Entry' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 42, intParentMenuID = 0 WHERE strMenuName = 'Contact Point' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 43, intParentMenuID = 0 WHERE strMenuName = 'Grain Accounting' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 44, intParentMenuID = 0 WHERE strMenuName = 'Ag Accounting' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 45, intParentMenuID = 0 WHERE strMenuName = 'Petrolac' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 46, intParentMenuID = 0 WHERE strMenuName = 'Remote C-Store (xx)' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 47, intParentMenuID = 0 WHERE strMenuName = 'Process C-Store (xx)' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 48, intParentMenuID = 0 WHERE strMenuName = 'Store Accounting' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
	UPDATE tblSMMasterMenu SET intSort = 49, intParentMenuID = 0 WHERE strMenuName = 'Select a C-Store' AND strModuleName = 'Origin' AND (intParentMenuID = 0 OR intParentMenuID IS NULL)
END