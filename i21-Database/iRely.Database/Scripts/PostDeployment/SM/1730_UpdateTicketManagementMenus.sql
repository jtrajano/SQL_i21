GO
	UPDATE rm SET ysnAvailable = 0
	FROM tblSMUserRoleMenu rm
	INNER JOIN tblSMMasterMenu mm ON rm.intMenuId = mm.intMenuID
	WHERE strMenuName = 'Delivery Sheets' AND ysnAvailable IS NULL

	IF EXISTS (SELECT TOP 1 1 FROM tblGRCompanyPreference WHERE ysnDeliverySheet = 1)
    	EXEC uspSMSetMenuAvailability 'Delivery Sheets', 'Ticket Management', 1 
	ELSE
    	EXEC uspSMSetMenuAvailability 'Delivery Sheets', 'Ticket Management', 0

GO