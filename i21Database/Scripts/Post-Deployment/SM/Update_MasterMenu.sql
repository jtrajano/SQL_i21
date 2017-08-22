-- Added on 17.3 but this file can be deleted on 17.4
GO
IF EXISTS (SELECT TOP 1 1 FROM tblGLCompanyPreference WHERE ysnDeliverySheet = 1)
    EXEC uspSMSetMenuAvailability 'Delivery Sheets', 'Ticket Management', 1 
ELSE
	EXEC uspSMSetMenuAvailability 'Delivery Sheets', 'Ticket Management', 0
GO