GO
	UPDATE rm SET ysnAvailable = (SELECT COUNT(*) FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1)
	FROM tblSMUserRoleMenu rm
	INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID
	WHERE strMenuName IN ('Origin Audit Log', 'Import GL from Subledger') AND strModuleName = 'General Ledger' AND ysnAvailable IS NULL

GO