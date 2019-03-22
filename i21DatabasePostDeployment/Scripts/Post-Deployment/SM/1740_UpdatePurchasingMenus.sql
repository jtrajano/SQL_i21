GO
	UPDATE rm SET ysnAvailable = (SELECT COUNT(*) FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1)
	FROM tblSMUserRoleMenu rm
	INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID
	WHERE strMenuName IN ('Import', 'Import Vouchers from Origin') AND strModuleName = 'Accounts Payable' AND ysnAvailable IS NULL
GO