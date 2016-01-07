﻿CREATE PROCEDURE [dbo].[uspSMSortOriginMenus]
AS
BEGIN
	UPDATE tblSMMasterMenu SET intSort = 31 WHERE strMenuName = 'PT Customer Inquiry' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 32 WHERE strMenuName = 'Ag Customer Inquiry' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 33 WHERE strMenuName = 'Grain Customer Inquiry' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 34 WHERE strMenuName = 'Print/View Reports' AND strModuleName = 'Origin' AND intParentMenuID = 0

	UPDATE tblSMMasterMenu SET intSort = 35 WHERE strMenuName = 'Company Setup' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 36 WHERE strMenuName = 'General Ledger' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 37 WHERE strMenuName = 'Fixed Assets' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 38 WHERE strMenuName = 'Accounts Payable' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 39 WHERE strMenuName = 'Payroll' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 40 WHERE strMenuName = 'Time Entry' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 41 WHERE strMenuName = 'Contact Point' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 42 WHERE strMenuName = 'Grain Accounting' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 43 WHERE strMenuName = 'Ag Accounting' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 44 WHERE strMenuName = 'Petrolac' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 45 WHERE strMenuName = 'Remote C-Store (xx)' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 46 WHERE strMenuName = 'Process C-Store (xx)' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 47 WHERE strMenuName = 'Store Accounting' AND strModuleName = 'Origin' AND intParentMenuID = 0
	UPDATE tblSMMasterMenu SET intSort = 48 WHERE strMenuName = 'Select a C-Store' AND strModuleName = 'Origin' AND intParentMenuID = 0
END