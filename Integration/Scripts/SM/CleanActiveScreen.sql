GO
	PRINT 'Clearing Active Screens'
	IF EXISTS(SELECT TOP 1 1 FROM tblSMActiveScreen)
		DELETE FROM tblSMActiveScreen
GO