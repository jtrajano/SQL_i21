GO
	/* SET KEEP SEARCH SCREEN OPEN */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Keep Search Screen Open - 1810')
	BEGIN
		UPDATE tblSMUserPreference
		SET ysnKeepSearchScreensOpen = 1
		
		PRINT N'Set Keep Search Screen Open - 1810'
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Keep Search Screen Open - 1810', 'Keep Search Screen Open - 1810', GETDATE())
	END
GO