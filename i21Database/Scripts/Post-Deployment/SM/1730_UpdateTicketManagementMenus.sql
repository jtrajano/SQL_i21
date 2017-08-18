GO
	UPDATE rm SET ysnAvailable = 0
	FROM tblSMUserRoleMenu rm
	INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID
	WHERE strMenuName = 'Delivery Sheets' AND ysnAvailable IS NULL
GO