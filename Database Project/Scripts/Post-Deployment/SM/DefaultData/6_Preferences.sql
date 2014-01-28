GO
	PRINT N'BEGIN INSERT DEFAULT PREFERENCES'
GO
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMPreferences WHERE intUserID = 0 AND strPreference = N'isLegacyIntegration')
	BEGIN
		insert tblSMPreferences	(intUserID, strPreference ,strDescription ,strValue ,intSort ,intConcurrencyId) select 0, 'isLegacyIntegration', 'isLegacyIntegration', 'true', 0, 0
	END
GO
	PRINT N'END INSERT DEFAULT PREFERENCES'
GO