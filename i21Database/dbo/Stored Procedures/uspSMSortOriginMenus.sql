CREATE PROCEDURE [dbo].[uspSMSortOriginMenus]
AS
BEGIN
	UPDATE tblSMMasterMenu SET intSort = 23 WHERE strMenuName = 'PT Customer Inquiry' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 24 WHERE strMenuName = 'Ag Customer Inquiry' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 25 WHERE strMenuName = 'Grain Customer Inquiry' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 26 WHERE strMenuName = 'Print/View Reports' AND strModuleName = 'Origin' AND intParentMenuID = 0

	UPDATE tblSMMasterMenu SET intSort = 27 WHERE strMenuName = 'Company Setup' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 28 WHERE strMenuName = 'General Ledger' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 29 WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 30 WHERE strMenuName = 'Accounts Payable' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 31 WHERE strMenuName = 'Payroll' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 32 WHERE strMenuName = 'Time Entry' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 33 WHERE strMenuName = 'Contact Point' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 34 WHERE strMenuName = 'Grain Accounting' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 35 WHERE strMenuName = 'Ag Accounting' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 36 WHERE strMenuName = 'Petrolac' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 37 WHERE strMenuName = 'Remote C-Store (xx)' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 38 WHERE strMenuName = 'Process C-Store (xx)' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 39 WHERE strMenuName = 'Store Accounting' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 40 WHERE strMenuName = 'Select a C-Store' AND strModuleName = 'Origin' AND intParentMenuID = 0
END